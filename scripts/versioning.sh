#!/bin/bash

# This bash shell script automates versioning for GitHub repositories
# Created on: November 2023
#     Author: Jamie Holland at IMI Critical Engineering, Poole.
# Last Modified on: January 2024
#     Author: Jamie Holland at IMI Critical Engineering, Poole.

# Gets the list of all tags and selects the most recent
REVLIST=`git rev-list --tags --max-count=1`
VERSION=`git describe --tags $REVLIST`
# Gets the current branch name
BRANCH=`git branch --show-current`

# Splits the current tag into a number of parts depending on the meaning of each one.
VNUM1=$(echo "$VERSION" | cut -d"." -f1 | sed 's/v//')
VNUM2=$(echo "$VERSION" | cut -d"." -f2)
VNUM3=$(echo "$VERSION" | cut -d"." -f3 | grep -Eo '[0-9]+')
VNUM4=$(echo "$VERSION" | cut -d"." -f3 | grep -Eo '[[:alpha:]]+')
VNUM5=$(echo "$VERSION" | cut -d"." -f4)

# Checks for major, minor or patch in the commit message and increment the relevant version number.
MAJOR=`git log --format=%B -n 1 HEAD | grep '(MAJOR)'`
MINOR=`git log --format=%B -n 1 HEAD | grep '(MINOR)'`
PATCH=`git log --format=%B -n 1 HEAD | grep '(PATCH)'`
CLEAN=`git log --format=%B -n 1 HEAD | grep '(CLEAN)'`
# Phase increments the alpha, beta or rc number by 1 (rc1 -> rc2)
PHASE=`git log --format=%B -n 1 HEAD | grep '(PHASE)'`
ALPHA=`git log --format=%B -n 1 HEAD | grep '(ALPHA)'`
BETA=`git log --format=%B -n 1 HEAD | grep '(BETA)'`
RC=`git log --format=%B -n 1 HEAD | grep '(RC)'`

# Checks if a tag exists, if not creates an initial one V0.0.0-alpha.1.
if [ -z "$VERSION" ]; then
    echo "No tag exists setting the first tag to V0.0.0-alpha.1"
    VNUM1=0
    VNUM2=0
    VNUM3=0
    VNUM4='alpha'
    VNUM5=1
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
# Checks if the current tag is rc and the branch is not main, then tag drops to beta.
elif ([ "$VNUM4" == 'rc' ] && [ "$BRANCH" != "main" ]); then
    VNUM4='beta'
    VNUM5=1
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
fi

# Runs checks for the Major, Minor and Patch instructions,
# also resets the phase number if incremental commands are run.

# Upon receiving the MAJOR command increments the version number and resets the phase number.
if [ "$MAJOR" ]; then
    echo "Update major version"
    VNUM1=$((VNUM1+1))
    VNUM2=0
    VNUM3=0
    if [ -z "$VNUM4" ]; then
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
    else
        VNUM5=0
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    fi
# Upon receiving the MINOR command increments the version number and resets the phase number.
elif [ "$MINOR" ]; then
    echo "Update minor version"
    VNUM2=$((VNUM2+1))
    VNUM3=0
    if [ -z "$VNUM4" ]; then
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
    else
        VNUM5=0
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    fi
# Upon receiving the PATCH command increments the version number and resets the phase number.
elif [ "$PATCH" ]; then
    echo "Update patch version"
    VNUM3=$((VNUM3+1))
    if [ -z "$VNUM4" ]; then
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
    else
        VNUM5=0
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    fi
fi

# check if the previous tag was CLEAN and the branch is still main, if so revert to rc.
if ([ -z "$VNUM4" ] && [ "$BRANCH" == "main" ]); then
    VNUM4='rc'
    VNUM5=1
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
# check if the previous tag was CLEAN and the branch is not main, if so revert to alpha.
elif ([ -z "$VNUM4" ] && [ "$BRANCH" != "main" ]); then
    VNUM4='alpha'
    VNUM5=1
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
fi

# Runs checks for the Clean, Phase, Alpha, Beta and RC instructions

# Upon receiving the CLEAN command removes the phase and phase number.
if [ "$CLEAN" ]; then
    if [ "$BRANCH" == "main" ]; then
        echo "Create a clean release tag removing additional labels"
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
    else
        echo "Must be on the main branch to create a clean release tag"
        NEW_TAG="invalidbranch"
    fi
# Upon receiving the PHASE command increments phase number.
elif [ "$PHASE" ]; then
    echo "Update phase $VNUM4 version"
    VNUM5=$((VNUM5+1))
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
# Upon receiving the ALPHA command sets the phase to alpha and phase number to 1.
elif [ "$ALPHA" ]; then
    if [ "$VNUM4" == 'alpha' ]; then
        echo "Update alpha version"
        VNUM5=$((VNUM5+1))
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    else
        echo "Set alpha version"
        VNUM4='alpha'
        VNUM5=1
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    fi
# Upon receiving the BETA command sets the phase to beta and phase number to 1.
elif [ "$BETA" ]; then
    if [ "$VNUM4" == 'beta' ]; then
        echo "Update beta version"
        VNUM5=$((VNUM5+1))
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    else
        echo "Set beta version"
        VNUM4='beta'
        VNUM5=1
        NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
    fi
# Upon receiving the RC command sets the phase to rc and phase number to 1.
elif [ "$RC" ]; then
    if [ "$BRANCH" == "main" ]; then
        if [ "$VNUM4" == 'rc' ]; then
            echo "Update release candidate"
            VNUM5=$((VNUM5+1))
            NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
        else
            echo "For current tag set release candidate"
            VNUM4='rc'
            VNUM5=1
            NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
        fi
    else
        echo "Must be on the main branch to create a RC tag"
        NEW_TAG="invalidbranch"
    fi
elif [ "$VNUM5" == "0" ]; then
    VNUM5=1
    NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
fi

# Checks if tag is valid, if not increment the phase number until a valid tag is found
if [ $(git tag -l "$NEW_TAG") ]; then
    VALID=false
    while [ "$VALID" = false ];  do
        if [ $(git tag -l "$NEW_TAG") ]; then
            echo "The Tag $NEW_TAG already exists incrementing PHASE by 1"
            VNUM5=$((VNUM5+1))
            NEW_TAG="v$VNUM1.$VNUM2.$VNUM3-$VNUM4.$VNUM5"
        else
            echo "valid Tag setting tag to $NEW_TAG"
            VALID=true
        fi
    done
fi

# Get current tag and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

echo "################################################################"
echo "Bash Shell Script Versioning Output:"
echo "################################################################"
if [ -z "$NEW_TAG" ]; then
    echo "No instruction detected the branch will remain as $VERSION"
elif [ "$NEW_TAG" == "invalidbranch" ]; then
    echo "The current branch is $BRANCH"
    echo "To set either a release or rc you must be on the main branch not the $BRANCH branch"
elif [ -z "$NEEDS_TAG" ]; then
    echo "Updating the tag from $VERSION to $NEW_TAG"
    git tag $NEW_TAG
    git push --tags
else
    echo "The tag $NEW_TAG already exists the latest tag will remain as $VERSION"
fi
echo "################################################################"
