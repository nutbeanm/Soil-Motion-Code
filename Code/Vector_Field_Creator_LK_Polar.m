function [max_boundary_layer_thickness,mean_boundary_layer_thickness,std_boundary_layer_thickness] = Vector_Field_Creator_LK_Polar(frame_1,frame_2,time_step,image_width_cm,xc,yc,r,soil_background_height,theta_max,theta_min)

% Parameters
search_region_radius = 4; % [pixels]
font_size = 30;

% Creating Region Array of Two Frames
region_array_1 = Region_Creator_2(frame_1,xc,yc,r,soil_background_height);
region_array_2 = Region_Creator_2(frame_2,xc,yc,r,soil_background_height);

% Creating Colour Array to be Used for Creating Plots
frame_1_colour = frame_1;
frame_2_colour = frame_2;

% Finding Information on First Frame
size_array = size(region_array_1);
image_height = size_array(1);
image_width = size_array(2);

% Converting Two Frames to Grayscale
frame_1 = im2gray(frame_1);
frame_2 = im2gray(frame_2);

% Converting Frames to Double Class
frame_1 = double(frame_1);
frame_2 = double(frame_2);

% Making Wheel and Background Pixels Black for Both Frames
soil_isolated_frame_1 = Soil_Isolation(frame_1,region_array_1);
soil_isolated_frame_2 = Soil_Isolation(frame_2,region_array_2);

% Creating Partial Derivatives for Lucas-Kanada Method
integrated_frames = zeros(image_height,image_width,2);
integrated_frames(:,:,1) = soil_isolated_frame_1;
integrated_frames(:,:,2) = soil_isolated_frame_2;
[I_x,I_y,I_t] = gradient(integrated_frames);
I_x_array = I_x(:,:,1)*(image_width/image_width_cm);
I_y_array = I_y(:,:,1)*(image_width/image_width_cm);
I_t_array = I_t(:,:,1)/time_step;

% Loading Weight Matrix
load("W_file_4.mat");

% Determing Soil Velocity Components with Lucas-Kanade Method
current_percent_complete = 0;
disp("Computational Status: " + num2str(current_percent_complete) + "%")
v_x_array = zeros(image_height,image_width);
v_y_array = zeros(image_height,image_width);
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        percent_complete = round((y_pixel/image_height)*100);
        if percent_complete > current_percent_complete
            clc
            disp("Computational Status: " + num2str(percent_complete) + "%")
            current_percent_complete = percent_complete;
        end
        region = region_array_1(y_pixel,x_pixel);
        if region == 'S'
            x_pixel_min = x_pixel - search_region_radius;
            x_pixel_max = x_pixel + search_region_radius;
            y_pixel_min = y_pixel - search_region_radius;
            y_pixel_max = y_pixel + search_region_radius;
            A = [];
            b = [];
            for y_pixel_prime = y_pixel_min:y_pixel_max
                for x_pixel_prime = x_pixel_min:x_pixel_max
                    if (x_pixel_prime >= 1) && (x_pixel_prime <= image_width) ...
                            && (y_pixel_prime >= 1) && (y_pixel_prime <= image_height) && (region == 'S')
                        I_x = I_x_array(y_pixel_prime,x_pixel_prime);
                        I_y = I_y_array(y_pixel_prime,x_pixel_prime);
                        I_t = I_t_array(y_pixel_prime,x_pixel_prime);
                    else
                        I_x = 0;
                        I_y = 0;
                        I_t = 0;
                    end
                    A = [A; I_x I_y];
                    b = [b;-I_t];
                end
            end
            v_array = inv(transpose(A)*A)*transpose(A)*b;
            v_x = v_array(1);
            v_y = v_array(2);
            v_x_array(y_pixel,x_pixel) = v_x;
            v_y_array(y_pixel,x_pixel) = v_y;
        else
            v_x = 0;
            v_y = 0;
            v_x_array(y_pixel,x_pixel) = v_x;
            v_y_array(y_pixel,x_pixel) = v_y;
        end
    end
end

% Making Background and Wheel in Velocity Array NaN
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        percent_complete = round(((image_height + y_pixel)/(2*image_height))*100);
        if percent_complete > current_percent_complete
            clc
            disp("Computational Status: " + num2str(percent_complete) + "%")
            current_percent_complete = percent_complete;
        end
        region = region_array_1(y_pixel,x_pixel);
        if region ~= 'S'
            v_x_array(y_pixel,x_pixel) = NaN;
            v_y_array(y_pixel,x_pixel) = NaN;
        
        elseif y_pixel <= 170 && x_pixel <= 280
            v_x_array(y_pixel,x_pixel) = NaN;
            v_y_array(y_pixel,x_pixel) = NaN;
        
        end
    end
end

% Making Velocity Array
velocity_array = sqrt(v_x_array.^2 + v_y_array.^2);
max_velocity = max(velocity_array,[],"all");
relative_velocity_array = velocity_array/max_velocity;
plot_max_velocity = max_velocity;

