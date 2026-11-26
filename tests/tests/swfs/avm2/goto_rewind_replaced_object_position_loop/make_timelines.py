# Adds the timeline symbols used by Test.as to test.swf (Asc can't make timelines).
# Shapes A, B, C, D are 10, 20, 30 and 40 px wide; sprites SA..SD each hold one of them.
# Frames are lists of tags; each symbol is linked to an AS3 class of the same name.
import sys, zlib, struct
def tag(code, data):
    if len(data) < 0x3F: return struct.pack('<H', code << 6 | len(data)) + data
    return struct.pack('<HI', code << 6 | 0x3F, len(data)) + data
def rect(xmin, xmax, ymin, ymax):
    nbits = max(v.bit_length() for v in (xmin, xmax, ymin, ymax)) + 1
    bits = format(nbits, '05b') + ''.join(format(v, f'0{nbits}b') for v in (xmin, xmax, ymin, ymax))
    bits += '0' * (-len(bits) % 8)
    return bytes(int(bits[i:i + 8], 2) for i in range(0, len(bits), 8))
def shape(cid, w): return tag(2, struct.pack('<H', cid) + rect(0, w * 20, 0, 200) + b'\0\0\0\0')
def place(d, c): return tag(26, bytes([0x02]) + struct.pack('<HH', d, c))
def replace(d, c): return tag(26, bytes([0x03]) + struct.pack('<HH', d, c))
def remove(d): return tag(28, struct.pack('<H', d))
def sprite(cid, frames):
    data = b''.join(b''.join(f) + tag(1, b'') for f in frames)
    return tag(39, struct.pack('<HH', cid, len(frames)) + data + tag(0, b''))
A, B, C, D = 10, 11, 12, 13
defs = shape(A, 10) + shape(B, 20) + shape(C, 30) + shape(D, 40)
f1 = [place(1, A), place(3, C), place(5, D)]
slots = {
    # Replacing objects, with AS3 children around them.
    'Replace1': [[place(1, A)], [replace(1, B)]],
    'Replace3': [[place(1, A), place(3, C)], [replace(3, B)]],
    'Replace1And3': [[place(1, A), place(3, C)], [replace(1, B), replace(3, B)]],
    'ReplaceMiddle': [[place(1, A), place(3, C), place(5, A)], [replace(3, B)]],
    'ReplaceFirstOf3': [f1, [replace(1, B)]],
    'ReplaceSecondOf3': [f1, [replace(3, B)]],
    'ReplaceLastOf3': [f1, [replace(5, B)]],
    'ReplaceFirstAndLast': [f1, [replace(1, B), replace(5, B)]],
    'ReplaceFirstOf4': [f1 + [place(7, A)], [replace(1, B)]],
    'ReplaceTwice': [[place(1, A), place(3, C)], [replace(3, B)], [replace(1, D)]],
    # Tags not in depth order.
    'TagsOutOfOrder': [[place(5, D), place(1, A), place(3, C)], [replace(1, B)]],
    'TagsOutOfOrder2': [[place(3, C), place(1, A), place(5, D)], [replace(1, B)]],
    # Objects removed or added, without replacements.
    'Unchanged': [f1, []],
    'Removed3': [f1, [remove(3)]],
    'Replace1Removed3': [f1, [replace(1, B), remove(3)]],
    'Added4': [f1, [place(4, B)]],
    'Added3': [[place(1, A), place(5, D)], [place(3, C)]],
    'Replace1Added5': [[place(1, A), place(3, C)], [replace(1, B), place(5, D)]],
}
names = []
for i, (name, frames) in enumerate(slots.items()):
    defs += sprite(100 + i, frames); names.append((100 + i, name.encode()))
symbols = tag(76, struct.pack('<H', len(names)) + b''.join(struct.pack('<H', i) + n + b'\0' for i, n in names))
path = sys.argv[1]
d = open(path, 'rb').read()
body = zlib.decompress(d[8:]) if d[:1] == b'C' else d[8:]
nb = body[0] >> 3; pos = (5 + 4 * nb + 7) // 8 + 4
while pos < len(body):
    cl = struct.unpack_from('<H', body, pos)[0]; code, ln, hl = cl >> 6, cl & 0x3F, 2
    if ln == 0x3F: ln = struct.unpack_from('<I', body, pos + 2)[0]; hl = 6
    if code == 76: break
    pos += hl + ln
body = body[:pos] + defs + symbols + body[pos:]
open(path, 'wb').write(b'FWS' + d[3:4] + struct.pack('<I', len(body) + 8) + body)
