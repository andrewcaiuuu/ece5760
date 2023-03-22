import numpy as np
from fxpmath import Fxp

raw = np.linspace(0, 0.5, 15)
raw_reversed = np.linspace(0.5, 0, 15)


print("raw", raw)
print(len(raw))

print("raw_reversed", raw_reversed)
print(len(raw))

raw_combined = []
for i in range(len(raw) + len(raw_reversed)):
    if (i < 15):
        raw_combined.append(raw[i])
    else:
        raw_combined.append(raw_reversed[i-15])

fixed_combined = []
for i in range(len(raw_combined)):
    fixed_combined.append(Fxp(raw_combined[i], signed=True, n_word=18, n_frac=16).hex())

print("raw_combined_fixed", fixed_combined)
print("raw_combined", raw_combined)
# print(len(raw_combined), len(fixed_combined))