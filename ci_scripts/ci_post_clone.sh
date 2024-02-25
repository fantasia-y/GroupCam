#!/bin/sh

echo "Stage: PRE-Xcode Build is activated .... "

# Move to the place where the scripts are located.
# This is important because the position of the subsequently mentioned files depend of this origin.
cd $CI_PRIMARY_REPOSITORY_PATH/$CI_XCODE_PROJECT || exit 1

echo $(ls)

cd $CI_PROJECT_FILE_PATH

echo $(ls)

cd $CI_WORKSPACE_PATH

echo $(ls)

# Write a JSON File containing all the environment variables and secrets.
touch ./SupportingFiles/secrets.json

printf "{\"BASE_URL\":\"%s\",\"PUSHER_INSTANCE_ID\":\"%s\",\"AWS_ACCESS_KEY_ID\":\"%s\",\"AWS_SECRET_ACCESS_KEY\":\"%s\"}" "$BASE_URL" "$PUSHER_INSTANCE_ID" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" >> ./SupportingFiles/secrets.json

echo "Wrote Secrets.json file."

echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
