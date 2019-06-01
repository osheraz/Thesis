
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
l4=0.08;
l1=0.285;
r=0.237;
l3=0.046;
l2=0.293;
lp=0.206;
l33 = 0.398;

%%%%%%%%%%%% Arm mech %%%%%%%%%%%%
q=asind((x.^2+h^2-l1^2)./(2.*x.*h));
a=asind(-h+x.*sin(q))./(l1);
b_ = asind((h.*sind(90-q))/(l1)) - 12.6;
b = b_ + 36.35;
%%%%%%%%%%%% Bucket mech %%%%%%%%%%%%
phi=acosd((y.^2 - r.^2 - l3.^2)./(-2.*r.*l3));
gama = 180 - phi - 45.79 - 47;
[QB,G] = meshgrid(q - b , gama);
delta = QB + G;
%%%%% Bucket Tip location %%%%%%%%%%%
p1 = x.*cosd(q) + l33.*cosd(q-b);
p2 = lp.*cosd(delta);
p3 = x.*sind(q) + l33.*sind(q-b);
p4 = lp.*sind(delta);
Xp = bsxfun(@plus, p1, p2);
Yp = bsxfun(@plus, p3, p4);


%% Plots 
% t1x,z1x,z1y for arm plot
f = 12.6 + b_;
t1x = x.*cosd(q) + l2.*cosd(q-f); 
z1x = 0.*t1x;                     
z1y = h.*ones(1,length(t1x));
t1y = x.*sind(q) + l2.*sind(q-f); 
color = [0.7 0.7 0.7];

for i=1:8:length(t1x)  
    h1 = plot([z1x(i) t1x(i)],[z1y(i) t1y(i)],'color',color,'LineStyle','-','LineWidth',7,'DisplayName','Arm Link');hold on
    h2 = plot(t1x(i),t1y(i),'o','color',color,'MarkerFaceColor',color,'MarkerEdgeColor','None');
    h3 = plot([t1x(i) p1(i)],[t1y(i) p3(i)],'color',color,'LineStyle','-','LineWidth',7);hold on
    h4 = plot(p1(i),p3(i),'bo','MarkerFaceColor','b','DisplayName','Joint');hold on
    h5 = plot(z1x(i),z1y(i),'bo','MarkerFaceColor','b'); hold on
end
h6 = plot(Xp,Yp,'o','color',[0.6350 0.0780 0.1840],'MarkerSize',1,'DisplayName','bucket x,y tip');

% Bucket plot
p22 = l4.*cosd(delta + 45.79);
p44 = l4.*sind(delta + 45.79);
Xpp = bsxfun(@plus, p1, p22);
Ypp = bsxfun(@plus, p3, p44);

for i= 1:8:length(t1x)
    j =i*length(t1x)+30;
    %plot([p1(i) Xp(j)],[p3(i) Yp(j)],'color','k','LineStyle','-','LineWidth',2);hold on
    h7 = plot([p1(i) Xpp(j)],[p3(i) Ypp(j)],'color','k','LineStyle','-','LineWidth',3,'DisplayName','Bucket Link');hold on
    xplot=[p1(i),(p1(i)+Xp(j))/2-0.01, Xp(j)]; yplot = [p3(i),(p3(i)+Yp(j))/2-0.02, Yp(j)];
    p = polyfit(xplot,yplot,2);
    p2 = polyfit([p1(i) Xpp(j)],[p3(i) Ypp(j)],2);
    xu=linspace(xplot(1),xplot(3),100);
    zu=linspace(p1(i),Xpp(j),100);
    z1=polyval(p, xu);
    z2=polyval(p2, zu);
    tog1 = [xu zu] ; tog2 = [z1 z2];
    h8= plot(xu, z1,'color','k','LineStyle','-','LineWidth',3); hold on
    k = boundary(tog1(:), tog2(:), 0.4);
    h9 = fill(tog1(k),tog2(k),'k','facealpha',.1,'LineStyle','none','DisplayName','Bucket area'); hold on
