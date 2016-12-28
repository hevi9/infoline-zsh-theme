import logging
import os
import pwd
import re
import shutil
import socket
import stat
import sys
import time

import git
import psutil

from . import ansi

log = logging.getLogger(__name__)
D = log.debug


class Char:
    fill = ' '
    cont = '…'
    plus = '✚'
    cross = '✖'
    dot = '●'
    flag = '⚑'
    skull = '🕱'
    jobs = '⚙'
    level = '⮇'
    disk = '🖸'
    memory = '🖫'
    untracked = '?'
    ahead = '⭱'
    behind = '⭳'
    diverged = '⭿'
    stashed = '≡'
    start = '▶'
    file = '🗎'
    dir = '📁'
    todo = '🔨'


class NoColor:
    ok = ""
    note = ""
    focus = ""
    important = ""
    error = ""
    default = ""
    reset = ""
    line = ""
    strip = re.compile(r'')


# non-printable terminal control sequence wrap
def zsh_cover(t):
    return "%%{%s%%}" % t


class Shell(NoColor):
    ok = zsh_cover(ansi.fg(2))
    note = zsh_cover(ansi.fg(4))
    focus = zsh_cover(ansi.fg(3))
    important = zsh_cover(ansi.fg(5))
    error = zsh_cover(ansi.fg(168))
    default = zsh_cover(ansi.fg_default)
    reset = zsh_cover(ansi.reset)
    line = zsh_cover(ansi.bg(237))
    strip = re.compile(r'%{.*?%}')


class Info:
    def __init__(self, render_func, priority, align):
        self.render_func = render_func
        self.name = render_func.__name__
        self.width = None
        self.value = None
        self.priority = priority
        self.align = align

    def render(self, ctx):
        self.value = self.render_func(ctx)
        if self.value:
            self.value += Shell.default
        self.width = len(Shell.strip.sub('', self.value))
        return self


infos = []


def info(*, priority=0, align="L"):
    def wrap(func):
        infos.append(Info(func, priority, align))
        return func

    return wrap


## * Show host if in remote (ssh) computer
@info()
def host(ctx):
    try:
        os.environ["SSH_CLIENT"]
        return socket.gethostname()
    except KeyError:
        return ""


## * Show Current Working directory
##   * show cwd, trunkated from start if not enough room
##   * Current dir part as green if can write, red if not
##   * Number of files in current dir
@info()
def cwd(ctx):
    try:
        cwd = os.getcwd()
    except FileNotFoundError:  # missing cwd
        return Shell.error + os.environ.get("PWD", "") + Char.skull
    if os.access(cwd, os.W_OK):
        color = Shell.ok
    else:
        color = Shell.error
    home = os.environ["HOME"]
    if home:
        common = os.path.commonpath((cwd, home))
        if common == home:
            cwd = "~" + cwd[len(home):] if len(cwd) > len(home) else "~"
    dir = os.path.dirname(cwd)
    name = os.path.basename(cwd)
    if dir == "/" and not name:
        name = "/"
        dir = ""
    if dir:
        dir = dir + os.sep if dir != "/" else dir
    # select and/or cwd info into given space
    if len(dir) + len(name) <= ctx.maxwidth:
        return dir + color + name + Shell.default
    else:
        dir = Char.cont + dir[-(ctx.maxwidth - len(name) - 1):]
        if len(dir) + len(name) <= ctx.maxwidth:
            return dir + color + name + Shell.default
        else:
            name = Char.cont + name[-(ctx.maxwidth - 1):]
            return color + name + Shell.default


# TODO git detached head
# TODO git conflicted files
# TODO git stashes
# logic from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/git.zsh
## * Show git status if exists
##   * Repo dirty
##   * Untracked files
##   * Repo ahead, behind or diverged from upstream. Missing upstream.
@info()
def show_git(ctx):
    try:
        repo = git.Repo(search_parent_directories=True)
    except git.InvalidGitRepositoryError:
        return ""
    except Exception as ex:
        D("gitpython %s", ex)
        return ""
    branch = repo.active_branch
    color = Shell.focus if repo.is_dirty() else ""
    indicators = ""
    if len(repo.untracked_files):
        indicators += Shell.note + Char.untracked + Shell.default
    try:
        ahead = [i for i in repo.iter_commits("%s@{upstream}..HEAD" % branch)]
        behind = [i for i in repo.iter_commits("HEAD..%s@{upstream}" % branch)]
        if len(ahead) > 0 and len(behind) > 0:
            indicators += Shell.note + Char.diverged + Shell.default
        elif len(ahead) > 0:
            indicators += Shell.note + Char.ahead + Shell.default
        elif len(behind) > 0:
            indicators += Shell.note + Char.behind + Shell.default
        else:
            pass
    except git.GitCommandError:  # branch does not have upstream
        indicators += Shell.error + Char.ahead + Shell.default
    return color + str(branch) + indicators


# NOTE Set export VIRTUAL_ENV_DISABLE_PROMPT=yes
# TODO Sign for virtual env
## * Show python virtual env
@info()
def virtual_env(ctx):
    try:
        venv = os.environ["VIRTUAL_ENV"]
        venv = os.path.basename(venv)
        return venv
    except KeyError:
        return ""


def can_write(entry):
    try:
        st = entry.stat()
    except Exception:
        return False
    mode = st.st_mode
    euid = os.geteuid()
    egid = os.getegid()
    return (mode & stat.S_IWOTH or
            (egid == st.st_gid and mode & stat.S_IWGRP) or
            (euid == st.st_uid and mode & stat.S_IWUSR))


