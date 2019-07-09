set -euo pipefail

display_info() {
  printf "Usage ./stop.sh [OPT]\nOptions are:\n"
  printf "  -h: Show this message\n"
  printf "  -v: Delete volumes\n"
  exit 0
}

DELETE=false
while getopts "vh" OPT; do
  case "$OPT" in
    "v") DELETE=true;;
    "h") display_info;;
    "?") display_info;;
  esac
done

DOCKER_COMPOSE_OPTS="-p hermes -f docker-compose.dev.yml"

if [ "$DELETE" == "true" ]; then
  docker-compose $DOCKER_COMPOSE_OPTS down -v  
else
  docker-compose $DOCKER_COMPOSE_OPTS down 
fi