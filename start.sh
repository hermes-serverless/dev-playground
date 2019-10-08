set -euo pipefail

display_info() {
  printf "Usage ./start.sh [OPT]\nOptions are:\n"
  printf "  -h: Show this message\n"
  printf "  -m: Migrate\n"
  printf "  -s: Seed\n"
  exit 0
}

SEED=false
MIGRATE=false
while getopts "msh" OPT; do
  case "$OPT" in
    "m") MIGRATE=true;;
    "s") SEED=true;;
    "h") display_info;;
    "?") display_info;;
  esac 
done

docker network create hermes || true

DOCKER_COMPOSE_OPTS="-p hermes -f docker-compose.dev.yml"

if [ "$MIGRATE" == "true" ] || [ "$SEED" == "true" ]; then
  docker build -t hermeshub/db-migrator --target=migrator ./function-registry-api/packages/function-registry-api
  docker-compose $DOCKER_COMPOSE_OPTS up -d function-registry-db
  
  if [ "$MIGRATE" == "true" ]; then
    docker run --network=hermes --rm -it hermeshub/db-migrator ./scripts/migrate.sh -e development
  fi

  if [ "$SEED" == "true" ]; then
    docker run --network=hermes --rm -it hermeshub/db-migrator ./scripts/seed.sh -e development
  fi

  docker-compose $DOCKER_COMPOSE_OPTS down
fi

docker-compose $DOCKER_COMPOSE_OPTS up --build