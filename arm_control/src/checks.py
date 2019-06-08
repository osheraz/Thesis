import numpy as np

dx = 20
dy = dx
# Motor specs: [mm]
x = np.linspace(270, 339, dx)  # HDA50 Stroke
y = np.linspace(200, 260, dy)  # P16 Stroke
y_ = 197  # P16 Extracted length
x_ = 246  # HDA50 Extracted length
h = 140
L = 550
l4 = 80
l1 = 285
r = 237
l3 = 46
l2 = 293
lp = 206
l33 = 398
H = 330
minPWM = 20

# Arm mech

q = np.arcsin((x**2 + h**2 - l1**2) / (2*x*h))
# a = np.arcsin(-h + x*np.sin(q)) /(l1)
b_ = np.arcsin((h* np.sin(np.pi/2 - q)) /(l1)) - 12.6*np.pi/180
b = b_ + 36.35*np.pi/180

# Bucket mech

phi = np.arccos((y**2 - r**2 - l3**2) / (-2 * r * l3))
gama = 87.21*np.pi/180 - phi
[QB, G] = np.meshgrid(q - b, gama)
delta = QB + G

# Bucket tip location

p1 = x*np.cos(q) + l33 * np.cos(q - b)
p2 = lp * np.cos(delta)
p3 = x*np.sin(q) + l33 * np.sin(q - b) + H
p4 = lp *np.sin(delta)
Xp = np.add(p1, p2)
Yp = np.add(p3, p4)


angle =  0 * np.pi /180
height = 50

eps_d = 3 * np.pi / 180
eps_h = 10
delta_ = delta + 20 * np.pi / 180
delta_deg = np.degrees(delta_)

[idx, idy] = np.where(abs(delta_ - angle) < eps_d)
[ihx, ihy] = np.where(abs(Yp - height) < eps_h)

ind_x = idy[np.isin(Yp[idx, idy], Yp[ihx, ihy])]  # TODO fix the indexing issue here
ind_y = idx[np.isin(Yp[idx, idy], Yp[ihx, ihy])]

x_cmd = (x[ind_x] - x_) * 1023 / 101
y_cmd = (y[ind_y] - y_) * 1023 / 150



x_cmd = x_cmd[np.where(min(abs(x_cmd - x_cmd_old)))]
y_cmd = y_cmd[np.where(min(abs(y_cmd - y_cmd_old)))]



des_cmd = np.array([x_cmd, x_cmd, y_cmd, y_cmd]).astype(int)