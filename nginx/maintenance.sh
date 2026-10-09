#!/bin/sh
# Trikem underhållsläge på production1.
#
#   sudo ./nginx/maintenance.sh install   # lägger ut sida + nginx-filer, kör nginx -t
#   sudo ./nginx/maintenance.sh on        # visa underhållssidan
#   sudo ./nginx/maintenance.sh off       # tillbaka till Odoo
#   ./nginx/maintenance.sh status
set -eu

WWW=/var/www/trikem-maintenance
REPO=$(cd "$(dirname "$0")/.." && pwd)

case "${1:-}" in
  install)
    mkdir -p "$WWW"
    # Loggan läggs in i HTML:en så att sidan är en enda fil (alla URL:er ger samma sida).
    B64=$(base64 -w0 "$REPO/docs/logo.png")
    sed "s|src=\"logo.png\"|src=\"data:image/png;base64,$B64\"|" \
        "$REPO/docs/index.html" > "$WWW/index.html"
    chmod 644 "$WWW/index.html"
    install -m 644 "$REPO/nginx/snippets/trikem-maintenance.conf" /etc/nginx/snippets/
    if [ -e /etc/nginx/conf.d/trikem-maintenance.conf ]; then
      echo "Behåller befintlig /etc/nginx/conf.d/trikem-maintenance.conf (IP-lista)"
    else
      install -m 644 "$REPO/nginx/conf.d/trikem-maintenance.conf" /etc/nginx/conf.d/
    fi
    nginx -t
    echo "Klart. Lägg in 'include snippets/trikem-maintenance.conf;' i server-blocken och kör: systemctl reload nginx"
    ;;
  on)
    touch "$WWW/ON"
    echo "Underhållsläge PÅ"
    ;;
  off)
    rm -f "$WWW/ON"
    echo "Underhållsläge AV"
    ;;
  status)
    if [ -e "$WWW/ON" ]; then echo "PÅ"; else echo "AV"; fi
    ;;
  *)
    echo "Användning: $0 install|on|off|status" >&2
    exit 1
    ;;
esac
