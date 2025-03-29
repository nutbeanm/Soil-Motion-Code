function [angle_array,boundary_layer_array] = Boundary_Layer_Plot_Creator(relative_velocity_array,max_pixel_radius,x_pixel_array,y_pixel_array,xc,yc,r,image_width,image_width_cm)

angle_array = [];
boundary_layer_array = [];

for angle = 0:180
    trigger = false;
    for radius = 0:max_pixel_radius
        x_pixel = round(xc + radius*cosd(angle));
        y_pixel = round(yc + radius*sind(angle));
        if any(x_pixel_array == x_pixel) && any(y_pixel_array == y_pixel)
            relative_velocity = relative_velocity_array(y_pixel,x_pixel);
            if ~isnan(relative_velocity) && ~trigger
                trigger = true;
                x_pixel_start = x_pixel;
                y_pixel_start = y_pixel;
            elseif isnan(relative_velocity) && trigger
                trigger = false;
                x_pixel_end = previous_x_pixel;
                y_pixel_end = previous_y_pixel;
                boundary_layer_thickness = sqrt((x_pixel_end-xc)^2 + (y_pixel_end-yc)^2) - r;
                boundary_layer_thickness_cm = boundary_layer_thickness*(image_width_cm/image_width);
                boundary_layer_array = [boundary_layer_array,boundary_layer_thickness_cm];
                reference_angle = -(angle - 90);
                angle_array = [angle_array,reference_angle];
            end
        end
        previous_x_pixel = x_pixel;
        previous_y_pixel = y_pixel;
    end
end


