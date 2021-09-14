cat <<EOF >EU_docker_AutoUp.sh
docker ps -a | egrep 'Created|Exited'
until [ $? -ne 0 ]
  do
     docker start $(docker ps -a | egrep 'Created|Exited' | awk '{print $1}')
     docker ps -a | egrep 'Created|Exited'
done
EOF
