"""Builds test.swf from base.swf (Test.as and MyFont.as, compiled by the test
runner) by adding a frame 2 with a font and the SymbolClass tag that links it
to MyFont. The font is TestFont1 from ../font_enumeratefonts_filter/test.swf.

Usage: python3 make_swf.py
"""

import struct
import zlib

FONT_ID = 1


def read_tags(path):
    data = open(path, "rb").read()
    body = zlib.decompress(data[8:]) if data[:3] == b"CWS" else data[8:]
    rect_bytes = (5 + 4 * (body[0] >> 3) + 7) // 8
    header = body[: rect_bytes + 4]
    tags = []
    pos = len(header)
    while pos < len(body):
        code_len = struct.unpack("<H", body[pos : pos + 2])[0]
        code, length = code_len >> 6, code_len & 63
        pos += 2
        if length == 63:
            length = struct.unpack("<I", body[pos : pos + 4])[0]
            pos += 4
        tags.append((code, body[pos : pos + length]))
        pos += length
        if code == 0:
            break
    return data[3], header, tags


def tag(code, payload):
    return struct.pack("<HI", (code << 6) | 63, len(payload)) + payload


version, header, tags = read_tags("base.swf")
_, _, font_tags = read_tags("../font_enumeratefonts_filter/test.swf")
font = next(
    payload
    for code, payload in font_tags
    if code == 75 and payload[5 : 5 + payload[4]].rstrip(b"\0") == b"TestFont1"
)
font = struct.pack("<H", FONT_ID) + font[2:]

out = b"".join(tag(code, payload) for code, payload in tags if code != 0)
out += tag(75, font)  # DefineFont3
out += tag(76, struct.pack("<HH", 1, FONT_ID) + b"MyFont\0")  # SymbolClass
out += tag(1, b"")  # ShowFrame
out += tag(0, b"")  # End

# Two frames.
rect_bytes = len(header) - 4
header = header[:rect_bytes] + header[rect_bytes : rect_bytes + 2] + struct.pack("<H", 2)
body = header + out
open("test.swf", "wb").write(b"FWS" + bytes([version]) + struct.pack("<I", 8 + len(body)) + body)
