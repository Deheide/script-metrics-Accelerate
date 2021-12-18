#!/bin/sh

usage()
{
  echo "-r"'\t'"repository name"
  echo "-o"'\t'"owner of a repository name"
  exit 2
}


while getopts r:o:h flag
do
    case "${flag}" in
        r) REPO_NAME=${OPTARG};;
        o) OWNER_NAME=${OPTARG};;
        h) # Display help.
            usage
            exit 0
        ;;
    esac
done

GIT_REPO="https://api.github.com/repos/$OWNER_NAME/$REPO_NAME";

##VERYFING IF REPO EXISTS
if curl --fail --silent --output /dev/null $GIT_REPO 
then
    #IN THIS CASE THE REPO EXISTS AND WE HAVE TO RUN THE SCRIPT


    #little example on how to get all values json like of the api with format commit.url
    #curl -sL $GIT_REPO/tags | jq -r ".[].commit.url"

    results=$(curl -sL $GIT_REPO/tags | jq -r ".[].commit.sha");
    tagsversion=$(curl -sL $GIT_REPO/tags | jq -r ".[].name");



    #counting how many tags we have on project
    TOTALTAGS=0;
    for i in $tagsversion; do TOTALTAGS=$(($TOTALTAGS+1)); done
    echo "total number of tags found:"$TOTALTAGS




    curl -sL $GIT_REPO/tags | jq -r ".[].name" >> tagsversion.txt;

    #doing requests per commit to get most recent tag date
    COUNT_TAG=1;
    for i in $results; do 
        echo "getting the date via request for the $COUNT_TAG th tag...";
        #Its important to note that here we only check the first page of the sha as we want the recent one.
        curl -sL $GIT_REPO"/commits?sha="$i"&page=1&per_page=1" | jq -r ".[].commit.author.date" >> tagdates.txt;
        COUNT_TAG=$(($COUNT_TAG+1));

        #loop for 2 seconds period between requests
        j=1;
        while [ $j -le 2 ]
        do
            sleep 1;
            #printing seconds in real time on screen
            echo -n ".."$j;
            j=$(($j+1));
        done
        echo "";

    done

    presentYearMonth=$(date +"%Y-%m");
    #totaltags=cat tagdates.txt | grep -o $presentYearMonth | wc -l;
    echo "present year and month: $presentYearMonth";
    
    #rm tagdates.txt tagsversion.txt
else
    echo "repo not found!";
fi
