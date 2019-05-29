
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
%%%%% Bucket Tip location %%%%%%%%%%%
p1 = x.*cosd(q) + l33.*cosd(q-b);
p2 = lp.*cosd(q-b+gama);
p3 = x.*sind(q) + l33.*sind(q-b);
p4 = lp.*sind(q-b+gama);
[P1,P2] = meshgrid(p1,p2);
[P3,P4] = meshgrid(p3,p4);

Xp= P1+P2;
Yp= P3 + P4;

%% Plots
f = 12.6 + b_;              
t1x = x.*cosd(q) + l2.*cosd(q-f); % for arm plot
z1x = 0.*t1x; % for arm plot
z1y = h.*ones(1,length(t1x));
t1y = x.*sind(q) + l2.*sind(q-f) % for arm plot
color = [0.7 0.7 0.7];

for i=1:8:length(t1x)  % arm plot
   h1 = plot([z1x(i) t1x(i)],[z1y(i) t1y(i)],'color',color,'LineStyle','-','LineWidth',7,'DisplayName','Arm Link');hold on
   h2 = plot(t1x(i),t1y(i),'o','color',color,'MarkerFaceColor',color,'MarkerEdgeColor','None');
   h3 = plot([t1x(i) p1(i)],[t1y(i) p3(i)],'color',color,'LineStyle','-','LineWidth',7);hold on
   h4 = plot(p1(i),p3(i),'bo','MarkerFaceColor','b','DisplayName','Joint');hold on
   h5 = plot(z1x(i),z1y(i),'bo','MarkerFaceColor','b'); hold on
end
h6 = plot(Xp,Yp,'o','color',[0.6350 0.0780 0.1840],'MarkerSize',1,'DisplayName','bucket x,y tip');

% for ploting bucket
p22 = l4.*cosd(q-b+gama + 45.79);
p44 = l4.*sind(q-b+gama + 45.79);
[P11,P22] = meshgrid(p1,p22);
[P33,P44] = meshgrid(p3,p44);

Xpp= P11+P22;
Ypp= P33+P44;

for i= 1:8:length(t1x)
    j =i*length(t1x)+30;
%     plot([p1(i) Xp(j)],[p3(i) Yp(j)],'color','k','LineStyle','-','LineWidth',2);hold on
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

