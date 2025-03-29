function new_frame = Black_Pixel_Remover(frame,num_black_pixels_remove)

% Determining Frame Information
size_array = size(frame);
frame_height = size_array(1);
frame_width = size_array(2);

% Creating New Frame
new_frame_height = frame_height - 2*num_black_pixels_remove;
new_frame_width = frame_width;
new_frame = zeros(new_frame_height,new_frame_width,3);

% Filling New Frame
for y_pixel = 1:frame_height
    for x_pixel = 1:frame_width
        if (y_pixel > num_black_pixels_remove) && (y_pixel < (frame_height-num_black_pixels_remove+1))
            red = frame(y_pixel,x_pixel,1);
            green = frame(y_pixel,x_pixel,2);
            blue = frame(y_pixel,x_pixel,3);
            new_y_pixel = y_pixel - num_black_pixels_remove;
            new_frame(new_y_pixel,x_pixel,1) = red;
            new_frame(new_y_pixel,x_pixel,2) = green;
            new_frame(new_y_pixel,x_pixel,3) = blue;
        end
    end
end

% Converting Colour Information to Correct Type
new_frame = uint8(new_frame);



