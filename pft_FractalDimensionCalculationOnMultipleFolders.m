%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pft_FractalDimensionCalculationOnMultipleFolders                                                                              %
%                                                                                                                               %
% A function to process all the sub-folders within a top-level folder.                                                          %
%                                                                                                                               %
% PFT - 06. 09. 2019.                                                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear the workspace as usual

clear all
close all
clc

fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Locate a batch folder, extract the histology slices, then write them to new sub-folders, one per row - otherwise quit

[ OK, Base, Rows, Cols ] = pft_CropRectangularSlices;

if (OK == false)
  h = pft_MsgBox('No source data selected', 'Exit', 'modal');
  uiwait(h);
  delete(h);
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Locate all the folders beneath

Listing = dir(Base);
Entries = { Listing.name  };
Folders = [ Listing.isdir ];
Entries = Entries(Folders);

SingleDot = strcmp(Entries, '.');
Entries(SingleDot) = [];
DoubleDot = strcmp(Entries, '..');
Entries(DoubleDot) = [];

Results = strcmp(Entries, 'Automated FD Calculation Results');

if ~isempty(Results)
  Entries(Results) = [];
end

Entries = Entries';

if isempty(Entries)
  h = pft_MsgBox('No sub-folders found.', 'Exit', 'modal');
  uiwait(h);
  delete(h);
  return;
end

NDIRS = length(Entries);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create the binarized image slices at the original (not necessarily uniform) cropped size

OtsuLevels = NaN(Rows, 20);
EM         = NaN(Rows, 20);

for n = 1:NDIRS
  [ OtsuThresholds, OtsuEfficiencyMetrics ] = pft_CreateThresholdImagesPerFolder(Base, Entries{n});
  
  OtsuLevels(n, :) = OtsuThresholds;
  EM(n, :)         = OtsuEfficiencyMetrics;  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Crop the binarized images with a polygonal ROI

for n = 1:NDIRS
  pft_CreateRoiCroppedImagesPerFolder(Base, Entries{n});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Extract a common area threshold from a cropped version of the first ROI-constrained PEDI for later on-the-fly de-speckling 
Path = fullfile(Base, Entries{1}, 'Pre-Edge-Detected-Image-Slice-01-ED.png');
PEDI = imread(Path);

Path = fullfile(Base, Entries{1}, 'Original-Mask-Slice-01-ED.png');
Mask = imread(Path);

s = regionprops(Mask, 'BoundingBox');

PEDI = imcrop(PEDI, s(1).BoundingBox);

