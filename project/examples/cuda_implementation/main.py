from cu import *
from PIL import Image, ImageDraw
import os

def crop_to_circle(image):
    # Create a new image with alpha channel (RGBA) and same size as original
    circle_mask = Image.new('L', image.size, 0)

    # Create a draw object for the mask
    draw = ImageDraw.Draw(circle_mask)

    # Draw a white circle with diameter of the height of the image
    draw.ellipse((0, 0, image.height, image.height), fill=255)

    # Apply the mask to the original image using the alpha channel
    result = image.copy()
    result.putalpha(circle_mask)

    # Crop the result to the bounding box of the circle
    result = result.crop(result.getbbox())

    return result

if __name__ == "__main__":
    img = Image.open("cuda_implementation/images/audrey.jpg").convert('L')
    img = crop_to_circle(img)
    img.show()
    arr = np.array(img)
    print(arr.shape)
    print(arr[0][0])
    print(arr[250][250])
    print("hello world")