% Plotting Surface Plot (cm/s)
[X,Y] = meshgrid(1:image_width,1:image_height);
figure()
surf(X,Y,velocity_array)
xlabel("X Axis [Pixels]")
ylabel("Y Axis [Pixels]")
zlabel("Soil Velocity [cm/s]")
title("Velocity Vector Field (Unaltered)")

% Plotting Surface Plot (Relative)
[X,Y] = meshgrid(1:image_width,1:image_height);
figure()
surf(X,Y,relative_velocity_array)
xlabel("X Axis [Pixels]")
ylabel("Y Axis [Pixels]")
zlabel("Relative Velocity")
title("Velocity Vector Field (Unaltered)")

% Creating Contour Plot for Relative Velocity
figure()
contourf(X,Y,relative_velocity_array)
zlabel("Relative Velocity")
colorbar
set(gca, 'YDir','reverse')
title("Contour Plot of Relative Speed","FontSize",font_size)
set(gca, 'YDir','reverse')
set(gca,'XTick',[], 'YTick', [])

% Creating Relative Velocity Arrays for Boundary Layer Error
relative_velocity_array_upper_bound = relative_velocity_array;
relative_velocity_array_lower_bound = relative_velocity_array;
cutoff_ratio_upper = 0.2;
cutoff_ratio_lower = 0.4;
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        relative_velocity = relative_velocity_array(y_pixel,x_pixel);
        if (relative_velocity < cutoff_ratio_upper)
            relative_velocity_array_upper_bound(y_pixel,x_pixel) = NaN;
        end
        if (relative_velocity < cutoff_ratio_lower)
            relative_velocity_array_lower_bound(y_pixel,x_pixel) = NaN;
        end
    end
end

% Converting Slow Velocity to NaN
cutoff_ratio = 0.3;
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        relative_velocity = relative_velocity_array(y_pixel,x_pixel);
        if relative_velocity < cutoff_ratio
            relative_velocity_array(y_pixel,x_pixel) = NaN;
        end
    end
end
relative_velocity_array_reference = relative_velocity_array;

% Adjusting Velocity Array
relative_velocity_array = (relative_velocity_array - cutoff_ratio)*(1/(1-cutoff_ratio));

% Smoothing and Adjusting Velocity Array
window_average_size = 5;
relative_velocity_array = smoothdata2(relative_velocity_array,"movmean",window_average_size);
max_velocity = max(relative_velocity_array,[],"all");
relative_velocity_array = relative_velocity_array/max_velocity;

% Plotting Velocity Vector Field
load("Red_Spectrum_Velocity.mat");
load("Green_Spectrum_Velocity.mat");
load("Blue_Spectrum_Velocity.mat")
velocity_graphic_frame = zeros(image_height,image_width,3);
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        percent_complete = round(((y_pixel+image_height)/(3*image_height))*100);
        if percent_complete > current_percent_complete
            clc
            disp("Computational Status: " + num2str(percent_complete) + "%")
            current_percent_complete = percent_complete;
        end
        region = region_array_1(y_pixel,x_pixel);
        if region == 'B' || region == 'W'
            red = frame_1_colour(y_pixel,x_pixel,1);
            green = frame_1_colour(y_pixel,x_pixel,2);
            blue = frame_1_colour(y_pixel,x_pixel,3);
        else
            relative_velocity = relative_velocity_array(y_pixel,x_pixel);
            if isnan(relative_velocity)
                red = 0;
                green = 0;
                blue = 255;
            else
                [red,green,blue] = Velocity_Colour(relative_velocity,red_smooth_array,green_smooth_array,blue_smooth_array);
            end
        end
        velocity_graphic_frame(y_pixel,x_pixel,1) = uint8(red);
        velocity_graphic_frame(y_pixel,x_pixel,2) = uint8(green);
        velocity_graphic_frame(y_pixel,x_pixel,3) = uint8(blue);
    end
end
velocity_graphic_frame = uint8(velocity_graphic_frame);
decimal_place = 2;
max_velocity = round(plot_max_velocity,decimal_place);
figure()
image(velocity_graphic_frame)
%xlabel("X Axis [Pixels]")
%ylabel("Y Axis [Pixels]")
title("Velocity Vector Field (Maximum Velocity: " + num2str(max_velocity) + " cm/s)",'FontSize',font_size)
set(gca,'XTick',[], 'YTick', [])
axis equal

% Making Direction Array
direction_array = zeros(image_height,image_width);
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        relative_velocity = relative_velocity_array_reference(y_pixel,x_pixel);
        if ~isnan(relative_velocity)
            v_x = v_x_array(y_pixel,x_pixel);
            v_y = -v_y_array(y_pixel,x_pixel);
            direction = atan2d(v_y,v_x);
            % Correcting Angle Produced by atan2d
            if direction < 0
                direction = direction + 360;
            end
            direction_array(y_pixel,x_pixel) = direction;
        else
            direction_array(y_pixel,x_pixel) = NaN;
        end
    end
end
direction_array_1 = direction_array;

