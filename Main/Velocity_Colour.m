%{

Function Purpose:

To determine the appropriate colour of a pixel given it's relative speed,
which will be used to create the velocity portion of the created vector
fields.

Input:
    - Relative speed (between 0 and 1)
    - Velocity colour spectrum data:
        - Blue_Spectrum_Velocity.mat
        - Green_Spectrum_Velocity.mat
        - Red_Spectrum_Velocity.mat
Output:
    - The three colour components between 0 and 255:
        - Red
        - Green
        - Blue

%}

function [red,green,blue] = Velocity_Colour(relative_speed,red_smooth_array,green_smooth_array,blue_smooth_array)

% Loading Data
%{
load("Red_Spectrum_Velocity.mat");
load("Green_Spectrum_Velocity.mat");
load("Blue_Spectrum_Velocity.mat");
%}

% Creating Position Array
len = length(red_smooth_array);
position_array = 1:len;

% Converting Relative Speed to Position
position = 1 + (len - 1)*relative_speed;
position = round(position);

% Determining Colour Components
%{
red = interp1(position_array,red_smooth_array,position);
green = interp1(position_array,green_smooth_array,position);
blue = interp1(position_array,blue_smooth_array,position);
%}
red = red_smooth_array(position);
green = green_smooth_array(position);
blue = blue_smooth_array(position);

% Converting to Integer Type
red = uint8(red);
green = uint8(green);
blue = uint8(blue);

end
