function [ EdgeDetectedImage, Threshold ] = pft_CreateEdgeDetectedImage(BW)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Padding units
DX = 24;
DY = 24;

% We need 2 sets of image axes
NROWS = 768; 
NCOLS = 768;

WD = NCOLS;
HT = NROWS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Position the main figure in the centre of the screen
Full = get(0, 'ScreenSize');

Area = zeros([1, 4], 'double');

Area(3) = 2*WD + 3*DX;
Area(4) =   HT + 13*DY;
Area(1) = Full(3)/2 - Area(3)/2;
Area(2) = Full(4)/2 - Area(4)/2;

hf = figure('Name', 'Processing Decision: Set A Common Edge-Detection Threshold', 'MenuBar', 'none', 'NumberTitle', 'off', 'Renderer', 'OpenGL', 'Position', Area);

set(hf, 'CloseRequestFcn', @my_closefcn);  % Trap the close button
set(hf, 'KeyPressFcn', @my_keypressfcn);   % Trap a RETURN or an ESCAPE from the keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Position 2 axes objects on the canvas
Here = zeros([1, 4], 'double');

Here(1) = DX;
Here(2) = Area(4) - DY - HT;
Here(3) = WD;
Here(4) = HT;

hBWAxes = axes('Parent', hf, 'Units', 'Pixels', 'Position', Here);
imshow(BW, [], 'Parent', hBWAxes);

text(32, 32, 'De-speckled binarized image', 'Color', [1 0 0], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hBWAxes);

Here = Here + [ DX + WD, 0, 0, 0 ];

Threshold = 0.45;

EdgeDetectedImage = edge(BW, 'sobel', Threshold);

hEdgeDetectedImageAxes = axes('Parent', hf, 'Units', 'Pixels', 'Position', Here);
imshow(EdgeDetectedImage, [], 'Parent', hEdgeDetectedImageAxes);

text(32, 32, 'Edge-detected image', 'Color', [1 0 0], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hEdgeDetectedImageAxes);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  
% Position the slider and text label to control the Threshold of the display
Here = zeros([1, 4], 'double');

Here(1) = DX;
Here(2) = DY;
Here(3) = DX + 2*WD;
Here(4) = 2*DY;

hThresholdSlider = uicontrol('Parent', hf, 'Style', 'Slider', 'Value', Threshold, 'Min', 0.0, 'Max', 1.0, 'SliderStep', [0.01, 0.05], ...
                             'Position', Here, 'Callback', @threshold_slider_callback);            
                         
hThresholdSliderListener = addlistener(hThresholdSlider, 'ContinuousValueChange', @threshold_slider_listener_callback);

Here = Here + [ 0, 2*DY, 0, 0 ];

hThresholdSliderText = uicontrol('Parent', hf, 'Style', 'Text', 'Position', Here, 'String', ...
                                  sprintf('Edge-Detection Threshold: %.2f', Threshold), 'FontSize', 20, 'FontWeight', 'bold');        
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
     
% Now create an APPLY button
Here = zeros([1, 4], 'double');

Here(1) = DX;
Here(2) = 7*DY;
Here(3) = DX + 2*WD;
Here(4) = 4*DY;

hApplyButton = uicontrol('Parent', hf, 'Style', 'Pushbutton', 'Position', Here, 'String', 'Apply and Exit', ...
                         'FontSize', 32, 'FontWeight', 'bold', 'Callback', @pushbutton_callback);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now initialize the display and block user interaction from the command line while the figure continues to exist (as a 'modal' object)
uiwait(hf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % The normal APPLY AND QUIT function
    function pushbutton_callback(hObj, eventdata)
        pause(0.25);
        
        delete(hf);
    end

    % A nested closing function
    function my_closefcn(hObj, eventdata) 
        pause(0.25);
        
        delete(hf);
    end

    % A nested function to catch a keypress
    function my_keypressfcn(hObj, eventdata)
        currChar = get(hf, 'CurrentKey');
        
        if (isequal(currChar, 'return') || isequal(currChar, 'escape'))   
            pause(0.25);
            
            delete(hf);
        end
    end

    % Handle the Threshold slider
    function threshold_slider_callback(hObj, eventdata)
      Threshold = 0.01*round(get(hObj, 'Value')/0.01);
      
      set(hThresholdSliderText, 'String', sprintf('Threshold: %.2f', Threshold));
      
      EdgeDetectedImage = edge(BW, 'sobel', Threshold);
      
      imshow(EdgeDetectedImage, [], 'Parent', hEdgeDetectedImageAxes);
      
      text(32, 32, 'Edge-detected image', 'Color', [1 0 0], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hEdgeDetectedImageAxes);      
    end

    % Handle the Threshold slider continuously
    function threshold_slider_listener_callback(hObj, eventdata)
      Threshold = 0.01*round(get(hObj, 'Value')/0.01);
      
      set(hThresholdSliderText, 'String', sprintf('Threshold: %.2f', Threshold));
      
      EdgeDetectedImage = edge(BW, 'sobel', Threshold);
      
      imshow(EdgeDetectedImage, [], 'Parent', hEdgeDetectedImageAxes);
      
      text(32, 32, 'Edge-detected image', 'Color', [1 0 0], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hEdgeDetectedImageAxes);  
    end
end

