%{

Function Purpose:

To determine the appropriate colour of a pixel given it's angle of 
direction, which will be used to create the direction portion of the 
created vector fields.

Input:
    - Angle in degrees (ideally between 0 and 360, but can correct for
    values given from atan2d).
    - Angle array, which should match the variable new_angle_array in the
    program Colour_Wheel_Creator.
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

function [red,green,blue] = Direction_Colour(angle,red_array,green_array,blue_array)

% Parameters
angle_array = 0:1:359;

% Loading Data
%{
load("Red_Spectrum_Direction.mat");
load("Green_Spectrum_Direction.mat");
load("Blue_Spectrum_Direction.mat");
%}

% Rounding Angle such that the Colour may be Indexed in the Arrays
angle = round(angle);

% Correcting Angle Produced by atan2d
if angle < 0
    angle = angle + 360;
end

% Finding Index
index = find(angle_array == angle);

% Creating Position Array
red = red_array(index);
green = green_array(index);
blue = blue_array(index);

end