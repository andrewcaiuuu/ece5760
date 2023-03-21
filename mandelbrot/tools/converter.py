from fxpmath import Fxp

x = Fxp(0.125, signed=True, n_word=18, n_frac=16)
print(x.hex())