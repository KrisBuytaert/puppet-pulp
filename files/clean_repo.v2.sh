#!/bin/bash

set -e

while getopts r:p:d:c: o; do
    case "$o" in
        r)        repo="$OPTARG";;
        p)        package="$OPTARG";;
        d)        deletion_date="$OPTARG";;
        c)        count="$OPTARG";;
    esac
done

if [ -z "$repo" ] || [ -z "$package" ] || [ -z "$deletion_date" ] || [ -z "$count" ]; then
    echo "All the paramaters are require.";
    echo ""
    echo "-r (repo)                name of the repository";
    echo "-p (package)             name of the package";
    echo "-d (deletion_date)     delete packages before date (example: '1 month' '2 weeks' '1 year')";
    echo "-c (count)               number of builds to keep even if passed deletion date";
    echo ""
    echo "Example: ./clean_pulp_package -r my-repository -p my-package -d \"1 month\" -c 20"
    echo ""
    exit 1;
fi


REPO=$repo
PACKAGE=$package
OLDERTHANDATE=$deletion_date
RETENTIONCOUNT=$count

pulp_admin='/usr/bin/pulp-admin';

# Authenticate agains pulp
$pulp_admin login --user admin  --password admin

# Get last build number of package from repo
LATESTBUILD=$($pulp_admin rpm repo content rpm --repo-id="$REPO" --match "filename=$PACKAGE" --fields=release | sed '/^$/d' | tr -s " " | cut -d' ' -f2 | sort -n | tail -1)

# Get theoretical older build number
OLDESTBUILD="$(echo "$LATESTBUILD - $RETENTIONCOUNT" | bc)"

echo ""
echo "Latest build: $LATESTBUILD"
echo "Oldest build: $OLDESTBUILD"
echo ""

# Computate deletion date
DELETION_DATE=$(date +"%Y-%m-%d" --date="-$OLDERTHANDATE")

echo "Going to delete all $PACKAGE packages from $REPO before $DELETION_DATE and keep all packages newer than $OLDESTBUILD"
echo ""

JSON="{\"filename\": {\"\$regex\": \"$PACKAGE\"},\"release\": {\"\$lt\": \"$OLDESTBUILD\"}}"

# List packages
$pulp_admin rpm repo content rpm --repo-id="$REPO" --before "$DELETION_DATE" --filters="$JSON"

# Example
# pa rpm repo content rpm --repo-id="my-private-repo" --before "2014-03-22" --filters='{"filename": {"$regex": "my-package"},"release":{"$lt": "37"}}'

# Remove all packages older than a certain date and retain newer packages
$pulp_admin rpm repo remove rpm --repo-id="$REPO" --before "$DELETION_DATE" --filters="$JSON"

# Resync metadata
$pulp_admin rpm repo publish run --repo-id=$REPO

# Kill orphans
$pulp_admin orphan remove --all

# Logout
$pulp_admin logout;
