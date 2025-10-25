sudo bash -c '
set -euo pipefail
STAMP=$(date +%Y%m%d-%H%M%S)
BK="/root/nginx-ipv6-purge-$STAMP"
echo "[*] Backup ke $BK"; mkdir -p "$BK"; cp -a /etc/nginx "$BK/"

echo "[*] Menonaktifkan SEMUA listen IPv6 [::]:* di seluruh konfigurasi..."
grep -RIl --include="*.conf" --include="*" "\[::\]:" /etc/nginx 2>/dev/null | while read -r f; do
  sed -ri \
    -e "s/^\s*(listen\s+\[::\]:\s*[0-9]+([^;]*);)/# \1  # disabled: no IPv6/g" \
    "$f"
done

echo "[*] Test config"
nginx -t

echo "[*] Reload/Restart Nginx"
rm -f /run/nginx.pid || true
systemctl reload nginx || systemctl restart nginx

echo "[✓] Selesai. Status:"
systemctl status nginx --no-pager -l || true
'