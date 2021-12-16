#!/bin/sh

while getopts r:o: flag
do
    case "${flag}" in
        r) REPO_NAME=${OPTARG};;
        o) OWNER_NAME=${OPTARG};;
    esac
done

GIT_REPO="https://api.github.com/repos/$OWNER_NAME/$REPO_NAME"

##VERIFICACAO SE EXISTE REPOSITORIO
if curl --fail --silent --output /dev/null $GIT_REPO 
then
    #NESSE CASO O REPO EXISTE E DEVEMOS RODAR O SCRIPT


    #echo "Repo Name: $REPO_NAME";
    #echo "Owner Name: $OWNER_NAME";
    #echo "git repo: $GIT_REPO";

    #exemplo pegando todos os valores de commit.url no repo acima
    #curl -sL $GIT_REPO/tags | jq -r ".[].commit.url"

    #curl -sL $GIT_REPO/tags | jq -r ".[].commit.url"

    results=$(curl -sL $GIT_REPO/tags | jq -r ".[].commit.sha")
    curl -sL $GIT_REPO/tags | jq -r ".[].name" >> names.txt


    CONT_TAG=1;

    for i in $results; do 
        echo "realizando consulta da $CONT_TAG tag...";
        #echo $GIT_REPO"/commits?sha="$i"&page=1&per_page=1"
        curl -sL $GIT_REPO"/commits?sha="$i"&page=1&per_page=1" | jq -r ".[].commit.author.date" >> dates.txt;
        CONT_TAG=$(($CONT_TAG+1))

        #codigo para esperar dez segundos
        j=1
        while [ $j -le 5 ]
        do
            sleep 1
            echo -n ".."$j
            j=$(($j+1))
        done
        echo ""
        #printado os 10 segundos na tela com espaco

    done

    echo $dates

else
    echo "repo not found!"
fi
