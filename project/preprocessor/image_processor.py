import numpy as np
from PIL import Image, ImageDraw
from itertools import product

def prepare_image(file_name, wheel_pixel_size=480, weighting=False):
    
    image = Image.open(file_name).resize((wheel_pixel_size, wheel_pixel_size))

    if weighting:     
        image = 1 - np.array(image.convert(mode="L").getdata()).reshape((wheel_pixel_size, wheel_pixel_size)) / 255
        non_zero_mask = image > 0
        log2_arr = np.log2(np.where(non_zero_mask, image, 1))
        rounded_log2_arr = np.round(log2_arr)
        rounded_arr = np.abs(rounded_log2_arr)
        
        # print(non_zero_mask)
        image = np.where(non_zero_mask, rounded_arr, 0)

        # masking it off
        # coords = np.array(list(product(range(wheel_pixel_size), range(wheel_pixel_size))))
        # x_coords = coords.T[0]
        # y_coords = coords.T[1]
        # coords_distance_from_centre = np.sqrt((x_coords - (wheel_pixel_size-1)*0.5)**2 + (y_coords - (wheel_pixel_size-1)*0.5)**2)
        # mask = np.array(coords_distance_from_centre > wheel_pixel_size*0.5)
        # mask = np.reshape(mask, (-1, wheel_pixel_size))
        # image[mask] = -1
        image = np.clip(image, a_min=None, a_max=3)
    else:
        image = 255 - np.array(image.convert(mode="L").getdata()).reshape((wheel_pixel_size, wheel_pixel_size))
        coords = np.array(list(product(range(wheel_pixel_size), range(wheel_pixel_size))))
        x_coords = coords.T[0]
        y_coords = coords.T[1]
        coords_distance_from_centre = np.sqrt((x_coords - (wheel_pixel_size-1)*0.5)**2 + (y_coords - (wheel_pixel_size-1)*0.5)**2)
        mask = np.array(coords_distance_from_centre > wheel_pixel_size*0.5)
        mask = np.reshape(mask, (-1, wheel_pixel_size))
        image[mask] = 0

    # return image.T[:,::-1].astype(int)
    return image.astype(int)


def display_image_from_txt(source):
    # Read the text file into a 2D NumPy array
    with open(source, 'r') as f:
        data = [list(map(float, line.split())) for line in f]
        array = np.array(data)

    normalized_array = (array - array.min()) / (array.max() - array.min()) * 255
    image = Image.fromarray(normalized_array.astype(np.uint8))

    image.show()

if __name__ == "__main__":
    image = prepare_image("preprocessor/ah_monochrome.jpg", weighting=False)
    np.savetxt('preprocessor/ah_monochrome.txt', image, fmt='%d', delimiter=' ')

    weight = prepare_image( "preprocessor/ah_wpos.jpg", weighting=True)
    np.savetxt('preprocessor/ah_wpos.txt', weight, fmt='%d', delimiter=' ')

    display_image_from_txt("preprocessor/ah_monochrome.txt")