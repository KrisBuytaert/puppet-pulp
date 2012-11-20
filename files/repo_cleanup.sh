#!/bin/bash
# repo_cleanup script

PURGE_REPOID="$1"
ARCHIVE_REPOID="$2"
LOCKFILE="/tmp/repo_cleanup.lock"

die(){
  case $1 in
    3,4,5,6)
      echo -e "\e[0;31m[ERROR]\e[m Error occurred at $0:$LINENO\n\e[0;31m[ERROR]\e[m Exiting with RETVAL $1"
    ;;
  esac
  exit $1
}

##
## Help text
##

help(){
cat <<EOF && die 0
Usage: $0 <purge_repoid> <archive_repoid>

Exit statuses:
* 1:   Wrong number of arguments
* 2:   Lockfile exists
* 3:   Failed to remove old temp files
* 4:   Failed to get pkgnames
* 5:   Failed to upload pkgs to archive repo
* 6:   Failed to remove pkgs from purge repo
* 127: Exit on user input

EOF
}

##
## check arguments
##

[[ ($1 == '-h') ]] && help
[[ -z $PURGE_REPOID ]] && echo -e '\e[0;31m[ERROR]\e[m<purge_repoid> must be set!' && die 1
[[ -z $ARCHIVE_REPOID ]] && echo -e '\e[0;31m[ERROR]\e[m<archive_repoid> must be set!' && die 1

##
## lockfile logic
##

[[ -f $LOCKFILE ]] && echo -e "\e[0;31m[ERROR]\e[m Lockfile exists at: \"$LOCKFILE\"\n\e[0;31m[ERROR]\e[m Exiting .." && die 2
touch $LOCKFILE
trap "rm $LOCKFILE -f; die 127" INT QUIT KILL HUP ABRT TERM
trap "rm $LOCKFILE -f" EXIT

##
## remove files from previous run
##

echo "Removing old temp files"
rm /tmp/oldpkgs -f || die 3
rm /tmp/oldpkgs.csv -f || die 3

##
## get list of packages to archive
##

echo "Building packagelist for repo: $PURGE_REPOID"
INPUT_DIR="/var/lib/`pulp-admin repo info --id $PURGE_REPOID|grep '^Repo URL'|cut -d/ -f 4-`"
OLDPKGS=`ls -1 $INPUT_DIR|grep -v 'repodata'|awk -F. '{print $1}'|rev|cut -d- -f2-|rev|uniq`
for i in $OLDPKGS; do
  ls -1 $INPUT_DIR|grep "$i-[0-9]"|sort -n|head --lines=-1 2> /dev/null >> /tmp/oldpkgs || die 4
done

##
## upload packages to archive repo
##

echo "Uploading old packages to repo: $ARCHIVE_REPOID"
cd $INPUT_DIR
pulp-admin content upload `cat /tmp/oldpkgs` --repoid=$ARCHIVE_REPOID --nosig || die 5

##
## remove pkgs from current repo
##

echo "Removing old packages from repo: $PURGE_REPOID"
CSV=`pulp-admin content list --repoid $PURGE_REPOID`
for i in `cat /tmp/oldpkgs`; do
  echo $CSV|tr ' ' '\n'|grep "$i" >> /tmp/oldpkgs.csv
done
#echo 'n'|pulp-admin repo remove_package --csv /tmp/oldpkgs.csv --id $PURGE_REPOID || die 6
#pulp-admin repo generate_metadata --id $PURGE_REPOID

echo "Done archiving old packages from $PURGE_REPOID to $ARCHIVE_REPOID" && exit 0
