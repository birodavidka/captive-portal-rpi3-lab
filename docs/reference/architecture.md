# Architektúra

Ez a dokumentum a Raspberry Pi 3 alapú captive portal lab architektúráját írja le, a komponensek szerepével és a fő adatfolyamokkal együtt.

**Áttekintés**
- A Raspberry Pi 3 gatewayként működik: WAN oldalon `eth0`, LAN/AP oldalon `wlan0`.
- A vendég kliens DHCP‑t és DNS‑t kap, majd captive portalon keresztül kerül engedélyezésre.
- A portal UI és az admin felület Vite‑ban készül; a backend az auth, voucher, session és audit logikát kezeli.
- A metrikák és forgalmi számlálók gyűjtése külön collector komponens feladata.

**Topológia (lab)**
```text
Internet
   |
   |  (eth0 - upstream/WAN)
   |
[Raspberry Pi 3]
   |- hostapd       -> Wi‑Fi access point
   |- dnsmasq       -> DHCP / DNS
   |- nftables      -> NAT / forward / policy
   |- Captive engine -> redirect + auth kapu
   |- API           -> voucher / session / audit
   |- Portal UI     -> vendég UI + admin UI
   |- MySQL         -> adatok és metrikák
   |
   |  (wlan0 - guest/LAN)
   |
Guest kliensek
```

**Komponensek és szerepek**

| Komponens | Szerep | Megjegyzés |
|---|---|---|
| `hostapd` | Wi‑Fi AP | SSID, csatorna, WPA2/WPA3 beállítások |
| `dnsmasq` | DHCP + DNS | IP kiosztás, alap hotspot DNS |
| `nftables` | NAT + policy | Guest izoláció, mgmt allowlist, counters |
| Captive engine | Portal kényszerítés | openNDS (FAS) vagy CoovaChilli (RADIUS) |
| Portal UI (Vite) | Vendég felület | Login/ÁSZF/voucher flow |
| API (Python/TS) | Auth + session | Voucher, audit, admin endpointok |
| MySQL | Adattárolás | Vouchers, sessions, stats |
| Collector | Metrikák | nftables/RADIUS számlálók ingest |

**Captive portal folyamat (MVP)**
1. Kliens csatlakozik a vendég SSID‑hez, DHCP‑t kap.
2. Az első HTTP/HTTPS kérés redirectet kap a portal oldalra.
3. A portal UI elfogadja az ÁSZF‑et vagy bekéri a voucher kódot.
4. Az API validálja a voucher‑t és létrehozza a sessiont.
5. A gateway engedélyezi a kliens forgalmát a session idejére.
6. A session lezárásra kerül timeout vagy logout esetén.

**Rövid technikai magyarázat (rétegek)**
- `hostapd` L2 szinten AP módba kapcsolja a Wi‑Fi kártyát és kezeli az association/auth folyamatot.
- `systemd-networkd` determinisztikus IP‑t ad a `wlan0` interfésznek, stabil alapot teremtve a DHCP/DNS számára.
- `dnsmasq` DHCP szerverként IP‑t oszt, DNS forwarderként továbbítja a kéréseket.
- `nftables` és kernel forwarding engedélyezik a `wlan0` → `eth0` forgalmat és NAT‑olják a klienseket.

**Adatfolyamok és naplózás**
- DHCP lease → eszköz metaadat (MAC, hostname, first/last seen).
- Portal auth → session és auth_event rekordok.
- nftables/RADIUS counters → idősoros metrika (session_stats).
- Admin műveletek → audit log bejegyzések.

**Captive engine opciók**
- **openNDS + FAS**: a gateway végzi a „fogást”, a portal + API külső döntést hoz. Jó, ha a portal és az API a fókusz.
- **CoovaChilli + FreeRADIUS**: klasszikus AAA és accounting irány. Jó, ha az enterprise AAA szemlélet a fő bemutatási cél.

**Observability és admin**
- Aktív sessionök és session history.
- Eszközlista (MAC, DHCP hostname, OUI vendor).
- Forgalmi metrikák (bytes in/out, idősor).

**Kapcsolódó ábrák**
- `docs/diagrams/01-topology.md`
- `docs/diagrams/02-auth-flow.md`

**Nyitott döntések**
- Captive engine véglegesítése (openNDS vs CoovaChilli).
- Admin dashboard mélysége és a collector szükséges részletei.
- Vouchers vs felhasználó alapú auth kombináció.
