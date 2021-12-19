#!/bin/bash


##########################PART OF CODE RESPONSIBLE FOR FLAGS SET TO RUN THE CODE#####################

usage()
{
  echo -e "-r"'\t'"repository name"
  echo -e "-o"'\t'"owner of a repository name"
  echo -e "-d"'\t'"starting date of period following the format: YEAR-MONTH E.g: 2021-11  .If not set, the default value is the present month"
  echo -e "-m"'\t'"how many months past starting date to analysis. E.g: 1, 2 .   .If not set, the default value is 0"
  exit 2
}

STARTING_DATE=$(date +"%Y-%m");
EXTRA_MONTHS=0;

while getopts d:m:r:o:h flag
do
    case "${flag}" in
        d) STARTING_DATE=${OPTARG};;
        m) EXTRA_MONTHS=${OPTARG};;
        r) REPO_NAME=${OPTARG};;
        o) OWNER_NAME=${OPTARG};;
        h) # Display help.
            usage
            exit 0
        ;;
    esac
done


#####################################################################################################


GIT_REPO="https://api.github.com/repos/$OWNER_NAME/$REPO_NAME";

##VERYFING IF REPO EXISTS
if curl --fail --silent --output /dev/null $GIT_REPO 
then
    #IN THIS CASE THE REPO EXISTS AND WE HAVE TO RUN THE SCRIPT


    #little example on how to get all values json like of the api with format commit.url
    #curl -sL $GIT_REPO/tags | jq -r ".[].commit.url"

    #GETTING VIA JQ JSON SPECIFIC FIELDS
    results=$(curl -sL $GIT_REPO/tags | jq -r ".[].commit.sha");
    tagsversion=$(curl -sL $GIT_REPO/tags | jq -r ".[].name");



    #counting how many tags we have on project
    TOTALTAGS=0;
    tagNames=();
    for i in $tagsversion; do 
        TOTALTAGS=$(($TOTALTAGS+1));
        tagNames+=("$i");
    done
    echo "total number of tags found:"$TOTALTAGS


    #NEED TO SPECIFY LIMIT FOR THE NEXT FOR AS IT CAN GO OVER 60
    #DEPENDING ON HOW MANY TAGS THE REPO THATS BEING CHECKED HAS

    #######FOR RESPONSIBLE TO REQUEST COMMIT DATES###################
    #doing requests per commit to get most recent tag date
    COUNT_TAG=1;
    tagDates=();
    for i in $results; do 
        echo "getting the date via request for the $COUNT_TAG th tag...";
        #Its important to note that here we only check the first page of the sha as we want the recent one.
        string=$(curl -sL $GIT_REPO"/commits?sha="$i"&page=1&per_page=1" | jq -r ".[].commit.author.date");
        tagDates+=("$string");
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



    TOTALVERSIONS=$TOTALTAGS;
    totalDeploys=0;

    echo -n "Calculating how many deploys found in period of time"
    for ((i=0;i<$TOTALVERSIONS;i++)); do
        #showing progress
        echo -n ".";
        #breaking starting date into two variables
        month=${STARTING_DATE:5:7};
        year=${STARTING_DATE:0:4};
        for((j=0;j<=$EXTRA_MONTHS;j++)); do
            #echo "entrando segundo for i="$i"   j="$j;
            #echo "valor month="$month"   valor year="$year;
            aux=$(printf "%02d\n" $month);
            if echo "${tagDates[$i]}" | grep -o "$year"-"$aux" > /dev/null
            then
                totalDeploys=$(($totalDeploys+1));
            fi
            #adding + 1 to month
            month=$(($month+1));
            #echo "apos adicao de +1 em month="$month;
            ##if month is above 12 it means has past one year
            if [ "$month" -eq 13 ]
            then
                #echo "caso em que month passou de 13!"
                year=$(($year+1));
                month=01;
                #echo "NOVO valor month="$month"   valor year="$year;
            fi
        done
    done
    echo ""
    echo "This many deploys happened in the timespan:"$totalDeploys;



    #For debugging purposes , here we can print all the tags with it release dates together
    # for ((i=0;i<$TOTALVERSIONS;i++)); do
    #     echo "tag name: ""${tagNames[$i]}""   tag date: ""${tagDates[$i]}";
    # done




    #totaltags=cat tagdates.txt | grep -o $presentYearMonth | wc -l;

else
    echo "repo not found or limit of requests exceeded!";
fi
