- This repository contains a collection of processing scripts that have been utilized for the processing of multi-site MRI data.

- The scripts are written in BASH and have been tested on XUBUNTU 18.04 LTS VirtualBox. They should also be compatible with XUBUNTU/UBUNTU 18.04 LTS running on actual Linux machines.

- Dependencies
  The scripts require the following software and libraries:

  - dcm2niix
  - FSL
  - ANTs
  - Nibabel
  - Python

- Functionalities
  The scripts carry out the following operations:
  - Conversion of Simens dicom files and Philips ParRec files
  - Pre-processing and post-processing of MP2RAGE files
  - Intensity normalization of FLAIR, along with pre- and post-processing
  - Pre-processing and post-processing of GRE

- Apart from the scripts, the current processing procedure also utilizes several external tools.
  - MatLab (tested on 2019a) is required to process GRE files for R2* map, QSM, and MP2RAGE T1 map.
  - JHUKKI QSM Toolbox (Dr. Xu Li) is required to process GRE images for QSM processing.
    https://github.com/xuli99/JHUKKI_QSM_Toolbox
  - T1 processing MatLab tool by Jose P. Marques.
    https://github.com/JosePMarques/MP2RAGE-related-scripts
  - A Docker tool (Dr. Blake Dewey) is required to process filtered phase images using a Laplacian-based phase unwrapping algorithm and Gaussian high-pass filtering. https://github.com/blakedewey/phase_unwrap
  - A Python tool for Least Trimmed Squared (LTS) algorithm-based intensity normalization 

