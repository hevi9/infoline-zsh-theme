import logging
import os
import pwd
import re
import shutil
import socket
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
    # TODO skull uses 2 characters
    skull = '\U0001F571'  # '🕱' 2 chars ? U+1F571
    jobs = '⚙'
    level = '⮇'
    disk = '🖸'
    untracked = '?'
    ahead = '⭱'
    behind = '⭳'
    diverged = '⭿'
    stashed = '≡'
    start = '▶'


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


zsh_cover = lambda t: "%%{%s%%}" % t


class ZshShell(NoColor):
    ok = zsh_cover(ansi.fg(2))
    note = zsh_cover(ansi.fg(4))
    focus = zsh_cover(ansi.fg(3))
    important = zsh_cover(ansi.fg(5))
    error = zsh_cover(ansi.fg(168))
    default = zsh_cover(ansi.fg_default)
    reset = zsh_cover(ansi.reset)
    line = zsh_cover(ansi.bg(237))
    strip = re.compile(r'%{.*?%}')


Shell = ZshShell


class Info:
    def __init__(self, render_func, priority, align):
        self.render_func = render_func
        self.name = render_func.__name__
        self.width = None
        self.value = None
        self.priority = priority
        self.align = align

    def render(self, maxwidth, ctx):
        self.value = self.render_func(maxwidth, ctx)
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


@info()
def host(maxwidth, _):
    try:
        os.environ["SSH_CLIENT"]
        return socket.gethostname()
    except KeyError:
        return ""


@info()
def cwd(maxwidth, _):
    cwd = os.getcwd()
    files = os.listdir(cwd)
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
    files = "(%d)" % len(files)
    # select and/or cwd info into given space
    if len(dir) + len(name) + len(files) <= maxwidth:
        return dir + color + name + Shell.default + files
    elif len(dir) + len(name) <= maxwidth:
        return dir + color + name + Shell.default
    else:
        dir = Char.cont + dir[-(maxwidth - len(name) - 1):]
        D(dir)
        if len(dir) + len(name) <= maxwidth:
            return dir + color + name + Shell.default
        else:
            name = Char.cont + name[-(maxwidth - 1):]
            return color + name + Shell.default


# TODO git detached head
# TODO git conflicted files
# TODO git stashes
# logic from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/git.zsh
@info()
def show_git(maxwidth, _):
    try:
        repo = git.Repo()
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


@info()
def virtual_env(maxwidth, _):
    try:
        venv = os.environ["VIRTUAL_ENV"]
        venv = os.path.basename(venv)
        return venv
    except KeyError:
        return ""


@info(align="R")
def rc(_, ctx):
    try:
        rc = int(ctx["rc"])
        if rc != 0:
            return Shell.error + str(rc) + Char.skull
        else:
            return ""
    except KeyError:
        return Shell.error + "rc=$?"


@info(align="R")
def jobs(_1, _2):
    this_process = psutil.Process()
    # filter this process out
    shell_childrens = [i for i in this_process.parent().children()
                       if i != this_process]
    if len(shell_childrens) > 0:
        return Shell.note + str(len(shell_childrens)) + Char.jobs
    else:
        return ""


@info(align="R")
def shell_level(_1, _2):
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


@info(align="R")
def disk(_1, _2):
    usage = psutil.disk_usage(".").percent
    if usage > 80:
        return Shell.important + "%d" % usage + Char.disk
    else:
        return ""


@info(align="R")
def virtual_memory(_1, _2):
    usage = psutil.virtual_memory().percent
    if usage > 80:
        return Shell.important + "%dVM" % usage
    else:
        return ""


# TODO todos


clocks = {
    0: '🕛', 30: '🕧', 100: '🕐', 130: '🕜', 200: '🕑', 230: '🕝',
    300: '🕒', 330: '🕞', 400: '🕓', 430: '🕟', 500: '🕔', 530: '🕠',
    600: '🕕', 630: '🕡', 700: '🕖', 730: '🕢', 800: '🕗', 830: '🕣',
    900: '🕘', 930: '🕤', 1000: '🕙', 1030: '🕥', 1100: '🕚', 1130: '🕦'
}


@info(align="R")
def clock(_1, _2):
    hour = time.localtime().tm_hour % 12
    minute = time.localtime().tm_min
    if minute < 15:
        minute = 0
    elif minute < 45:
        minute = 30
    else:
        minute = 0
        hour += 1
        hour = 0 if hour > 12 else hour
    D("time=%d %d %d", hour, minute, hour * 100 + minute)
    return clocks[hour * 100 + minute]


def start():
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


def main():
    if os.environ.get("DEBUG_PROMPT"):
        logging.basicConfig(level=logging.DEBUG)

    ctx = {}
    for arg in sys.argv[1:]:
        try:
            key, value = arg.split('=', 1)
            ctx[key] = value
        except ValueError:
            ctx[arg] = None
    D("ctx=%s", ctx)

    columns, _ = shutil.get_terminal_size()  # seems not to work always
    D("columns=%d", columns)

    w = sys.stdout.write

    remain = columns - 1 - 1
    for info in infos:
        info.render(int(2 / 3 * remain), ctx)
        if info.value:
            remain -= info.width + 1
    remain += 1 + 1

    for i, info in enumerate(infos):
        D("info-%d %s %s%d '%s'", i, info.name, info.align, info.width,
          info.value)

    lefts = [i.value for i in infos if i.align == "L" and i.value]
    rights = [i.value for i in infos if i.align == "R" and i.value]

    w(Shell.reset)
    w(Shell.line)
    w(Char.fill)
    w(Char.fill.join(lefts))
    w(Char.fill * remain)
    w(Char.fill.join(rights))
    w(Char.fill)
    w(Shell.reset)
    w(start())
    w(Shell.reset)


if __name__ == "__main__":
    main()
