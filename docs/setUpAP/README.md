# AP + Captive v1 beallitas (Debian 13, Pi 3)

Ez a dokumentum lepesrol lepesre rogzit, mit allitottunk be, miert volt ra szukseg, es hogyan ellenoriztuk a mukodest.
Cel: stabil AP + DHCP + NAT + egyszeru captive enforcement (nftables + portal/API logika), ugy hogy az `eth0` SSH eleres mindig megmaradjon.

## Kiindulasi helyzet

- OS: Debian GNU/Linux 13 (trixie)
- Kernel: 6.12.x+rpt-rpi-v8
- `eth0`: upstream WAN, DHCP, ezen megy az SSH
- `wlan0`: guest/LAN AP halozat
- NetworkManager aktiv, de `wlan0`-t kivesszuk a kezelesebol
- Cel alhalozat: `192.168.4.0/24` (gateway: `192.168.4.1`)

## Miert erre az iranyra mentunk

- Stabil router alapok kellenek, mielott a portal/UI/API keszen van.
- Captive enforcement cel: default deny a guest halo felol, csak DHCP/DNS + portal, majd auth utan engedely.
- openNDS/CoovaChilli/FreeRADIUS opciok nyitva maradnak, de MVP-ben egyedi nftables logika a gyorsabb es kontrollaltabb.

## Halozati szerepek rogzitese

### 1) `wlan0` kivetele a NetworkManagerbol

Miert: elkeruljuk az utkozest hostapd + statikus IP mellett.

Fajl:
`/etc/NetworkManager/conf.d/unmanaged-wlan0.conf`

```ini
[keyfile]
unmanaged-devices=interface-name:wlan0
```

### 2) Statikus IP `wlan0`-on (systemd-networkd)

Miert: stabil gateway cim a DHCP-hez, a captive szabalyokhoz es a portalhoz.
ConfigureWithoutCarrier: AP inditas elott is meglegyen az IP.

Fajl:
`/etc/systemd/network/10-wlan0.network`

```ini
[Match]
Name=wlan0

[Network]
Address=192.168.4.1/24
DHCP=no
IPv6AcceptRA=no
ConfigureWithoutCarrier=yes
```

## AP es DHCP/DNS

### 3) hostapd (AP)

Miert: AP mod, SSID es WPA2.

Fajl:
`/etc/hostapd/hostapd.conf`

```ini
interface=wlan0
driver=nl80211

ssid=YOUR_SSID
country_code=HU
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1

auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=YOUR_PASSPHRASE
rsn_pairwise=CCMP

ctrl_interface=/run/hostapd
ctrl_interface_group=0
```

Fajl:
`/etc/default/hostapd`

```ini
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

### 4) dnsmasq (DHCP/DNS)

Miert: kliens IP kiosztas, DNS forward.

Fajl:
`/etc/dnsmasq.d/ap.conf`

```ini
interface=wlan0
bind-interfaces

domain-needed
bogus-priv

dhcp-range=192.168.4.50,192.168.4.150,255.255.255.0,12h
dhcp-option=3,192.168.4.1
dhcp-option=6,192.168.4.1
dhcp-leasefile=/var/lib/misc/dnsmasq.leases
log-dhcp
```

Android captive detection tamogatas:

```ini
dhcp-option=114,http://192.168.4.1/

# Android
address=/connectivitycheck.gstatic.com/192.168.4.1
address=/clients3.google.com/192.168.4.1
address=/connectivitycheck.android.com/192.168.4.1

# Apple
address=/captive.apple.com/192.168.4.1
address=/www.apple.com/192.168.4.1

# Windows
address=/www.msftconnecttest.com/192.168.4.1
address=/msftconnecttest.com/192.168.4.1
address=/www.msftncsi.com/192.168.4.1
address=/msftncsi.com/192.168.4.1

