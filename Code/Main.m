% Clearing Workspace
clear
clc
close all

% Parameters
%frame_number_1 = 6450; % [Unitless]
%frame_number_2 = 6455; % [Unitless]
FPS = 30; % [Frames/s]
video_name = "Test Campaign 5 - 1.25cm Slip.MOV"; % [Unitless]
experiment_info_name = "Experiment_Campaign_5_Information.csv";
mode = 3; % [Unitless]
num_black_pixels_remove = 4; % [pixels]
%image_width_cm = 19.7; % [cm]
comp_time_decimal_place = 2;
boundary_layer_decimal_place = 2;

% Getting Information for Experiment
data_table = readtable(experiment_info_name);
experiment = 2;
information = data_table(:,(experiment+1));
information = table2array(information);
P1x = information(2);
P1y = information(3);
P2x = information(4);
P2y = information(5);
P3x = information(6);
P3y = information(7);
PAx = information(8);
PAy = information(9);
PBx = information(10);
PBy = information(11);
soil_background_height = information(12);
frame_number_1 = information(13);
frame_number_2 = information(14);
image_width_cm = information(15);
P1 = [P1x,P1y];
P2 = [P2x,P2y];
P3 = [P3x,P3y];
PA = [PAx,PAy];
PB = [PBx,PBy];

% Intermediate Calculations
frame_difference = frame_number_2 - frame_number_1;
time_step = frame_difference/FPS;

% Extracting Video Frames
video_object = VideoReader(video_name);
try
    frame_1 = read(video_object,frame_number_1);
    frame_2 = read(video_object,frame_number_2);
catch
    warning("That frame doesn't exist for this video!")
    return
end

% Removing Black Pixels on the Top and Bottom of an Image
frame_1 = Black_Pixel_Remover(frame_1,num_black_pixels_remove);
frame_2 = Black_Pixel_Remover(frame_2,num_black_pixels_remove);

% Compressing Image
compression_factor = 0.4;
frame_1 = imresize(frame_1,compression_factor);
frame_2 = imresize(frame_2,compression_factor);

% Determining Center of Wheel
[xc,yc,r] = Wheel_Center(P1,P2,P3);

% Determining Maximum and Minimum Angle for Measuring Boundary Layer
x1 = PA(1);
y1 = PA(2);
x2 = PB(1);
y2 = PB(2);
theta_max = 90 - atan2d((y1-yc),(x1-xc));
theta_min = 90 - atan2d((y2-yc),(x2-xc));

% Running Program Based on Mode
if mode == 1
    Frame_Comparer(frame_1,frame_2)
elseif mode == 2
    Graphic_Creator_2(frame_1,frame_2,xc,yc,r,soil_background_height)
elseif mode == 3
    tic;
    [max_boundary_layer_thickness,mean_boundary_layer_thickness,std_boundary_layer_thickness] = Vector_Field_Creator_LK_Polar(frame_1,frame_2,time_step,image_width_cm,xc,yc,r,soil_background_height,theta_max,theta_min);
    computational_time = toc;
    computational_time = round(computational_time,comp_time_decimal_place);
    disp("Computational Time: " + num2str(computational_time) + "s")
    disp(" ")
    max_boundary_layer_thickness = round(max_boundary_layer_thickness,boundary_layer_decimal_place);
    mean_boundary_layer_thickness = round(mean_boundary_layer_thickness,boundary_layer_decimal_place);
    std_boundary_layer_thickness = round(std_boundary_layer_thickness,boundary_layer_decimal_place);
    disp("Maximum Boundary Layer Thickness: " + num2str(max_boundary_layer_thickness) + " cm")
    disp("Average Boundary Layer Thickness: " + num2str(mean_boundary_layer_thickness) + " cm")
    disp("Standard Deviation of Boundary Layer Thickness: " + num2str(std_boundary_layer_thickness) + " cm")
    disp(" ")
    disp("Maximum Allowable Measurement Angle: " + num2str(theta_max) + " Degrees")
    disp("Minimum Allowable Measurement Angle: " + num2str(theta_min) + " Degrees")
else
    disp("That mode doesn't exist!")
end