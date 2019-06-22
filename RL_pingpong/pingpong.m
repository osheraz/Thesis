function pingpong % main func. set the parameters, screen and draw the basic. open qlearning func.
% osher azulay & lihi kalakuda 
close all;clc
%% update the state each 0.1 sec
global Vx Vy w Step score h D r Position RobotPosition V phi FieldState Velocity Vxstart Vystart X0 Y0 in_kick count kicks
D=0;
kicks=0;
count=0;
in_kick = 0;
Vxstart=2;Vystart=2*rand;
Vx=Vxstart;Vy=Vystart;
w=300 ;Step=1 ;score=0;D=1;
r=2;
V=sqrt(Vx^2+Vy^2);
Position=[30,30];
RobotPosition=[35,35];
phi=0;
FieldState=[0 0 0 0 0];
Velocity=0;
X0 = 140;
Y0 = randperm(90,1);
s=get(0,'screensize');
h.f=figure('menubar','figure','numbertitle','on','name','p pi pin ping pong meuman','position',[s(3)/2-300,s(4)/2-300,w,w]); %figure init
h.a=axes('xlim',[-10 147],'ylim',[0 90]); % set axes;
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
grid on;
h.p=patch([0 5 5 0],[40 40 50 50],[1 0 0 ]);  % drawing padde
h.b=patch(X0+r*sin([0:.01:1]*2*pi),Y0+r*cos([0:.01:1]*2*pi),[0 0 1]); % drawing ball
patch([5 15],[15 5],[0 1 0]);% set field 
patch([5 15],[15 15],[0 1 0]);
patch([5 15],[15 25],[0 1 0]);
patch([5 15],[45 35],[0 1 0]);
patch([5 15],[45 45],[0 1 0]);
patch([5 15],[45 55],[0 1 0]);
patch([5 15],[75 65],[0 1 0]);
patch([5 15],[75 75],[0 1 0]);
patch([5 15],[75 85],[0 1 0]);
set(gca,'Xtick',0:24.5:147)
qlearning
%--------------------------------------------------------------------------
function DoAction(action) % this func get the next action the robot need to do and change the positions accordingly. open game func.  
global D in_kick h score
score=score-10;
if (action==4) % kick forward
    in_kick=1;
    for i=1:10
     if D 
         break
     end
     set(h.p,'xdata',get(h.p,'xdata')+1);
    Game()
    end
    for i=1:10
      if D 
         break
     end
     set(h.p,'xdata',get(h.p,'xdata')-1);
     Game()
    end
    in_kick=0;
end
if (action==6) % kick down
    in_kick=1;
    for i=1:10
     if D 
         break
     end
        set(h.p,'xdata',get(h.p,'xdata')+1);
        set(h.p,'ydata',get(h.p,'ydata')+1);
        Game()
    end
    for i=1:10
      if D 
         break
     end
     set(h.p,'xdata',get(h.p,'xdata')-1);
     set(h.p,'ydata',get(h.p,'ydata')-1);
     Game()
    end 
    in_kick=0;
end
if (action==5) % kick up
    in_kick=1;
    for i=1:10
      if D 
         break
     end
     set(h.p,'xdata',get(h.p,'xdata')+1);
     set(h.p,'ydata',get(h.p,'ydata')-1);
     Game()
    end
    for i=1:10
      if D 
         break
     end
     set(h.p,'xdata',get(h.p,'xdata')-1);
     set(h.p,'ydata',get(h.p,'ydata')+1);
     Game()
    end 
    in_kick=0;
end
if (action==2) % move paddle down
    if(get(h.p,'ydata') < 60 )
        for i=1:10
          if D 
             break
         end
        if ~in_kick
           set(h.p,'ydata',get(h.p,'ydata')+3);
           Game();
        end
        end
    end
end
if (action==1) % move paddle up
    if(get(h.p,'ydata') >30)
        for i=1:10
         if D 
            break
         end
        if ~in_kick
           set(h.p,'ydata',get(h.p,'ydata')-3);       
           Game()
        end
        end
    end
end
if (action==3) % do nothing
        if ~in_kick
           set(h.p,'ydata',get(h.p,'ydata'));
           Game();
        end
        score=score+10;
