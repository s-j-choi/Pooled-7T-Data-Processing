# Pooled-7T-Data-Processing
- The current collection of processing scripts has been used to process multi-site data. 
- The scripts are written in BASH and tested on XUBUNTU 18.04 LTS. They should work on UBUNTU 18.04 LTS as well.
- The scripts require the followings:
  - dcm2niix
  - FSL
  - ANTs
  - Nibabel
  - Python
- The scripts perform:
  - file conversion of Simens dicom files and Philips ParRec files
  - MP2RAGE files pre- and post-processing
  - FLAIR intensity normalization, pre- and post-processing
  - GRE pre- and post-processing  

- Apart from the scripts, the current processing procedure also utilizes several external tools.
  - MatLab (tested on 2019a) is required to process GRE files for R2* map, QSM, and MP2RAGE T1 map.
  - JHUKKI QSM Toolbox (Dr. Xu Li) is required to process GRE images for QSM processing.
    https://github.com/xuli99/JHUKKI_QSM_Toolbox
  - T1 processing MatLab tool by Jose P. Marques.
    https://github.com/JosePMarques/MP2RAGE-related-scripts
  - A Docker tool (Dr. Blake Dewey) is required to process filtered phase images using a Laplacian-based phase unwrapping algorithm and Gaussian high-pass filtering. https://github.com/blakedewey/phase_unwrap
  - A Python tool for Least Trimmed Squared (LTS) algorithm-based intensity normalization 

