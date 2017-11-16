#!/bin/bash
output_basedir='/Volumes/CFMI-CFS/sync/ADS/data/mri/nii.gz'
input_basedir='/Volumes/CFMI-CFS/sync/ADS/data/mri/dicoms'

for session in ${input_basedir}/t*; do
	parallel --link -k mkdir -p ${output_basedir}/{1}-$(basename ${session}) ::: $(find ${session} ! -path ${session} -type d -maxdepth 1 -exec basename {} \;)
	parallel --bar --link -k dcm2niix -v -t -o "${output_basedir}/{1}-$(basename ${session})" ${session}/{1}/*MPRAGE* ::: $(find ${session} ! -path ${session} -type d -maxdepth 1 -exec basename {} \;)
done

parallel --bar --link -k recon-all -i {} -subject {} ::: $(ls /Volumes/CFMI-CFS/sync/ADS/data/mri/nii.gz/*/*MPRAGE*.nii.gz | awk '{print $NF}') ::: $(ls /Volumes/CFMI-CFS/sync/ADS/data/mri/nii.gz/*/*MPRAGE*.nii.gz | awk '{print $NF}' | sed 's;/GR_IR-Siemens_MPRAGE;;g' | sed 's/.nii.gz//g' | sed 's_/Volumes/CFMI-CFS/sync/ADS/data/mri/__g')
