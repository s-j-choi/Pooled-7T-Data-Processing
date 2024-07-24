#!/bin/bash

################################################################################
# Last updated: 2022-12-05 (Seongjin Choi)				       #
################################################################################
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
		echo "######################################"
		echo "Working on ${subj}/${visit}..."
		cd ${workDIR}/${subj}/${visit}/out

		## pre-contrast
		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI.nii.gz ]; then
			echo ">>> Preparing files to use..."
			cp ${visit}_MP2RAGE_real_t93.nii.gz Re_INV1.nii.gz
			cp ${visit}_MP2RAGE_real_t131.nii.gz Re_INV1.nii.gz
			cp ${visit}_MP2RAGE_real_t148.nii.gz Re_INV1.nii.gz
			cp ${visit}_MP2RAGE_real_t1870.nii.gz Re_INV2.nii.gz
			cp ${visit}_MP2RAGE_real_t1897.nii.gz Re_INV2.nii.gz
			cp ${visit}_MP2RAGE_real_t1936.nii.gz Re_INV2.nii.gz
			cp ${visit}_MP2RAGE_real_t2025.nii.gz Re_INV2.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t93.nii.gz Im_INV1.nii.gz						
			cp ${visit}_MP2RAGE_imaginary_t131.nii.gz Im_INV1.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t148.nii.gz Im_INV1.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t1870.nii.gz Im_INV2.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t1897.nii.gz Im_INV2.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t1936.nii.gz Im_INV2.nii.gz
			cp ${visit}_MP2RAGE_imaginary_t2025.nii.gz Im_INV2.nii.gz

			echo ">>> Calculating UNI for ${subj}/${visit} based on Marques et al. 2010..."
			echo ">>> Calculating numerator..."
			${FSLDIR}/bin/fslmaths Re_INV1 -mul Re_INV2 Re1xRe2	
			${FSLDIR}/bin/fslmaths Im_INV1 -mul Im_INV2 Im1xIm2
			${FSLDIR}/bin/fslmaths Re1xRe2 -add Im1xIm2 numerator

			echo ">>> Calculating denominator..."
			${FSLDIR}/bin/fslmaths Re_INV1 -mul Re_INV1 Re1xRe1
			${FSLDIR}/bin/fslmaths Re_INV2 -mul Re_INV2 Re2xRe2
			${FSLDIR}/bin/fslmaths Im_INV1 -mul Im_INV1 Im1xIm1
			${FSLDIR}/bin/fslmaths Im_INV2 -mul Im_INV2 Im2xIm2
			${FSLDIR}/bin/fslmaths Re1xRe1 -add Re2xRe2 -add Im1xIm1 -add Im2xIm2 denominator

			echo ">>> Calculating UNI..."
			${FSLDIR}/bin/fslmaths numerator -div denominator -add 0.5 ${subj}-${visit}_MP2RAGE-UNI
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_MP2RAGE-UNI -sub 0.5 ${subj}-${visit}_MP2RAGE-UNI_std
			echo "Calculated UNI. <<<" 
		else	
			echo "Skipping..."
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-UNI_DEN.nii.gz ]; then
			echo ">>> Denoising UNI..."
			${FSLDIR}/bin/fslmaths Re2xRe2 -add Im2xIm2 ${visit}_INV2SQRD
			${FSLDIR}/bin/fslmaths ${visit}_INV2SQRD -sqrt ${visit}_MP2RAGE-INV2
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_MP2RAGE-UNI -mul ${visit}_MP2RAGE-INV2 ${subj}-${visit}_MP2RAGE-UNI_DEN
			echo "Denoised. <<<"
		else
			echo "Skipping..."
		fi

		## post-contrast
		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI.nii.gz ]; then
			echo ">>> Preparing files to use for MP2RAGE Gd images..."
			cp ${visit}_Gd-MP2RAGE_real_t93.nii.gz Gd-Re_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t131.nii.gz Gd-Re_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t148.nii.gz Gd-Re_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t1870.nii.gz Gd-Re_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t1897.nii.gz Gd-Re_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t1936.nii.gz Gd-Re_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t2008.nii.gz Gd-Re_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_real_t2025.nii.gz Gd-Re_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t93.nii.gz Gd-Im_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t131.nii.gz Gd-Im_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t148.nii.gz Gd-Im_INV1.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t1870.nii.gz Gd-Im_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t1897.nii.gz Gd-Im_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t1936.nii.gz Gd-Im_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t2008.nii.gz Gd-Im_INV2.nii.gz
			cp ${visit}_Gd-MP2RAGE_imaginary_t2025.nii.gz Gd-Im_INV2.nii.gz			
						
			echo ">>> Calculating Gd-UNI for ${subj} based on Marques et al. 2010..."
			echo ">>> Calculating Gd numerator..."
			${FSLDIR}/bin/fslmaths Gd-Re_INV1 -mul Gd-Re_INV2 Gd-Re1xRe2
			${FSLDIR}/bin/fslmaths Gd-Im_INV1 -mul Gd-Im_INV2 Gd-Im1xIm2
			${FSLDIR}/bin/fslmaths Gd-Re1xRe2 -add Gd-Im1xIm2 Gd-numerator
			echo ">>> Calculating Gd denominator..."
			${FSLDIR}/bin/fslmaths Gd-Re_INV1 -mul Gd-Re_INV1 Gd-Re1xRe1
			${FSLDIR}/bin/fslmaths Gd-Re_INV2 -mul Gd-Re_INV2 Gd-Re2xRe2
			${FSLDIR}/bin/fslmaths Gd-Im_INV1 -mul Gd-Im_INV1 Gd-Im1xIm1
			${FSLDIR}/bin/fslmaths Gd-Im_INV2 -mul Gd-Im_INV2 Gd-Im2xIm2
			${FSLDIR}/bin/fslmaths Gd-Re1xRe1 -add Gd-Re2xRe2 -add Gd-Im1xIm1 -add Gd-Im2xIm2 Gd-denominator
			echo ">>> Calculating Gd-UNI..."
			${FSLDIR}/bin/fslmaths Gd-numerator -div Gd-denominator -add 0.5 ${subj}-${visit}_MP2RAGE-Gd-UNI
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_MP2RAGE-Gd-UNI -sub 0.5 ${subj}-${visit}_MP2RAGE-Gd-UNI_std
			echo "Calculated Gd-UNI. <<<" 
		else	
			echo "Skipping..."
		fi

		if [ ! -f ./${subj}-${visit}_MP2RAGE-Gd-UNI_DEN.nii.gz ]; then
			echo ">>> Denoising Gd-UNI..."
			${FSLDIR}/bin/fslmaths Gd-Re2xRe2 -add Gd-Im2xIm2 ${visit}_Gd-INV2SQRD
			${FSLDIR}/bin/fslmaths ${visit}_Gd-INV2SQRD -sqrt ${visit}_MP2RAGE-Gd-INV2
			${FSLDIR}/bin/fslmaths ${subj}-${visit}_MP2RAGE-Gd-UNI -mul ${visit}_MP2RAGE-Gd-INV2 ${subj}-${visit}_MP2RAGE-Gd-UNI_DEN
			echo "Denoised. <<<"
		else
			echo "Skipping..."
		fi



		## N4_correction for INV2
		if [ ! -f ./${visit}_MP2RAGE-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-INV2.nii.gz ]; then
			echo "N4 correction for INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-INV2.nii.gz -o [${visit}_MP2RAGE-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-INV2.nii.gz]
			echo ""
		else
			echo "Skipping..."
		fi



		## N4_correction for Gd-INV2
		if [ ! -f ./${visit}_MP2RAGE-Gd-INV2_N4.nii.gz ] && [ -f ./${visit}_MP2RAGE-Gd-INV2.nii.gz ]; then
			echo "N4 correction for Gd-INV2..."
			time ${ANTSPATH}/N4BiasFieldCorrection -i ${visit}_MP2RAGE-Gd-INV2.nii.gz -o [${visit}_MP2RAGE-Gd-INV2_N4.nii.gz, bias_${visit}_MP2RAGE-Gd-INV2.nii.gz]
			echo ""
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



