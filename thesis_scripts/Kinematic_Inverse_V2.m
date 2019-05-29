% clc
% clear all


%%  Kinematics

f = figure;
f.Renderer = 'painters';
% Constants:
h=0.14;
dx=20;
dy=dx;
L = 0.55;
x=linspace(0.26,0.34,dx);
y=linspace(0.197,0.27,dy);
hx = -0.216;
hy = 0.333;
l4=0.106;
l1=0.285;
b_add = 12.6.*pi/180;
r=0.237;
l3=0.046;
l2=0.293;
lp=0.206;
%%%%%%%%%%%% Arm mech %%%%%%%%%%%%
q=asin((x.^2+h^2-l1^2)./(2.*x.*h));
sina=(-h+x.*sin(q))./(l1);
a = asin(sina); % alpha from the sinus
b = a + b_add.*pi/180; % beta
a_deg= a.*180/pi;
q_deg=q.*180/pi;
b_deg=b.*180/pi;
gama = (180 - 96.65).*pi/180 - b;
gama_deg = gama.*180/pi;
%%%%%%%%%%%% Bucket mech %%%%%%%%%%%%
dx = r.* cos(gama);
dy = r.* sin(gama);
gama = (180 - 96.65).*pi/180 - b;
phi=acos((y.^2 - r.^2 - l3.^2)./(-2.*r.*l3));
phi_deg = phi.*180/pi;
[GAMA,PHI] = meshgrid(gama , phi);
delta = pi - (PHI + GAMA + 46.*pi/180);
delta_deg = delta.*180/pi;
bucket_angle = delta_deg + 20;

%% Plots
P1=x.*cos(q)+l2.*cos(b) + dx;   % X location of bucket joint
P2=lp.*cos(delta);              
t1x = x.*cos(q)+l2.*cos(b); % for arm plot
z1x = 0.*t1x; % for arm plot
z1y = h.*ones(1,length(t1x));
% [X1,X2]=meshgrid(P1,P2);
Xp = bsxfun(@plus, P1, P2);

P3=x.*sin(q)+l2.*sin(b) - dy ;
t1y = x.*sin(q)+l2.*sin(b); % for arm plot
P4=lp.*sin(delta);
% [Y1,Y2]=meshgrid(P3,P4);
Yp = bsxfun(@plus, P3 , P4);
% Xp=X1+X2;
% Yp=Y1+Y2;
color = [0.7 0.7 0.7];
for i=1:8:length(t1x)  % arm plot
   h1 = plot([z1x(i) t1x(i)],[z1y(i) t1y(i)],'color',color,'LineStyle','-','LineWidth',7,'DisplayName','Arm Link');hold on
   h2 = plot(t1x(i),t1y(i),'o','color',color,'MarkerFaceColor',color,'MarkerEdgeColor','None');
   h3 = plot([t1x(i) P1(i)],[t1y(i) P3(i)],'color',color,'LineStyle','-','LineWidth',7);hold on
   h4 = plot(P1(i),P3(i),'bo','MarkerFaceColor','b','DisplayName','Joint');hold on
   h5 = plot(z1x(i),z1y(i),'bo','MarkerFaceColor','b'); hold on
end
% h6 = plot(Xp,Yp,'o','color',[0.6350 0.0780 0.1840],'MarkerSize',1,'DisplayName','bucket x,y tip');
h6 = plot(Xp,Yp,'DisplayName','bucket x,y tip');

% for ploting bucket
P22=l4.*cos(delta+46.*pi/180);
% [X11,X22]=meshgrid(P1,P22);
P44=l4.*sin(delta+46.*pi/180);
% [Y11,Y22]=meshgrid(P3,P44);
Xpp=bsxfun(@plus, P1, P22);
Ypp=bsxfun(@plus, P3, P44);
% [P1,P3] = meshgrid(P1,P3);

for i= 1:8:length(t1x)
    j =i*length(t1x)+30;
%   plot([P1(i) Xp(j)],[P3(i) Yp(j)],'color','k','LineStyle','-','LineWidth',2);hold on
    h7 = plot([P1(i) Xpp(j)],[P3(i) Ypp(j)],'color','k','LineStyle','-','LineWidth',3,'DisplayName','Bucket Link');hold on
    xplot=[P1(i),(P1(i)+Xp(j))/2-0.01, Xp(j)]; yplot = [P3(i),(P3(i)+Yp(j))/2-0.02, Yp(j)];
    p = polyfit(xplot,yplot,2);
    p2 = polyfit([P1(i) Xpp(j)],[P3(i) Ypp(j)],2);
    xu=linspace(xplot(1),xplot(3),100);
    zu=linspace(P1(i),Xpp(j),100);  
    z1=polyval(p, xu);
    z2=polyval(p2, zu);
    tog1 = [xu zu] ; tog2 = [z1 z2];
    h8= plot(xu, z1,'color','k','LineStyle','-','LineWidth',3); hold on
    k = boundary(tog1(:), tog2(:), 0.4);
    h9 = fill(tog1(k),tog2(k),'k','facealpha',.1,'LineStyle','none','DisplayName','Bucket area'); hold on
end
%% boundry plot
k = boundary(Xp(:), Yp(:), 0.9);
h10 = fill(Xp(k),Yp(k),'r','facealpha',.1,'LineStyle','none','DisplayName','Loader Work Area');
xlabel('Bucket X coordinate [m]')
ylabel('Bucket Y coordinate [m]')

lgnd = legend([h1,h4,h6(1),h7,h9,h10]);
set(lgnd,'color','w');
set(lgnd, 'Box', 'on');
axis square
grid minor


%% Inverse
eps_d = 1;
eps_h = 0.02;
height = 0.1;

% prompt = 'Enter requested angle [ Deg ] ';
% angle = input(prompt);
angle = 25;

[rowd , cold ] = find(abs(delta_deg - angle) < eps_d);
% plot(Xp(rowd,cold),Yp(rowd,cold),'m*')
[rowh , colh ] = find(abs(Yp - height) < eps_h);
% plot(Xp(rowh,colh),Yp(rowh,colh),'ko')
[row,col] = find( abs(delta_deg - angle) < eps_d & abs(Yp - height) < eps_h );
plot(Xp(row,col),Yp(row,col),'b+')
xp =bsxfun(@plus, x(col).*cos(q(col)) + l2.*cos(b(col)) + dx(col), lp.*cos(delta(row,col)));
yp =bsxfun(@plus, x(col).*sin(q(col)) + l2.*sin(b(col)) - dy(col), lp.*sin(delta(row,col)));
plot(xp,yp,'or')
fprintf('First Motor extention %d .\n',x(row)*100);
fprintf('First Motor extention %d .\n',y(col)*100);

