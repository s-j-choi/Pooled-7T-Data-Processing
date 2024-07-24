#!/bin/bash

################################################################################
# Last updated: 2022-12-13 (Seongjin Choi)				       #
################################################################################
# Location to unwrapp phase images. It needs to be specified on the computer where "DOCKER" is installed. 
unwrapDIR=/media/sf_D_DRIVE/Pooled_PhaseUnwrapping

# Specify the location where data downloaded/unzipped.
workDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/29/pooled-7t-mri-ms_2
cd ${workDIR}
# Get subject flder names in the location where data have been unzipped.
subjlist=`ls`

###############################################################################################
# When an individual has to be processed, provide a specific ID and uncomment the line below. #
###############################################################################################
#subjlist="pooled-7t-mri-ms_002" 

for subj in ${subjlist}
do
	cd ${workDIR}/${subj}/
	# Get the visit folder names under each subject. 
	#visitlist=`ls`
	visitlist="2019-07-01"
	for visit in ${visitlist}
	do
		echo "Working on ${subj}/${visit}..."
		cd ${workDIR}/${subj}/${visit}/out
		
		# MAGNITUDE data
		if [ ! -f ./${subj}-${visit}_GREmags.nii.gz ]; then
			echo "Concatenating ${subj}/${visit} GRE magnitude images..."
			${FSLDIR}/bin/fslmerge -t ${subj}-${visit}_GREmags ${visit}_GRE_e1.nii.gz ${visit}_GRE_e2.nii.gz ${visit}_GRE_e3.nii.gz ${visit}_GRE_e4.nii.gz ${visit}_GRE_e5.nii.gz
			echo "Concatenated."
		else
			echo "Skipping..."
		fi

		# PHASE data
		if [ ! -f ./${subj}-${visit}_GREphs.nii.gz ]; then
			echo "Concatenating ${subj}/${visit} GRE phase images..."
			${FSLDIR}/bin/fslmerge -t ${subj}-${visit}_GREphs ${visit}_GRE_e1_ph.nii.gz ${visit}_GRE_e2_ph.nii.gz ${visit}_GRE_e3_ph.nii.gz ${visit}_GRE_e4_ph.nii.gz ${visit}_GRE_e5_ph.nii.gz
			echo "Concatenated."
		else
			echo "Skipping..."
		fi


		# Step 1: N4 correction before perform XFM.
		# Step 2: Get XFM3 from GRE_e1_N4 to INV2_N4. 
		# Step 3: Apply XFM1 & XFM3 to the GREmags: GREmags in MNI152 space

		## Step 1: N4 correction
		if [ ! -f ./${subj}-${visit}_GRE_mag_e1_N4.nii.gz ]; then
			echo "N4 correction for GRE_mag_e1..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_GRE_e1.nii.gz -o [${subj}-${visit}_GRE_mag_e1_N4.nii.gz, bias_${visit}_GRE_e1.nii.gz]
			echo ""
		fi


		## Step 2: Get XFM3 
		# Rigid Coregisration
			# Linear transformation
			# ANTs parameters for "antsRegistration"
			dim=3
			XFM1=Rigid
			hitogram_matching=0 # {0 = intermodal, 1 = intramodal}
			interpolation=Linear 
			shrink_factors=8x4x2x1
			smoothing_sigmas=3x2x1x0vox
		if [ ! -f ./${subj}-${visit}_GRE_mag_e1_N4_2_INV2_N4.nii.gz ]; then
			echo "ANTs coregistering GRE_e1_N4 to INV2_N4..."
						# --float 0 = DOUBLE, 1 = SINGLE
			time ${ANTSPATH}/antsRegistration -d ${dim} --float 1 \
		     					  -o [ ${subj}-${visit}_GRE_mag_e1_N4_2_INV2_N4_, ${subj}-${visit}_GRE_mag_e1_N4_2_INV2_N4.nii.gz ] \
							  -w [0.005, 0.995] \
							  -n ${interpolation} \
							  -u ${hitogram_matching} \
							  -r [ ${visit}_MP2RAGE-INV2_N4.nii.gz, ${subj}-${visit}_GRE_mag_e1_N4.nii.gz, 1 ] \
							  -t ${XFM1}[ 0.1 ] \
							  -m MI[ ${visit}_MP2RAGE-INV2_N4.nii.gz, ${subj}-${visit}_GRE_mag_e1_N4.nii.gz, 1, 32, Regular, 0.25 ] \
							  -c [ 1000x500x250x100, 1e-6, 10 ] \
							  -f ${shrink_factors} \
							  -s ${smoothing_sigmas} \
							  -v 1
		fi

		## XFMing to MNI152 space
		MNI=~/Desktop/MNI_reference_image/MNI152_T1_0.7mm_brain.nii.gz

		## Step 3: Applying XFM1 ad XFM3
		if [ ! -f ./${subj}-${visit}_GREmags_in_MNI152.nii.gz ]; then
			echo "XFMing GREmags to MNI152..." 
			# --float 0 = DOUBLE, 1 = SINGLE 
			# -e 0/1/2/3: scalr/vector/tensor/time-series
			dim=3
			interpolation=Linear
			## XFMs used
			XFM3=${subj}-${visit}_GRE_mag_e1_N4_2_INV2_N4_0GenericAffine.mat
			XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat
			time ${ANTSPATH}/antsApplyTransforms -d $dim \
							     --float 1 \
							     -e 3 \
							     -r ${MNI} \
							     -i ${subj}-${visit}_GREmags.nii.gz \
							     -o ${subj}-${visit}_GREmags_in_MNI152.nii.gz \
							     -n ${interpolation} \
							     -t ${XFM1} \
							     -t ${XFM3} \
							     -v 1
		fi

		# Copying phase images to a location to unwrapp
		if [ ! -f ./${subj}-${visit}_GRE_all_phs_Unwrapped.nii.gz ]; then
			echo "Copying phase images to unwrapDIR/..."
			if [ ! -d ${unwrapDIR}/${subj}/${visit} ]; then
				mkdir ${unwrapDIR}/${subj}
				mkdir ${unwrapDIR}/${subj}/${visit}
			fi
			
			cp ./*_ph.nii.gz ${unwrapDIR}/${subj}/${visit}/
			echo "Done for ${subj}/${visit}."
		else
			echo "Pass."
		fi
 
		echo "Done for ${subj}/${visit}."

	done
	
	echo "Done for ${subj}."
done

echo "All done."


