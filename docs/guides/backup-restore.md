# Backup és rollback

Ez a dokumentum a lab biztonságos változtatási folyamatát és a backup/rollback alapelveket rögzíti.

**Cél**
- Hálózati vagy tűzfalszabály változtatás előtt gyors visszaállítás biztosítása.
- SSH elérés megőrzése a teljes iteráció alatt.

**Mit kell menteni**
- `hostapd`, `dnsmasq`, `nftables`, `sysctl` konfigurációk.
- Hálózati beállítások és route táblák.
- Kritikus logok és diagnosztikai kimenetek.

**Mikor mentünk**
- Minden routing, NAT vagy tűzfalszabály módosítás előtt.
- Minden szolgáltatás verzió vagy konfiguráció cseréje előtt.

**Rollback elv**
- Legalább két párhuzamos SSH session aktív.
- Konzol menekülőút biztosítása.
- Gyors visszaállítás előkészített mentésből.

**Későbbi kiegészítés**
- A `scripts/backup` és `scripts/restore` mappák részletes használati leírása.
