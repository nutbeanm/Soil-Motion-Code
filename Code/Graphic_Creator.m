%{

Function Purpose:

To display the three regions of a frame.

Input:
    - A region array created from a video frame array.
Output:
    - An image, which represents each region with a respective colour.

%}

function Graphic_Creator(region_array)

% Determining Frame Size
frame_size_array = size(region_array);
y_size = frame_size_array(1); % [pixels]
x_size = frame_size_array(2); % [pixels]

% Creating Empty Graphics Array
graphic_array = zeros(y_size,x_size,3);

% Filling Graphic Array
for y_pixel = 1:y_size
    for x_pixel = 1:x_size
        region = region_array(y_pixel,x_pixel);
        if region == 'B'
            graphic_array(y_pixel,x_pixel,1) = 0;
            graphic_array(y_pixel,x_pixel,2) = 255;
            graphic_array(y_pixel,x_pixel,3) = 0;
        elseif region == 'W'
            graphic_array(y_pixel,x_pixel,1) = 255;
            graphic_array(y_pixel,x_pixel,2) = 0;
            graphic_array(y_pixel,x_pixel,3) = 0;
        elseif region == 'S' 
            graphic_array(y_pixel,x_pixel,1) = 0;
            graphic_array(y_pixel,x_pixel,2) = 0;
            graphic_array(y_pixel,x_pixel,3) = 255;
        end
    end
end

% Displaying Image
image(graphic_array)
%{
xlabel("X Axis [Pixels]")
ylabel("Y Axis [Pixels]")
title("Video Regions")
%}
axis equal

end