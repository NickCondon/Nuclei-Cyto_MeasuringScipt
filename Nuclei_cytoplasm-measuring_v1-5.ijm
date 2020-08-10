print("\\Clear")

//	MIT License

//	Copyright (c) 2018 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.


//IMB Macro Splash screen (Do not remove this acknowledgement)
scripttitle="Nuclei and Cytoplasm Measuring Script";
version="1.5";
versiondate="05/09/2019";
description="Details: <br>This script takes 2D images of Zebrafish and finds the nuclei for measuring. <br><br> It then converts  all Green labelling (ch1) into 32-bit, "
+"NaN background, before measuring the nuclei mean intensity. <br><br> A region around the nuclei is measured by creating a banding selection of a user defined distance. "
+"<br><br> Output files are saved into a directory called results"


print("FIJI Macro: "+scripttitle);															//Prints script title to log window
print("Version: "+version+" ("+versiondate+")");
											//Prints script version & version date to log window
print("ACRF: Cancer Biology Imaging Facility");
												//Prints script acknowledgement to log window
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
										//Prints script acknowledgement to log window
print("");
																					//Prints linespace to log window

//IMB script dialog box (Do not remove this acknowledgement).
    showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The Institute for Molecular Bioscience <br> The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><\h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+versiondate+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+"</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");


Dialog.create("Choosing your working directory.");																				//Directory Warning and Instruction panel     
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
 	Dialog.show(); 
 
run("Set Measurements...", "area mean standard median display redirect=None decimal=3");	//Defines the measurements required for this script
run("Clear Results");																																			//Clears any results from the results window
roiManager("Reset");																																			//Deletes any ROIs from the manager

path = getDirectory("Choose Source Directory ");																					//Variable for directory
list = getFileList(path);																																	//Variable for file list
xlsVar = 2; 																																							//Variable for excel row calculations (excludes title row)



ext = ".tif"; 																																						//Variable for file exension
  Dialog.create("Choosing your settings");																								//Dialogue requesting user input settings
  	Dialog.addString("File Extension:", ext);																							//Dialogue requesting file extension
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
 	Dialog.addNumber("Banding Distance (Pixels): ", 1.5)																		//Dialogue requesting band spacing size
  	Dialog.addCheckbox("Run in batch mode (Background)", true);														//Dialogue toggle for batch (background mode)
  	Dialog.show();
  ext = Dialog.getString();																																//VAR = file extensino [string]
	batch=Dialog.getCheckbox();																															//VAR = batch mode status [boolean]
	band = Dialog.getNumber();																															//VAR = size of band [number]


	print("**********  Paramaters  **********");																						//Prints user settings to the log window
	print("Working directory: "+path);																											//Prints directory location to the log window
	print("Chosen file extension: "+ext);																										//Prints chosen file extension to the log window
	print("Banding Size (Pixels): "+band);																									//Prints band size to the log window
	
if (batch==1){																																						//Batch mode conditional run
	setBatchMode(true);																																			//Turns on background mode
	print("Running In batch mode.");																												//Prints to the log that batch mode is enabled
	}

getDateAndTime(year, month, week, day, hour, min, sec, msec);															//Obtaining date and time 
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);		//Prints the script run time and date to the log window
start = getTime();																																				//Starts the script timer

print("");																																								//Prints a linespace to the log window	
resultsDir = path+"Results"+year+"-"+(month+1)+"-"+day+"__"+hour+"."+min+"."+sec+"/";			//VAR = location of the results directory within the working directory [string]
File.makeDirectory(resultsDir);																														//Creates an output directory with the name using the VAR=resultsDir
summaryFile = File.open(resultsDir+"Results.xls");																				//Creates a results file named Results.xls
print(summaryFile,"Filename \t Nuclei # \t Nuclei Intensity \t Cytoplasm Intensity \t Number of Nuclei \t Cyto/Nuclei \t Nuclei/Cyto");
//Prints title colunms into Results.xls


