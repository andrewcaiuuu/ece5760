from cu import *
from PIL import Image, ImageDraw
import os
import time

def generate_hooks(n_hooks, wheel_pixel_size, hook_pixel_size):
    
    r = (wheel_pixel_size / 2) - 1
    
    theta = np.arange(n_hooks, dtype="float64") / n_hooks * (2 * np.pi)
    
    epsilon = np.arcsin(hook_pixel_size / wheel_pixel_size)
    
    theta_acw = theta.copy() + epsilon
    theta_cw = theta.copy() - epsilon
    
    theta = np.stack((theta_cw, theta_acw)).ravel("F")
    
    x = r * (1 + np.cos(theta)) + 0.5
    y = r * (1 + np.sin(theta)) + 0.5
    
    return np.array((x,y)).T


def through_pixels(p0, p1):
    
    d = max(int(((p0[0]-p1[0])**2 + (p0[1]-p1[1])**2) ** 0.5), 1)
    
    pixels = p0 + (p1-p0) * np.array([np.arange(d+1), np.arange(d+1)]).T / d
    pixels = np.unique(np.round(pixels), axis=0).astype(int)
    
    return pixels


def build_through_pixels_dict(n_hooks, wheel_pixel_size, hook_pixel_size):

    n_hook_sides = n_hooks * 2

    l = [(0,1)]
    for j in range(n_hook_sides):
        for i in range(j):
            if j-i > 10 and j-i < (n_hook_sides - 10):
                l.append((i, j))
    
    random_order = np.random.choice(len(l),len(l),replace=False)
    
    d = {}    
    t_list = []
    t0 = time.time()
    
    for n in range(len(l)):
        (i, j) = l[random_order[n]]
        p0, p1 = hooks[i], hooks[j]
        d[(i,j)] = through_pixels(p0, p1)
        
        t = time.time() - t0
        t_left = t * (len(l) - n - 1) / (n + 1)
        print(f"time left = {time.strftime('%M:%S', time.gmtime(t_left))}", end="\r")
    
    clear_output()
    return d

if __name__ == "__main__":    
    img = Image.open("cuda_implementation/images/audrey.jpg").convert('L')
    img = crop_to_circle(img)
    img.show()
    xcoords, ycoords = generate_circle_points(200, 250)

    arr = np.array(img)