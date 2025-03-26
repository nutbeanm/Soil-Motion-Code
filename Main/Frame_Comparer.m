%{

Function Purpose:

To plot the two frames which the vectors fields are created with, to gauge 
the difference between the two frames. To compare them easily, on the plot 
window select view, then plot browser.This will allow you to quickly switch
between the two images.

Input:
    - The frame numbers for both frames.
Output:
    - Plots for the two frames.

%}

function Frame_Comparer(frame_1,frame_2)

% Creating Figure for First Frame
%figure('Name','First Frame','NumberTitle','off','Renderer','Painters')
figure()
image(frame_1)
title("First Frame")
axis equal

% Creating Figure for Second Frame
%figure('Name','Second Frame','NumberTitle','off','Renderer','Painters')
figure()
image(frame_2)
title("Second Frame")
axis equal

end