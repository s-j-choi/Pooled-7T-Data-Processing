# Pooled-7T-Data-Processing
- The current collection of processing scripts has been used to process multi-site data. 
- The scripts are written in BASH and tested on XUBUNTU 18.04 LTS. They should work on UBUNTU 18.04 LTS as well.
- The scripts require FSL and ANTs preinstalled via Neurodebian.
- In addition to the scripts, three external tools (one Matlab, one Python on Docker, and one Python) are employed in the current processing procedure.
  - MatLab (tested on 2019a) is required.
- 

- All tools were installed using Neurodebian packages
  i. dcm2niix: for dicom file conversion
  ii.	FSL: for basic nifty file processing
  iii.	ANTs: for basic nifty file processing 
  iv.	Nibabel: python packages for neuroimaging data processing
  v.	Python installed (via Anaconda)

-	BASH scripts for 
  o	file conversion: one for Philips data, the other for Siemen data 
  o	MP2RAGE file processing: 2 scripts. 
  o	FLAIR processing: 1 script 
  o	GRE processing: 2 scripts

-	External tools required:
  o	Matlab for processing GRE R2* map/QSM and MP2RAGE T1 map
  o	Docker tool (Dr. Blake @ JHU) for Laplacian-based phase unwrapping of GRE phase image