% Converting Direction Array to Polar
theta_array = zeros(image_height,image_width);
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        direction = direction_array(y_pixel,x_pixel);
        if ~isnan(direction)
            delta_y = y_pixel - yc;
            delta_x = x_pixel - xc;
            theta = -(90 - atan2d(delta_y,delta_x));
            direction_array(y_pixel,x_pixel) = direction + theta;
            theta_array(y_pixel,x_pixel) = theta;
        end
    end
end
direction_array_2 = direction_array;

% Smoothing Direction Array
direction_array = smoothdata2(direction_array,"movmean",window_average_size);

% Plotting Direction Array
load("Red_Spectrum_Direction.mat");
load("Green_Spectrum_Direction.mat");
load("Blue_Spectrum_Direction.mat")
direction_graphic_frame = zeros(image_height,image_width,3);
for y_pixel = 1:image_height
    for x_pixel = 1:image_width
        region = region_array_1(y_pixel,x_pixel);
        if region == 'B' || region == 'W'
            red = frame_1_colour(y_pixel,x_pixel,1);
            green = frame_1_colour(y_pixel,x_pixel,2);
            blue = frame_1_colour(y_pixel,x_pixel,3);
        else
            direction = direction_array(y_pixel,x_pixel);
            if isnan(direction)
                red = 0;
                green = 0;
                blue = 255;
            else
                [red,green,blue] = Direction_Colour(direction,red_array,green_array,blue_array);
            end
        end
        direction_graphic_frame(y_pixel,x_pixel,1) = uint8(red);
        direction_graphic_frame(y_pixel,x_pixel,2) = uint8(green);
        direction_graphic_frame(y_pixel,x_pixel,3) = uint8(blue);
    end
end
direction_graphic_frame = uint8(direction_graphic_frame);
figure()
image(direction_graphic_frame)
%xlabel("X Axis [Pixels]")
%ylabel("Y Axis [Pixels]")
title("Direction Vector Field","FontSize",font_size)
set(gca,'XTick',[], 'YTick', [])
axis equal

% Making Boundary Layer Plot
max_pixel_radius = image_width;
x_pixel_array = 1:image_width;
y_pixel_array = 1:image_height;
[angle_array_1,boundary_layer_array] = Boundary_Layer_Plot_Creator(relative_velocity_array,max_pixel_radius,x_pixel_array,y_pixel_array,xc,yc,r,image_width,image_width_cm);
figure()
line_width = 3;
line_style = ' -k';
plot(angle_array_1,boundary_layer_array,line_style,'LineWidth',line_width)
xlabel("Angle [Degrees]")
ylabel("Boundary Layer Thickness [cm]")
title("Radial Boundary Layer Profile")
max_boundary_layer_thickness = max(boundary_layer_array);
avg_boundary_layer_thickness_1 = mean(boundary_layer_array);
boundary_layer_array_1 = boundary_layer_array;

% Making Boundary Layer Plot for Upper Bound
[angle_array_2,boundary_layer_array] = Boundary_Layer_Plot_Creator(relative_velocity_array_upper_bound,max_pixel_radius,x_pixel_array,y_pixel_array,xc,yc,r,image_width,image_width_cm);
boundary_layer_array_2 = boundary_layer_array;

% Making Boundary Layer Plot for Lower Bound
[angle_array_3,boundary_layer_array] = Boundary_Layer_Plot_Creator(relative_velocity_array_lower_bound,max_pixel_radius,x_pixel_array,y_pixel_array,xc,yc,r,image_width,image_width_cm);
boundary_layer_array_3 = boundary_layer_array;

% Determining Average Boundary Layer with Allowable Angle Range
boundary_layer_array_main = [];
boundary_layer_array_upper = [];
boundary_layer_array_lower = [];
for i = 1:length(angle_array_1)
    angle = angle_array_1(i);
    if (angle >= theta_min) && (angle <= theta_max)
        boundary_layer = boundary_layer_array_1(i);
        boundary_layer_array_main = [boundary_layer_array_main,boundary_layer];
    end
end
for i = 1:length(angle_array_2)
    angle = angle_array_2(i);
    if (angle >= theta_min) && (angle <= theta_max)
        boundary_layer = boundary_layer_array_2(i);
        boundary_layer_array_upper = [boundary_layer_array_upper,boundary_layer];
    end
end
for i = 1:length(angle_array_3)
    angle = angle_array_3(i);
    if (angle >= theta_min) && (angle <= theta_max)
        boundary_layer = boundary_layer_array_3(i);
        boundary_layer_array_lower = [boundary_layer_array_lower,boundary_layer];
    end
end
avg_boundary_layer_thickness_main = mean(boundary_layer_array_main);
avg_boundary_layer_thickness_upper = mean(boundary_layer_array_upper);
avg_boundary_layer_thickness_lower = mean(boundary_layer_array_lower);
boundary_layers_array = [avg_boundary_layer_thickness_main,avg_boundary_layer_thickness_upper,avg_boundary_layer_thickness_lower];
mean_boundary_layer_thickness = mean(boundary_layers_array);
std_boundary_layer_thickness = std(boundary_layers_array);