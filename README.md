# trikem-maintenance

Tillfällig underhållssida för Trikem under uppgraderingen till Odoo 19.

> **Kund:** Trikem · **Publikt repo med flit** — ska raderas när uppgraderingen är klar.

Sidan ligger i [`docs/`](docs/) och serveras med GitHub Pages (branch `main`, mapp `/docs`).

## Underhållsläge på production1 (nginx)

`nginx/` innehåller ett underhållsläge som slås på/av utan att röra Odoo-konfigurationen:

| Fil | Hamnar i | Syfte |
|---|---|---|
| `nginx/conf.d/trikem-maintenance.conf` | `/etc/nginx/conf.d/` | IP-adresser som går förbi underhållssidan (fyll i på servern) |
| `nginx/snippets/trikem-maintenance.conf` | `/etc/nginx/snippets/` | Inkluderas i varje server-block som ska stängas |
| `nginx/maintenance.sh` | – | `install`, `on`, `off`, `status` |

```sh
sudo ./nginx/maintenance.sh install   # lägger sidan i /var/www/trikem-maintenance + nginx -t
# lägg in i server-blocken för www/b2b/retailer.trikem.se (+ trikem18.implefy.se), direkt efter server_name:
#     include snippets/trikem-maintenance.conf;
sudo nginx -t && sudo systemctl reload nginx
sudo ./nginx/maintenance.sh on        # alla utom bypass-IP får sidan (HTTP 503 + Retry-After)
sudo ./nginx/maintenance.sh off       # tillbaka till Odoo
```

Av/på kräver ingen reload – nginx tittar efter filen `/var/www/trikem-maintenance/ON`.
