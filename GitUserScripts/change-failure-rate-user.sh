#!/bin/bash


##########################PART OF CODE RESPONSIBLE FOR FLAGS SET TO RUN THE CODE#####################

usage()
{
  echo -e "-r"'\t'"repository name"
  echo -e "-o"'\t'"owner of a repository name"
  echo -e "-l"'\t'"Bug label to search on all issues. E.g: Type:%20Bug ( if the tag was Type: Bug) ; or , Bug (if the tag was just called Bug)"
  echo -e "-d"'\t'"Starting date to calculate the change failure rate. E.g: 2021-11  .If not set, the default value is the present month"
  echo -e "-u"'\t'"Git user."
  echo -e "-t"'\t'"Git user token."
  exit 2
}

STARTING_DATE=$(date +"%Y-%m");
EXTRA_MONTHS=0;

while getopts d:m:l:u:t:r:o:h flag
do
    case "${flag}" in
        d) STARTING_DATE=${OPTARG};;
        l) LABEL=${OPTARG};;
        r) REPO_NAME=${OPTARG};;
        o) OWNER_NAME=${OPTARG};;
        u) GIT_USERNAME=${OPTARG};;
        t) GIT_TOKEN=${OPTARG};;
        h) # Display help.
            usage
            exit 0
        ;;
    esac
done


#####################################################################################################

GIT_REPO="https://api.github.com/repos/$OWNER_NAME/$REPO_NAME";

if [ -z "$LABEL" ]
then
      echo "-l (BUG LABEL) not present. Use -h or read the README for help"
      exit 0
fi

##VERYFING IF REPO EXISTS
if curl --fail --silent --output /dev/null $GIT_REPO -u $GIT_USERNAME:$GIT_TOKEN
then
    #IN THIS CASE THE REPO EXISTS AND WE HAVE TO RUN THE SCRIPT
    #issuesFoundInPage=$(curl -sL $GIT_REPO"/issues?state=all&since=2010-12-07T09:05:28Z&per_page=100&page=9" -u $GIT_USERNAME:$GIT_TOKEN | grep created_at);
    flag=1
    i=1
    while [ $flag -eq 1 ]
    do
        parcialPageIssues=$(curl -sL $GIT_REPO"/issues?state=all&since=$STARTING_DATE-01T00:00:00Z&per_page=100&page=$i" -u $GIT_USERNAME:$GIT_TOKEN | grep '"created_at":' | wc -l)
        if [ $parcialPageIssues -lt 100 ]; then
            flag=0
        fi
        i=$(($i+1));
        totalPageIssues=$(($totalPageIssues+$parcialPageIssues));
    done

    flag=1
    i=1
    while [ $flag -eq 1 ]
    do
        parcialPageIssues=$(curl -sL $GIT_REPO"/issues?state=all;labels=$LABEL&since=$STARTING_DATE-01T00:00:00Z&per_page=100&page=$i" -u $GIT_USERNAME:$GIT_TOKEN | grep '"created_at":' | wc -l)
        if [ $parcialPageIssues -lt 100 ]; then
            flag=0
        fi
        i=$(($i+1));
        totalLabelPageIssues=$(($totalLabelPageIssues+$parcialPageIssues));
    done

    totalLabelPageIssues=$(($totalLabelPageIssues * 100))
    #little example on how to get all values json like of the api with format commit.url
    #curl -sL $GIT_REPO/tags | jq -r ".[].commit.url"
    result=$(jq -n "$totalLabelPageIssues"/"$totalPageIssues");
    echo "The calculated change failure rate percentage:" $result"%"

else
    echo "repo not found or limit of requests exceeded!";
fi
