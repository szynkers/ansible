# filter_plugins/mikrotik_decode.py
import re

HEX2 = re.compile(r'^[0-9A-Fa-f]{2}$')

def mikrotik_unescape(s: str):
    if s is None:
        return None
    if not isinstance(s, str):
        s = str(s)

    b = bytearray()
    i = 0
    while i < len(s):
        if s[i] == "\\" and i + 2 < len(s):
            h = s[i+1:i+3]
            if HEX2.match(h):
                b.append(int(h, 16))
                i += 3
                continue
        # normalny znak -> bajty UTF-8
        b.extend(s[i].encode("utf-8"))
        i += 1

    # RouterOS bywa niespójny (czasem UTF-8, czasem cp1250/latin2)
    for enc in ("utf-8", "cp1250", "iso-8859-2"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            pass
    return b.decode("utf-8", errors="replace")

class FilterModule(object):
    def filters(self):
        return {"mikrotik_unescape": mikrotik_unescape}