## * Show number of files in current directory with color: ok - all writable
##   focus - some not writable, error - none writable
@info(align="R")
def files(ctx):
    if len(ctx.files):
        count = 0
        for entry in ctx.files:
            if can_write(entry):
                count += 1
        color = Shell.error
        if count == len(ctx.files):
            color = Shell.ok
        if 0 < count < len(ctx.files):
            color = Shell.focus
        return color + str(len(ctx.files)) + Char.file
    else:
        return ""


## * Show number of directories in current dircetory with color:
##   ok - all writable, focus - some not writable, error - none writable
@info(align="R")
def dirs(ctx):
    if len(ctx.dirs):
        count = 0
        for entry in ctx.dirs:
            if can_write(entry):
                count += 1
        color = Shell.error
        if count == len(ctx.dirs):
            color = Shell.ok
        if 0 < count < len(ctx.dirs):
            color = Shell.focus
        return color + str(len(ctx.dirs)) + Char.dir
    else:
        return ""


## * 🕱 Program return code if error
@info(align="R")
def rc(ctx):
    try:
        rc = int(ctx.rc)
        if rc != 0:
            return Shell.error + str(rc) + Char.skull
        else:
            return ""
    except KeyError:
        return Shell.error + "rc=$?"


## * ⚙ Number of spawned jobs from shell
@info(align="R")
def jobs(ctx):
    this_process = psutil.Process()
    # filter this process out
    shell_childrens = [i for i in this_process.parent().children()
                       if i != this_process]
    if len(shell_childrens) > 0:
        return Shell.note + str(len(shell_childrens)) + Char.jobs
    else:
        return ""


## * ⮇ Shell level indicator
@info(align="R")
def shell_level(ctx):
    try:
        level = int(os.environ["SHLVL"])
        D("shell level=%d", level)
        # shell level is -1 compared to shell environment level for some reason
        if level > 0:
            return Shell.focus + str(level) + Char.level
        else:
            return ""
    except KeyError or ValueError:
        return Shell.error + "\\$SHLVL"


## * 🖸 Disk usage alert if over 80% capacity
@info(align="R")
def disk(ctx):
    usage = psutil.disk_usage(".").percent
    if usage > 80:
        return Shell.important + "%d" % usage + Char.disk
    else:
        return ""


## * 🖫 Virtual memory usage alert if over 80% capacity
@info(align="R")
def virtual_memory(ctx):
    usage = psutil.virtual_memory().percent
    if usage > 80:
        return Shell.important + "%d" % usage + Char.memory
    else:
        return ""


# TODO todos in current directory info


clocks = {
    0: '🕛', 30: '🕧', 100: '🕐', 130: '🕜', 200: '🕑', 230: '🕝',
    300: '🕒', 330: '🕞', 400: '🕓', 430: '🕟', 500: '🕔', 530: '🕠',
    600: '🕕', 630: '🕡', 700: '🕖', 730: '🕢', 800: '🕗', 830: '🕣',
    900: '🕘', 930: '🕤', 1000: '🕙', 1030: '🕥', 1100: '🕚', 1130: '🕦'
}


@info(align="R")
def clock(ctx):
    hour = time.localtime().tm_hour % 12
    minute = time.localtime().tm_min
    if minute < 15:
        minute = 0
    elif minute < 45:
        minute = 30
    else:
        minute = 0
        hour += 1
    hour = 0 if hour > 11 else hour
    D("time=%d %d %d", hour, minute, hour * 100 + minute)
    try:
        return clocks[hour * 100 + minute]
    except KeyError:
        return ""


def start(ctx):
    euid = os.geteuid()
    user = ""
    if euid == 0:
        user = pwd.getpwuid(euid).pw_name
        color = Shell.important
    elif euid < 1000:
        user = pwd.getpwuid(euid).pw_name
        color = Shell.note
    else:
        color = Shell.focus
    return color + user + Char.start + " "


class ctx:
    rc = 0
    maxwidth = 1000
    files = []
    dirs = []


# NOTE Set export DEBUG_PROMPT=1 to show debug log on prompt making
def main():
    if os.environ.get("DEBUG_PROMPT"):
        logging.basicConfig(level=logging.DEBUG)

    # collect information
    for arg in sys.argv[1:]:
        try:
            key, value = arg.split('=', 1)
            setattr(ctx, key, value)
        except ValueError:
            setattr(ctx, arg, None)
    for entry in os.scandir("."):
        if entry.is_dir():
            ctx.dirs.append(entry)
        else:
            ctx.files.append(entry)
    D("ctx=%s", vars(ctx))

    # detemine column width
    columns, _ = shutil.get_terminal_size()  # seems not to work always
    D("columns=%d", columns)

    # render components infos
    remain = columns - 1 - 1
    for info in infos:
        ctx.maxwidth = int(2 / 3 * remain)
        info.render(ctx)
        if info.value:
            remain -= info.width + 1
    remain += 1 + 1

    for i, info in enumerate(infos):
        D("info-%d %s %s%d '%s'", i, info.name, info.align, info.width,
          info.value)

    # gather areas
    lefts = [i.value for i in infos if i.align == "L" and i.value]
    rights = [i.value for i in infos if i.align == "R" and i.value]

    # construct prompt
    w = sys.stdout.write
    w(Shell.reset)
    w(Shell.line)
    w(Char.fill)
    w(Char.fill.join(lefts))
    w(Char.fill * remain)
    w(Char.fill.join(rights))
    w(Char.fill)
    w(Shell.reset)
    w(start(ctx))
    w(Shell.reset)


if __name__ == "__main__":
    main()

# TODO main exception wrap

# Copyright (C) 2016 Petri Heinilä, License LGPLv3
