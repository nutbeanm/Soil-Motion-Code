function Graphic_Creator_2(frame_1,frame_2,xc,yc,r,soil_background_height)

% Creating Region Array of Two Frames
region_array_1 = Region_Creator_2(frame_1,xc,yc,r,soil_background_height);
region_array_2 = Region_Creator_2(frame_2,xc,yc,r,soil_background_height);

% Creating Region Plots of Both Frames
figure('Name','First Frame','NumberTitle','off')
Graphic_Creator(region_array_1);
title("First Frame")
figure('Name','Second Frame','NumberTitle','off')
Graphic_Creator(region_array_2);
title("Second Frame")

end