init_cr = -2
init_ci = 1


def calculate_ci_cr(numSteps, init_cr, init_ci):
    new_cr_base = init_cr + (3.0/640)*(numSteps%640)
    new_ci_base = init_ci - (2.0/480)*(numSteps//640)
    return new_cr_base, new_ci_base



if __name__ == "__main__":
    print(calculate_ci_cr(0x62ce, init_cr, init_ci))



