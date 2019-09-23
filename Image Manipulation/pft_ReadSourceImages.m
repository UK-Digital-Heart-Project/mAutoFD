function [ OriginalStack, BinarizedStack, BinaryMask, PerimeterStack, PEDIStack, Conditions ] = pft_ReadSourceImages(Folder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:   Folder              - Self-explanatory.                                                                                          %
%                                                                                                                                            %
% Outputs:  OriginalStack       - Excised from a montage using a rectangular crop.                                                           %
%           BinarizedStack      - Binarized according to a manually set threshold.                                                           %
%           BinaryMask          - A stack of areas covering the blood pool and extending beyond it into the myocardium.                      %
%           PerimeterStack      - A stack of boundaries to act as a starting point for the FD calculation.                                   %
%           PEDIStack           - A stack of pre-edge-detected images (within a polygonal ROI).                                              %
%           Conditions          - An array of error conditions, initialised to all 'OK' for this one-off code branch.                        %
%                                                                                                                                            %
% PFT - 06. 09. 2019.                                                                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the images, labelled as slices - they will be different in size, so they will need to be zero-filled

Listing = dir(fullfile(Folder, 'Original-Image-Slice-*.png'));
Entries = { Listing.name };
Folders = [ Listing.isdir ];
Entries = Entries(~Folders);
Entries = sort(Entries);
Entries = Entries';

NSLICES = length(Entries);

Rows = zeros([NSLICES, 1], 'int32');
Cols = zeros([NSLICES, 1], 'int32');

for s = 1:NSLICES
  File = sprintf('Original-Image-Slice-%02d-ED.png', s);
  Path = fullfile(Folder, File);
  Temp = imread(Path);
  [ Rows(s), Cols(s) ] = size(Temp);
end

NROWS = max(Rows);
NCOLS = max(Cols);

OriginalStack  = zeros([NROWS, NCOLS, NSLICES], 'uint8');
BinarizedStack = zeros([NROWS, NCOLS, NSLICES], 'uint8');
BinaryMask     = zeros([NROWS, NCOLS, NSLICES], 'uint8');
PerimeterStack = zeros([NROWS, NCOLS, NSLICES], 'uint8');
PEDIStack      = zeros([NROWS, NCOLS, NSLICES], 'uint8');

BinarizedStack(:) = 255;    % White, not black

for s = 1:NSLICES
  File = sprintf('Original-Image-Slice-%02d-ED.png', s);
  Path = fullfile(Folder, File);
  Temp = imread(Path);
  OriginalStack(1:Rows(s), 1:Cols(s), s) = Temp;  
        
  File = sprintf('Binarized-Image-Slice-%02d-ED.png', s);
  Path = fullfile(Folder, File);
  Temp = imread(Path);
  BinarizedStack(1:Rows(s), 1:Cols(s), s) = Temp;
  
  File = sprintf('Original-Mask-Slice-%02d-ED.png', s);
  Path = fullfile(Folder, File);
  Temp = imread(Path);
  BinaryMask(1:Rows(s), 1:Cols(s), s) = Temp;
  
  PerimeterStack(1:Rows(s), 1:Cols(s), s) = bwperim(Temp, 8);
  
  File = sprintf('Pre-Edge-Detected-Image-Slice-%02d-ED.png', s);
  Path = fullfile(Folder, File);
  Temp = imread(Path);
  PEDIStack(1:Rows(s), 1:Cols(s), s) = Temp; 
end

BinaryMask     = logical(BinaryMask);
PerimeterStack = logical(PerimeterStack);  

Conditions = repmat({ 'OK' }, [20, 1]);

end







