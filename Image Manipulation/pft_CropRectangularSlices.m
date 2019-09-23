function [ OK, Base, Rows, Cols ] = pft_CropRectangularSlices

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Begin browsing from the Desktop
if ispc
  Username = getenv('Username');
  Home = fullfile('C:', 'Users', Username, 'Desktop');
elseif isunix 
  [ Status, CmdOut ] = system('whoami');
  Home = fullfile('home', CmdOut, 'Desktop');
elseif ismac
  [ Status, CmdOut ] = system('whoami');
  Home = fullfile('Users', CmdOut, 'Desktop');
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Prompt for an RGB source image
[ FileName, PathName, FilterIndex ] = uigetfile(fullfile(Home, '*.tif'), 'Select the original pink histology montage');

% Exit with an error condition if no file is chosen
if (FilterIndex == 0)
  h = msgbox('No file chosen', 'Exit', 'modal');
  uiwait(h);
  delete(h);
  OK = false;
  return;
end

% Read in the RGB source montage and convert it to grayscale
Source = fullfile(PathName, FileName);

Pink = imread(Source);
Gray = rgb2gray(Pink);

% Create a sub-folder to hold the individual image slices (further grouped by rows) - use the montage filename sans extension
[ P, N, E ] = fileparts(Source);

mkdir(PathName, N);

Base = fullfile(PathName, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show the grayscale image and ask the user to state the number of rows and columns
hf = figure('Name', 'Grayscale image', 'MenuBar', 'none', 'NumberTitle', 'off');
imshow(Gray, [0, 255]);

[ Rows, Cols ] = pft_GetRowsAndColumns;

% Create some new sub-folders within the recently created "Base" folder
for r = 1:Rows
  if (r == 1)
    mkdir(Base, 'Row 1 - Top');
  elseif (r == Rows)
    mkdir(Base, sprintf('Row %1d - Bottom', r));
  else
    mkdir(Base, sprintf('Row %1d', r));
  end
end

% Prompt the user to crop the source montage into rectangles
h = msgbox('Select cropping rectangles', 'Processing decision', 'modal');
uiwait(h);
delete(h);

[ NR, NC ] = size(Gray);

WD = round(NC/Cols);
HT = round(NR/Rows);

wd = WD - 32;
ht = HT - 32;

for r = 1:Rows
  for c = 1:Cols
    x0 = 16 + (c - 1)*WD;
    y0 = 16 + (r - 1)*HT;
    
    StartRect = [ x0, y0, wd, ht ];
    hr = imrect(gca, StartRect);
    FinalRect = wait(hr);
    
    wd = FinalRect(3);
    ht = FinalRect(4);
    
    BW = createMask(hr);
    
    X = imcrop(Gray, FinalRect);
    
    if (r == 1)
      F = fullfile(Base, 'Row 1 - Top', sprintf('Original-Image-Slice-%02d-ED.png', c));
      G = fullfile(Base, 'Row 1 - Top', sprintf('Rectangle-%02d.txt', c));
    elseif (r == Rows)
      F = fullfile(Base, sprintf('Row %1d - Bottom', r), sprintf('Original-Image-Slice-%02d-ED.png', c));
      G = fullfile(Base, sprintf('Row %1d - Bottom', r), sprintf('Rectangle-%02d.txt', c));
    else
      F = fullfile(Base, sprintf('Row %1d', r), sprintf('Original-Image-Slice-%02d-ED.png', c));
      G = fullfile(Base, sprintf('Row %1d', r), sprintf('Rectangle-%02d.txt', c));
    end
  
    imwrite(X, F);
  
    Gray(BW) = 255;
    
    imshow(Gray, [0, 255]);
    
    delete(hr);
    
    clearvars hr
    
    FID = fopen(G, 'wt');
    fprintf(FID, '%.2f\n', FinalRect);
    fclose(FID);    
  end
end

pause(1.0);

delete(hf);

clearvars hf
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Signal success and exit
OK = true;

end