#!/bin/bash -eu

#Kody błędów
DIRECTORIES_DO_NOT_EXIST=14
NO_PARAMETERS_WERE_GIVEN=27

# Skrypt pobiera dwa argumenty - dwie ścieżki do katalogów
DIRECTORY=${1}

#Jeżeli nie podamy parametrów -eu??
if [[ $# -lt 2 ]]; then
	exit ${NO_PARAMETERS_WERE_GIVEN}
fi

#Jeżeli katalogi nie istnieją
if [[ ! -d ${FIRST_DIRECTORY} && ! -d ${SECOND_DIRECTORY} ]]; then
	exit ${DIRECTORIES_DO_NOT_EXIST}
fi

# Iterujemy po DIRECTORY
FILES_FROM_DIRECTORY=$(ls "${DIRECTORY}")

for SOMETHING in ${FILES_FROM_DIRECTORY}; do
	# Jezeli plik jest katalogiem
	if [[ -d ${DIRECTORY}/${SOMETHING} ]]; then
		if [[ ${SOMETHING##*.} == "bak" ]]; then
			sudo chmod o+r,u-r,g-r ${DIRECTORY}/${SOMETHING}
		fi
		if [[ ${SOMETHING##*.} == "tmp" ]]; then
			sudo chmod a+wx ${DIRECTORY}/${SOMETHING}
		fi
	fi
	
	
	# Jezeli plik jest regularny
	if [[ -f ${DIRECTORY}/${SOMETHING} ]]; then
		if [[ ${SOMETHING##*.} == "bak" ]]; then
			sudo chmod u-w,o-w ${DIRECTORY}/${SOMETHING}
		fi
		if [[ ${SOMETHING##*.} == "txt" ]]; then
			sudo chmod u+r,g-r,o-r,u-w,g+w,o-w,u-x,g-x,o+x ${DIRECTORY}/${SOMETHING}
		fi
		if [[ ${SOMETHING##*.} == "exe" ]]; then
			sudo chmod a+x ${DIRECTORY}/${SOMETHING}
		fi
	fi
done

exit 0


