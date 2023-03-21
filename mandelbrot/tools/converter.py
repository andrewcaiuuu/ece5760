from fxpmath import Fxp

x = Fxp(0.125, signed=True, n_word=27, n_frac=25)
print(x.hex())