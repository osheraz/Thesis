%% 305277071 Lihi Kalakuda & 203099247 Osher Azulay
%x1=centerx;y1=centery;
clearvars -except x1 y1
clc

vid=VideoReader('MOV01A.wmv');                                 %To read the video into the matlab.
nframes = get(vid,'NumberOfFrames');                           %Get the number of frames
rate=get(vid,'FrameRate');                                     %Get the rate
%%
for i=1:1:nframes                                              %Loop over the frames
    frame= read(vid,i);                                        %reading the frame no. i
    img=imsubtract(frame(:,:,1),rgb2gray(frame));              %Get red component of the image
    img=medfilt2(img ,[3,3]);                                  %Apllying Median Filter, filltering the noise
    img=im2bw(img,0.25);                                       %converts grayscale image to binary image , luminance > 0.25 =1 , else 0.
    bw=bwlabel(img,8);                                         %Label connected components in 2-D binary image
    props=regionprops(bw,'BoundingBox','Centroid');            %Calculate centroids,BoundingBox for connected components in the image
    figure(1)
    imshow(frame)                                              %Displaying the frame
    hold on
    xv=[ 34 45 665 680 34];                                    %get the table cordinates for later use
    yv=[ 500 61 46 494 500];
    if ~isempty(props)
        for j=1:length(props)
            % bb=props(j).BoundingBox;                        %get boundingbox rectangle
            bcx(j)=props(j).Centroid(1);                      %get x cordinate of the centroid
            bcy(j)=props(j).Centroid(2);                      %get y cordinate of the centroid
        end
        in=inpolygon(bcx, bcy, xv, yv);                       %check whether the point inside the table
        bcx=bcx(in);
        bcy=bcy(in);
        bcx=bcx( find(abs(bcx(1:end)-mean(bcx))<150));        %remove distant centroids by checking the mean of found centroid in frame i
        bcy=bcy( find(abs(bcy(1:end)-mean(bcy))<150));
        bc(1)=mean(bcx);                                      %in case where there is more then 1 centroid ,get the mean
        bc(2)=mean(bcy);
        centerx(i) = (bc(1));                                 %save centroid path
        centery(i) = (bc(2));
        % rectangle('Position',bb,'EdgeColor','w','LineWidth',1)
        plot(xv,yv,'LineWidth',2)
        plot(bc(1),bc(2),'-w+','LineWidth',2)                 % plot centroid on the frame , marked as X
        pause(0.0001);
        bcx=0;
        bcy=0;
        hold off
    end
end
hold on                                                      %Plot Path
vx=diff(centerx(2:2:end)).*0.5*rate / 720;                         %Compute Vx by Vx=(X(i)-X(i-1))/dt , first order dervative                 
vy=diff(centery(2:2:end)).*0.5*rate / 576;                         %Compute Vy by Vy=(Y(i)-Y(i-1))/dt , first order dervative 
V= (vx.^2+vy.^2).^(1/2);        
plot(centerx(2:end),centery(2:end),'r')
figure(2)                                                    %Display velocity over time

plot((1/rate)*(1:length(V)),V,'-');grid minor                %Smooths the data in the column vector y using a moving average filter
hold on
plot((1/rate)*(1:length(V)),smooth(V),'r--*')
plot((1/rate)*(1:length(V)),smooth(smooth(V)),'g*')
xlabel('Time[sec]')
ylabel('Velocity[m/s]')
legend('Velocity without smooth','Velocity with 1Xsmooth','Velocity with 2Xsmooth')
title('Velocity over time evaluation')

%% for error eval ---

plot(x1,y1,'*')                                             % x1,y1 all the center's that found

for z=1:size(x1,2)
    for f=1:size(x1,1)
    if x1(f,z)
        Ex(f,z)=x1(f,z)-centerx(f);
        Ey(f,z)=y1(f,z)-centery(f);
        E(f,z)=(Ex(f,z).^2+Ey(f,z).^2).^(1/2);
    end
    end
end



