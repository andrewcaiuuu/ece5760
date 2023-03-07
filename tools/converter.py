import struct 
import math 

decimal_places = 23 
input = -2

def float_to_fix(f):
    res = int(f * (2 ** decimal_places))
    return hex(res)


def fix_to_float(i):
    return struct ( '<i', int (float(i) / (2 ** decimal_places)))

if __name__ == "__main__":
    print(float_to_fix(input))
    # fix_to_float(input)