end
%-------------------------------------------------------------------------- 
function getVelocity()% normelize the velocity and the angle of the ball
    global Vx Vy V phi Velocity
    Vtemp=sqrt(Vx^2+Vy^2);
    teta=atan2(Vy,Vx)*180/pi;
    if (teta >0 && teta <=45)
         phi=0;
    elseif (teta >45 && teta <=90)
        phi=1;
    elseif (teta >90 && teta <=135)
        phi=2; 
    elseif (teta >135 && teta <=180)
        phi=3 ;       
    elseif (teta <0 && teta >=-45)
        phi=7;
    elseif (teta <-45 && teta >=-90)
        phi=6;
    elseif (teta <-90 && teta >=-135)
        phi=5;
    else 
        phi=4 ;
    end
    if (Vtemp >0 && Vtemp <=2)
       V=0;
    elseif (Vtemp >2 && Vtemp <=4)
        V=1;
    elseif (Vtemp >4 && Vtemp <=6)
        V=2;
     else 
        V=3; 
     end
    Velocity=[V,phi];
%-------------------------------------------------------------------------- 
function getRobotPos()% calc the position of the robot
    global RobotPosition h
    Rx=unique(get(h.p,'xdata'));Rx=Rx([1,end]); % Rx - Paddle x pos
    Ry=unique(get(h.p,'ydata'));Ry=Ry([1,end]); % Ry - Paddle y pos
    f=floor(sum(Ry)/2);
    switch f
        case 15
            RobotPosition=0;
        case 45
            RobotPosition=1;
        otherwise
            RobotPosition=2;
    end       
%-------------------------------------------------------------------------- 
function getBallPos()% calc the position of the ball
    global Position h
    Bx=unique(get(h.b,'xdata'));Bx=Bx([1,end]); % Bx - ball x pos
    By=unique(get(h.b,'ydata'));By=By([1,end]); % By - ball y pos%  Step is equivelent for the power
    Position=floor([((6/147)*(sum(Bx)/2)),((9/90)*(sum(By)/2))]);
    if Position(2) <= 0
        Position(2)=0;
    end
    if Position(2) >= 9
        Position(2)=8;
    end
%--------------------------------------------------------------------------
function Restart() % restart the game to start new episode.
    global h Vx Vy Vxstart Vystart r X0 Y0 D count kicks
    Vxstart=2;Vystart=2*rand;
    Vx=Vxstart;
    Vy=Vystart;
    Y0 = randperm(90,1) ; 
    if ~D
    count=count+1;
    end
    set(h.b,'xdata',X0+r*sin([0:.01:1]*2*pi)); % update Vx of ball
    set(h.b,'ydata',Y0+r*cos([0:.01:1]*2*pi)); % update vY OF THE BALL
    set(h.p,'ydata',[40 40 50 50]); % update Paddle direction
    set(h.p,'xdata',[0 5 5 0]);
    D=1;
    kicks=0;
%--------------------------------------------------------------------------
function Game(varargin) % calc the rewards and the screen limits and update the screen. 
    %If the robot fail, start the func restart.
global Vx Vy Step score h D r Position FieldState RobotPosition Velocity kicks
D=0;
Bx=unique(get(h.b,'xdata'));Bx=Bx([1,end]); % Bx - ball x pos
By=unique(get(h.b,'ydata'));By=By([1,end]); % By - ball y pos
Rx=unique(get(h.p,'xdata'));Rx=Rx([1,end]); % Rx - Paddle x pos
Ry=unique(get(h.p,'ydata'));Ry=Ry([1,end]); % Ry - Paddle y pos

if By(1)<=r  % if hit the lower side , go up
    Vy=abs(Vy);
elseif By(2)>=90-r % if hit the upper side , go down
    Vy=-abs(Vy);
end
if Bx(1)<= 0 % if hit the left wall
    Vx=abs(Vx);
elseif Bx(2)>=147-r % if hit the left wall
    Vx=-abs(Vx);
end

if (Bx(1)-Rx(2)<=1 && By(2)>=Ry(1) && By(1)<=Ry(2) && By(1)+r >Ry(1) && By(2)- r <Ry(2)) % Case hit!
    Vx=abs(Vx);
    Vy=Vy+Step;
    score=score+300;
    kicks=kicks+1;
end

if (Bx(2) <= Rx(2) || Bx(1)<5) % Case fail
    score=score-1000;
    Restart()
end

set(h.b,'xdata',get(h.b,'xdata')+Vx); % update Vx of ball
set(h.b,'ydata',get(h.b,'ydata')+Vy); % update VY OF THE BALL
set(h.p,'ydata',get(h.p,'ydata')); % update Paddle direction
    getBallPos()
    getRobotPos()
    getVelocity()
    FieldState=[Position,Velocity,RobotPosition];  
 %drawnow;
%--------------------------------------------------------------------------
 function qlearning % this func get the field status, the ball position, robot position, 
     %ball velocity, open func DoAction and updating Q matrix and file.