[ DespeckledPEDI, CommonAreaThreshold ] = pft_CreateDespeckledImage(PEDI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set a common edge-detection threshold from the first image in the first folder - use the outputs from the previous section

[ EdgeDetectedImage, CommonEDThreshold ] = pft_CreateEdgeDetectedImage(DespeckledPEDI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ask whether to trim data for summary FD statistics

Answer = questdlg('Discard end slices for summary statistics ?', 'Processing decision', 'Yes', 'No', 'No');

switch Answer
  case { '', 'No' }
    DiscardEndSlices = 'No';
  case 'Yes'
    DiscardEndSlices = 'Yes';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select the output Excel sheet and back it up straightaway

SummaryFile       = fullfile(Base, 'Summary-Auto-FD-Histology-v3.csv');
SummaryBackupFile = fullfile(Base, 'Summary-Auto-FD-Histology-v3-Backup.csv');

if (exist(SummaryFile, 'file') ~= 2)
  Head = [ 'Folder,', ...
           'Slices present,', ...
           'Fractal dimension - Slice 1,', 'Slice 2,', 'Slice 3,', 'Slice 4,', 'Slice 5,', ...
           'Slice 6,', 'Slice 7,', 'Slice 8,', 'Slice 9,', 'Slice 10,', ...
           'Slice 11,', 'Slice 12,', 'Slice 13,', 'Slice 14,', 'Slice 15,', ...
           'Slice 16,', 'Slice 17,', 'Slice 18,', 'Slice 19,', 'Slice 20,', ...
           '255 x Otsu binarizing threshold - Slice 1,', 'Slice 2,', 'Slice 3,', 'Slice 4,', 'Slice 5,', ...
           'Slice 6,', 'Slice 7,', 'Slice 8,', 'Slice 9,', 'Slice 10,', ...
           'Slice 11,', 'Slice 12,', 'Slice 13,', 'Slice 14,', 'Slice 15,', ...
           'Slice 16,', 'Slice 17,', 'Slice 18,', 'Slice 19,', 'Slice 20,', ...
           'Otsu efficiency metric - Slice 1,', 'Slice 2,', 'Slice 3,', 'Slice 4,', 'Slice 5,', ...
           'Slice 6,', 'Slice 7,', 'Slice 8,', 'Slice 9,', 'Slice 10,', ...
           'Slice 11,', 'Slice 12,', 'Slice 13,', 'Slice 14,', 'Slice 15,', ...
           'Slice 16,', 'Slice 17,', 'Slice 18,', 'Slice 19,', 'Slice 20,', ...
           'De-speckling area threshold - Slice 1,', 'Slice 2,', 'Slice 3,', 'Slice 4,', 'Slice 5,', ...
           'Slice 6,', 'Slice 7,', 'Slice 8,', 'Slice 9,', 'Slice 10,', ...
           'Slice 11,', 'Slice 12,', 'Slice 13,', 'Slice 14,', 'Slice 15,', ...
           'Slice 16,', 'Slice 17,', 'Slice 18,', 'Slice 19,', 'Slice 20,', ...
           'Edge-detection threshold - Slice 1,', 'Slice 2,', 'Slice 3,', 'Slice 4,', 'Slice 5,', ...
           'Slice 6,', 'Slice 7,', 'Slice 8,', 'Slice 9,', 'Slice 10,', ...
           'Slice 11,', 'Slice 12,', 'Slice 13,', 'Slice 14,', 'Slice 15,', ...
           'Slice 16,', 'Slice 17,', 'Slice 18,', 'Slice 19,', 'Slice 20,', ...
           'End slices discarded for statistics,', ...
           'Slices evaluated,', 'Slices used,', ...
           'Mean global FD,', ...
           'Mean basal FD,', 'Mean apical FD,', ...
           'Max. basal FD,', 'Max. apical FD' ];     
                 
  fid = fopen(SummaryFile, 'at');
  fprintf(fid, '%s\n', Head);
  fclose(fid);
end

copyfile(SummaryFile, SummaryBackupFile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is a signalling error condition for the o/p CSV file

FDMeasureFailed = 0.0;    % Signal that an attempt was made, but failed - this will be excluded from the FD statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Process all the suitable folders

if (exist(fullfile(Base, 'Automated FD Calculation Results'), 'dir') ~= 7)
  mkdir(Base, 'Automated FD Calculation Results');
end

h1 = waitbar(0, sprintf('Processed 0 of %1d folders', NDIRS), 'Units', 'normalized', 'Position', [0.225 0.45 0.2 0.1]);

set(h1, 'Name', 'Progress - folders');

for n = 1:NDIRS
    
  if (exist(fullfile(Base, 'Automated FD Calculation Results', Entries{n}), 'dir') ~= 7)
    mkdir(fullfile(Base, 'Automated FD Calculation Results'), Entries{n});
  end
  
  SourceFolder = fullfile(Base, Entries{n});
  TargetFolder = fullfile(Base, 'Automated FD Calculation Results', Entries{n});
    
  [ OriginalStack, BinarizedStack, BinaryMask, PerimeterStack, PEDIStack, Conditions ] = pft_ReadSourceImages(SourceFolder);
  
  if isempty(BinarizedStack)
    rmdir(TargetFolder, 's');
    Dane = sprintf('%s, %s %s', Entries{n}, repmat('  ,', [1, 68]), '  ');
    fid = fopen(SummaryFile, 'at');
    fprintf(fid, '%s\n', Dane);
    fclose(fid);
    waitbar(n/NDIRS, h1, sprintf('Processed %1d of %1d folders', n, NDIRS));
    continue;
  end

  [ NR, NC, NP ] = size(BinarizedStack);
  
  h2 = waitbar(0, sprintf('Processed 0 of %1d slices', NP), 'Units', 'normalized', 'Position', [0.525 0.45 0.2 0.1]);
  
  set(h2, 'Name', 'Progress - slices');
  
  FD = NaN(1, 20);
  FractalDimensions = repmat({ 'NaN' }, [1, 20]);
  
  OL = OtsuLevels(n, :);
  OtsuLevelThreshold = repmat({ 'NaN' }, [1, 20]);
  for s = 1:NP
    OtsuLevelThreshold(s) = { sprintf('%1d', round(255.0*OL(s))) };
  end
  
  OtsuEM = EM(n, :);
  OtsuMetrics = repmat({ 'NaN' }, [1, 20]);
  for s = 1:NP
    OtsuMetrics(s) = { sprintf('%.9f', OtsuEM(s)) };
  end
  
  CAT = NaN(1, 20);
  CAT(1:NP) = CommonAreaThreshold;
  DespecklingAreaThreshold = repmat({ 'NaN' }, [1, 20]);
  DespecklingAreaThreshold(1:NP) = { sprintf('%1d', CommonAreaThreshold) };
  
  EDT = NaN(1, 20);
  EDT(1:NP) = CommonEDThreshold;
  EdgeDetectionThreshold = repmat({ 'NaN' }, [1, 20]);
  EdgeDetectionThreshold(1:NP) = { sprintf('%.2f', CommonEDThreshold) };
  
  for p = 1:NP
      
    switch Conditions{p}        
        
      case 'OK'  
        Data = OriginalStack(:, :, p);
        Wzor = BinarizedStack(:, :, p);        
        Mask = BinaryMask(:, :, p);
        Perimeter = PerimeterStack(:, :, p);
        PEDI = PEDIStack(:, :, p);                
  
        s = regionprops(Mask, 'BoundingBox');
        
        Data = imcrop(Data, s(1).BoundingBox);
        Wzor = imcrop(Wzor, s(1).BoundingBox);
        Mask = imcrop(Mask, s(1).BoundingBox);
        Perimeter = imcrop(Perimeter, s(1).BoundingBox);
        PEDI = imcrop(PEDI, s(1).BoundingBox);
          
        pft_WriteInputImages(Data, Wzor, Mask, Perimeter, PEDI, p, TargetFolder);
        
        try
          FD(p) = pft_JC_FractalDimensionCalculation(Data, Mask, PEDI, CommonAreaThreshold, CommonEDThreshold, p, TargetFolder);  
          FractalDimensions{p} = sprintf('%.9f', FD(p));
        catch
          Conditions{p} = 'FD measure failed';
          FD(p) = FDMeasureFailed;
          FractalDimensions{p} = 'FD measure failed';
        end       
 
    end
       
    waitbar(p/NP, h2, sprintf('Processed %1d of %1d slices', p, NP));
  
  end
  
  waitbar(1, h2, sprintf('Processed %1d of %1d slices', NP, NP));
  
  pause(0.1);
  
  delete(h2);
  
  waitbar(n/NDIRS, h1, sprintf('Processed %1d of %1d folders', n, NDIRS));  
  
  % Extract and process the FD values for the current stack, trimmed to the number of slices present
  
  StackFD = FD(1:NP);
    
  switch DiscardEndSlices
    case 'No'
      S = pft_JC_FDStatistics(StackFD, false);
    case 'Yes'
      S = pft_JC_FDStatistics(StackFD, true);
  end  
  
  % Write out the formatted FD o/p as text 
  
  FormattedFDOutput = '';
  
  for c = 1:19
    switch Conditions{c}
      case 'OK'
        if isnan(FD(c))
          FormattedFDOutput = [ FormattedFDOutput 'NaN,' ];
        else
          FormattedFDOutput = [ FormattedFDOutput sprintf('%s,', FractalDimensions{c}) ];
        end
      case 'FD measure failed'
        FormattedFDOutput = [ FormattedFDOutput sprintf('%s,', FractalDimensions{c}) ];      
    end
  end  
  
  switch Conditions{20}
    case 'OK'
      if isnan(FD(20))
        FormattedFDOutput = [ FormattedFDOutput 'NaN' ];
      else
        FormattedFDOutput = [ FormattedFDOutput sprintf('%s', FractalDimensions{20}) ];
      end
    case 'FD measure failed'
      FormattedFDOutput = [ FormattedFDOutput sprintf('%s', FractalDimensions{20}) ];
  end
  
  % Do the same for the Otsu level values 
  FormattedOLOutput = '';
  
  for c = 1:19
    if isnan(OL(c))
      FormattedOLOutput = [ FormattedOLOutput 'NaN,' ];
    else
      FormattedOLOutput = [ FormattedOLOutput sprintf('%s,', OtsuLevelThreshold{c}) ];
    end
  end  
   
  if isnan(OL(20))
    FormattedOLOutput = [ FormattedOLOutput 'NaN' ];
  else
    FormattedOLOutput = [ FormattedOLOutput sprintf('%s', OtsuLevelThreshold{20}) ];
  end
  
  % Do the same for the EM values 
  FormattedEMOutput = '';
  
  for c = 1:19
    if isnan(OtsuEM(c))
      FormattedEMOutput = [ FormattedEMOutput 'NaN,' ];
    else
      FormattedEMOutput = [ FormattedEMOutput sprintf('%s,', OtsuMetrics{c}) ];
    end
  end  
   
  if isnan(OtsuEM(20))
    FormattedEMOutput = [ FormattedEMOutput 'NaN' ];
  else
    FormattedEMOutput = [ FormattedEMOutput sprintf('%s', OtsuMetrics{20}) ];
  end
    
  % Also the CAT values 
  FormattedCATOutput = '';
  
  for c = 1:19
    if isnan(CAT(c))
      FormattedCATOutput = [ FormattedCATOutput 'NaN,' ];
    else
      FormattedCATOutput = [ FormattedCATOutput sprintf('%s,', DespecklingAreaThreshold{c}) ];
    end
  end  
   
  if isnan(CAT(20))
    FormattedCATOutput = [ FormattedCATOutput 'NaN' ];
  else
    FormattedCATOutput = [ FormattedCATOutput sprintf('%s', DespecklingAreaThreshold{20}) ];
  end 
   
  % And for the EDT values  
  
  FormattedEDTOutput = '';
  
  for c = 1:19
    if isnan(EDT(c))
      FormattedEDTOutput = [ FormattedEDTOutput 'NaN,' ];
    else
      FormattedEDTOutput = [ FormattedEDTOutput sprintf('%s,', EdgeDetectionThreshold{c}) ];
    end
  end  
  
  if isnan(EDT(20))
    FormattedEDTOutput = [ FormattedEDTOutput 'NaN' ];
  else
    FormattedEDTOutput = [ FormattedEDTOutput sprintf('%s', EdgeDetectionThreshold{20}) ];
  end
        
  Dane = sprintf('%s,%1d,%s,%s,%s,%s,%s,%s,%1d,%1d,%.9f,%.9f,%.9f,%.9f,%.9f', ...
                 Entries{n}, ...
                 NP, ...
                 FormattedFDOutput, ...
                 FormattedOLOutput, ...
                 FormattedEMOutput, ...
                 FormattedCATOutput, ...
                 FormattedEDTOutput, ...
                 DiscardEndSlices, S.SlicesEvaluated, S.SlicesUsed, ...
                 S.MeanGlobalFD, ...
                 S.MeanBasalFD, S.MeanApicalFD, ...
                 S.MaxBasalFD, S.MaxApicalFD);
             
  fid = fopen(SummaryFile, 'at');
  fprintf(fid, '%s\n', Dane);
  fclose(fid);
            
end

waitbar(1, h1, sprintf('Processed %1d of %1d folders', NDIRS, NDIRS));

pause(0.1);
  
delete(h1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tidy up any undeleted graphics handles

clearvars h1 h2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Home, James !

h = pft_MsgBox('Done !', 'Quit', 'modal');
uiwait(h);
delete(h);




