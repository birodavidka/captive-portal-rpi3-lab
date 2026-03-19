# Monorepo struktúra

Ez a dokumentum röviden bemutatja a monorepo felépítését és a fő mappák szerepét.

**Miért monorepo**
- Egy helyen verziózott alkalmazás, infrastruktúra és dokumentáció.
- Reprodukálható lab, egységesített változáskövetés.
- Könnyebb demo és portfólió csomagolás.

**Fő mappák**

| Mappa | Szerep |
|---|---|
| `apps/portal-web` | Vite‑alapú captive portal UI + admin dashboard |
| `apps/portal-api` | Backend API (voucher, session, audit) |
| `apps/collector` | Metrika és log ingest komponens |
| `infra/pi-router` | Router konfigurációk és template‑ek |
| `infra/compose` | Docker compose a lab szolgáltatásokhoz |
| `scripts/` | Backup/restore, preflight, smoke test |
| `docs/` | Dokumentáció és döntési napló |
| `artifacts/` | Baseline és diagnosztikai mentések |
| `archive/` | Sikertelen vagy elvetett kísérletek |

**Baseline fájlok javasolt elhelyezése**
- Rendszerinfó: `artifacts/baseline/2026-03-08/system-info/`
- Hálózati mentések: `artifacts/baseline/2026-03-08/network/`
- Nyers backupok: `artifacts/baseline/2026-03-08/backups/`
- Összesített riport: `artifacts/baseline/2026-03-08/reports/`

**Publikálási szabály**
- Nyers configok és érzékeny fájlok ne kerüljenek publikus repóba.
- A repo‑ban inkább `.example` vagy kitakarított verziók legyenek.

**Megjegyzés**
- A struktúra célja, hogy a mérnöki folyamat végig dokumentált és reprodukálható legyen.
 - Az aktuális router configok a `infra/pi-router/config/` alatt vannak; a korábbi állapotok a `artifacts/baseline/` alatt maradnak.

**Dokumentációs rend**
- `docs/guides/` – folyamat‑ és használati leírások
- `docs/reference/` – stabil technikai leírások
- `docs/notes/` – napló, troubleshooting, döntések
