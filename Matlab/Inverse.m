% Written by Osher Azulay
% Inverse

% Constants:
h=140;
dx=20;
dy=dx;
L = 550;
x=linspace(270,339,dx);
y=linspace(197,260,dy);
H = 330;
l4=80;
l1=285;
r=237;
l3=46;
l2=293;
lp=206;
l33 = 398;
l44 = 669.5;
y_ = 197;
x_ = 246;

yp = 100;   % Height related to XYZ1 !!!
angle = 10.47; % TODO angle + 20
PSI = asind((yp - lp*sind(angle))/(l44));
xp = l44*cosd(PSI) +lp*cosd(angle);
alpha = acosd((l44^2 + l1^2 - l33^2)/(2*l44*l1)) + PSI;
PHI = 77.31 - angle - abs(PSI)

x = sqrt(h^2 +l1^2 + 2*h*l1*sind(alpha)) 
y = sqrt(r^2 +l3^2 -2*r*l3*cosd(PHI)) 

x_mm = (x - x_);
y_mm = (y - y_);
x_cmd = x_mm.*(1023/101);
y_cmd = y_mm.*(1023/150);
height = yp + 140
fprintf('Angle	%.2f 	[deg]\n',angle );
fprintf('Height	%.2f 	[mm]\n',height );
fprintf('Arm Motor extention	%.2f    [mm]    [%.1f - cmd]	\n',x_mm,x_cmd);
fprintf('Bucket Motor extention	%.2f    [mm]	[%.1f - cmd]	\n',y_mm,y_cmd);