for (z=0; z<list.length; z++) {																														//Main script loop. Repeats for total number of files in working directory
if (endsWith(list[z],ext)){																																//Secondary script loop. Only opens files with the given file extension
 		print("Opening File "+(z+1)+" of "+list.length+" total files");												//Prints the current file number (and total file number) to the log window
 		open(path+list[z]);																																		//Opens the zth file in directory
		windowtitle = getTitle();																															//VAR = file name [string]
		windowtitlenoext = replace(windowtitle, ext, "");																			//VAR = file name with no extension [string]

	
		run("Duplicate...", "duplicate channels=1");																					//Duplicates out the ch1 (cytoplasm) channel for measurements
		rename("green");																																			//Renames the window to "green"
		selectWindow(windowtitle);																														//Selects the main 'original' window
		run("Duplicate...", "duplicate channels=2");																					//Duplicates the ch2 (nuclei) channel for thresholding
		rename("nuc");																																				//Renames the window to "nuc"
		selectWindow(windowtitle);																														//Selects the main 'original' window										
		run("Duplicate...", "duplicate channels=2");																					//Duplicates the ch2 (nuclei)channel for mask use
		rename("nucformask");																																	//Renames the window to "nucformask"
		run("Subtract Background...", "rolling=20");																					//Massages red (nuclei) channel prior to thresholding
		run("Median...", "radius=2");																													//Massages red (nuclei) channel prior to thresholding
		setAutoThreshold("MaxEntropy dark");																									//Threshold image using MaxEntropy dark setting
		setOption("BlackBackground", false);																									//Sets threshold option
		run("Convert to Mask");																																//Creates binary mask based on red (nuclei) channel
		run("Analyze Particles...", "size=20-Infinity show=Masks exclude clear add");					//Finds only nuclei sized objects for the mask
		rename("mask1"); 																																			//Renames the window to "mask1"

		selectWindow("green");
		run("Duplicate...", "duplicate channels=1");																					//Duplicates ch1 image
		rename("green31");																																		//Renames the window to "green31"
		run("Duplicate...", "duplicate channels=1");																					//Duplicates ch1 image
		rename("green32");																																		//Renames the window to "green32"
		setMinAndMax(0, 65535);																																//Re-sets display range to full 16-bit range
		call("ij.ImagePlus.setDefault16bitRange", 16);																				//Sets the defult display range to 16-bit
		run("32-bit");																																				//Converts the image to 32-bit
		setAutoThreshold("Mean dark");																												//Threshold image using Mean dark
		run("NaN Background");																																//Defines "background" pixels as not a number (NaN)

		numNuc = roiManager("count");																													//VAR = count of the number of nuclei [number]
			
		if (numNuc >= 1) {																																		//Loop for if one of more nuclei was found
		nucI = newArray(numNuc);																															//ARRAY = arrary for nuclei intensity (number of nuclei long)
		cytoI = newArray(numNuc);																															//ARRAY = arrary for cytoplasmic intensity (number of nuclei long)
		
			selectWindow("green32");																														//Selects the cytoplasmic window (green32)
			roiManager("Measure");																															//Measures every nuclei found as defined by ROI list
			for (r=0; r<numNuc; r++){																														//Loop for scraping results window into arrays
					nucI[r] = getResult("Mean",r);																									//Collects "Mean" (intensity) of the nuclei region and places it into ARRAY
					}
			roiManager("Save", resultsDir+ windowtitlenoext + "_nuclei.zip");										//Saves Nuclei ROIs as a .zip into the results directory with the file name appended
			print("Saving nuclei ROI list");																										//Prints ROI of nuclei has saved to the log window
		
			selectWindow("green32");																														//Selects the cytoplasmic window (green32)
				run("Clear Results");																															//Clears the results window
				for (rep = 0; rep<numNuc; rep++){																									//Loop for updating ROIs from nuclei selections to bands (for cytoplasm measurments
					roiManager("Select", rep);																											//Selects the rep'th ROI from the list
					run("Enlarge...", "enlarge=1");																									//Increases selection by 1 to exclude any nuc membrane issues
					run("Make Band...", "band="+band);																							//Creates a selection (band) at the current location 1 pixel form the nuclei border
					roiManager("update");																														//Updates ROI selection
					}
				
			run("Clear Results");																																//Clears the results window
			selectWindow("green32");																														//Selects the cytoplasmic window (green32)
		
			n = roiManager("count");																														//VAR = number of ROIs found [number]
  			for (f=0; f<n; f++) {																															//Loops through each updated ROI of the list
     			roiManager("select", f);																												//Selects the f'th ROI from the list
					run("Measure");																																	//Measures this particular ROI
					cytoI[f] = getResult("Mean",f);																									//Collects "Mean" (intensity) of the cytoplasm region and places it into ARRAY
          }	

			for (j=0 ; j<numNuc ; j++) {  																											//Loop for pulling values from the arrays into single lines for excel output
    			nucInt = nucI[j];																																//VAR = tempory placeholder for the output vales from the nuclei intensity ARRAY
    			cytoInt = cytoI[j];																															//VAR = tempory placeholder for the output vales from the cytoplasm intensity ARRAY
    			nuccount = j+1;																																	//VAR = tempory placeholder for the output counter (increasing from base 0)
    			print(summaryFile,windowtitle+"\t"+nuccount+"\t"+nucInt+"\t"+cytoInt+"\t"+numNuc+"\t=D"+xlsVar+"/C"+xlsVar+"\t=C"+xlsVar+"/D"+xlsVar);
//Prints the measurements and details into the Results.xls as well as performing two calculations
  	   		xlsVar = xlsVar + 1;																														//updates the VAR = xlsVar to be one higher for the next rows calculations
  	   			}

	selectWindow("green32");																																//Selects the cytoplasmic window (green32)
	saveAs("tiff", resultsDir+windowtitlenoext+"_green-selection.tif");											//Saving NaN/32-bit green channel image
 	print("Saving Green masked image");																											//Prints saving status to the log window
 	close();																																								//Closes image window
 	selectWindow("mask1");																																	//Selects the nuclei mask window
 	saveAs("tiff", resultsDir+windowtitlenoext+"_nuclei-mask.tif");													//Saving the nuclei mask (thresholded) image
 	print("Saving nuclei mask");																														//Prints saving status to the log window
 	close();																																								//Closes image window
 	roiManager("Save", resultsDir+ windowtitlenoext + "_cyto.zip");													//Saves cytoplasm band ROIs as a .zip into the results directory with the filename 
 	print("Saving cytoplasm ROI list");																											//Prints ROI of cytoplasm bands has saved to the log window
 	close();																																								//Closes image window

	selectWindow("green");																																	//Selects the cytoplasmic window (green)
 		run("Enhance Contrast", "saturated=0.35");																						//Runs auto brightness and contrast
 		roiManager("Set Color", "white");																											//Sets ROIs lines to be the colour white
		roiManager("Set Line Width", 1);																											//Sets ROIs line width to be 1
 		roiManager("Show All");																																//Displays all ROIs onto the image window
 		roiManager("Show All with labels");																										//Displays all ROI labels onto the image window
 		run("Flatten");																																				//Flattens the ROI overlays into a new image
 		saveAs("png", resultsDir+windowtitlenoext+"_selectionnumbers.png");										//Saves overlay image as a png into the results directory
 		print("Saving overview image");																												//Prints saving status to the log window
 	 	while (nImages > 0){close();}																													//Closes any remaining open windows
			print("All outputs saved and closed");																							//Prints all windows closed to the log window
			print("");}																																					//Prints a line space to the log window
		roiManager("reset");																																	//Removes any ROIs from the ROI manager
}}																																												//End of all file loops

print("Batch Completed");print("Total Runtime was:");print((getTime()-start)/1000); 			//Prints run stats to the log window

selectWindow("Log");																																			//Selects the log window
saveAs("Text", resultsDir+"Log.txt");																											//Saves the log window

title = "Batch Completed"; msg = "Put down that coffee! Your job is finished";						//VARs = Dialog window text [sting]
waitForUser(title, msg);  																																//Displays dialogue to user

//End of Script
