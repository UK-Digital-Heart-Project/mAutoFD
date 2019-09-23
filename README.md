# AutoFD
Matlab script for automated fractal analysis of histological slices taken from the hearts of mice.

## Prerequisites
- Matlab.
- Windows or Linux - there are no guarantees for MacOS.
- Possibly GhostScript.
- Possibly XPDF.

## Input data

- A single RGB (pink-stained) montage of cardiac histology slices. Samples from different animals should be arranged in successive rows.

  E.g., the sample data set "Small-Sample.tif".

## Method

The approach is based on our [FracAnalyse](https://github.com/UK-Digital-Heart-Project/fracAnalyse) software, 
but there is no Level-Set Estimation/Bias-Field Elimination step, due to the limited contrast in the histological slices,
and the very different morphology of the trabeculations in mouse hearts (as compared to human hearts).

![FD images](https://github.com/UK-Digital-Heart-Project/AutoFD/blob/master/FDworkflow.png)

## Installation
Clone this repo to a folder in your MATLAB workspace then add all directories to the path:

```addpath(genpath('pwd')); savepath;```

## Usage
Put the TIFF-format source image in a convenient location - you will be prompted to browse for it.

Run the script ```pft_FractalDimensionCalculationOnMultipleFolders```

## Processing
First, you will be prompted to crop the montage into rectangular slices.
These do not have to be exactly the same size - padding will be used later to create image stacks of uniform height and width.
Each row of slices will be written to a different, numbered "input" folder. The cropping rectangles are saved (as plain-text ASCII files) for possible later re-use.

The cropped images are then be binarized automatically using Otsu's method - the Level and Efficiency Metric are recorded in a summary CSV file.

Next, you will need to crop the binarized images with a manually drawn ROI. An initial ellipse will be drawn,
but you can move the vertices, as well as add or remove them.

To remove small speckles from the images, you will be prompted for an area threshold in a GUI displaying the binarized and de-speckled image.
The threshold is controlled from a continuously responsive slider. The threshold set for the first image will be applied to all the subsequent ones.
The default value offered on start-up of the GUI should be appropriate for the sample data set.

The final processing decision is to set an edge-detection threshold to create the edge image from the de-speckled image, prior to the usual
box-counting FD calculation. This setting is not critical, and like the area threshold for de-speckling, it is set using the first image
and applied to all the later ones. The default value invariably works well, but it is available to be changed.

A summary CSV file is generated for each montage processed, with each row of results corresponding to each row of the montage.
For the sample data set, an organizing folder called "Small-Sample" is created, with further sub-folders for "inputs" (pre-FD images),
"outputs" (documenting the processing) and the summary CSV file, as well as a backup.
  
## Test data
Use the image:                                          ```Small-Sample.tif```

## Outputs
Early results are written to the sub-folders ```Row 1 - Top``` and ```Row 2 - Bottom```.
Outputs are written to a new sub-folder ```Automated FD Calculation Results``` of the top-level folder ```Small-Sample```.
Each subject's folder will contain intermediate images and box-counting statistics.

Fractal dimension values are output to ```Summary-Auto-FD-Histology-v3.csv```. 
If you run the script more than once (perhaps with different processing parameters), new results will be appended.
