DICOMDIR=/Volumes/Anvil/sync/mri.raw/adolescent-development-study/dicoms
BIDSDIR=/Volumes/Anvil/sync/datasets/ads.bids.dataset
# Get dependencies (make into function later...)
if [ -z $(which dcm2niix) ]; then
    if [ $(uname) = 'Darwin' ]; then
        if [ -z $(which brew) ]; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        brew install dcm2niix
    elif [ $(uname) = 'Linux' ]; then
        git clone https://github.com/rordenlab/dcm2niix.git ${HOME}/dcm2niix
        cd ${HOME}/dcm2niix
		mkdir build && cd build
		cmake ..
		make
    fi
fi
if [ -z $(which dcm2bids) ]; then
	git clone https://github.com/cbedetti/Dcm2Bids.git ${HOME}/Dcm2Bids
	cd ${HOME}/Dcm2Bids
	pip install .	
fi
if [ -z $(which parallel) ]; then
    if [ $(uname) = 'Darwin' ]; then
        if [ -z $(which brew) ]; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        brew install parallel
    elif [ $(uname) = 'Linux' ]; then
    	echo "GNU parallel does not exist on this system.. this installation is complicated.. please download->build first then run this again.. sorry! exiting.." && exit
    fi
fi
#
subjects=$(find ${DICOMDIR}/ -type d -d 1 | sed 's|/| |g' | awk '{print $NF}')
##  build jsons for each subject
for subject in ${subjects}; do
	parallel -k --link --bar dcm2niix -b o -ba n ${DICOMDIR}/${subject}/{} ::: $(find ${DICOMDIR}/${subject} -type d -d 1 | sed 's|/| |g' | awk '{print $NF}') 
done
## now convert
parallel -k --link --bar dcm2bids --forceDcm2niix --clobber -d ${DICOMDIR}/{}/* -p {} -s ses-01 -c /Volumes/Anvil/sync/mri.raw/adolescent-development-study/config.json -o ${BIDSDIR} ::: $(find ${DICOMDIR}/ -type d -d 1 | sed 's|/| |g' | awk '{print $NF}')	