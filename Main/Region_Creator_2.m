function region_array = Region_Creator_2(frame,xc,yc,r,soil_background_height)

% Determining Frame Size
frame_size_array = size(frame);
y_size = frame_size_array(1); % [pixels]
x_size = frame_size_array(2); % [pixels]

% Creating Empty Regions Array
region_array = strings(y_size,x_size);

% Looping Through Array
for y_pixel = 1:y_size
    for x_pixel = 1:x_size
        d = sqrt((x_pixel - xc)^2 + (y_pixel - yc)^2);
        if d <= r
            region_array(y_pixel,x_pixel) = 'W';
        elseif y_pixel < soil_background_height
            region_array(y_pixel,x_pixel) = 'B';
        else
            region_array(y_pixel,x_pixel) = 'S';
        end
    end
end

