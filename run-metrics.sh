while getopts r:o: flag
do
    case "${flag}" in
        r) REPO_NAME=${OPTARG};;
        o) OWNER_NAME=${OPTARG};;
    esac
done

GIT_REPO="https://api.github.com/repos/$OWNER_NAME/$REPO_NAME"



echo "Repo Name: $REPO_NAME";
echo "Owner Name: $OWNER_NAME";


echo "git repo: $GIT_REPO";

curl -sL $GIT_REPO/tags | jq -r ".[].commit.sha"
