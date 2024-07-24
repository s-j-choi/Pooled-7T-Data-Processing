#!/bin/bash

################################################################################
# Last updated: 2022-12-11 (Seongjin Choi)				       #
################################################################################
# Specify the location where data downloaded/unzipped.
workDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/33/pooled-7t-mri-ms_2
cd ${workDIR}

# Get subject flder names in the location where data have been unzipped.
subjlist=`ls`

###############################################################################################
# When an individual has to be processed, provide a specific ID and uncomment the line below. #
###############################################################################################
#subjlist="pooled-7t-mri-ms_006"

for subj in ${subjlist}
do
	cd ${workDIR}/${subj}/
	# Get the visit folder names under each subject.	 
	visitlist=`ls`
	for visit in ${visitlist}
	do
		echo "######################################"
		echo "Working on ${subj}/${visit}..."
		cd ${workDIR}/${subj}/${visit}/out

		## UNI_std: pre-processing to estimate T1 map using Marques' MP2RAGE toolbox
		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI_std.nii.gz ]; then
			echo "Making standard UNI image..."
			# Rescaling SIMENSE UNI output
			if [ -f ${visit}_MP2RAGE-UNI.nii.gz ]; then 
				${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-UNI -div 4095 ${visit}_MP2RAGE-UNI_rescaled
				# Standrd UNI images have intensity values from -0.5 to 0.5 (Marques et al. NeuroImage 2010)
				${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-UNI_rescaled -sub 0.5 ${subj}-${visit}_MP2RAGE-UNI_std
			fi
			# Dealing with file name with _e1. 
			if [ -f ${visit}_MP2RAGE-UNI_e1.nii.gz ]; then 
				${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-UNI_e1 -div 4095 ${visit}_MP2RAGE-UNI_rescaled
				# Standrd UNI images have intensity values from -0.5 to 0.5 (Marques et al. NeuroImage 2010)
				${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-UNI_rescaled -sub 0.5 ${subj}-${visit}_MP2RAGE-UNI_std
			fi 
		else
			echo "Skipping...."
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI.nii.gz ] && [ -f ./${visit}_MP2RAGE-UNI_rescaled.nii.gz ] ; then
			cp ${visit}_MP2RAGE-UNI_rescaled.nii.gz ${subj}-${visit}_MP2RAGE-UNI.nii.gz
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_std.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-UNI.nii.gz ] ; then
			echo "Making standard Gd-UNI image..."
			# Rescaling SIMENSE Gd-UNI output 
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-Gd-UNI -div 4095 ${visit}_MP2RAGE-Gd-UNI_rescaled
			# Standrd UNI images have intensity values from -0.5 to 0.5 (Marques et al. NeuroImage 2010)
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-Gd-UNI_rescaled -sub 0.5 ${subj}-${visit}_MP2RAGE-Gd-UNI_std
		else
			echo "Skipping...."
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_std.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-UNI_e1.nii.gz ] ; then
			echo "Making standard Gd-UNI image..."
			# Rescaling SIMENSE Gd-UNI output 
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-Gd-UNI_e1 -div 4095 ${visit}_MP2RAGE-Gd-UNI_rescaled
			# Standrd UNI images have intensity values from -0.5 to 0.5 (Marques et al. NeuroImage 2010)
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-Gd-UNI_rescaled -sub 0.5 ${subj}-${visit}_MP2RAGE-Gd-UNI_std
		else
			echo "Skipping...."
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI.nii.gz ] && [ -f ./${visit}_MP2RAGE-GD-UNI_rescaled.nii.gz ] ; then
			cp ${visit}_MP2RAGE-Gd-UNI_rescaled.nii.gz ${subj}-${visit}_MP2RAGE-Gd-UNI.nii.gz
		fi

		## N4_correction: INV2_N4 and Gd-INV2_N4
		cd ${workDIR}/${subj}/${visit}/out

		if [ ! -f ./${visit}_MP2RAGE-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-INV2.nii.gz ]; then
			echo "N4 correction for INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-INV2.nii.gz -o [${visit}_MP2RAGE-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-INV2.nii.gz]
			echo ""
		else
			echo "Skipping..."
		fi

		if [ ! -f ./${visit}_MP2RAGE-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-INV2_e1.nii.gz ]; then
			echo "N4 correction for INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-INV2_e1.nii.gz -o [${visit}_MP2RAGE-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-INV2.nii.gz]
			echo ""
		else
			echo "Skipping..."
		fi
		
		if [ ! -f ./${visit}_MP2RAGE-Gd-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-INV2.nii.gz ]; then
			echo "N4 correction for Gd-INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-Gd-INV2.nii.gz -o [${visit}_MP2RAGE-Gd-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-Gd-INV2.nii.gz]
			echo ""
		else
			echo "Skipping..."
		fi	

		if [ ! -f ./${visit}_MP2RAGE-Gd-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-INV2_e1.nii.gz ]; then
			echo "N4 correction for Gd-INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-Gd-INV2_e1.nii.gz -o [${visit}_MP2RAGE-Gd-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-Gd-INV2.nii.gz]
			echo ""
		else
			echo "Skipping..."
		fi


		## UNI_DEN & Gd-UNI_DEN
		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI_DEN.nii.gz ] && [ -f ./${visit}_MP2RAGE-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-UNI_rescaled.nii.gz ]; then	
			echo "Making UNI_DEN..."
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-UNI_rescaled -mul ${visit}_MP2RAGE-INV2_N4 ${subj}-${visit}_MP2RAGE-UNI_DEN.nii.gz
			echo "Made UNI_DEN."
		else 	
			echo "Skipping..."
		fi
	 
		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_DEN.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-UNI_rescaled.nii.gz ]; then	
			echo "Making Gd-UNI_DEN..."
			${FSLDIR}/bin/fslmaths ${visit}_MP2RAGE-Gd-UNI_rescaled -mul ${visit}_MP2RAGE-Gd-INV2_N4 ${subj}-${visit}_MP2RAGE-Gd-UNI_DEN
			echo "Made Gd-UNI_DEN."
		else 	
			echo "Skipping..."
		fi

		## Skull stripping
		dirMASK=~/Desktop/ANTs_Templates/Kirby # Where the templates are saved.
		t1w=UNI_DEN
		if [ ! -f ./${subj}-${visit}_MP2RAGE-${t1w}-BrainExtractionBrain.nii.gz ]; then
			
			echo "Extracting brain of ${subj}/${visit} ..." 
			time ${ANTSPATH}/antsBrainExtraction.sh \
						-d 3 \
						-a ${subj}-${visit}_MP2RAGE-${t1w}.nii.gz \
						-e ${dirMASK}/S_template3.nii.gz \
						-m ${dirMASK}/S_template3_BrainExtractionProbabilityMask.nii.gz \
						-o ${subj}-${visit}_MP2RAGE-${t1w}-
		elif [ -f ./${subj}-${visit}_MP2RAGE-${t1w}-BrainExtractionBrain.nii.gz ]; then
			echo "Skipping..."
		fi


		echo "Done for ${subj}/${visit}."	
	
	done
	echo "Done for ${subj}."
	
done
echo "All done."

echo "##########################################################"
echo "Make T1 map using Marques MP2RAGE toolbox before Step 2-2."
echo "##########################################################" 	



