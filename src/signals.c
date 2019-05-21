#define _GNU_SOURCE 1

#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/select.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#ifdef __linux__
#include <sys/prctl.h>
#endif

#define DDB_API_LEVEL 8
#define DDB_WARN_DEPRECATED 1

#include <deadbeef/deadbeef.h>

#if (DB_API_VERSION_MAJOR != 1) || (DB_API_VERSION_MINOR < 8)
#error DB_API_VERSION 1.8 is required
#endif

#define LICENSE_TEXT \
    "Copyright 2016-2018 Hyperblast\n" \
    "\n" \
    "Permission is hereby granted, free of charge, to any person obtaining a copy " \
    "of this software and associated documentation files (the \"Software\"), to deal " \
    "in the Software without restriction, including without limitation the rights " \
    "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell " \
    "copies of the Software, and to permit persons to whom the Software is " \
    "furnished to do so, subject to the following conditions:\n" \
    "\n" \
    "The above copyright notice and this permission notice shall be included in " \
    "all copies or substantial portions of the Software.\n" \
    "\n" \
    "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR " \
    "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, " \
    "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE " \
    "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER " \
    "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, " \
    "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN " \
    "THE SOFTWARE.\n"

#define atomic_or(ptr, val) __sync_fetch_and_or((ptr), (val))
#define log_error(...) fprintf(stderr, "signals: " __VA_ARGS__)

enum
{
    GOT_STOP = 1,
};

struct handler_entry
{
    int signum;
    int is_set;
    struct sigaction old_action;
};

static struct handler_entry handlers[] =
{
    { .signum = SIGTERM },
    { .signum = SIGINT },
    { .signum = SIGHUP },
};

#define HANDLER_COUNT (int)(sizeof(handlers) / sizeof(handlers[0]))

static DB_functions_t* ddb_api;
static int notify_flags;
static int notify_pipe[] = { -1, -1 };
static intptr_t helper_thread_id;

static int create_pipe()
{
    if (pipe(notify_pipe) < 0)
    {
        log_error("pipe failed: %s\n", strerror(errno));
        return -1;
    }

    if (fcntl(notify_pipe[0], F_SETFD, O_NONBLOCK | FD_CLOEXEC) < 0 ||
        fcntl(notify_pipe[1], F_SETFD, O_NONBLOCK | FD_CLOEXEC) < 0)
    {
        log_error("fcntl failed: %s\n", strerror(errno));
        return -1;
    }

    return 0;
}

static void close_pipe()
{
    if (notify_pipe[0] >= 0)
    {
        close(notify_pipe[0]);
        notify_pipe[0] = -1;
    }

    if (notify_pipe[1] >= 0)
    {
        close(notify_pipe[1]);
        notify_pipe[1] = -1;
    }
}

static void send_notify(int flag)
{
    atomic_or(&notify_flags, flag);

    (void) write(notify_pipe[1], "Y", 1);
}

static inline int signal_flag(int signum)
{
    return 1 << (signum + 1);
}

static void handle_signal(int signum)
{
    send_notify(signal_flag(signum));
}

static int setup_handlers()
{
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = handle_signal;

    for (int i = 0; i < HANDLER_COUNT; i++)
    {
        if (sigaction(handlers[i].signum, &action, &handlers[i].old_action) < 0)
        {
            log_error("sigaction failed: %s\n", strerror(errno));
            return -1;
        }

        handlers[i].is_set = 1;
    }

    return 0;
}

static void restore_handlers()
{
    for (int i = 0; i < HANDLER_COUNT; i++)
    {
        if (handlers[i].is_set)
        {
            sigaction(handlers[i].signum, &handlers[i].old_action, NULL);
            handlers[i].is_set = 0;
        }
    }
}

static void restart()
{
    char exe_path[1024];
    ssize_t exe_path_size = readlink("/proc/self/exe", exe_path, sizeof(exe_path));

    if (exe_path_size == sizeof(exe_path))
    {
        log_error("exe path is too long, aborting restart\n");
        return;
    }

    exe_path[exe_path_size] = '\0';

    char* args[] = { exe_path, NULL };

    pid_t pid = getpid();

    switch (fork())
    {
    case -1:
        log_error("fork failed: %s\n", strerror(errno));
        return;

    case 0:
        while (kill(pid, 0) == 0)
            usleep(100000);

        if (errno != ESRCH)
        {
            log_error("kill failed: %s\n", strerror(errno));
            break;
        }

        execv(exe_path, args);
        log_error("execl failed: %s\n", strerror(errno));
        break;

    default:
        return;
    }

    exit(1);
}

static void helper_thread(void* arg)
{
    (void) arg;

#ifdef __linux__
    prctl(PR_SET_NAME, "signals-helper", 0, 0, 0, 0);
#endif

    int flags = atomic_or(&notify_flags, 0);

    while(!flags)
    {
        fd_set set;
        FD_ZERO(&set);
        FD_SET(notify_pipe[0], &set);
        select(notify_pipe[0] + 1, &set, NULL, NULL, NULL);

        flags = atomic_or(&notify_flags, 0);
    }

    if (!(flags & GOT_STOP))
        ddb_api->sendmessage(DB_EV_TERMINATE, 0, 0, 0);
}

static int signals_stop()
{
    if (helper_thread_id)
    {
        send_notify(GOT_STOP);
        ddb_api->thread_join(helper_thread_id);
        helper_thread_id = 0;
    }

    restore_handlers();
    close_pipe();

    if ((notify_flags & signal_flag(SIGHUP))
        && ddb_api->conf_get_int("signals.sighup.restart", 0))
        restart();

    return 0;
}

static int signals_start()
{
    if (create_pipe() < 0)
    {
        signals_stop();
        return -1;
    }

    if (setup_handlers() < 0)
    {
        signals_stop();
        return -1;
    }

    helper_thread_id = ddb_api->thread_start(helper_thread, NULL);

    if (!helper_thread_id)
    {
        signals_stop();
        return -1;
    }

    return 0;
}

static DB_misc_t plugin_def =
{
    .plugin =
    {
        .api_vmajor = 1,
        .api_vminor = DDB_API_LEVEL,
        .version_major = 2,
        .version_minor = 0,
        .type = DB_PLUGIN_MISC,
        .id = "signals",
        .name = "Unix signals support",
        .descr = "Handles SIGTERM, SIGINT and SIGHUP unix signals",
        .website = "https://github.com/hyperblast/ddb_signals",
        .configdialog = "property \"Restart on SIGHUP\" checkbox signals.sighup.restart 0;\n",
        .copyright = LICENSE_TEXT,
        .start = signals_start,
        .stop = signals_stop,
    },
};

DB_plugin_t* signals_load(DB_functions_t* api)
{
    ddb_api = api;
    return DB_PLUGIN(&plugin_def);
}
