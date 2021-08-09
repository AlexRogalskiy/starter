#!/bin/bash
if [ -z "$SERVER_SSL_KEY_PASSWORD" ] || [ -z "$SERVER_SSL_KEY_STORE_PASSWORD" ]
then
  echo "Usage:"
  echo ""
  echo "self_signed.sh [java_home] [hostname] [certificates_directory_path] [cacerts_password]"
  echo ""
  echo "  - java_home is defaulted to $JAVA_HOME"
  echo "  - hostname is defaulted to $HOSTNAME"
  echo "  - certificates_directory_path is defaulted to current diretory"
  echo "  - cacerts_password is defaulted to changeit"
  echo ""
  echo "SERVER_SSL_KEY_PASSWORD and SERVER_SSL_KEY_STORE_PASSWORD environment variables must be defined"
  echo ""
  echo "If you have only one JRE / JDK and JAVA_HOME environment variable set:"
  echo "./self_signed.sh"
  echo ""
  echo "If you have several java versions installed, run for each for instance:"
  echo "./self_signed.sh \"C:/Java/jdk1.8.0_281\""
  echo ""
  exit 1
else

  echo "#------------------------------------------"
  echo "# This is a no-op script"
  echo "# Copy / paste output to:"
  echo "#   - generate certificate files"
  echo "#   - import certificates into cacerts file"
  echo "#------------------------------------------"
  
  echo "SERVER_SSL_KEY_PASSWORD: ${SERVER_SSL_KEY_PASSWORD}"
  echo "SERVER_SSL_KEY_STORE_PASSWORD: ${SERVER_SSL_KEY_STORE_PASSWORD}"
  
  if [ -z "$1" ]
  then
	if [ -z "$JAVA_HOME" ]
    then
      echo "ERROR: could not locate JDK / JRE root directory"
	  exit 1
    else
      JAVA=$JAVA_HOME
	  echo "JDK / JRE root directory defaulted to JAVA_HOME. Provide JDK / JRE root directory as 1st command-line argument to change that."
    fi
  else
    JAVA=$1
  fi
  JAVA=$(echo $JAVA | sed 's/\\/\//g')
  echo "JAVA: $JAVA"
  
  if [ -f "${JAVA}/lib/security/cacerts" ]
  then
    # recent JDKs and JREs style
    CACERTS="${JAVA}/lib/security/cacerts"
  elif [ -f "${JAVA}/jre/lib/security/cacerts" ]
  then
    # legacy JDKs style (1.8 and older)
    CACERTS="${JAVA}/jre/lib/security/cacerts"
  else
    echo "ERROR: could not locate cacerts under $JAVA"
    exit 1
  fi
  echo "CACERTS path: $CACERTS"
  
  if [ -z "${2}" ]
  then
    HOST="$HOSTNAME"
	echo "Using HOSTNAME env variable. Override with 2nd command-line argument"
  else
    HOST="${2}"
  fi
  echo "HOST (certificate CN): $HOST"
  
  if [ -z "${3}" ]
  then
    CERTIF_DIR="."
	echo "Using current directory as output directory for certificate files. Override with 3rd command-line argument"
  else
    CERTIF_DIR="${3}"
  fi
  CERTIF_DIR=$(echo $CERTIF_DIR | sed 's/\\/\//g')
  echo "certificates directory path: $CERTIF_DIR"
  
  if [ -z "${4}" ]
  then
    CACERTS_PASSWORD="changeit"
	echo "Using $CACERTS_PASSWORD as cacerts file password. Override with 4th command-line argument"
  else
    CACERTS_PASSWORD="${4}"
  fi
  echo "cacerts file password: $CACERTS_PASSWORD" 
  echo "#------------------------------------------"
  echo "self_signed.sh $JAVA $HOST $CERTIF_DIR $CACERTS_PASSWORD"
  echo "#------------------------------------------"
fi

echo ""
echo ""
rm -f ${HOST}_self_signed.config;
sed 's/\[hostname\]/'${HOST}'/g' "${CERTIF_DIR}/self_signed_template.config" > "${CERTIF_DIR}/${HOST}_self_signed.config"

echo openssl req -config \"${CERTIF_DIR}/${HOST}_self_signed.config\" -new -keyout \"${CERTIF_DIR}/${HOST}_req_key.pem\" -passout pass:${SERVER_SSL_KEY_PASSWORD} -out \"${CERTIF_DIR}/${HOST}_cert_req.pem\" -reqexts v3_req
echo ""

echo openssl x509 -req -days 365 -extfile \"${CERTIF_DIR}/${HOST}_self_signed.config\" -in \"${CERTIF_DIR}/${HOST}_cert_req.pem\" -extensions v3_req -signkey \"${CERTIF_DIR}/${HOST}_req_key.pem\" -passin pass:${SERVER_SSL_KEY_PASSWORD} -out \"${CERTIF_DIR}/${HOST}_self_signed.crt\"
echo ""

echo openssl x509 -in \"${CERTIF_DIR}/${HOST}_self_signed.crt\" -out \"${CERTIF_DIR}/${HOST}_self_signed.pem\" -outform PEM
echo ""
 
echo openssl pkcs12 -export -in \"${CERTIF_DIR}/${HOST}_self_signed.crt\" -inkey \"${CERTIF_DIR}/${HOST}_req_key.pem\" -passin pass:${SERVER_SSL_KEY_PASSWORD} -name ${HOST} -out \"${CERTIF_DIR}/${HOST}_self_signed.p12\" -passout pass:${SERVER_SSL_KEY_STORE_PASSWORD}
echo ""

echo \"${JAVA}/bin/keytool\" -importkeystore -srckeystore \"${CERTIF_DIR}/${HOST}_self_signed.p12\" -srcstorepass \"${SERVER_SSL_KEY_STORE_PASSWORD}\" -srcstoretype pkcs12 -srcalias ${HOST} -destkeystore \"${CERTIF_DIR}/${HOST}_self_signed.jks\" -deststoretype PKCS12 -deststorepass ${SERVER_SSL_KEY_STORE_PASSWORD} -destalias ${HOST}
echo ""

echo "# Might need to sudo this one"
echo \"${JAVA}/bin/keytool\" -importkeystore -srckeystore \"${CERTIF_DIR}/${HOST}_self_signed.p12\" -srcstorepass \"${SERVER_SSL_KEY_STORE_PASSWORD}\" -srcstoretype pkcs12 -srcalias ${HOST} -destkeystore \"${CACERTS}\" -deststorepass ${CACERTS_PASSWORD} -destalias ${HOST}
echo ""
