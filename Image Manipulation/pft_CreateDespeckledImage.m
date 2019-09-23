function [ DespeckledPEDI, Threshold ] = pft_CreateDespeckledImage(PEDI)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some initial - possibly lengthy - preparation
PEDI = logical(PEDI);

wb = waitbar(0, 'Preparing GUI - please wait ... ');

RPS = regionprops(PEDI, 'PixelIdxList');

Areas = arrayfun(@(s) numel(s.PixelIdxList), RPS);

waitbar(1, wb, 'Done ! ');

pause(0.25);

delete(wb);

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

Dort = zeros([1, 4], 'double');

Dort(3) = 2*WD + 3*DX;
Dort(4) =   HT + 13*DY;
Dort(1) = Full(3)/2 - Dort(3)/2;
Dort(2) = Full(4)/2 - Dort(4)/2;

hf = figure('Name', 'Processing Decision: Set A Common Area Threshold', 'MenuBar', 'none', 'NumberTitle', 'off', 'Renderer', 'OpenGL', 'Position', Dort);

set(hf, 'CloseRequestFcn', @my_closefcn);  % Trap the close button
set(hf, 'KeyPressFcn', @my_keypressfcn);   % Trap a RETURN or an ESCAPE from the keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Position 2 axes objects on the canvas
Here = zeros([1, 4], 'double');

Here(1) = DX;
Here(2) = Dort(4) - DY - HT;
Here(3) = WD;
Here(4) = HT;

hPEDIAxes = axes('Parent', hf, 'Units', 'Pixels', 'Position', Here);
imshow(PEDI, [0, 1], 'Parent', hPEDIAxes);

text(32, 32, 'Pre-edge-detected image', 'Color', [0 1 1], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hPEDIAxes);

Here = Here + [ DX + WD, 0, 0, 0 ];

Threshold = 116;

DespeckledPEDI = PEDI;
      
Small = find(Areas < Threshold);
      
if ~isempty(Small)         
  NROIS = length(Small);
        
  for n = 1:NROIS
    DespeckledPEDI(RPS(Small(n)).PixelIdxList) = 0;
  end
end

hDespeckledImageAxes = axes('Parent', hf, 'Units', 'Pixels', 'Position', Here);
imshow(DespeckledPEDI, [0, 1], 'Parent', hDespeckledImageAxes);

text(32, 32, 'De-speckled image', 'Color', [0 1 1], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hDespeckledImageAxes);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  
% Position the slider and text label to control the Threshold of the display
Here = zeros([1, 4], 'double');

Here(1) = DX;
Here(2) = DY;
Here(3) = DX + 2*WD;
Here(4) = 2*DY;

hThresholdSlider = uicontrol('Parent', hf, 'Style', 'Slider', 'Value', Threshold, 'Min', 0, 'Max', 256, 'SliderStep', [1.0, 8.0]/256.0, ...
                             'Position', Here, 'Callback', @threshold_slider_callback);            
                         
hThresholdSliderListener = addlistener(hThresholdSlider, 'ContinuousValueChange', @threshold_slider_listener_callback);

Here = Here + [ 0, 2*DY, 0, 0 ];

hThresholdSliderText = uicontrol('Parent', hf, 'Style', 'Text', 'Position', Here, 'String', ...
                                  sprintf('Area Threshold: %1d', Threshold), 'FontSize', 20, 'FontWeight', 'bold');        
               
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
      Threshold = round(get(hObj, 'Value'));
      
      set(hThresholdSliderText, 'String', sprintf('Area Threshold: %1d', Threshold));
      
      DespeckledPEDI = PEDI;
      
      Small = find(Areas < Threshold);
      
      if ~isempty(Small)         
        NROIS = length(Small);
        
        for n = 1:NROIS
          DespeckledPEDI(RPS(Small(n)).PixelIdxList) = 0;
        end
      end
      
      imshow(DespeckledPEDI, [0, 1], 'Parent', hDespeckledImageAxes);
      
      text(32, 32, 'De-speckled image', 'Color', [0 1 1], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hDespeckledImageAxes);      
    end

    % Handle the Threshold slider continuously
    function threshold_slider_listener_callback(hObj, eventdata)
      Threshold = round(get(hObj, 'Value'));
      
      set(hThresholdSliderText, 'String', sprintf('Area Threshold: %1d', Threshold));
      
      DespeckledPEDI = PEDI;
      
      Small = find(Areas < Threshold);
      
      if ~isempty(Small)         
        NROIS = length(Small);
        
        for n = 1:NROIS
          DespeckledPEDI(RPS(Small(n)).PixelIdxList) = 0;
        end
      end
      
      imshow(DespeckledPEDI, [0, 1], 'Parent', hDespeckledImageAxes);
      
      text(32, 32, 'De-speckled image', 'Color', [0 1 1], 'FontSize', 16, 'FontWeight', 'bold', 'Parent', hDespeckledImageAxes);      
    end
end

