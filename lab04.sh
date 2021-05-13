#!/bin/bash -eu

function print_help () {
    echo "This script allows to search over movies database"
    echo -e "-d DIRECTORY\n\tDirectory with files describing movies"
    echo -e "-a ACTOR\n\tSearch movies that this ACTOR played in"
    echo -e "-t QUERY\n\tSearch movies with given QUERY in title"
    echo -e "-f FILENAME\n\tSaves results to file (default: results.txt)"
    echo -e "-x\n\tPrints results in XML format"
    echo -e "-h\n\tPrints this help message"
    echo -e "-y YEAR\n\tPrints movies newer than YEAR"
    echo -e "-p QUERY\n\tPrints movies found by given QUERY"
}

function print_error () {
    func=$1
    shift
    echo -e "\e[31m\033[1m$func\033[0m" >&2 "$@"
}

function get_movies_list () {
    local -r MOVIES_DIR=${1}
    local -r MOVIES_LIST=$(cd "${MOVIES_DIR}" && realpath -- *)
    echo "${MOVIES_LIST}"
}

function query_title () {
    # Returns list of movies from ${1} with ${2} in title slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Title" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_actor () {
    # Returns list of movies from ${1} with ${2} in actor slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if  grep "| Actors" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function print_xml_format () {
    local -r FILENAME=${1}
    local TEMP
    TEMP=$(cat "${FILENAME}")

    # TODO: replace first line of equals signs

    # TODO: change 'Author:' into <Author>
    # TODO: change others too

    # append tag after each line
    TEMP=$(echo "${TEMP}" | sed -r 's/([A-Za-z]+).*/\0<\/\1>/')

    # replace the last line with </movie>
    TEMP=$(echo "${TEMP}" | sed '$s/===*/<\/movie>/')

    echo "${TEMP}"
}

function print_movies () {
    local -r MOVIES_LIST=${1}
    local -r OUTPUT_FORMAT=${2}

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ "${OUTPUT_FORMAT}" == "xml" ]]; then
            print_xml_format "${MOVIE_FILE}"
        else
            cat "${MOVIE_FILE}"
        fi
    done
}

#Dodaj opcję -y ROK:
function query_year () {
    local -r MOVIES_LIST=${1}
    local YEAR=${2} 

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        FOUND_YEAR=$(grep "| Year" "${MOVIE_FILE}")
        ONLY_DATA=${FOUND_YEAR##*Year: }            
        if [[ ${ONLY_DATA} > ${YEAR} ]]; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

# Dodaj wyszukiwanie po polu z fabułą, za pomocą wyrażenia regularnego
function query_plot () {
    local -r MOVIES_LIST=${1}
    local QUERY=${2} 
 
    local RESULTS_LIST=()
   for MOVIE_FILE in ${MOVIES_LI }; do
        RESULT=$(grep "| Plot: ${QUERY}" "${MOVIE_FILE}")
        if  [[ -n ${RESULT} ]] ; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}
#ANY_ERRORS=false

NOT_USED_D_OPTION=true
while getopts ":hd:t:a:y:p:f:x" OPT; do
  case ${OPT} in
    h)
        print_help
        exit 0
        ;;
    d) #Dodaj sprawdzenie, czy na pewno wykorzystano opcję '-d' i czy jest to katalog
        if [[ -d "${OPTARG}" ]]; then
            NOT_USED_D_OPTION=false
            MOVIES_DIR=${OPTARG}
        fi
        ;;
    t)
        SEARCHING_TITLE=false
        QUERY_TITLE=${OPTARG}
        ;;
    f) #Dotyczy opcji ‘-f’: jeżeli plik podany przez użytkownika nie posiada rozszerzenia '.txt' dodaj je
        TYPE=${OPTARG##*.}
        NAME=${OPTARG%.*}
        if [[ ${TYPE} != "txt" ]]; then
            TYPE="txt"
        fi
        FILE_4_SAVING_RESULTS="${NAME}.${TYPE}"
        ;;
    a)
        SEARCHING_ACTOR=true
        QUERY_ACTOR=${OPTARG}
        ;;
    p)  
        SEARCHING_PLOT=true
        QUERY_PLOT=${OPTARG}
        ;;    
    x)
        OUTPUT_FORMAT="xml"
        ;;
    y)
        SEARCHING_YEAR=true
        QUERY_YEAR=${OPTARG}
        ;;
    \?)
        print_error "ERROR: Invalid option: -${OPTARG}"
        #ANY_ERRORS=true
        exit 1
        ;;
  esac
done


if  ${NOT_USED_D_OPTION:-false}; then
    print_error "Catalog was not set. Use -d option"
    exit 1
fi

MOVIES_LIST=$(get_movies_list "${MOVIES_DIR}")

if ${SEARCHING_TITLE:-false}; then
    MOVIES_LIST=$(query_title "${MOVIES_LIST}" "${QUERY_TITLE}")
fi

if ${SEARCHING_PLOT:-false}; then
    MOVIES_LIST=$(query_plot "${MOVIES_LIST}" "${QUERY_PLOT}")
fi

if ${SEARCHING_ACTOR:-false}; then
    MOVIES_LIST=$(query_actor "${MOVIES_LIST}" "${QUERY_ACTOR}")
fi

if ${SEARCHING_YEAR:-false}; then
    MOVIES_LIST=$(query_year "${MOVIES_LIST}" "${QUERY_YEAR}")
fi

if [[ "${#MOVIES_LIST}" -lt 1 ]]; then
    echo "Found 0 movies :-("
    exit 0
fi

if [[ "${FILE_4_SAVING_RESULTS:-}" == "" ]]; then
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}"
else
    # TODO: add XML option
    print_movies "${MOVIES_LIST}" "raw" | tee "${FILE_4_SAVING_RESULTS}"
fi
