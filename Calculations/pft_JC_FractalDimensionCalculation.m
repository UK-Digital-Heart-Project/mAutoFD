function FD = pft_JC_FractalDimensionCalculation(CroppedOriginalImage, BinaryMask, PEDI, CAT, EDT, Slice, OutputFolder)

% Create the de-speckled pre-edge-detected image using the common area threshold
PEDI = logical(PEDI);

DespeckledPEDI = PEDI;

RPS = regionprops(DespeckledPEDI, 'PixelIdxList');

Areas = arrayfun(@(s) numel(s.PixelIdxList), RPS);

Small = find(Areas < CAT);

if ~isempty(Small)
  NROIS = length(Small);  
    
  for n = 1:NROIS
    DespeckledPEDI(RPS(Small(n)).PixelIdxList) = 0;   
  end
end    

% Create the edge-detected image locally (within the bounding box common to the other inputs) using the common edge-detection threshold
EdgeImage = edge(255*uint8(DespeckledPEDI), 'sobel', EDT);

% Box-counting with FD computation
FD = pft_JC_bxct(EdgeImage, Slice, OutputFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These o/p images will be created and written upon successful completion of the FD calculation.                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now output some more images
a = double(CroppedOriginalImage);
a = uint8(255.0*normalize01(a));

e = double(EdgeImage);
e = uint8(255.0*normalize01(abs(e)));

t = a;
t(~BinaryMask) = 0;

h = double(PEDI);
h = uint8(255.0*normalize01(h));

d = double(DespeckledPEDI);
d = uint8(255.0*normalize01(d));

% Write out the "threshold" image here ("h" is for "Threshold", and "t" is already used in JC's notation)
FileName = sprintf('Cropped-Pre-Edge-Detected-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(h, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end  

% Now the de-speckled version
FileName = sprintf('Despeckled-Cropped-Pre-Edge-Detected-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(d, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end

% Also the edge image
FileName = sprintf('Cropped-Edge-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(e, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end  

% This image is coloured RGB (with yellow edges)
FileName = sprintf('Edge-On-Cropped-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  e = double(EdgeImage);                 % Convert to doubles before convolution
  e = conv2(e, ones(2, 2)/4.0, 'same');  % Widen the edge for visibility
  Tol = 0.1;                             % Set a threshold for sharpening/binarizing the edges
  Highlight = (e > Tol);                 % Create an edge mask
  R = t;                                 % Begin composing the fused RGB image - first, the red channel
  G = t;                                 % Now the green channel
  B = t;                                 % And the blue
  R(Highlight) = 255;                    % Mark the edge sharply
  G(Highlight) = 0;                      % Suppress the green component
  B(Highlight) = 0;                      % Also the blue
  Composite = cat(3, R, G, B);           % Assemble an RGB image
  imwrite(Composite, PathName);          % Write the "fused" image
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

end

