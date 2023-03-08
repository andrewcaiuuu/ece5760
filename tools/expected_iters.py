init_cr = -2
init_ci = 1


def calculate_ci_cr(numSteps, init_cr, init_ci):
    new_cr_base = init_cr + (3.0/640)*(numSteps%640)
    new_ci_base = init_ci - (2.0/480)*(numSteps//640)
    return new_cr_base, new_ci_base

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
    for i in range(0x4b000):
        ci, cr = calculate_ci_cr(i, init_cr, init_ci)
        print(iterate(ci, cr, 10))