global h FieldState Position Velocity RobotPosition score count kicks
Bx=unique(get(h.b,'xdata'));Bx=Bx([1,end]); % Bx - ball x pos
By=unique(get(h.b,'ydata'));By=By([1,end]); % By - ball y pos
Rx=unique(get(h.p,'xdata'));Rx=Rx([1,end]); % Rx - Paddle x pos
Ry=unique(get(h.p,'ydata'));Ry=Ry([1,end]); % Ry - Paddle y pos
% learning parameters
gamma = 0.9;    % discount factor  
alpha = 0.2;    % learning rate    
epsilon =0.92;  % exploration probability (1-epsilon = exploit / epsilon = explore)
% states
all_state = fliplr(combvec(0:2,0:7,0:3,0:8,0:5)');
getBallPos()
getRobotPos()
getVelocity()
FieldState=[Position,Velocity,RobotPosition];
% actions
action = [1,2,3,4,5,6]; %set action array
actionName={'Move Up','Move Down', 'None', 'Kick Up', 'Kick Center', 'Kick Down'};
DoAction(action(3));
% initial Q matrix
% State [ 0:5 , 0:8 , 0:3 , 0:7 , 0:2]
if exist('P100.csv', 'file')~=0
    Q = csvread('P100.csv') ; 
else
    Q = zeros(length(all_state),length(action));
end
K = 100000;        % maximum number of frames 
current_state_inx =(find(ismember(all_state,FieldState,'rows')));  % the initial state to begin from
%% the main loop of the algorithm
for k = 1:K 
    getBallPos()
    getRobotPos()
    getVelocity()
    FieldState=[Position,Velocity,RobotPosition];
    St=FieldState;  % Get the current state 
    current_state_inx =(find(ismember(all_state,St,'rows')));  % id of the current state    
    r=rand; % get 1 uniform random number
    x=sum(r>=cumsum([0, 1-epsilon, epsilon])); % check it to be in which probability area  
    if RobotPosition==0
        %%  availible action = [2,3,4,5,6];
        % choose either explore or exploit
        if x == 1   % exploit
        [~,umax]=max(Q(current_state_inx,2:6));
        current_action = action(umax+1);
        else                                                               % explore NEED TO ADD THAT IN THE BOT/TOP NOT POSSIBLE TO MOVE DOWN/UP
        current_action=datasample(action(2:6),1);                          % choose 1 action randomly (uniform random distribution)
        end    
   elseif RobotPosition==2
       %%  availible action = [1,3,4,5,6];
        if x == 1   % exploit
        [~,umax]=max(Q(current_state_inx,[1 3:6]));
        if umax~=1
            umax=umax+1
        end
        current_action = action(umax);
        else                                                              % explore NEED TO ADD THAT IN THE BOT/TOP NOT POSSIBLE TO MOVE DOWN/UP
        current_action=datasample(action([1 3:6]),1);                            % choose 1 action randomly (uniform random distribution)
        end
    else
    % case in the middle , everything is possible
    % choose either explore or exploit
       if x == 1   % exploit
        [~,umax]=max(Q(current_state_inx,:));
        current_action = action(umax);
        else                                                              % explore NEED TO ADD THAT IN THE BOT/TOP NOT POSSIBLE TO MOVE DOWN/UP
        current_action=datasample(action,1);                              % choose 1 action randomly (uniform random distribution)
        end
    end
  
  
    DoAction(current_action)                                          % doing action && update FieldState to St+1

    action_idx= find(action==current_action);                         % id of the chosen action 
                    % UPDATE State to State_time_plus_1
    next_state_idx=(find(ismember(all_state,FieldState,'rows')));      % id of the next state                                                 
    % print the results in each iteration
    KICK(k)=kicks;
    kicks=0;
    disp(['Episode: ' num2str(count)  '   k index: '   num2str(k)  ]);
    disp(['current state : ' num2str(St) '    next state : ' num2str(FieldState) '      action index : ' num2str(action(action_idx))' '  taken action : ' actionName{action_idx}]);
    disp(['reward : ' num2str(score)]);
    
    % update the Q matrix using the Q-learning rule
    Q(current_state_inx,action_idx) = Q(current_state_inx,action_idx) + alpha * (score + gamma* max(Q(next_state_idx,:)) - Q(current_state_inx,action_idx));
    score=0;
    action = [1,2,3,4,5,6]; 
    disp(['Q(current_State) : ' num2str(Q(current_state_inx,:))]);  % display Q in each level
    disp('------------------------------------------------------------------------------------');
end
% display the final Q matrix
filename = 'P100.csv';
csvwrite(filename,Q);
disp(sum(KICK));