# Firefox
address=/detectportal.firefox.com/192.168.4.1
```

Megjegyzes:
- Nem wildcard DNS hijackot hasznalunk, mert auth utan is a Pi-re mutatna minden nevfeloldas.
- A fenti domain-ek elegsegesek ahhoz, hogy a fo mobil/desktop kliensek captive probe-ja nagy esellyel felhozza a portalt automatikusan.

## IP forwarding + NAT

### 5) IP forwarding

Miert: `wlan0` -> `eth0` routing.

Fajl:
`/etc/sysctl.d/99-ipforward.conf`

```ini
net.ipv4.ip_forward=1
```

### 6) nftables (NAT + captive enforcement v1)

Miert:
- NAT a guest halo forgalmara
- Captive: pre-auth csak portal, post-auth full internet

Fajl:
`/etc/nftables.conf`

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  set authed_v4 {
    type ipv4_addr
    flags timeout
    timeout 12h
  }

  chain input {
    type filter hook input priority 0; policy accept;
    iifname "wlan0" tcp dport 8080 accept
    iifname "eth0" tcp dport 8080 drop
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept
    iifname "wlan0" oifname "eth0" ip saddr @authed_v4 accept
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}

table ip nat {
  set authed_v4 {
    type ipv4_addr
    flags timeout
    timeout 12h
  }

  chain prerouting {
    type nat hook prerouting priority -100; policy accept;
    iifname "wlan0" ip saddr @authed_v4 accept
    iifname "wlan0" tcp dport 80 redirect to :8080
  }

  chain postrouting {
    type nat hook postrouting priority 100; policy accept;
    oifname "eth0" ip saddr 192.168.4.0/24 masquerade
  }
}
```

Auth engedelyezes (API-bol kesobb):

```bash
sudo nft add element inet filter authed_v4 { 192.168.4.127 timeout 12h }
sudo nft add element ip nat authed_v4 { 192.168.4.127 timeout 12h }
```

Auth visszavonas:

```bash
sudo nft delete element inet filter authed_v4 { 192.168.4.127 }
sudo nft delete element ip nat authed_v4 { 192.168.4.127 }
```

## Portal kiszolgalas

### 7) nginx (port 8080)

Miert: stabilabb, mint `python -m http.server`.
A captive redirect 80-rol 8080-ra megy.

Fajl:
`/etc/nginx/sites-available/captive-portal`

```nginx
server {
    listen 8080 default_server;
    server_name _;

    root /var/www/captive-portal;
    index index.html;

    location = /hotspot-detect.html {
        try_files /index.html =404;
    }

    location = /generate_204 { return 302 http://192.168.4.1:8080/; }
    location = /gen_204      { return 302 http://192.168.4.1:8080/; }
    location = /connecttest.txt { return 302 http://192.168.4.1:8080/; }
    location = /redirect        { return 302 http://192.168.4.1:8080/; }
    location = /ncsi.txt        { return 302 http://192.168.4.1:8080/; }
    location = /success.txt     { return 302 http://192.168.4.1:8080/; }

    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }
}
```

### 8) Portal build kiexportalasa nginx ala

Miert:
- a portal mar Next appkent keszul
- a jelenlegi guest flow statikus oldalakkal mukodik
- Pi-n egyszerubb es stabilabb, ha nginx kozvetlenul a generalt fajlokat szolgalja ki

Frontend oldalon:

```ts
// apps/portal-web/next.config.ts
const nextConfig = {
  output: "export",
  trailingSlash: true,
};
```

Build helyben vagy a Pi-n:

```bash
cd apps/portal-web
npm run build
```

Ennek eredmenye az `apps/portal-web/out/` mappa.

Telepites a Pi-n:

```bash
sudo mkdir -p /var/www/captive-portal
sudo rsync -av --delete apps/portal-web/out/ /var/www/captive-portal/
sudo nginx -t
sudo systemctl reload nginx
```

Fontos:
- A portal `index.html`, `/guest/`, `/login/` es a tobbi statikus route az exportalt `out/` konyvtarbol jon.
- Az export build egyszer ker ki kulso font asseteket a build gepen, ezert a `npm run build` alatt kell mukodo upstream internet.
- Ha a gateway IP nem `192.168.4.1`, akkor a `dnsmasq` es `nginx` captive endpointokban ezt at kell irni.

## Mukodes ellenorzese

### AP + DHCP

- Kliens IP: `192.168.4.x`
- Gateway: `192.168.4.1`
- DNS: `192.168.4.1`

### Pre-auth

- `http://example.com` -> portal
- `ping 8.8.8.8` -> nem megy

### Post-auth

- `ping 8.8.8.8` -> megy
- `https://google.com` -> megy
- `http://example.com` -> nem redirectal

## "Ne zarjuk ki magunkat" szabalyok

- `eth0` DHCP es SSH marad erintetlen.
- `wlan0` kulon alhalozat, statikus IP.
- Minden lepes utan ellenorzes.
- Captive tesztet mindig guest oldalrol vegezz.

## Nyitott iranyok (kesobb)

- openNDS / CoovaChilli / FreeRADIUS integracio kesobb.
- Portal + API integracio (voucher, session, audit).
- Metrikak es session statisztikak.
