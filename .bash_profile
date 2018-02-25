#!/usr/bin/env bash

if [ -f "$HOME/.bash_config" ]; then
  . "$HOME/.bash_config"
else
  echo "WARNING: bash configuration not found!"  
fi

function op_check_session {
  #first test if we have a session and it's valid
  if [ ${!config["1PasswordSession"]} ]; then
    op list users &> /dev/null
    
    if [ $? -ne 0 ]; then
      unset ${!config["1PasswordSession"]}  
    fi
  fi

  #by now it's assumed that any session that is set is valid so if we don't have a session then we have to signin
  if [ -z ${!config["1PasswordSession"]} ]; then
    eval $(op signin ${config["1PasswordAccountName"]} ${config["1PasswordEmailAddress"]} ${config["1PasswordSecretKey"]})

    if [ -z ${!config["1PasswordSession"]} ]; then
      return -1
    fi
  fi

  return 0
}

function op_lookup {
  op_check_session || return -1
  op list items | jq '.'  | grep $1 
}

function op_creds {
  op_check_session || return -1
  user=$(op get item $1 | jq '.details.fields[] | select(.designation=="username").value')
  pass=$(op get item $1 | jq '.details.fields[] | select(.designation=="password").value')
  echo "Username: $user"
  echo $pass | sed -e 's/^"//' -e 's/"$//' | xclip -sel clip
}

