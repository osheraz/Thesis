
r=0.26:0.01:0.38;
q=21:1:30;
[R,Q]=meshgrid(r,q);
F=90./(R.*sin(Q*pi/180));
contourf(R,Q,F,50);
%caxis([0,1])
colorbar
ylim([20 30])
xlim([0.26 0.32 ])
colormap jet
xlabel('R [m]')
ylabel('\theta [deg]')
hold on
plot([0.27 0.27],[22 28],'--w','LineWidth',3) ;hold on
plot([0.30 0.30],[22 28],'--w','LineWidth',3) ;hold on
plot([0.27 0.30],[22 22],'--w','LineWidth',3) ;hold on
plot([0.27 0.30],[28 28],'--w','LineWidth',3) ;hold on
title('Force vs \theta , radius')
% the chosen
figure(2)
f=90./(0.285.*sin(q*pi/180)); 
plot(q,f)

figure(3)
r=0.02:0.001:0.12;
q=30:0.5:80;
[R,Q]=meshgrid(r,q);
F=12./(R.*sin(Q*pi/180));
contourf(R,Q,F,50);
caxis([0,800])
ylim([30 80])
xlim([0.02 0.08 ])
colorbar
colormap jet
xlabel('R [m]')
ylabel('\alpha [deg]')
hold on
plot([0.04 0.04],[34 75],'--w','LineWidth',3) ;hold on
plot([0.07 0.07],[34 75],'--w','LineWidth',3) ;hold on
plot([0.04 0.07],[34 34],'--w','LineWidth',3) ;hold on
plot([0.04 0.07],[75 75],'--w','LineWidth',3) ;hold on

title('Force vs \alpha , radius')