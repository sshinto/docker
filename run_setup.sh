#!/usr/bin/env bash
 echo -i "Login to ocp to get the environmental variables."
 echo -i "Login into OCP"
 if oc login <OCP>; then
   echo "Logged in"
 else
   echo "Please enter correct credentials"
   exit 1
 fi

 read -p "Please enter project from the above list. : " project
 if oc project $project; then
   echo "Project list"
 else
   echo "Please enter correct project"
   exit 1
 fi

 oc get secrets

 read -p "Please enter secret name from the above list. : " secertfile

 echo "Add environament variables to env file in the root directory"
 echo  >> env
 grep -Fx -q "CASSANDRA_PASSWORD=cassandra" env || echo "CASSANDRA_PASSWORD=cassandra" >> env

 if  keyfile=$(oc get secret $secertfile  --template={{.data.keyfile}}); then
    keyfile=$(echo "keyfile="$(oc get secret $secertfile  --template={{.data.keyfile}} | base64 -d))
    grep -Fx -q "$keyfile" env || echo "$keyfileD">> env
 else
    echo "keyfile does not exists"
 fi
 

 if [[ ! -e secrets ]]; then
    mkdir secrets
 elif [[ ! -d secrets ]]; then
    echo "secrets directory already exists" 1>&2
 fi
 sleep 1
 

 if  keystore=$(oc get secret $secertfile -o yaml  $1 2> /dev/null | grep " keystore.jks"); then
   keystore=$(oc get secret $secertfile -o yaml  $1 2> /dev/null | grep " keystore.jks")
   keystore=$(echo $keystore | sed -e "s/keystore.jks://g" | sed 's/ //g')
   echo $keystore | base64 --decode >  secrets/keystore.jks
 else
    echo "keystore.jks does not exists"
 fi

 if  truststore=$(oc get secret $secertfile -o yaml  $1 2> /dev/null | grep " truststore.jks"); then
   truststore=$(oc get secret $secertfile -o yaml  $1 2> /dev/null | grep " truststore.jks")
   truststore=$(echo $truststore | sed -e "s/truststore.jks://g" | sed 's/ //g')
   echo $truststore | base64 --decode >  secrets/truststore.jks
 else
    echo "truststore.jks does not exists"
 fi
