# Nuclei & Cytoplasm Measuring Script

Developed by Dr Nicholas Condon.

[ACRF:Cancer Biology Imaging Facility](https://imb.uq.edu.au/microscopy), 
Institute for Molecular Biosciences, The University of Queensland
Brisbane, Australia 2019.

This script is written in the ImageJ1 Macro Language.


## Background
This script takes 2D images of Zebrafish and finds the nuclei for measuring. <br><br> 
It then converts  all Green labelling (ch1) into 32-bit, NaN background, before measuring the nuclei mean intensity. <br><br> 
A region around the nuclei is measured by creating a banding selection of a user defined distance. <br><br> 
Output files are saved into a directory called results

## Running the script

The first dialog box to appear explains the script, acknowledges the creator and the ACRF:Cancer Biology Imaging Facility.

The second window to open will warn the user about file selection and noting the file extension.

The next window to open will be the input file directory location.

The next dialog to open will prompt the user to select parameters for the script to run. These include, the expected file's extension (eg, .oir, .tif, etc), the cytoplasm band size and whether to run in batch mode (background).

The file extension is actually a file ‘filter’ running the command ‘ends with’ which means for example .tif may be different from .txt in your folder only opening .tif files. Perhaps you wish to process files in a folder containing <Filename>.tif and <Filename>+deconvolved.tif you could enter in the box here deconvolved.tif to select only those files. It also uses this information to tidy up file names it creates (i.e. no example.tif.avi)

Running the script in batch mode won’t open the files into your OS, instead it runs in the background, which is faster and more memory efficient.

The final dialog box is an alert to the user that the batch is completed.

## Output files

Files are put into a results directory called '_Results_<date&time>' within the chosen working directory. Files will be saved as either a .tif, .csv or .txt for the log file. Original filenames are kept and have tags appended to them based upon the chosen parameters.

A text file called log.txt is included which has the chosen parameters and date and time of the run.


## Turning off Bio-Formats Import Window

Preventing the Bio-formats Importer window from displaying:
1. Open FIJI
2. Navigate to Plugins > Bio-Formats > Bio-Formats Plugins Configuration
3. Select Formats
4. Select your desired file format (e.g. “Zeiss CZI”) and select “Windowless”
5. Close the Bio-Formats Plugins Configuration window

Now the importer window won’t open for this file-type. To restore this, simply untick ‘Windowless”
