
FILENAME = 'hwxFile'
COLOR_REG = '$t4'
DATA_REG = '$a1'
BG_COLOR = 'E4F9F5'
SCREEN_WDITH = 64
DIGIT_WIDTH = 3

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
            offset = ((count//DIGIT_WIDTH)*SCREEN_WDITH + count%DIGIT_WIDTH) * 4
            stripped_vals.append('\tli {0}, {3}\n\tsw {0}, {1}({2})'.format(COLOR_REG, offset, DATA_REG, first+second))
            count += 1
    return stripped_vals

for i in range(10):
    cur_filename = '{}{}.txt'.format(FILENAME, i)
    #print('-------------------- COLOUR DATA FOR {} --------------------\n'.format(i))
    print('draw{}:'.format(i))
    with open(cur_filename, mode='r') as f:
        for val in process_file(f):
            print(val)
    print('\tj drawDigitDone')
    print()
