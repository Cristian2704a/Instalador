#!/bin/bash

# https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$PROJECT_ROOT/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# required imports
source "${PROJECT_ROOT}"/variables/manifest.sh
source "${PROJECT_ROOT}"/utils/manifest.sh
source "${PROJECT_ROOT}"/lib/manifest.sh

if [ -z "$1" ]; then
  echo "Erro: Chave de licença do MaxMind não fornecida."
  echo "Uso: ./register_maxmind.sh <sua_chave_de_licenca>"
  exit 1
fi

maxmind_license_key=$1

print_banner
printf "${WHITE} 💻 Configurando o GeoIP com a nova chave...${GRAY_LIGHT}"
printf "\n\n"

sudo su - root <<EOF
apt-get install -y nginx-module-geoip2
sed -i '1s@^@load_module /usr/share/nginx/modules/ngx_http_geoip2_module.so;\n@' /etc/nginx/nginx.conf
EOF

system_geoip_setup
system_nginx_restart

print_banner
printf "${GREEN} ✔️ Configuração do GeoIP concluída com sucesso!${NC}"
printf "\n\n"