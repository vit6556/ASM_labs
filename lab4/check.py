n = 10
x = 0.9

res = 0
for i in range(1, n + 1):
    if i % 2 == 1:
        res += (x ** i) / i
    else:
        res -= (x ** i) / i

print(res)
