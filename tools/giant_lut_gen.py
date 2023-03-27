import numpy as np
from fxpmath import Fxp

def pyramid(n):
    r = np.arange(n)
    d = np.minimum(r,r[::-1])
    return np.minimum.outer(d,d)

if __name__ == '__main__':
    res = pyramid(30)
    res = res / res.max()
    # for row in res:
    #     print(' '.join(str(x) for x in row))
    
    for column in range(res.shape[1]):
        for el in res[:, column]:
            print(Fxp(el, signed=True, n_word=18, n_frac=16).hex())