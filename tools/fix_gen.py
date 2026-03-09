import os
p = os.path.join(os.path.dirname(__file__), 'gen_impl3.py')
with open(p, 'rb') as f:
    data = f.read()
n = data.count(b'[:{]')
data = data.replace(b'[:{]', b'')
with open(p, 'wb') as f:
    f.write(data)
print(f'Fixed {n} corruptions')
