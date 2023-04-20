from numba import cuda, njit, prange
import numpy as np

@cuda.jit
def find_best_pins_kernel(x_coords, y_coords, numPins, cropped_width, best_norm, constructed_img, inverted_img):
    i, j = cuda.grid(2)
    if i < numPins and j < numPins and j < i:
        norm = 0
        for k in prange(cropped_width):
            for l in prange(cropped_width):
                norm += (constructed_img[x_coords[i]*cropped_width+k][y_coords[i]*cropped_width+l] -
                         inverted_img[x_coords[j]*cropped_width+k][y_coords[j]*cropped_width+l])**2
        best_norm[i][j] = norm

def find_best_pins(x_coords, y_coords, numPins, cropped_width, constructed_img, inverted_img):
    cuda.initialize()
    coords_size = np.int32(numPins)
    img_size = np.int32(cropped_width)
    pin_size = np.int32(numPins*numPins)
    norm_size = np.int32(numPins*numPins)
    memorysize = np.int32(2 * MAX_WIDTH)
    
    device_x_coords = cuda.to_device(x_coords)
    device_y_coords = cuda.to_device(y_coords)
    device_constructed_img = cuda.to_device(constructed_img)
    device_inverted_img = cuda.to_device(inverted_img)
    device_bestPin1 = cuda.device_array((pin_size,), dtype=np.int32)
    device_bestPin2 = cuda.device_array((pin_size,), dtype=np.int32)
    device_bestNorm = cuda.device_array((norm_size,), dtype=np.int64)
    
    blockDim = (16,16)
    gridDim = ((numPins + blockDim[0] - 1) // blockDim[0], (numPins + blockDim[1] - 1) // blockDim[1])
    
    find_best_pins_kernel[gridDim, blockDim](device_x_coords, device_y_coords, numPins, cropped_width, 
                                             device_bestNorm, device_constructed_img, device_inverted_img)

    norm = device_bestNorm.copy_to_host()
    bestNorm = np.min(norm[np.triu_indices(numPins, k=1)])

    bestPinIndex = np.where(norm == bestNorm)
    bestPin1 = bestPinIndex[0][0]
    bestPin2 = bestPinIndex[1][0]

    return (bestPin1, bestPin2, bestNorm)