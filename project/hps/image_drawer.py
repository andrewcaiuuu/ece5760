import numpy as np
from PIL import Image, ImageDraw
from itertools import product

def display_from_tuple_list(source, size):
    # Read the text file into a 2D NumPy array
    with open(source, 'r') as f:
        data = [list(map(int, line.split())) for line in f]
        array = np.array(data)

    thread_image = Image.new('RGB', (size,size), (255,255,255))
    draw = ImageDraw.Draw(thread_image)

    print(array.shape)
    for line in array:
        draw.line((line[0], line[1], line[2], line[3]), fill=(0,0,0))

    # thread_image.show()
    thread_image.save("hps/out.png")

if __name__ == "__main__":
    display_from_tuple_list("hps/output.txt", 480)