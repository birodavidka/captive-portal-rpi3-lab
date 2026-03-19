# Hardening és biztonsági elvek

Ez a dokumentum a lab hardening szemléletét, alapelveit és ajánlott lépéseit rögzíti.

**Alapelvek**
- Ne zárjuk ki magunkat a rendszerből.
- Minden kritikus változtatás előtt legyen visszaállítási terv.
- A guest és a management felületek szigorúan szeparáltak.

**Hozzáférés és szeparáció**
- SSH és admin felület csak menedzsment irányból elérhető.
- Guest hálózatból default deny minden management szolgáltatás felé.
- Külön tűzfalszabályok guest és mgmt irányra.

**SSH hardening**
- Kulcsos autentikáció kötelező.
- Jelszavas belépés tiltása.
- Root login tiltása.
- Rate limit vagy fail2ban opcionálisan.

**Tűzfal és hálózat**
- Default deny inbound a guest háló felől.
- Engedélyezett: DNS, DHCP, portal elérés.
- Kimenő forgalom kontrollja session‑szabályok alapján.

**Backup és rollback**
- Minden hálózati/tűzfal módosítás előtt config backup.
- Legalább két párhuzamos SSH session a változtatások alatt.
- Konzol menekülőút biztosítása (monitor/keyboard vagy más hozzáférés).

**Szolgáltatások minimalizálása**
- Felesleges szolgáltatások leállítása.
- Csak a szükséges portok nyitva.
- Logrotate és retention beállítás a fontos logokra.

**Konténer és API hardening (ha alkalmazott)**
- Minimális image‑ek, minimális portkitettség.
- Secret kezelés elkülönítve.
- Admin endpointok korlátozása és auditálása.
