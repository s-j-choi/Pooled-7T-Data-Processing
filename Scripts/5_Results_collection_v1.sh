#!/bin/bash

################################################################################
# Last updated: 2022-12-11 (Seongjin Choi)				       #
################################################################################
# Location of data downloaded unzipped.
workDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/33/pooled-7t-mri-ms_2

# Location of upload folder
uploadDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/33

# Upload fodler
if [ ! -d ${uploadDIR}/Files_for_upload ]; then
	mkdir ${uploadDIR}/Files_for_upload
fi

cd ${workDIR}
# Get subject folder names in the location where data have been unzipped.
subjlist=`ls`

####################################################################################################
# When a few individuals need to be processed, provide a specific ID and uncomment the line below. #
####################################################################################################
#subjlist="pooled-7t-mri-ms_023 pooled-7t-mri-ms_024 pooled-7t-mri-ms_025"

for subj in ${subjlist}
do
	# Folder
	if [ ! -d ${uploadDIR}/Files_for_upload/${subj} ]; then
		mkdir ${uploadDIR}/Files_for_upload/${subj}
	fi
	
	cd ${workDIR}/${subj}/
	# Get the visit folder names under each subject. 
	visitlist=`ls`
	#visitlist="2019-07-01"
	for visit in ${visitlist}
	do
		echo "Working on ${subj}/${visit}..."
		# Folder
		if [ ! -d ${uploadDIR}/Files_for_upload/${subj}/${visit} ]; then
			mkdir ${uploadDIR}/Files_for_upload/${subj}/${visit}
		fi	
			
		# File collection	
		if [ "$(ls -A ${uploadDIR}/Files_for_upload/${subj}/${visit})" ]; then
			echo "Files_for_upload/${subj}/${visit}/ is not empty."
		else
			echo "Copying files for upload..."
			cp ${workDIR}/${subj}/${visit}/out/*MNI152.nii.gz ${uploadDIR}/Files_for_upload/${subj}/${visit}/
			cp ${workDIR}/${subj}/${visit}/out/*outskull_mask.nii.gz ${uploadDIR}/Files_for_upload/${subj}/${visit}/
			# Clean up unnecessary files copied to the 'Folder_for_upload/' and rename long file names to shoter ones.
			rm -rf ${uploadDIR}/Files_for_upload/${subj}/${visit}/*INV2*
			rm -rf ${uploadDIR}/Files_for_upload/${subj}/${visit}/${visit}_MP2RAGE-T1_map*
			mv ${uploadDIR}/Files_for_upload/${subj}/${visit}/${subj}-${visit}_MP2RAGE-UNI_DEN-BrainExtractionMask_in_MNI152.nii.gz ${uploadDIR}/Files_for_upload/${subj}/${visit}/${subj}-${visit}_BrainExtractionMask.nii.gz
			mv ${uploadDIR}/Files_for_upload/${subj}/${visit}/${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152_brain_RSBFA_f0p2_outskull_mask.nii.gz ${uploadDIR}/Files_for_upload/${subj}/${visit}/${subj}-${visit}_SkullContentsMask.nii.gz
			echo "Copied."
		fi		
		
		echo "Done for ${subj}/${visit}."
	done
	echo "Done for ${subj}."
done
echo 
