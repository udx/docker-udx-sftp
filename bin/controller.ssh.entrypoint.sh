#!/bin/sh
##
##
##

export _SERVICE=${USER};
export CONNECTION_STRING=$(echo ${ENV_VARS} | cut -d ';' -f 1)
export USER_LOGIN=$(echo ${ENV_VARS} | cut -d ';' -f 2)

echo "[$(date)] Have a session for [${USER_LOGIN}] : ${USER}, ${SSH_ORIGINAL_COMMAND}, ${SSH_CLIENT}, ${SSH_CONNECTION} and [${CONNECTION_STRING}] command." >> /root/.pm2/logs/rabbit-ssh-server-out.log

## SFTP.
# if [[ "${SSH_ORIGINAL_COMMAND}" == "internal-sftp" ]]; then

#   echo "[$(date)] Have SFTP connection [${CONNECTION_STRING}] for [${USER}]." >> /root/.pm2/logs/rabbit-ssh-server-out.log

#   /usr/local/bin/kubectl exec -n ${CONNECTION_STRING} -i -- /usr/lib/sftp-server

#   exit;

fi

if [[ "${SSH_ORIGINAL_COMMAND}" == "/usr/lib/ssh/sftp-server" ]]; then

  echo "[$(date)] Have SFTP connection [${CONNECTION_STRING}] for [${USER}]." >> /root/.pm2/logs/rabbit-ssh-server-out.log

  /usr/local/bin/kubectl exec -n ${CONNECTION_STRING} -i -- /usr/lib/sftp-server

  exit;

fi

## Specific Command, pipe into container.
if [[ "x${SSH_ORIGINAL_COMMAND}" != "x" ]]; then

  echo "[$(date)] Have SSH session using command: [docker $CONNECTION_STRING /bin/bash -c ${SSH_ORIGINAL_COMMAND})] for [${USER}] For from [${API_REQUEST_URL}]." >> /root/.pm2/logs/rabbit-ssh-server-out.log

  /usr/local/bin/kubectl exec ${_SERVICE} -ti -- "${SSH_ORIGINAL_COMMAND}"
fi;

## Terminal, pipe into container.
if [[ "x${SSH_ORIGINAL_COMMAND}" == "x" ]]; then

  echo "kubectl exec -n ${CONNECTION_STRING} -ti /bin/bash" >> /root/.pm2/logs/rabbit-ssh-server-out.log

  #if [  "x${SSH_CONNECTION}" != "x" ]; then
  #  export GIT_AUTHOR_EMAIL="${SSH_USER}";
  #  export GIT_AUTHOR_NAME="${SSH_USER}";
  #fi;

  ## Detect Max Columns and Rows.

  export _COLUMNS=$(tput cols);
  export _ROWS=$(tput lines);
  
  ## Set Columns and Rows
  stty rows ${_ROWS} cols ${_COLUMNS};
  
  ## Log screen size.
  echo "[$(date)] Container [${USER}] has [${_COLUMNS}] columns and [${_ROWS}] rows." >> /root/.pm2/logs/rabbit-ssh-server-out.log

  _command="/usr/local/bin/kubectl exec -n $CONNECTION_STRING -ti -- /bin/bash"

  echo $_command >> /root/.pm2/logs/rabbit-ssh-server-out.log

  $_command;

fi;

exit;

