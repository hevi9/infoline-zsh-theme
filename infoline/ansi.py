esc = "\x1b"
# esc = ""
csi = esc + "[" # Control Sequence Introducer

def sgr(text):
    return "{}{}m".format(csi, text)

def fg(n):
    return sgr("38;5;{}".format(str(n)))

def bg(n):
    return sgr("48;5;{}".format(str(n)))


reset = sgr("0")

fg_default = sgr("39")

bg_default = sgr("49")

if __name__ == "__main__":
    import sys
    w = sys.stdout.write
    def dump(fn):
        for i in range(16):
            for j in range(16):
                k = i * 16 + j
                w("{}{:03}{} ".format(fn(k), k, reset))
            w("\n")
    dump(fg)
    w("\n")
    dump(bg)
    w("\n")