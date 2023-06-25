#!@bash@/bin/bash

PATH=@path@

if (( $# < 2 )); then
    echo "usage: git-change-time COMMIT_ID DATE" >&2
    exit 1
fi

git filter-branch -f --env-filter \
    "if [ \$GIT_COMMIT = '$1' ]
     then
         export GIT_AUTHOR_DATE='$2'
         export GIT_COMMITTER_DATE='$2'
     fi"
