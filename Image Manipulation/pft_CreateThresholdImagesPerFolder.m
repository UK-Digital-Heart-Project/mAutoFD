function [ OtsuLevels, EM ] = pft_CreateThresholdImagesPerFolder(Root, SubFolder)

% Count the images
Listing = dir(fullfile(Root, SubFolder, 'Original-Image-Slice-*.png'));
Entries = { Listing.name };
Folders = [ Listing.isdir ];
Entries = Entries(~Folders);
Entries = sort(Entries);
Entries = Entries';

NSLICES = length(Entries);

OtsuLevels = NaN(1, 20);
EM         = NaN(1, 20);

% Create the binarized images and provide the user with some feedback
wb = waitbar(0, 'Creating binarized images');

for n = 1:NSLICES
  Path = fullfile(Root, SubFolder, sprintf('Original-Image-Slice-%02d-ED.png', n));
  Gray = imread(Path);
  
  [ OtsuLevels(n), EM(n) ] = graythresh(Gray);
  BW = imbinarize(Gray, OtsuLevels(n));
      
  Path = fullfile(Root, SubFolder, sprintf('Binarized-Image-Slice-%02d-ED.png', n));
  imwrite(BW, Path);
  
  waitbar(double(n)/double(NSLICES), wb, sprintf('%1d of %1d images created', n, NSLICES));
end

waitbar(1, wb, sprintf('%1d of %1d images created', NSLICES, NSLICES));

pause(1.0);

delete(wb);

clearvars wb

end
