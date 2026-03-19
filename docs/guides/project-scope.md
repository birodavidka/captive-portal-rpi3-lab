# Projekt scope

Ez a dokumentum rögzíti a Raspberry Pi 3 alapú captive portal lab projekt célját, hatókörét és korlátait. A scope a dokumentációs és mérnöki munka közös kerete, nem részletes megvalósítási terv.

**Eredeti ötlet és motiváció**
- Raspberry Pi 3 routerként működik: WAN `eth0`, LAN/AP `wlan0`.
- Captive portal UI Vite‑ban, backend Python/TypeScript irányban.
- MySQL alapú voucher és session tárolás.
- Hardening gyakorlása, SSH elérés megőrzése, baseline backup.
- Portfólió‑ és szakdolgozat‑kompatibilis dokumentáció.

**Cél**
- Egy működő, dokumentált lab környezet felépítése, amely egy kis vendég Wi‑Fi gateway-t szimulál.
- A teljes mérnöki folyamat bemutatása: baseline, infrastruktúra beállítás, routing, hardening, döntések és kudarcok.
- Egy később bővíthető, egyedi captive portal stack alapjainak létrehozása.

**Projektkontekstus**
- Hardver: Raspberry Pi 3
- OS: Debian 13 (Trixie)
- Upstream: `eth0`, downstream: `wlan0`
- Monorepo struktúra: alkalmazások, infra, scriptek és dokumentáció együtt fejlődnek.

**Scope-ban**
- Router/gateway alapok: hostapd, dnsmasq, IP forwarding, NAT, nftables szabályok.
- Baseline és változáskövetés: rendszerinformációk, hálózati állapot, backupok.
- Captive portal architektúra: egyedi Python middleware + Vite frontend + MySQL tároló (tervezett/elő­készített komponensek).
- Dokumentáció: architektúra, döntések, hardening, troubleshooting, lab napló.
- Nyílt kísérletek és tanulságok: openNDS integráció dokumentált kudarca és irányváltás.

**Scope-on kívül**
- Teljes körű, enterprise szintű NAC/AAA megoldás.
- Automatikus kliens‑azonosítás vagy 802.1X/PKI integráció.
- Nagy rendelkezésre állás, redundancia, produkciós SLA.
- Gyártói/ISP szintű router funkciók (QoS policy engine, DPI, centralizált menedzsment).

**Fő szállítmányok (deliverables)**
- Reprodukálható lab infrastruktúra leírások és template-ek az `infra/` alatt.
- Captive portal UI és API váz (tervezési és kezdeti implementációs állapot).
- Dokumentációs csomag a `docs/` alatt, beleértve a döntési naplót és hardening jegyzeteket.
- Baseline és diagnosztikai artefaktok az `artifacts/` alatt.

**Feltételezések és korlátok**
- A lab környezet lokalizált, egyetlen Raspberry Pi 3 eszközre épül.
- A hálózat nem publikusan elérhető, kontrollált tesztkörnyezet.
- A biztonsági módosításoknál elsődleges a visszaállíthatóság és az SSH elérhetőség.
- A captive portal funkcionalitás iteratív; a stabil router alapok megelőzik az alkalmazásréteget.

**Sikerkritériumok**
- A Raspberry Pi stabilan biztosít vendég Wi‑Fi hozzáférést, elkülönített hálózattal.
- Reprodukálható a router konfiguráció és a baseline állapot.
- A captive portal architektúra és komponensei dokumentáltak és bővíthetők.
- A projekt bemutatható és auditálható portfólió/oktatási célra.

**Nyitott kérdések**
- A voucher/session modell véglegesítése és az API felület részletei.
- A MySQL séma és az admin UI terjedelme.
- A mérési/collector komponens valódi igénye és terjedelme.
