#!/bin/bash -eu

#Kody błędów
DIRECTORIES_DO_NOT_EXIST=14
NO_PARAMETERS_WERE_GIVEN=27

# Skrypt pobiera dwa argumenty - dwie ścieżki do katalogów
FIRST_DIRECTORY=${1}
SECOND_DIRECTORY=${2}

#Jeżeli nie podamy parametrów -eu??
if [[ $# -lt 2 ]]; then
	exit ${NO_PARAMETERS_WERE_GIVEN}
fi

#Jeżeli katalogi nie istnieją
if [[ ! -d ${FIRST_DIRECTORY} && ! -d ${SECOND_DIRECTORY} ]]; then
	exit ${DIRECTORIES_DO_NOT_EXIST}
fi

# Iterujemy po FIRST_DIRECTORY
FILES_FROM_1_DIRECTORY=$(ls "${FIRST_DIRECTORY}")

for SOMETHING in ${FILES_FROM_1_DIRECTORY}; do
	# Jezeli plik jest katalogiem
	if [[ -d ${FIRST_DIRECTORY}/${SOMETHING} ]]; then
	echo "${SOMETHING} - catalog"
	ln -s $(pwd "{FIRST_DIRECTORY}")/${FIRST_DIRECTORY}/${SOMETHING} ${SECOND_DIRECTORY}/${SOMETHING%.*}_ln
	fi
	
	# Jezeli plik jest dowiązaniem symbolicznym
	if [[ -L ${FIRST_DIRECTORY}/${SOMETHING} ]]; then
	echo "${SOMETHING} - soft link"
	fi
	
	# Jezeli plik jest regularny
	if [[ -f ${FIRST_DIRECTORY}/${SOMETHING} ]]; then
	echo "${SOMETHING} - regular file"
	ln -s $(pwd "{FIRST_DIRECTORY}")/${FIRST_DIRECTORY}/${SOMETHING} ${SECOND_DIRECTORY}/${SOMETHING%.*}_ln.${SOMETHING##*.}
	fi
done

exit 0


