
FILENAME = 'pausedHexVals.txt'
COLOR_REG = '$s7'
DATA_REG = '$t0'
BG_COLOR = 'E4F9F5'

def process_file(f):
    vals = []
    stripped_vals = []
    count = 0
    for line in f:
        vals += line.split(',')
    for val in vals:
        val = val.strip()
        if val != '':
            first = val[:2]
            second = val[4:]
            second =  second[-2:] + second[-4:-2] + second[:2]
            if second == '000000':
                second = BG_COLOR
            stripped_vals.append('\tli {0}, {3}\n\tsw {0}, {1}({2})'.format(COLOR_REG, count*4, DATA_REG, first+second))
            count += 1
    return stripped_vals

with open(FILENAME, mode='r') as f:
    for val in process_file(f):
        print(val)
