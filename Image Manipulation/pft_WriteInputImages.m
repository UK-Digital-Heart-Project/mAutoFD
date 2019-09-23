function pft_WriteInputImages(CroppedOriginalImage, CroppedBinarizedImage, BinaryMask, Perimeter, PEDI, Slice, OutputFolder)

% Output the available i/p images straightaway
a = double(CroppedBinarizedImage);
b = double(BinaryMask);
d = double(Perimeter);
e = double(PEDI);

f = double(CroppedOriginalImage);

a = uint8(255.0*normalize01(a));
b = uint8(255.0*normalize01(b));
d = uint8(255.0*normalize01(abs(d)));
e = uint8(255.0*normalize01(e));

f = uint8(255.0*normalize01(f));

% Output the cropped original image
FileName = sprintf('Cropped-Original-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(f, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end

% Output the cropped binarized image
FileName = sprintf('Cropped-Binarized-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(a, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

% Output the binary mask
FileName = sprintf('Cropped-Binary-Mask-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(b, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

% Show where the outer perimeter was drawn (within the image plane)
FileName = sprintf('Cropped-Perimeter-On-Binarized-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(imadd(a, d), PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

% Also the perimeter
FileName = sprintf('Cropped-Perimeter-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(d, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

% And the cropped pre-edge-detected image
FileName = sprintf('Cropped-Pre-Edge-Detected-Image-Slice-%02d-ED.png', Slice);
PathName = fullfile(OutputFolder, FileName);
FileWritten = false;
while (FileWritten == false)
  imwrite(e, PathName);
  pause(0.05);
  if (exist(PathName, 'file') == 2)
    FileWritten = true;
  end
end 

end

