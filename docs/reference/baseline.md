# Baseline dokumentáció

Ez a dokumentum a Raspberry Pi 3 lab környezet baseline állapotát és a gyűjtés módszerét összegzi. A részletes artefaktok az `artifacts/baseline/2026-03-08/` alatt találhatók.

**Cél**
- Kiinduló állapot rögzítése a későbbi változások biztonságos összehasonlításához.
- Visszaállítás és auditálhatóság támogatása.

**Rögzített környezet (2026-03-08)**
- OS: Debian GNU/Linux 13 (trixie)
- Kernel: 6.12.47+rpt-rpi-v8
- Architektúra: arm64
- Eszköz: Raspberry Pi 3 Model B Rev 1.2

**Erőforrások és tárolás**
- RAM: ~906 MiB, swap: ~905 MiB
- Rendszerpartíció: ~28.5 GB ext4, külön /boot/firmware

**Hálózati állapot**
- `eth0` és `wlan0` aktív, DHCP‑s címekkel.
- DHCP útvonalak mindkét interfészen jelen.
- SSH szolgáltatás elérhető (port 22).

**Wi‑Fi állapot**
- `wlan0` managed módban, aktív SSID‑vel.
- Bluetooth tiltva.

**Forwarding / tűzfal**
- `net.ipv4.ip_forward = 0` (baseline állapot).

**Gyűjtési parancsok (ajánlott)**
- OS és hardver: `cat /etc/os-release`, `uname -a`, `cat /proc/cpuinfo`, `nproc`, `free -h`.
- Tárolás: `lsblk`, `df -h`, `mount`.
- Hálózat: `ip -br a`, `ip a`, `ip r`, `ss -tulpn`, `resolvectl status`.
- Wi‑Fi képességek: `iw dev`, `iw phy`, `iw list`, `rfkill list`.
- Szolgáltatások: `systemctl status NetworkManager`, `systemctl status systemd-networkd`, `systemctl status wpa_supplicant`, `systemctl status ssh`.
- Tűzfal és NAT: `sysctl net.ipv4.ip_forward`, `sudo nft list ruleset`, `sudo iptables-save`.

**Egyben futtatható riport (minta)**
- A baseline gyűjtés összevonható egyetlen report fájlba, dátumozott névvel.
- A cél az, hogy a riport a legfontosabb OS, hálózati és szolgáltatás állapotokat tartalmazza.

**Megjegyzés**
- A baseline célja az összehasonlíthatóság, nem a végleges konfiguráció.
- Élesítés előtt a publikus adatok és IP‑k anonimizálása javasolt.


## Frissített hálózati állapot (2026-03-12)

- `wlan0` unmanaged (NetworkManagerből kivéve), `systemd-networkd` kezeli.
- `wlan0` statikus IP: `192.168.4.1/24` (`ConfigureWithoutCarrier=yes`).
- `hostapd` AP mód aktív, SSID sugárzás működik.
- `dnsmasq` DHCP/DNS aktív, pool: `192.168.4.50–192.168.4.150`.
- `net.ipv4.ip_forward = 1`.
- `nftables` NAT + forward aktív (`wlan0` → `eth0`).
- `eth0` továbbra is DHCP uplink, default route az `eth0`-n.