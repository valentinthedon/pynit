#!/bin/bash

# Fonction pour afficher l'utilisation du script
usage() {
  echo "Usage: pynit [-v version] [-d directory] PROJECT"
  exit 1
}

check_project() {
    local project=$1
    
    if [[ ! "$project" =~ ^[[0-9a-zA-Z._-]]+$ ]]; then
        echo "No invalide: $version" >&2
        exit 2
    fi
}

check_version() {
    local version=$1
    
    if [[ ! "$version" =~ ^[[:digit:]]+(\.[[:digit:]])*$ ]]; then
        echo "Version invalide: $version" >&2
        exit 2
    fi
}

check_repository() {
    local dir=$1
    local auto_yes=$2

    if [[ ! -d "$dir" ]]; then
        echo "$dir n'est pas un repertoire" >&2
        exit 4
    fi 

    if [[ ! -w "$dir" ]]; then
        echo "$dir: Permission refusée" >&2
        exit 4
    fi 

    # Vérifie si le répertoire est vide
    if [[ "$(ls -A "$dir")" ]]; then
        echo "Le répertoire '$dir' n'est pas vide. Voulez-vous vraiment l'initialiser ? (Y/n)"
        read -r confirmation
        if [[ $confirmation != "y" && $confirmation != "Y" && -n $confirmation  && $auto_yes -ne 1 ]]; then
            echo "Annulation de l'initialisation." >&2
            exit 7
        fi
    fi
}

# Fonction pour initialiser le projet
init_project() {
    local project=$1
    local dir=$2
    local version=$3

    mkdir -p "${dir}/${project}"

    # Se déplacer dans le répertoire
    pushd "${dir}/${project}"

    # Initialisation du projet (création d'un virtualenv et configuration)
    echo "Initialisation du projet $project avec Python $version..."

    # Utilisation de pyenv pour définir la version locale de Python
    pyenv local "$version"

    # Création de l'environnement virtuel
    python -m venv .venv

    touch __main__.py

    # Affiche un message de succès
    echo "Projet Python initialisé avec succès dans $dir."
    
    # Revenir au depot initial
    popd 
}


# Traitement des options
version=""
directory="."
project=""

type=""
auto_yes=0

while getopts ":v:d:y" opt; do
  case $opt in
    v)
        version=$OPTARG
        ;;
    d)
        directory=$OPTARG
        ;;
    y)
        auto_yes=1
        ;;
    \?)
        echo "Option invalide: -$OPTARG" >&2
        usage
        ;;
  esac
done

shift $((OPTIND-1))
project=$1

check_version $version
check_repository $project $auto_yes

version=$(pyenv versions --bare | grep -E "$version" | tail -1)

# Initialiser le projet
init_project "$project" "$version"