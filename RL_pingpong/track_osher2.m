%%
clear all;
clc

vid=VideoReader('MOV01A.wmv');        %To read the video into the matlab.
nframes = get(vid,'NumberOfFrames'); 
rate=get(vid,'FrameRate');
%%
for i=1:nframes
    frame= read(vid,i);                             %reading the frame no. i
    img=imsubtract(frame(:,:,1),rgb2gray(frame));   %Get red component of the image
    img=medfilt2(img ,[3,3]);                       %Apllying Median Filter, filltering the noise
    img=im2bw(img,0.25);                            % Convert the image into binary image with the red objects as white
    bw=bwlabel(img,8);
    props=regionprops(bw,'BoundingBox','Centroid'); %Calculate centroids,BoundingBox for connected components in the image 
    figure(1)
    imshow(frame)                                   %Displaying the frame
    hold on                
    for j=1:length(props)
        %bb=props(j).BoundingBox;                    % get boundingbox rectangle
        bc=props(j).Centroid;                       % get centroid
        centerx(i,j) = (bc(1)); 
        centery(i,j) = (bc(2));                  % Convert the centroids into Integer for further steps
        %rectangle('Position',bb,'EdgeColor','w','LineWidth',1)
        %plot(bc(1),bc(2),'-w+')  
        pause(0.00001)
    end
    hold off
end
hold on