end

k = boundary(Xp(:), Yp(:), 0.8);
h10 = fill(Xp(k),Yp(k),'r','facealpha',.1,'LineStyle','none','DisplayName','Loader Work Area'); % boundry of pointcloud
xlabel('Bucket X coordinate [m]');
ylabel('Bucket Y coordinate [m]');
lgnd = legend([h1,h4,h6(1),h7,h9,h10]);
set(lgnd,'color','w');
set(lgnd, 'Box', 'on');
axis square
grid minor
hold on

%% Inverse via
eps_d = 5;
eps_h = 0.01;
height = +0.1;
delta_ = delta  + 20 ;
angle = 20;
y_ = 0.197;
x_ = 0.246;
prompt = 'Enter requested angle [ Deg ] ';
angle = input(prompt);
prompt = 'Enter requested height [ Deg ] ';
height = input(prompt);

IND_D = find(abs(delta_ - angle) < eps_d);
% plot(Xp(IND_D),Yp(IND_D),'m*');hold on
IND_H = find(abs(Yp - height) < eps_h);
% plot(Xp(IND_H),Yp(IND_H),'ko')

ind = IND_H(ismember(IND_H,IND_D));
[row,col] = ind2sub(size(Yp),ind);
plot(Xp(ind),Yp(ind),'b+','MarkerSize',30); hold on
% check correction of x,y
xp =bsxfun(@plus, x(col).*cosd(q(col)) + l33.*cosd(q(col) - b(col)), lp.*cosd(delta(ind))');
yp =bsxfun(@plus, x(col).*sind(q(col)) + l33.*sind(q(col) - b(col)), lp.*sind(delta(ind))');
plot(xp,yp,'or');hold on

x_mm = (x(col) - x_).*1000;
y_mm = (y(row) - y_).*1000;
x_cmd = x_mm.*(1023/101);
y_cmd = y_mm.*(1023/150);

fprintf('Angle	%.2f +- %.2f	[deg]\n',angle ,eps_d);
fprintf('Height	%.2f +- %.2f	[mm]\n',height.*1000 ,eps_h);
fprintf('Arm Motor extention	%.2f    [mm]    [%.2f - cmd]	\n',x_mm,x_cmd);
fprintf('Bucket Motor extention	%.2f    [mm]	[%.2f - cmd]	\n',y_mm,y_cmd);

% get one of them
row= row(1);
col = col(1);
ind = ind(1);

%%%%% Arm Plot of requested angle & height
plot([z1x(col) t1x(col)],[z1y(col) t1y(col)],'color','g','LineStyle','-','LineWidth',7,'DisplayName','Arm Link');hold on
plot(t1x(col),t1y(col),'o','color',color,'MarkerFaceColor','g','MarkerEdgeColor','None');
plot([t1x(col) p1(col)],[t1y(col) p3(col)],'color','g','LineStyle','-','LineWidth',7);hold on
plot(p1(col),p3(col),'bo','MarkerFaceColor','b','DisplayName','Joint');hold on
plot(z1x(col),z1y(col),'bo','MarkerFaceColor','b'); hold on
plot([p1(col) Xpp(ind)],[p3(col) Ypp(ind)],'color','r','LineStyle','-','LineWidth',3,'DisplayName','Bucket Link');hold on
% plot([p1(col) Xp(ind)'],[p3(col) Yp(ind)],'color','k','LineStyle','-','LineWidth',2);hold on
xplot=[p1(col),(p1(col)+Xp(ind))/2-0.01, Xp(ind)]; yplot = [p3(col),(p3(col)+Yp(ind))/2-0.02, Yp(ind)];
p = polyfit(xplot,yplot,2);
xu=linspace(xplot(1),xplot(3),100);
z1=polyval(p, xu);
tog1 = [xu zu];
h8= plot(xu, z1,'color','r','LineStyle','-','LineWidth',3); hold on


