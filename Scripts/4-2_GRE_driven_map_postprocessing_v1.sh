#!/bin/bash

################################################################################
# Last updated: 2022-12-13 (Seongjin Choi)				       #
################################################################################
## Set your SITE
## 4-echo selected
#site=MNI
site=UMB

## 3-echo selecrted
#site=UPENN

# Location of unwrapped phase images
unwrapDIR=/media/sf_D_DRIVE/Pooled_PhaseUnwrapping

# Location of data downloaded unzipped.
workDIR=/media/sf_Y_DRIVE/Pooled_7T_Data/NAIMS_IR_download/29/pooled-7t-mri-ms_2
cd ${workDIR}

# Get subject folder names in the location where data have been unzipped.
subjlist=`ls`

####################################################################################################
# When a few individuals need to be processed, provide a specific ID and uncomment the line below. #
####################################################################################################
#subjlist="pooled-7t-mri-ms_023 pooled-7t-mri-ms_024 pooled-7t-mri-ms_025"

for subj in ${subjlist}
do
	cd ${workDIR}/${subj}/
	# Get the visit folder names under each subject. 
	#visitlist=`ls`
	visitlist="2019-07-01"
	for visit in ${visitlist}
	do
		echo "Working on ${subj}/${visit}..."
		### Collect unwrapped phase images if they eixist. Concatenate them before copying them.
		if [ ! -f ${workDIR}/${subj}/${visit}/out/${subj}-${visit}_GRE_all_phs_Unwrapped.nii.gz ]; then
			cd ${unwrapDIR}/${subj}/${visit}/
			
			# 6-echo GRE
			if [ -f ./${visit}_GRE_e6_ph_UNWRAPPED.nii.gz ]; then
				echo "Merging ${subj}/${visit} unwrapped phase images..."
				${FSLDIR}/bin/fslmerge -t ${workDIR}/${subj}/${visit}/out/${subj}-${visit}_GRE_all_phs_Unwrapped ${visit}_GRE_e1_ph_UNWRAPPED ${visit}_GRE_e2_ph_UNWRAPPED ${visit}_GRE_e3_ph_UNWRAPPED ${visit}_GRE_e4_ph_UNWRAPPED ${visit}_GRE_e5_ph_UNWRAPPED ${visit}_GRE_e6_ph_UNWRAPPED
				echo "Merged."
				#cp ${visit}_GRE_all_phs_Unwrapped.nii.gz ${workDIR}/${subj}/${visit}/out
				echo "Copied."
			fi
			
			# 5-echo GRE
			if [ -f ./${visit}_GRE_e5_ph_UNWRAPPED.nii.gz ] && [ ! -f ./${visit}_GRE_e6_ph_UNWRAPPED.nii.gz ]; then
				echo "Merging ${subj}/${visit} unwrapped phase images..."
				${FSLDIR}/bin/fslmerge -t ${workDIR}/${subj}/${visit}/out/${subj}-${visit}_GRE_all_phs_Unwrapped ${visit}_GRE_e1_ph_UNWRAPPED ${visit}_GRE_e2_ph_UNWRAPPED ${visit}_GRE_e3_ph_UNWRAPPED ${visit}_GRE_e4_ph_UNWRAPPED ${visit}_GRE_e5_ph_UNWRAPPED
				echo "Merged."
				#cp ${visit}_GRE_all_phs_Unwrapped.nii.gz ${workDIR}/${subj}/${visit}/out
				echo "Copied."
			fi 
			
		else
			echo "Pass."
		fi 

		cd ${workDIR}/${subj}/${visit}/out

		# 4-echo selected: MNI, UMB
		if [ "${site}" = "MNI" ] || [ "${site}" = "UMB" ]; then
			if [ ! -f ./${subj}-${visit}_mean_selected_GREmags.nii.gz ] && [ -f ./${subj}-${visit}_GREmags.nii.gz ]; then

				echo "Averaging magnitudes of selected 4 echoes..."
				${FSLDIR}/bin/fslroi ${subj}-${visit}_GREmags ${subj}-${visit}_selected_GREmags 1 4  
				${FSLDIR}/bin/fslmaths ${subj}-${visit}_selected_GREmags -Tmean ${subj}-${visit}_mean_selected_GREmags
				echo "Averaged."
			else
				echo "Pass."
			fi

			if [ ! -f ./${subj}-${visit}_mean_selected_GREphs_Unwrapped.nii.gz ] && [ -f ./${subj}-${visit}_GRE_all_phs_Unwrapped.nii.gz ]; then

				echo "Averaging phases of selected 4 echoes..."
				${FSLDIR}/bin/fslroi ${subj}-${visit}_GRE_all_phs_Unwrapped ${subj}-${visit}_selected_GREphs 1 4  
				${FSLDIR}/bin/fslmaths ${subj}-${visit}_selected_GREphs -Tmean ${subj}-${visit}_mean_selected_GREphs_Unwrapped
				echo "Averaged."
			else
				echo "Pass."	
			fi
	
		fi

		# 3-echo selected: UPENN
		if [ "${site}" = "UPENN" ]; then
			if [ ! -f ./${subj}-${visit}_mean_selected_GREmags.nii.gz ] && [ -f ./${subj}-${visit}_GREmags.nii.gz ]; then
				echo "Averaging magnitudes of selected 3 echoes..."
				${FSLDIR}/bin/fslroi ${subj}-${visit}_GREmags ${subj}-${visit}_selected_GREmags 1 3  
				${FSLDIR}/bin/fslmaths ${subj}-${visit}_selected_GREmags -Tmean ${subj}-${visit}_mean_selected_GREmags
				echo "Averaged."
			else
				echo "Pass."
			fi

			if [ ! -f ./${subj}-${visit}_mean_selected_GREphs_Unwrapped.nii.gz ] && [ -f ./${subj}-${visit}_GRE_all_phs_Unwrapped.nii.gz ]; then
				echo "Averaging phases of selected 3 echoes..."
				${FSLDIR}/bin/fslroi ${subj}-${visit}_GRE_all_phs_Unwrapped ${subj}-${visit}_selected_GREphs 1 3  
				${FSLDIR}/bin/fslmaths ${subj}-${visit}_selected_GREphs -Tmean ${subj}-${visit}_mean_selected_GREphs_Unwrapped
				echo "Averaged."
			else
				echo "Pass."	
			fi
	
		fi

		# Copy QSM  to /out/ folder
		if [ "${site}" = "UMB" ]; then
			if [ ! -f ./${subj}-${visit}_QSM.nii.gz ]; then
				#Need some header work for UMB QSM results.
				${FSLDIR}/bin/fslswapdim ${workDIR}/${subj}/${visit}/gre/1_chi_SFCR+0_Avg x -y z ${workDIR}/${subj}/${visit}/gre/1_chi_SFCR+0_Avg_reoriented
				${FSLDIR}/bin/fslcpgeom ${subj}-${visit}_GREmags.nii.gz ${workDIR}/${subj}/${visit}/gre/1_chi_SFCR+0_Avg_reoriented  		
				cp ${workDIR}/${subj}/${visit}/gre/1_chi_SFCR+0_Avg_reoriented.nii.gz ${subj}-${visit}_QSM.nii.gz		
			fi
		fi 		
		
		if [ "${site}" = "UPENN" ] || [ "${site}" = "MNI" ]; then
			if [ ! -f ./${subj}-${visit}_QSM.nii.gz ]; then
				cp ./GRE/GRE_chi_SFCR+0_Avg.nii.gz ./${subj}-${visit}_QSM.nii.gz
			fi
		fi

		## XFMing GRE-driven images/maps to MNI152 space
		MNI=~/Desktop/MNI_reference_image/MNI152_T1_0.7mm_brain.nii.gz
		## Applying XFM1 ad XFM3
		images="mean_selected_GREmags GRE_all_phs_Unwrapped mean_selected_GREphs_Unwrapped QSM"
		for image in ${images}
		do
			if [ ! -f ./${subj}-${visit}_${image}_in_MNI152.nii.gz ] && [ -f ./${subj}-${visit}_${image}.nii.gz ]; then
				echo ""
				echo "XFMing ${image} to MNI152 space..." 
				# --float 0 = DOUBLE, 1 = SINGLE 
				# -e 0/1/2/3: scalar/vector/tensor/time-series
				dim=3
				interpolation=Linear
				## XFMs used
				XFM3=${subj}-${visit}_GRE_mag_e1_N4_2_INV2_N4_0GenericAffine.mat
				XFM1=${subj}-${visit}_MP2RAGE-UNI_DEN_brain_2_MNI152_0GenericAffine.mat
				time ${ANTSPATH}/antsApplyTransforms -d $dim \
								     --float 1 \
								     -e 3 \
								     -r ${MNI} \
								     -i ${subj}-${visit}_${image}.nii.gz \
								     -o ${subj}-${visit}_${image}_in_MNI152.nii.gz \
								     -n ${interpolation} \
								     -t ${XFM1} \
								     -t ${XFM3} \
								     -v 1
				echo "${image} XFMed."
			else
				echo "Pass."
			fi

			
		done 
		echo "Done for ${subj}/${visit}."
		
	done	
	echo "Done for ${subj}."
done
echo "All done."



