# Lab napló

A lab napló rövid, dátum alapú bejegyzésekkel dokumentálja a mérföldköveket és döntéseket.

## 2026-03-06 – Brainstorming és scope
- Projekt cél: portfólió‑kompatibilis captive portal lab Raspberry Pi 3‑on.
- Fő komponensek: Vite portal UI, API (Python/TS), MySQL, nftables, hostapd, dnsmasq.
- Döntési pont: openNDS (FAS) vs CoovaChilli (RADIUS).

## 2026-03-08 – Baseline rögzítés
- Debian 13 (trixie) és kernel állapot rögzítve.
- Hálózati alapállapot felvéve (eth0 és wlan0 aktív, DHCP).
- Baseline artefaktok mentve az `artifacts/baseline/2026-03-08/` alatt.

## 2026-03-09 – Dokumentáció konszolidáció
- Projekt scope és architektúra dokumentumok létrehozása.
- Hardening és troubleshooting dokumentumok vázának elkészítése.
- Adatbázis séma dokumentáció rendezése.

## 2026-03-12 – Routed AP + captive v1 alapok
- `wlan0` kivétele a NetworkManager kezelesebol, statikus IP `192.168.4.1/24` a `systemd-networkd`-vel.
- `hostapd` AP beallitas, SSID sugarzas mukodik.
- `dnsmasq` DHCP/DNS kiosztas, guest alhalozat `192.168.4.0/24`.
- `nftables` NAT + forwarding aktiv, internet eleres mukodik guest oldalon.
- `nginx` 8080-on alap portal oldalhoz (HTTP redirect 80 -> 8080).
- Captive v1 enforcement: pre-auth csak portal, post-auth allowlist.

## 2026-03-13 – Captive finomitasok es stack irany
- Portal input szigoritas: `wlan0` felol engedett, `eth0` felol tiltott (8080).
- Android captive detection tamogatas dnsmasq opcio 114 + Google connectivity host override-okkal.
- Stack irany: Vite portal UI + FastAPI backend az MVP-hez.

## 2026-03-16 – Dokumentacio rendbetetel es aktualis config helye
- A `docs/` mappa atstrukturalt, kulon `guides/`, `reference/`, `notes/` csoportokra.
- Letrejott egy rovid `docs/README.md` index.
- Az aktualis router konfiguracio a `infra/pi-router/config/` ala kerult.
- A korabbi allapotok a baseline backupok alatt maradnak (`artifacts/baseline/`).

## Dátum nem rögzített – Docker telepítés kísérlet
- Docker repo hozzáadás `raspbian` ágon 404 hibával meghiúsult.
- `get-docker.sh` futtatás közben átmeneti hálózati hiba (connection reset).
- Végül Debian `trixie` repóval sikeres telepítés.

## Dátum nem rögzített – Routed AP előkészítés
- `wlan0` kivétele a NetworkManager kezeléséből.
- `systemd-networkd` használata statikus `10.10.10.1/24` IP‑hez.
- `hostapd` és `dnsmasq` alapkoncepciók rögzítése.
- IP forwarding és NAT tervezett lépések a routed AP befejezéséhez.

## 2026-03-12 – Routed AP kész (hostapd + dnsmasq + nftables)
- `wlan0` kivéve a NetworkManager alól, `systemd-networkd` statikus IP-vel.
- `hostapd` AP módban, SSID sugárzás működik.
- `dnsmasq` DHCP/DNS kiosztás működik (`192.168.4.0/24` tartomány).
- `nftables` NAT + forward aktív, internet elérés működik.
- Kliens teszt: IP kiosztás + ping `192.168.4.1`, `8.8.8.8`, `google.com` OK.
