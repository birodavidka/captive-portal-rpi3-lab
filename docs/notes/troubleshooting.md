# Troubleshooting napló

Ez a dokumentum a lab során felmerült hibák és megoldások rövid, visszakereshető összefoglalója.

**Gyors táblázat**

| Dátum | Tünet | Környezet | Ok | Megoldás | Állapot |
|---|---|---|---|---|---|
| 2026-03-08 | openNDS instabil működés Debian 13 alatt | Pi 3, Debian 13, nftables | Kompatibilitási és runtime problémák | A captive engine irányváltása egyedi middleware irányba | lezárt |
| Dátum nem rögzített | Docker repo 404 `raspbian trixie` ágon | Pi 3, Debian 13 | Nem létező repo ág | Debian repo vagy `get-docker.sh` használata | lezárt |
| Dátum nem rögzített | `get-docker.sh` közben hálózati hiba | Pi 3, Debian 13 | Átmeneti kapcsolat hiba | Újrafuttatás után sikeres | lezárt |

**Részletes bejegyzések**

## 2026-03-08 – openNDS instabilitás
- **Tünet:** az openNDS a Debian 13 (trixie) környezetben nem stabil, nftables kompatibilitási problémákkal.
- **Hatás:** a lab irányváltott egy kontrolláltabb, egyedi middleware architektúrára.
- **Következő lépés:** a captive engine véglegesítése későbbi mérföldkőként kezelendő.

## Dátum nem rögzített – Docker repo 404
- **Tünet:** a `https://download.docker.com/linux/raspbian trixie` repo 404‑et ad.
- **Hatás:** csomag telepítés megakad.
- **Megoldás:** Debian repo használata vagy `get-docker.sh` futtatása.

**Jegyzet**
- Új hibák felvitele rövid, reprodukálható formában történjen (tünet + környezet + megoldás).
