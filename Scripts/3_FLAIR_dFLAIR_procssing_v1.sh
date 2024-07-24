#!/bin/bash

################################################################################
# Last updated: 2022-12-12, Seongjin Choi				       #
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

		echo "Working on ${subj}/${visit}..."
		cd ${workDIR}/${subj}/${visit}/out


		## N4_correction 
		if [ ! -f ./${subj}-${visit}_FLAIR_N4.nii.gz ] && [ -f ./${visit}_FLAIR.nii.gz ]; then
			echo "N4 correction for FLAIR..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_FLAIR.nii.gz -o [ ${subj}-${visit}_FLAIR_N4.nii.gz, bias_${visit}_FLAIR.nii.gz ]
			echo ""
		else
			echo "Skipping..."
		fi

		## Gd-FLAIRs
		if [ ! -f ./${subj}-${visit}_Gd-FLAIR_N4.nii.gz ] && [ -f ./${visit}_Gd-FLAIR.nii.gz ]; then
			echo "N4 correction for Gd-FLAIR..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_Gd-FLAIR.nii.gz -o [ ${subj}-${visit}_Gd-FLAIR_N4.nii.gz, bias_${visit}_Gd-FLAIR.nii.gz ]
			echo ""
		else
			echo "Skipping..."
		fi


		## XFMing
		# Rigid Coregisration
			# Linear transformation
			# ANTs parameters for "antsRegistration"
			dim=3
			XFM2=Rigid
			hitogram_matching=0 # {0 = intermodal, 1 = intramodal}
			interpolation=Linear 
			shrink_factors=8x4x2x1
			smoothing_sigmas=3x2x1x0vox

		######################
		## FLAIR to MP2RAGE ##
		######################
		
		## FLAIR to MP2RAGE: XFM2_F_M 
		if [ ! -f ./${subj}-${visit}_FLAIR_N4_2_MP2RAGE_0GenericAffine.mat ] && [ -f ./${subj}-${visit}_FLAIR_N4.nii.gz ]; then
			echo "ANTs coregistering FLAIR_N4 to INV2_N4..."
						# --float 0 = DOUBLE, 1 = SINGLE
			time ${ANTSPATH}/antsRegistration -d ${dim} --float 1 \
		     					  -o [ ${subj}-${visit}_FLAIR_N4_2_MP2RAGE_, ${subj}-${visit}_FLAIR_N4_in_MP2RAGE_space.nii.gz ] \
							  -w [0.005, 0.995] \
							  -n ${interpolation} \
							  -u ${hitogram_matching} \
							  -r [ ${visit}_MP2RAGE-INV2_N4.nii.gz, ${subj}-${visit}_FLAIR_N4.nii.gz, 1 ] \
							  -t ${XFM2}[ 0.1 ] \
							  -m MI[ ${visit}_MP2RAGE-INV2_N4.nii.gz, ${subj}-${visit}_FLAIR_N4.nii.gz, 1, 32, Regular, 0.25 ] \
							  -c [ 1000x500x250x100, 1e-6, 10 ] \
							  -f ${shrink_factors} \
							  -s ${smoothing_sigmas} \
							  -v 1
		else
			echo "Skipping..."
		fi

		###########################
		## PostGd-FLAIR to FLAIR ##
		###########################
		
		# Gd_FLAIR to FLAIR_space: XFM2_GdF_F
		if [ ! -f ./${subj}-${visit}_Gd-FLAIR_N4_2_FLAIR_0GenericAffine.mat ] && [ -f ${subj}-${visit}_Gd-FLAIR_N4.nii.gz ]; then
			echo "ANTs coregistering Gd-FLAIR_N4 to FLAIR_N4..."
						# --float 0 = DOUBLE, 1 = SINGLE
			time ${ANTSPATH}/antsRegistration -d ${dim} --float 1 \
		     					  -o [ ${subj}-${visit}_Gd-FLAIR_N4_2_FLAIR_, ${subj}-${visit}_Gd-FLAIR_N4_in_FLAIR_space.nii.gz ] \
							  -w [0.005, 0.995] \
							  -n ${interpolation} \
							  -u ${hitogram_matching} \
							  -r [ ${subj}-${visit}_FLAIR_N4.nii.gz, ${subj}-${visit}_Gd-FLAIR_N4.nii.gz, 1 ] \
							  -t ${XFM2}[ 0.1 ] \
							  -m MI[ ${subj}-${visit}_FLAIR_N4.nii.gz, ${subj}-${visit}_Gd-FLAIR_N4.nii.gz, 1, 32, Regular, 0.25 ] \
							  -c [ 1000x500x250x100, 1e-6, 10 ] \
							  -f ${shrink_factors} \
							  -s ${smoothing_sigmas} \
							  -v 1
		else
			echo "Skipping..."
		fi


		# All XFMss used
		XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat	
		XFM2_F_M=${subj}-${visit}_FLAIR_N4_2_MP2RAGE_0GenericAffine.mat
		XFM2_GdF_M=${subj}-${visit}_Gd-FLAIR_N4_2_MP2RAGE_0GenericAffine.mat
		XFM2_GdF_F=${subj}-${visit}_Gd-FLAIR_N4_2_FLAIR_0GenericAffine.mat


		#########################
		## XFM TO MNI152 space ##
		#########################
		
		## XFMing to MNI152 space
		MNI=~/Desktop/MNI_reference_image/MNI152_T1_0.7mm_brain.nii.gz

		 # FLAIR 2 MP2RAGE 2 MNI
		 if [ ! -f ./${subj}-${visit}_FLAIR_N4_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_FLAIR_N4.nii.gz ]; then
			 echo "XFMing FLAIR_N4 to MP2RAGE_space, then, to MNI152_brain..." 
			 # --float 0 = DOUBLE, 1 = SINGLE 
			 # -e 0/1/2/3: scalr/vector/tensor/time-series
			 dim=3
			 interpolation=Linear
			 ## XFM2_F_M: from FLAIR to MP2RAGE
			 ## XFM1: from MP2RAGE to 
			 time ${ANTSPATH}/antsApplyTransforms -d $dim \
							      --float 1 \
							      -e 0 \
							      -r ${MNI} \
							      -i ${subj}-${visit}_FLAIR_N4.nii.gz \
							      -o ${subj}-${visit}_FLAIR_N4_in_MNI152.nii.gz \
							      -n ${interpolation} \
							      -t ${XFM1} \
							      -t ${XFM2_F_M} \
							      -v 1
		 else
			 echo "Skipping..."
		 fi


		# GdFLAIR to FLAIR to MP2RAGE to MNI152
		 if [ ! -f ./${subj}-${visit}_Gd-FLAIR_N4_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_Gd-FLAIR_N4.nii.gz ]; then
			 echo "XFMing Gd-FLAIR_N4 to FLAIR_space, MP2RAGE, then, to MNI152_brain..." 
			 # --float 0 = DOUBLE, 1 = SINGLE 
			 # -e 0/1/2/3: scalr/vector/tensor/time-series
			 dim=3
			 interpolation=Linear
			 ## XFM2_GdF1_F: from Gd-FLAIR to FLAIR
			 ## XFM2_F_M: from FLAIR to MP2RAGE
			 ## XFM1: from MP2RAGE to MNI
			 XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat
			 time ${ANTSPATH}/antsApplyTransforms -d $dim \
							      --float 1 \
							      -e 0 \
							      -r ${MNI} \
							      -i ${subj}-${visit}_Gd-FLAIR_N4.nii.gz \
							      -o ${subj}-${visit}_Gd-FLAIR_N4_in_MNI152.nii.gz \
							      -n ${interpolation} \
							      -t ${XFM1} \
							      -t ${XFM2_F_M} \
							      -t ${XFM2_GdF_F} \
							      -v 1
		 else
			 echo "Skipping..."
		 fi

		################################################
		## Least Trimmed Squares  if Gd-FLAIR exists. ##
		################################################
		# Outskull mask for LTS normalization of Gd_FLAIR to FLAIR
		n=2
		thr=0.$n
		thrf=RSBFA_f0p$n

		input=${subj}-${visit}_Gd-FLAIR_N4_in_MNI152.nii.gz
		ref=${subj}-${visit}_FLAIR_N4_in_MNI152.nii.gz
		mask=${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152_brain_${thrf}_outskull_mask.nii.gz
		output=${subj}-${visit}_LTS-Gd-FLAIR_in_MNI152.nii.gz
		pyDIR=~/Desktop/Processing_scripts/v1_release/LTS		

		if [ ! -f ./${subj}-${visit}_LTS-dFLAIR_in_MNI152.nii.gz ] && [ -f ./${input} ]; then
			echo "Working on ${visit}..."
			### Applying LTS to Gd-FLAIR.
			time python ${pyDIR}/LTS_2022-0825_updated_skull_on.py --input ${input} --ref ${ref} --mask ${mask} --output ${output}
			### Substraction image
			${FSLDIR}/bin/fslmaths ${output} -sub ${ref} ${subj}-${visit}_LTS-dFLAIR_in_MNI152
		elif [ -f ./${subj}-${visit}_LTS-dFLAIR_in_MNI152.nii.gz ]; then
			echo "LTS-dFLAIR exists in MNI space."
		else
			echo "Pass."
		fi

		# % dFLAIR
		if [ ! -f ./${subj}-${visit}_prcnt-dFLAIR_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_LTS-dFLAIR_in_MNI152.nii.gz ]; then
			echo "Making percent dFLAIR..."
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_LTS-dFLAIR_in_MNI152 -div ${ref} -mul 100 ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp1
			# Dealing with NaN pixel values
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp1 -nan ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp2
			# Limiting pixel intensity between -3000 and 3000
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp2 -thr -3000 ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp3
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_LTS-dFLAIR_in_MNI152_tmp3 -uthr 3000 ${subj}-${visit}_prcnt-dFLAIR_in_MNI152
			echo "Made it."	
		else
			echo "Pass."
		fi

		echo "Done for ${subj}/${visit}."

	done
	
	echo "Done for ${subj}."
done

echo "All done."


