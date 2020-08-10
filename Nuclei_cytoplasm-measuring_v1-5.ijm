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
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
print("");

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


Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
 	Dialog.show(); 
 
run("Set Measurements...", "area mean standard median display redirect=None decimal=3");	//Defines the measurements required for this script
run("Clear Results");																		//Clears any results from the results window
roiManager("Reset");																		//Deletes any ROIs from the manager

path = getDirectory("Choose Source Directory ");											//Variable for directory
list = getFileList(path);																	//Variable for file list
xlsVar = 2; 																				//Variable for excel row calculations (excludes title row)



ext = ".tif"; 																				//Variable for file exension
  Dialog.create("Choosing your settings");
  	Dialog.addString("File Extension:", ext);
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
 	Dialog.addNumber("Banding Distance (Pixels): ", 1.5)
  	Dialog.addCheckbox("Run in batch mode (Background)", true);
  	Dialog.show();
  	ext = Dialog.getString();																//VAR = file extensino [string]
	batch=Dialog.getCheckbox();																//VAR = batch mode status [boolean]
	band = Dialog.getNumber();																//VAR = size of band [number]


	print("**********  Paramaters  **********");											//Prints user settings to the log
	print("Working directory: "+path);
	print("Chosen file extension: "+ext);
	print("Banding Size (Pixels): "+band);
	
if (batch==1){																				//Batch mode conditional run
	setBatchMode(true);
	print("Running In batch mode.");
	}

	
getDateAndTime(year, month, week, day, hour, min, sec, msec);								//Obtaining date and time 
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
start = getTime();																			//Starts the script timer


print("");
resultsDir = path+"Results"+year+"-"+(month+1)+"-"+day+"__"+hour+"."+min+"."+sec+"/";
File.makeDirectory(resultsDir);																//Creates an output directory with the name using the VAR=resultsDir
summaryFile = File.open(resultsDir+"Results.xls");											//Creates a results file named Results.xls
print(summaryFile,"Filename \t Nuclei # \t Nuclei Intensity \t Cytoplasm Intensity \t Number of Nuclei \t Cyto/Nuclei \t Nuclei/Cyto");


for (z=0; z<list.length; z++) {
if (endsWith(list[z],ext)){
 		print("Opening File "+(z+1)+" of "+list.length+" total files");
 		open(path+list[z]);
		windowtitle = getTitle();
		windowtitlenoext = replace(windowtitle, ext, "");

	
		run("Duplicate...", "duplicate channels=1");										//Duplicates out the ch1 (cytoplasm) channel for measurements
		rename("green");
		selectWindow(windowtitle);															//Selects the main 'original' window
		run("Duplicate...", "duplicate channels=2");
		rename("nuc");
		selectWindow(windowtitle);															//Selects the main 'original' window										
		run("Duplicate...", "duplicate channels=2");
		rename("nucformask");
			run("Subtract Background...", "rolling=20");									//Massages red (nuclei) channel prior to thresholding
			run("Median...", "radius=2");
			setAutoThreshold("MaxEntropy dark");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Analyze Particles...", "size=20-Infinity show=Masks exclude clear add");	//Finds only nuclei sized objects for the mask
			rename("mask1"); 																//Renames the window to "mask1"


		selectWindow("green");
			run("Duplicate...", "duplicate channels=1");
			rename("green31");
			run("Duplicate...", "duplicate channels=1");
			rename("green32");
			setMinAndMax(0, 65535);
			call("ij.ImagePlus.setDefault16bitRange", 16);
			run("32-bit");
			setAutoThreshold("Mean dark");
			run("NaN Background");

		numNuc = roiManager("count");														//VAR = count of the number of nuclei [number]
			
		if (numNuc >= 1) {																	//Loop for if one of more nuclei was found
			nucI = newArray(numNuc);														//ARRAY = arrary for nuclei intensity (number of nuclei long)
			cytoI = newArray(numNuc);														//ARRAY = arrary for cytoplasmic intensity (number of nuclei long)
		
			selectWindow("green32");
				roiManager("Measure");
				for (r=0; r<numNuc; r++){
					nucI[r] = getResult("Mean",r);
					}
				roiManager("Save", resultsDir+ windowtitlenoext + "_nuclei.zip");			//Saves Nuclei ROIs
				print("Saving nuclei ROI list");
		
			selectWindow("green32");
				run("Clear Results");														//Clears the results window
				for (rep = 0; rep<numNuc; rep++){											//Loop for updating ROIs from nuclei selections to bands (for cytoplasm measurments
					roiManager("Select", rep);												//Selects the rep'th ROI from the list
					
					run("Make Band...", "band="+band);										//Creates a selection (band) at the current location 1 pixel form the nuclei border
					roiManager("update");													//Updates ROI selection
					}
				
			run("Clear Results");
			selectWindow("green32");
		
			n = roiManager("count");														//VAR = number of ROIs found [number]
  			for (f=0; f<n; f++) {															//Loops through each updated ROI of the list
     			roiManager("select", f);		
				run("Measure");																//Measures this particular ROI
				cytoI[f] = getResult("Mean",f);												//Collects "Mean" (intensity) of the cytoplasm region and places it into ARRAY
           		}	

			for (j=0 ; j<numNuc ; j++) {  													//Loop for pulling values from the arrays into single lines for excel output
    			nucInt = nucI[j];															//VAR = tempory placeholder for the output vales from the nuclei intensity ARRAY
    			cytoInt = cytoI[j];															//VAR = tempory placeholder for the output vales from the cytoplasm intensity ARRAY
    			nuccount = j+1;																//VAR = tempory placeholder for the output counter (increasing from base 0)
    		print(summaryFile,windowtitle+"\t"+nuccount+"\t"+nucInt+"\t"+cytoInt+"\t"+numNuc+"\t=D"+xlsVar+"/C"+xlsVar+"\t=C"+xlsVar+"/D"+xlsVar);
  	   			xlsVar = xlsVar + 1;
  	   			}

	selectWindow("green32");																//Selects the cytoplasmic window (green32)
	saveAs("tiff", resultsDir+windowtitlenoext+"_green-selection.tif");
 	print("Saving Green masked image");
 	close();
 	selectWindow("mask1");																	//Selects the nuclei mask window
 	saveAs("tiff", resultsDir+windowtitlenoext+"_nuclei-mask.tif");
 	print("Saving nuclei mask");
 	close();
 	roiManager("Save", resultsDir+ windowtitlenoext + "_cyto.zip");							//Saves cytoplasm band ROIs as a .zip into the results directory with the file name appended
 	print("Saving cytoplasm ROI list");
 	close();

	selectWindow("green");																	//Selects the cytoplasmic window (green)
 		run("Enhance Contrast", "saturated=0.35");
 		roiManager("Set Color", "white");
		roiManager("Set Line Width", 1);
 		roiManager("Show All");
 		roiManager("Show All with labels");
 		run("Flatten");
 		saveAs("png", resultsDir+windowtitlenoext+"_selectionnumbers.png");
 		print("Saving overview image");
 	 	while (nImages > 0){close();}														//Closes any remaining open windows
			print("All outputs saved and closed");
			print("");
		roiManager("reset");																//Removes any ROIs from the ROI manager
}}																							//End of all file loops


print("Batch Completed");print("Total Runtime was:");print((getTime()-start)/1000); 


selectWindow("Log");																		//Selects the log window
saveAs("Text", resultsDir+"Log.txt");

title = "Batch Completed"; msg = "Put down that coffee! Your job is finished";
waitForUser(title, msg);  

//End of Script