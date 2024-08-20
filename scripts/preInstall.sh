#set env vars
set -o allexport; source .env; set +o allexport;


# SMTP CONFIGURATION
cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"
done < "$filename"

rm post.txt

SMTP_ADDRESS=tuesday.mxrouting.net
SMTP_PORT=465

cat <<EOF >> "./.env"
SMTP_ADDRESS=$SMTP_ADDRESS
SMTP_LOGIN=$SMTP_LOGIN
SMTP_PASSWORD=$SMTP_PASSWORD
SMTP_USERNAME=$SMTP_LOGIN
SMTP_PORT=$SMTP_PORT

SECRET_KEY_BASE=$(openssl rand -hex 64)
EOF


cat <<EOT > ./servers.json
{
    "Servers": {
        "1": {
            "Name": "local",
            "Group": "Servers",
            "Host": "172.17.0.1",
            "Port": 4636,
            "MaintenanceDB": "maybe",
            "SSLMode": "prefer",
            "Username": "maybe",
            "PassFile": "/pgpass"
        }
    }
}
EOT
