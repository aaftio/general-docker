#!/bin/bash

# Enforces required env variables
required_vars=(TARGET_EMAIL BACKUP_DIR)
for required_var in "${required_vars[@]}"; do
  if [[ -z ${!required_var} ]]; then
    error=1
    echo >&2 "Error: $required_var env variable not set."
  fi
done

if [[ -n $error ]]; then
  exit 1
fi

if [ ! -f /.muttrc ]; then
  echo >&2 "Error: file /.muttrc not exist"
fi

if [[ -n $PASSWORD ]]; then
  PASSWORD="-p${PASSWORD}"
fi

FILE_NAME=${FILE_NAME:-'default_file_name.7z'}
EMAIL_SUBJECT=${EMAIL_SUBJECT:-'Backup'}

7z a $PASSWORD -mhe /tmp/$FILE_NAME $BACKUP_DIR

echo "$PASSWORD_TIPS" | mutt -s "$EMAIL_SUBJECT" -F /.muttrc $TARGET_EMAIL -a /tmp/$FILE_NAME
