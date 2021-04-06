#!/bin/bash -eu

#Kody błędów
DIRECTORIES_DO_NOT_EXIST=14
NO_PARAMETERS_WERE_GIVEN=27

# Skrypt pobiera dwa argumenty - dwie ścieżki do katalogów
DIRECTORY=${1}
FILE=${2}
DATE=$(date +"--iso-8601=seconds")

#Jeżeli nie podamy parametrów -eu??
if [[ $# -lt 2 ]]; then
	exit ${NO_PARAMETERS_WERE_GIVEN}
fi

#Jeżeli katalogi nie istnieją
if [[ ! -d ${FIRST_DIRECTORY} && ! -d ${SECOND_DIRECTORY} ]]; then
	exit ${DIRECTORIES_DO_NOT_EXIST}
fi

FILES2REMOVE=$(find ${DIRECTORY} -xtype l)
${DATE}${FILES2REMOVE} > ${FILE}

find ${DIRECTORY} -xtype l -exec rm {} \;


exit 0