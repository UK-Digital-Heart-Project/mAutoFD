function pft_CreateRoiCroppedImage(Base, SubFolder, Slice, NPLNS)

% Set a tight border
iptsetpref('ImshowBorder', 'tight');

% Read in the binarized image from the location specified in the parameter list
Path = fullfile(Base, SubFolder, sprintf('Binarized-Image-Slice-%02d-ED.png', Slice));

BinarizedImage = imread(Path);

% Show the binarized image with annotations and prompt for input
hf = figure('Name', 'Create a cropping ROI', 'MenuBar', 'none', 'NumberTitle', 'off');
ha = axes(hf);

imshow(BinarizedImage, []);

Captions = cell([1, 4]);

p = strfind(Base, filesep);
q = p(end);
r = q + 1;

Leaf = Base(r:end);

Captions{1} = Leaf;                                         % Main data folder
Captions{2} = SubFolder;                                    % Denoting the row in the montage
Captions{3} = sprintf('Slice %1d of %1d', Slice, NPLNS);    % Slice
Captions{4} = 'Double-click to create ROI ... ';            % Prompt

FS = 12;
DX = 18;
DY = 32;

for n = 1:4
  text(DX, n*DY, Captions{n}, 'Color', [0 0 1], 'FontSize', FS, 'FontWeight', 'bold', 'Interpreter', 'none');  
end

% Fetch the image dimensions and initialise an elliptical polygon for the user to modify
[ NR, NC ] = size(BinarizedImage);

NPTS = 20;

Theta = (2.0*pi/double(NPTS))*double(0:NPTS-1)';

px = (NC + 1)/2.0 + (NC/4.0)*cos(Theta);
py = (NR + 1)/2.0 + (NR/4.0)*sin(Theta);

Position = horzcat(px, py);

hi = impoly(ha, Position);

setColor(hi, [1 1 0]);

wait(hi);

Mask = createMask(hi);

% Create the cropped image from the input binarized image and the newly created mask
CroppedImage = zeros(size(BinarizedImage), class(BinarizedImage));

CroppedImage(Mask) = BinarizedImage(Mask);

delete(hi);
delete(ha);
delete(hf);

clearvars hr ha hf

% Write the outputs to the SOURCE image folder
Path = fullfile(Base, SubFolder, sprintf('Pre-Edge-Detected-Image-Slice-%02d-ED.png', Slice));
imwrite(CroppedImage, Path);

Path = fullfile(Base, SubFolder, sprintf('Original-Mask-Slice-%02d-ED.png', Slice));
imwrite(Mask, Path);

end

