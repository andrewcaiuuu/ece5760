import numpy as np
import matplotlib.pyplot as plt
from fxpmath import Fxp

uij = 0.125
uij_prev = 0.125
t = np.arange(0, 100, 1)
u = []
u_fixed = []

for i in range(len(t)):
    temp = -uij * 4 * (1/16) + uij * 2 - 0.9998*uij_prev
    uij_next = temp  * 0.9999
    u.append(uij)
    u_fixed.append(Fxp(uij, signed=True, n_word=18, n_frac=16).hex())
    print(u_fixed[i], u[i])
    uij_prev = uij
    uij = uij_next

# print(u_fixed)
plt.plot(t, u)
plt.show()