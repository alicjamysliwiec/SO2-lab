#!/bin/bash

# Skrypt pobiera trzy argumenty o warosciach domyslnych
SOURCE_DIR=${1:-"lab_uno"}
RM_LIST=${2:-"lab_uno/2remove"}
TARGET_DIR=${3:-"bakap"}

# Jezeli TARGET_DIR nie istnieje to go tworzymy
if [[ ! -d ${TARGET_DIR} ]]; then
	mkdir ${TARGET_DIR}
fi

# Iterujemy po RM_LIST
LISTA_RM=$(ls "${RM_LIST}")

for COSTAM in ${LISTA_RM}; do
	# Jezeli plik wystepuje w SOURCE_DIR to go usuwamy
	if [[ -e ${SOURCE_DIR}/${COSTAM} ]]; then
		rm -r ${SOURCE_DIR}/${COSTAM}
		echo "Usunieto ${COSTAM} z ${SOURCE_DIR}"
	fi		 
done

# Przegladamy pozostale pliki w SOURCE_DIR
LISTA_SRC=$(ls "${SOURCE_DIR}")

for PLIK in ${LISTA_SRC}; do
	# Jezeli plik jest jest regularny przenosimy do TARGET_DIR
	if [[ -f ${SOURCE_DIR}/${PLIK} ]]; then
		mv ${SOURCE_DIR}/${PLIK} ${TARGET_DIR}/${PLIK}
		echo "Przeniesiono ${PLIK} do ${TARGET_DIR}"
	# Jezeli plik jest katalogiem kopiujemy do TARGET_DIR	
	elif [[ -d ${SOURCE_DIR}/${PLIK} ]]; then
		cp -r ${SOURCE_DIR}/${PLIK} ${TARGET_DIR}/${PLIK}
		echo "Skopiowano ${PLIK} do ${TARGET_DIR}"
	fi		 
done

# Sprawdzamy ilosc plikow w katalogu SOURCE_DIR
ILOSC=$(ls "${SOURCE_DIR}" | wc -w)

# Jezeli sa jakies pliki w katalogu SOURCE_DIR
if [[ ${ILOSC} -ne 0 ]]; then
	echo "Jeszcze coś zostało!"
	# Jezeli sa co najmniej 2 pliki
	if [[ ${ILOSC} -gt 1 ]]; then
		echo "Zostały co najmniej 2 pliki"
		# Jezeli jest wiecej niz 4 pliki
		if [[ ${ILOSC} -gt 4 ]]; then
		echo "Zostało więcej niż 4 pliki"
		# Jezeli jest nie wiecej niz 4 ale co najmniej 2 pliki
		elif [[ ${ILOSC} -lt 5 ]]; then
		echo "Zostały 2, 3 lub 4 pliki"
		fi	
	fi
# Jezeli nie zostal zaden plik
else echo "Tu był Kononowicz"
fi

# Zmiana praw do edycji w katalogu TARGET_DIR
LISTA_TARGET=$(ls "${TARGET_DIR}")

for PLIK in ${LISTA_TARGET}; do
	chmod -R -w ${TARGET_DIR}/${PLIK}
	echo "Odebrano prawo do edycji pliku ${TARGET_DIR}/${PLIK}"
done

# Spakowanie katalogu TARGET_DIR o nazwie bakap_DATA.zip
# DATA w formacie RRRR-MM-DD
DATA=$(date +"%Y-%m-%d")
zip -r bakap_${DATA}.zip ${TARGET_DIR}

