# script-metrics-Accelerate

This script is capable of calculating similar metrics that are found on Accelerate.

## Installation(Pre-requirements)

This project will use [jq](https://stedolan.github.io/jq/download/) to make requests ( with selected parts) for the github API or read the documentation.

To install it simply run:

```bash
sudo apt-get install jq
```


## Usage

All scripts have a built in flag "-h" that will give a brief description of everything needed to run it.With examples as well. Inside the repo folder you will find two folders , one named: GitUserScripts and other named: ScriptsWithoutToken. The intended usage is with the GitUser and GitToken, as github API calls have an limit for requests per hour wich it is pretty low without authentication. So I encorage the usage of the scripts present on GitUserScripts.

In every script there is present these tags:
-r  repository name
-o  owner of a repository name

To make it easily you can understand by taking a look of this repo github url, wich it is:
https://github.com/Deheide/script-metrics-Accelerate

On it we have the user owner of the repository: Deheide. And followed by the repo name: script-metrics-Accelerate. So the usage of it on a script would be:


```bash
./scriptBeingUsed.sh -o Deheide -r script-metrics-Accelerate
```

All github repos follow this format: https://github.com/RepoOwner/RepoName
And the usage would be still:

```bash
./scriptBeingUsed.sh -o RepoOwner -r RepoName
```

Every script needs different flags and have different ways to use, but don't worry! As said every script has an -h option that shows all flags present and how to use it. To run this help options just do as it follows:

```bash
./scriptBeingUsed.sh -h
```

Now , Its important to know the difference betwen the folders. And here is a simple explanation of the difference between each one: 

### GitUserScripts

These scripts need your github username as well as an github token created within your account. These are used on every request made, and is easily verifiable just taking a look on the code.

### ScriptsWithoutToken

These scripts doesn't use the authentication on the API calls , so sometimes it can stop working as you reach the limit. So its usage is discouraged.

