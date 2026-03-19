# Mentések készítése – részletes dokumentáció

Ez a dokumentum lépésről lépésre leírja, hogyan készítettük el a Raspberry Pi 3 lab környezet mentéseit és baseline‑ját. A parancsok a Pi‑n futnak SSH‑n keresztül.

**Cél**
- A kiinduló rendszerállapot rögzítése.
- Visszaállítási alap biztosítása hálózati és tűzfal módosítások előtt.
- Reprodukálható, auditálható lab dokumentáció.

## 1) Előkészítés

Készítsünk egy mappát a mentéseknek a Pi‑n:

```bash
mkdir -p ~/lab-baseline
```

## 2) OS + hardver azonosítás

```bash
cat /etc/os-release | tee ~/lab-baseline/os-release.txt
hostnamectl | tee ~/lab-baseline/hostnamectl.txt
uname -a | tee ~/lab-baseline/uname.txt
cat /proc/cpuinfo | tee ~/lab-baseline/cpuinfo.txt
nproc | tee ~/lab-baseline/cpu-cores.txt
free -h | tee ~/lab-baseline/memory.txt
vcgencmd version | tee ~/lab-baseline/vcgencmd-version.txt
vcgencmd get_mem arm | tee ~/lab-baseline/vcgencmd-mem-arm.txt
vcgencmd get_mem gpu | tee ~/lab-baseline/vcgencmd-mem-gpu.txt
cat /proc/device-tree/model | tee ~/lab-baseline/model.txt
```

## 3) Tároló és fájlrendszer

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL | tee ~/lab-baseline/lsblk.txt
df -h | tee ~/lab-baseline/df.txt
mount | tee ~/lab-baseline/mount.txt
```

## 4) Hálózati interfészek és routing

```bash
ip -br a | tee ~/lab-baseline/ip-br-a.txt
ip a | tee ~/lab-baseline/ip-a.txt
ip r | tee ~/lab-baseline/ip-route.txt
ip rule | tee ~/lab-baseline/ip-rule.txt
ss -tulpn | tee ~/lab-baseline/ss-tulpn.txt
resolvectl status | tee ~/lab-baseline/resolvectl-status.txt
```

## 5) Wi‑Fi / AP képességek

```bash
iw dev | tee ~/lab-baseline/iw-dev.txt
iw phy | tee ~/lab-baseline/iw-phy.txt
iw list | tee ~/lab-baseline/iw-list.txt
rfkill list | tee ~/lab-baseline/rfkill.txt
```

## 6) Hálózatkezelő szolgáltatások

```bash
systemctl status NetworkManager --no-pager | tee ~/lab-baseline/status-NetworkManager.txt
systemctl status systemd-networkd --no-pager | tee ~/lab-baseline/status-systemd-networkd.txt
systemctl status dhcpcd --no-pager | tee ~/lab-baseline/status-dhcpcd.txt
systemctl status wpa_supplicant --no-pager | tee ~/lab-baseline/status-wpa_supplicant.txt
systemctl status ssh --no-pager | tee ~/lab-baseline/status-ssh.txt
```

## 7) Fontos csomagok listája

```bash
dpkg -l | grep -E 'hostapd|dnsmasq|nftables|iptables|opennds|freeradius|docker|NetworkManager|systemd-networkd|wpa_supplicant' | tee ~/lab-baseline/packages-network.txt
```

## 8) Forwarding + tűzfal + NAT baseline

```bash
sysctl net.ipv4.ip_forward | tee ~/lab-baseline/ip-forward.txt
sysctl net.ipv6.conf.all.forwarding | tee ~/lab-baseline/ipv6-forward.txt
sudo nft list ruleset | tee ~/lab-baseline/nft-ruleset.txt
sudo iptables-save | tee ~/lab-baseline/iptables-save.txt
```

## 9) Boot és naplók (gyors ellenőrzés)

```bash
systemd-analyze | tee ~/lab-baseline/systemd-analyze.txt
systemd-analyze blame | tee ~/lab-baseline/systemd-analyze-blame.txt
journalctl -b -p warning --no-pager | tee ~/lab-baseline/journal-warnings.txt
```

## 10) Docker baseline (ha van)

```bash
docker --version | tee ~/lab-baseline/docker-version.txt
docker info | tee ~/lab-baseline/docker-info.txt
docker ps -a | tee ~/lab-baseline/docker-psa.txt
```

## 11) Összefoglaló riport egyben

Ez egy gyors, dátumozott összefoglaló jelentés:

```bash
OUT=~/lab-baseline/report-$(date +%F-%H%M).txt
{
 echo "===== OS ====="
 cat /etc/os-release
 echo
 uname -a
 echo
 hostnamectl
 echo
 echo "===== MODEL / CPU / RAM ====="
 cat /proc/device-tree/model
 echo
 nproc
 echo
 free -h
 echo
 echo "===== STORAGE ====="
 lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
 echo
 df -h
 echo
 echo "===== NETWORK ====="
 ip -br a
 echo
 ip r
 echo
 ss -tulpn
 echo
 echo "===== WIFI ====="
 iw dev
 echo
 rfkill list
 echo
 echo "===== FORWARD / FIREWALL ====="
 sysctl net.ipv4.ip_forward
 echo
 sudo nft list ruleset
 echo
 echo "===== SERVICES ====="
 systemctl is-active ssh
 systemctl is-active NetworkManager
 systemctl is-active systemd-networkd
 systemctl is-active wpa_supplicant
 systemctl is-active hostapd
 systemctl is-active dnsmasq
} | tee "$OUT"
echo "Mentve ide: $OUT"
```

## 12) Mentések áthelyezése a repóba

A mentéseket dátum szerinti mappába rendezzük. Példa a `2026-03-08` snapshotra:

```bash
mkdir -p ~/captive-portal-rpi3-lab/artifacts/baseline/2026-03-08/{system-info,network,backups,reports}

mv ~/lab-baseline/os-release.txt ~/lab-baseline/hostnamectl.txt ~/lab-baseline/uname.txt \
   ~/lab-baseline/cpuinfo.txt ~/lab-baseline/cpu-cores.txt ~/lab-baseline/memory.txt \
   ~/lab-baseline/model.txt ~/lab-baseline/vcgencmd-* \
   ~/captive-portal-rpi3-lab/artifacts/baseline/2026-03-08/system-info/

mv ~/lab-baseline/ip-*.txt ~/lab-baseline/ip-route.txt ~/lab-baseline/ip-rule.txt \
   ~/lab-baseline/ss-tulpn.txt ~/lab-baseline/resolvectl-status.txt \
   ~/captive-portal-rpi3-lab/artifacts/baseline/2026-03-08/network/

mv ~/lab-baseline/report-*.txt \
   ~/captive-portal-rpi3-lab/artifacts/baseline/2026-03-08/reports/
```

Ha van nyers config backup (pl. `final-backup`), azt külön a `backups/` mappába tesszük.

## 13) Biztonsági megjegyzések

- Nyers konfigurációk és érzékeny adatok ne kerüljenek publikus repóba.
- Publikálás előtt csak kitakarított vagy `.example` fájlokat tartsunk meg.

