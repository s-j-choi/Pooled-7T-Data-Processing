#!/bin/bash

################################################################################
# Last updated: 2022-12-12 (Seongjin Choi)				       #
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
	#visitlist="2019-07-01"
	for visit in ${visitlist}
	do

		## XFMing to MNI152 space
		MNI=~/Desktop/MNI_reference_image/MNI152_T1_0.7mm_brain.nii.gz

		cd ${workDIR}/${subj}/${visit}/out
		
		## XFM UNI_DEN_BETed to MNI152 space #####
		## antsRegistrationSyN: fast for intra-contrast XFM compared to antsRegistration.sh
		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_Warped.nii.gz ]; then
			dim=3
			precision=f           # {f:float, d:double}
			hitogram_matching=0   # 0: no histogram matching, 1: use histogram matching
			gradient_step=0.1     
			cc_radius=4           # radius for cross correlation metric used in SyN
			number_of_cores=4     # the number of CPU cores to be used
			SyN=r		      # rigid XFM	
			time ${ANTSPATH}/antsRegistrationSyN.sh -d ${dim} \
								-p ${precision} \
								-f ${MNI} \
								-m ${subj}-${visit}_MP2RAGE-UNI_DEN-BrainExtractionBrain.nii.gz \
								-o ${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_ \
								-t ${SyN} \
								-j ${histogram_matching} \
								-g ${gradient_step} \
								-n ${number_of_cores} \
								-r ${cc_radius} \
								-v 1
		else
			echo "Skipping..."	
		fi



		## XFM MP2RAGE driven maps to MNI152
		images="MP2RAGE-UNI MP2RAGE-UNI_DEN T1_map_std MP2RAGE-UNI_DEN-BrainExtractionMask"
		for image in ${images}
		do
			## image to MNI152_space
			if [ ! -f ./${subj}-${visit}_${image}_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_${image}.nii.gz ]; then
				echo "XFMing ${image} with skull to MNI152 space..." 
				# --float 0 = DOUBLE, 1 = SINGLE 
				# -e 0/1/2/3: scalar/vector/tensor/time-series
				dim=3
				interpolation=Linear
				XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat
				time ${ANTSPATH}/antsApplyTransforms -d $dim \
								     --float 1 \
								     -e 0 \
								     -r ${MNI} \
								     -i ${subj}-${visit}_${image}.nii.gz \
								     -o ${subj}-${visit}_${image}_in_MNI152.nii.gz \
								     -n ${interpolation} \
								     -t ${XFM1} \
								     -v 1
			else
				echo "Skipping..."
			fi
		done 



		## In case of Post-contrast MP2RAGE exist
		if [ -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_DEN.nii.gz ]; then
			if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_DEN_2_UNI_DEN_Warped.nii.gz ]; then
			dim=3
			precision=f           # {f:float, d:double}
			hitogram_matching=0   # 0: no histogram matching, 1: use histogram matching
			gradient_step=0.1     
			cc_radius=4           # radius for cross correlation metric used in SyN
			number_of_cores=4     # the number of CPU cores to be used
			SyN=r		      # rigid XFM
			time ${ANTSPATH}/antsRegistrationSyN.sh -d ${dim} \
								-p ${precision} \
								-f ${subj}-${visit}_MP2RAGE-UNI_DEN.nii.gz \
								-m ${subj}-${visit}_MP2RAGE-Gd-UNI_DEN.nii.gz \
								-o ${subj}-${visit}_MP2RAGE-Gd-UNI_DEN_2_UNI_DEN_ \
								-t ${SyN} \
								-j ${histogram_matching} \
								-g ${gradient_step} \
								-n ${number_of_cores} \
								-r ${cc_radius} \
								-v 1
			else
				echo "Skipping..."	
			fi

			images="MP2RAGE-Gd-UNI MP2RAGE-Gd-UNI_DEN Gd-T1_map_std"
			for image in $images
			do
				## image to MNI152_space
				if [ ! -f ./${subj}-${visit}_${image}_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_${image}.nii.gz ]; then
					echo "XFMing $image with skull to MNI152 space..." 
					# --float 0 = DOUBLE, 1 = SINGLE 
					# -e 0/1/2/3: scalar/vector/tensor/time-series
					dim=3
					interpolation=Linear
					XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat
					GdXFM1=${subj}-${visit}_MP2RAGE-Gd-UNI_DEN_2_UNI_DEN_0GenericAffine.mat
					time ${ANTSPATH}/antsApplyTransforms -d $dim \
									     --float 1 \
									     -e 0 \
									     -r ${MNI} \
									     -i ${subj}-${visit}_${image}.nii.gz \
									     -o ${subj}-${visit}_${image}_in_MNI152.nii.gz \
									     -n ${interpolation} \
									     -t ${XFM1} \
									     -t ${GdXFM1} \
									     -v 1
				else
					echo "Skipping..."
				fi
			done
		fi


		# Outskull mask for expanded brain mask
		n=2
		thr=0.$n
		thrf=RSBFA_f0p$n
		
		# Make an outskull mask of UNI_DEN if Gd-FLAIR exists, in order to make LTS-Gd_FLAIR.  
		# Mesh -bet -A option to run 'bet2 -e option' and inskull/outsckull masks
		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152_brain_${thrf}_outskull_mask.nii.gz ] && [ -f ./${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152.nii.gz ]; then
			echo "Working on ${subj}/${visit}..."
			time ${FSLDIR}/bin/bet ${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152 ${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152_brain_${thrf} -o -f ${thr} -g 0 -m -R -S -B -F -A -v
			echo "Done."
		elif [ -f ./${subj}-${visit}_MP2RAGE-UNI_DEN_in_MNI152_brain_${thrf}_outskull_mask.nii.gz ]; then
			echo "Outskull mask exsits."
		else
			echo "Pass."
		fi

		echo "Done for ${subj}/${visit}."

	done
	
	echo "Done for ${subj}."
done

echo "All done."



