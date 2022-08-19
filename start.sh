echo Running nf-tproxy
/app/nf-tproxy
echo Running:  "TODO"
/app/sshttpd -L $LISTEN_PORT -S $SSH_PORT -H $HTTP_PORT -T

# Keep the container running, as sshttpd is running in the background
tail -f /dev/null