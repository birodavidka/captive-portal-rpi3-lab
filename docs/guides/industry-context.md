# Iparági háttér és minták

Ez a fejezet röviden összefoglalja, hogyan jelenik meg a captive portal és az enterprise Wi‑Fi hozzáférés a gyakorlatban.

**Captive portal szerepe**
- Tipikusan vendég Wi‑Fi (guest access) környezetekben használják.
- A kliens csatlakozik, majd egy kötelező weboldalon (ÁSZF, voucher, e‑mail, sponsor approval) halad át.
- A cél a kontrollált internetelérés és az auditálható hozzáférés.

**Enterprise belső hozzáférés**
- Belső Wi‑Fi‑nél általában 802.1X / WPA2‑Enterprise / WPA3‑Enterprise + RADIUS + NAC a standard.
- A captive portal itt jellemzően csak vendég forgatókönyvekhez kapcsolódik.

**Tipikus enterprise topológia**
- AP‑k + (W)LAN controller vagy cloud menedzsment.
- AAA: RADIUS alapú auth és accounting.
- Guest management: voucher, időkorlát, naplózás, riport.

**A lab értelme ebben a kontextusban**
- A projekt a vendég Wi‑Fi vonalat demonstrálja.
- Kiemeli a gateway logikát, auditálhatóságot és a hardening szemléletet.
