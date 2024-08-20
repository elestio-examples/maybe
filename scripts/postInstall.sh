#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 10s;

# Generate INVITE CODE
output=$(docker-compose exec app bundle exec rake invites:create)
invite_code=$(echo "$output" | tail -n 1)
echo "INVITE_CODE=$invite_code" >> .env
