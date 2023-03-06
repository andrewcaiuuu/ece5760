def iterate(ci, cr, max_iterations):

    iterations = 0

    zi = 0
    zr = 0

    for i in range(max_iterations):
        iterations += 1

        zr_temp = zr*zr - zi*zi + cr
        zi_temp = 2*zr*zi + ci

        zi = zi_temp
        zr = zr_temp

        if ((zi*zi + zr*zr) > 4):
            break

    return iterations

if __name__ == "__main__":
    ci = 1
    cr = -2
    print(iterate(ci, cr, 100))