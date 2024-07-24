#!/bin/bash

################################################################
# Last updated: 2022-12-01 (Seongjin Choi)				       #
################################################################
### NOTE: This file conversion requires dcm2niix (Chris Roden), which is already the part of the VM.

###################################################################################
# Specify the location where data downloaded/unzipped.
workDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/29/pooled-7t-mri-ms_2
###################################################################################

cd ${workDIR}
# Get subject flder names in the location where data have been unzipped.
subjlist=`ls`
for subj in ${subjlist}
do
	cd ${workDIR}/${subj}/
	# Get the visit folder names under each subject. 
	visitlist=`ls`
	for visit in ${visitlist}
	do
		# File conversion performs if there is no '${workDIR}/${subj}/${visit}/out/' folder.  
		if [ ! -d ${workDIR}/${subj}/${visit}/out ]; then
			mkdir ${workDIR}/${subj}/${visit}/out
			echo ">>> File conversion in progress..."
			echo ${subj}/${visit} 
			# Conversion options for Philips data
			dcm2niix -o ${workDIR}/${subj}/${visit}/out -f %f_%p -z y -v y ${workDIR}/${subj}/${visit}
			echo "Done for ${subj}/${visit}."
		else
			echo "Pass."
		fi
	done
done



