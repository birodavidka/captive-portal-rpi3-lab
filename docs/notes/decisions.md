# Döntési napló

Ez a dokumentum rögzíti a projekt fontosabb mérnöki döntéseit és azok indokait.

**2026-03-08 – openNDS irány elvetése**
- **Döntés:** az openNDS integrációt nem folytatjuk Debian 13 alatt.
- **Indok:** instabil működés és nftables kompatibilitási problémák.
- **Következmény:** egyedi middleware irány, kontrollált auth logika.

**2026-03-08 – Baseline-first megközelítés**
- **Döntés:** minden kritikus módosítás előtt baseline és backup.
- **Indok:** SSH elérés megőrzése, visszaállíthatóság.
- **Következmény:** baseline artefaktok külön `artifacts/` mappában.

**2026-03-09 – Monorepo struktúra**
- **Döntés:** a projekt monorepo formában épül.
- **Indok:** együtt verziózott alkalmazás, infra és dokumentáció.
- **Következmény:** `apps/`, `infra/`, `scripts/`, `docs/` egységes szerkezet.

**2026-03-09 – MVP fókusz**
- **Döntés:** voucher alapú beléptetés + session audit + alap metrikák.
- **Indok:** szakdolgozat‑kompatibilis scope, adatvédelmi kockázatok csökkentése.
- **Következmény:** DPI és részletes webes naplózás scope‑on kívül.

**2026-03-12 – Captive engine döntés: egyedi (nftables‑alapú) enforcement**
- **Döntés:** az MVP-ben a captive portal enforcement saját logikával készül (`nftables` allow/deny + portal/API integráció).
- **Indok:** openNDS korábban instabil volt Debian 13 + nftables mellett; CoovaChilli/FreeRADIUS túl nagy komplexitás az MVP‑hez. A projekt fókusza a portal + API + voucher/session logika, ehhez a legegyszerűbb a saját kapu.
- **Következmény:** a gateway csak alap redirect/allowlist/policy szerepet kap, az auth logika az API‑ban él. openNDS/CoovaChilli/FreeRADIUS későbbi opcióként nyitva marad.

**2026-03-13 – Frontend/API stack döntés (MVP)**
- **Döntés:** Vite alapú portal UI + FastAPI backend.
- **Indok:** gyors MVP, egyszeru build es deploy; nincs azonnali SSR/edge igeny. A portal es az API szetvalasztva, az nftables integracio attekinthetobb.
- **Következmény:** Next.js 16 opcionakent nyitva marad kesobbi osszevonashoz vagy SSR‑hez, de jelenleg kulon UI + API komponensek lesznek.

**2026-03-16 – Aktualis config helye vs baseline backup**
- **Döntés:** az aktualis router configok a `infra/pi-router/config/` alatt elnek, a baseline backupok pedig `artifacts/baseline/` alatt maradnak.
- **Indok:** a jelenlegi infrastruktura es a torteneti allapotok egyertelmu szetvalasztasa.
- **Következmény:** a `infra/` mindig az aktualis, mukodo konfiguraciot tukrozi; a baseline mentesei osszehasonlitasra es visszakeresesre szolgálnak.
