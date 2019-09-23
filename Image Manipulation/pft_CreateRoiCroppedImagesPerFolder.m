function pft_CreateRoiCroppedImagesPerFolder(Root, SubFolder)

% Count the images
Listing = dir(fullfile(Root, SubFolder, 'Binarized-Image-Slice-*.png'));
Entries = { Listing.name };
Folders = [ Listing.isdir ];
Entries = Entries(~Folders);
Entries = sort(Entries);
Entries = Entries';

NSLICES = length(Entries);

% Crop all the slices in the given sub-folder
for n = 1:NSLICES
  pft_CreateRoiCroppedImage(Root, SubFolder, n, NSLICES);
end

end
