# Captive Portal RPi3 Lab

A portfolio-oriented lab project that turns a Raspberry Pi 3 into a small edge router / guest access gateway and serves as the foundation for a custom captive portal system.

The goal of the project is not only to build a working portal, but also to document the full engineering process behind it: baseline collection, network setup, routing, hardening, failed integration attempts, and the transition toward a more maintainable custom solution.

---

## Project Overview

This repository contains a Raspberry Pi 3 based lab environment designed to simulate a small guest Wi-Fi access system.

The Raspberry Pi receives upstream connectivity on **eth0** and provides downstream wireless access on **wlan0**. The long-term objective is to build a custom captive portal stack with:

- a **Vite-based portal UI**
- a **Python-based middleware / API**
- **MySQL-backed voucher and session storage**
- optional **traffic collection and admin dashboard**
- infrastructure and router configuration tracked as code

This project is intentionally built as a **monorepo**, so the application code, infrastructure configuration, scripts, and documentation can evolve together.

---

## Why this project?

This lab is meant to demonstrate more than a splash page.

It is a practical mini guest-access / NAC-style prototype that combines:

- routed access point fundamentals
- DHCP/DNS/NAT on Linux
- captive portal design
- authentication / voucher concepts
- session auditing
- basic traffic/accounting visibility
- hardening and rollback-oriented operations
- reproducible infrastructure documentation

That makes it suitable both for learning and for portfolio / thesis-style presentation.

---

## Current Status

At the current stage, the repository focuses on:

- collecting and preserving a **clean system baseline**
- documenting the Raspberry Pi lab environment
- organizing the project into a maintainable monorepo structure
- preparing infrastructure-as-code style router configuration
- recording the failed **openNDS** integration attempt and the resulting engineering decision

### Important note

The original plan included testing openNDS as the captive portal engine.  
During implementation and debugging, Debian 13 compatibility issues were observed around nftables / runtime behavior, so the project direction was adjusted.

**Current engineering direction:**
- keep the Raspberry Pi as the router / gateway lab platform
- keep the custom portal frontend
- replace the fragile monolithic gateway layer with a **custom Python middleware**
- manage authorization logic more explicitly and transparently

---

## Target Architecture

```text
Internet
   |
   |  (eth0 - upstream/WAN)
   |
[Raspberry Pi 3]
   |- hostapd       -> Wi-Fi access point
   |- dnsmasq       -> DHCP / DNS for clients
   |- nftables      -> routing / NAT / client authorization logic
   |- Python API    -> captive portal middleware / voucher validation
   |- Vite frontend -> portal UI / admin UI
   |- MySQL         -> vouchers, sessions, audit data
   |
   |  (wlan0 - guest/LAN)
   |
Guest devices
```

### Logical layers

**Network layer**
- routed AP
- DHCP/DNS
- IP forwarding
- NAT

**Portal layer**
- guest onboarding UI
- voucher / login / acceptance flow
- controlled transition from limited to authorized access

**Application layer**
- session handling
- audit logging
- admin endpoints
- dashboard-ready metrics

**Operations / security**
- backups
- rollback mindset
- SSH-safe hardening
- reproducible configuration

---

## Repository Structure

```
captive-portal-rpi3-lab/
├── README.md
├── .gitignore
├── docs/
│   ├── 00-project-scope.md
│   ├── 01-architecture.md
│   ├── 02-baseline.md
│   ├── 03-decisions.md
│   ├── 04-hardening.md
│   └── diagrams/
│
├── artifacts/
│   └── baseline/
│       └── 2026-03-08/
│           ├── system-info/
│           ├── network/
│           ├── backups/
│           └── reports/
│
├── infra/
│   ├── pi-router/
│   │   ├── hostapd/
│   │   ├── dnsmasq/
│   │   ├── nftables/
│   │   ├── sysctl/
│   │   ├── network/
│   │   ├── NetworkManager/
│   │   └── systemd/
│   ├── compose/
│   └── provisioning/
│
├── apps/
│   ├── portal-web/
│   ├── portal-api/
│   └── collector/
│
├── scripts/
│   ├── backup/
│   ├── restore/
│   ├── gather-info/
│   └── smoke-tests/
│
└── archive/
    └── failed-experiments/
```

---

## Planned Components

### `apps/portal-web`

Frontend portal built with Vite.

Planned responsibilities:
- captive portal landing page
- voucher / login flow
- success / authorized page
- optional admin dashboard UI

### `apps/portal-api`

Backend service, planned in Python.

Planned responsibilities:
- voucher validation
- client authorization workflow
- session creation / expiration
- audit logging
- admin endpoints

### `apps/collector`

Optional Python service for metrics and traffic accounting.

Planned responsibilities:
- periodic session statistics collection
- nftables / gateway counter export
- health endpoint
- dashboard-oriented summaries

### `infra/pi-router`

Infrastructure-as-code style router configuration.

Planned responsibilities:
- hostapd templates
- dnsmasq templates
- nftables rules
- sysctl settings
- service integration helpers

### `docs/`

Project documentation and engineering notes.

Planned responsibilities:
- architecture
- threat model
- hardening notes
- implementation journal
- troubleshooting
- demo flow

---

## Baseline-First Approach

Before changing critical networking or security settings, this project stores a baseline snapshot of the Raspberry Pi environment.

Examples of collected data:
- CPU / memory / model information
- OS and kernel details
- hostname / system identification
- network interface details
- netplan / connection backups
- reports and manual notes

This supports:
- safer experimentation
- rollback planning
- traceable changes
- reproducible lab documentation

---

## Security Mindset

A key principle of this lab is:

> **do not lock yourself out while hardening the system**

Security-related priorities include:
- preserving backups before major changes
- avoiding guest access to management surfaces
- separating guest and admin concerns
- limiting exposed services
- keeping sensitive files out of public version control
- documenting rollback options before risky changes

During development, the Wi-Fi should remain in a controlled and safe state whenever the captive portal layer is incomplete or unstable.

---

## What happened with openNDS?

An early implementation path evaluated openNDS as the captive portal engine.

This was useful from a research and architectural point of view, but in this Debian 13 based Raspberry Pi environment the integration proved unstable. Rather than forcing a brittle dependency into the design, the project now treats that phase as a documented diagnostic milestone and moves toward a more controllable custom solution.

**This is not a failure of the project.**  
**It is part of the engineering process.**

The documented outcome is valuable because it shows:
- platform evaluation
- deep debugging effort
- risk awareness
- design adaptation based on observed behavior

---

## Roadmap

### Phase 0 — Baseline and documentation
- [x] Collect system and network baseline
- [x] Preserve backups
- [x] Create initial monorepo structure
- [x] Write core project documentation

### Phase 1 — Routed AP foundation
- [ ] Finalize hostapd configuration
- [ ] Finalize dnsmasq configuration
- [ ] Validate forwarding and NAT
- [ ] Document smoke tests

### Phase 2 — Custom captive portal backend
- [ ] Define voucher and session data model
- [ ] Build Python middleware skeleton
- [ ] Implement authorization workflow
- [ ] Add audit logging

### Phase 3 — Portal frontend
- [ ] Build Vite portal UI
- [ ] Connect to backend API
- [ ] Add success / denied / expired states
- [ ] Prepare demo-ready flow

### Phase 4 — Admin and observability
- [ ] Session history view
- [ ] Live client view
- [ ] Voucher management
- [ ] Traffic/accounting metrics
- [ ] Alerts / abuse detection basics

### Phase 5 — Hardening and reproducibility
- [ ] Add sanitized infra templates
- [ ] Add apply/restore scripts
- [ ] Add smoke tests
- [ ] Add deployment / rebuild notes

---

## Tech Stack

Planned / evaluated technologies in this project:

| Layer | Technology |
|---|---|
| Hardware | Raspberry Pi 3 |
| OS | Debian 13 (Trixie) |
| Wi-Fi AP | hostapd |
| DHCP/DNS | dnsmasq |
| Firewall / NAT / policy | nftables |
| Frontend | Vite |
| Backend | Python |
| Database | MySQL |
| Optional AAA / lab extension | FreeRADIUS |
| Containerization / lab services | Docker / Compose |

---

## What this repo is for

This repository is intended to support:
- lab experimentation
- structured troubleshooting
- thesis / portfolio documentation
- reproducible infrastructure work
- later demo and presentation material

It is not just an app repository.  
**It is the full engineering workspace around the app.**

---

## Notes for public version control

Before pushing publicly:
- remove or sanitize real secrets
- do not commit raw private backups blindly
- review network configuration dumps
- replace sensitive configs with `*.example` files where needed
- avoid publishing personally identifying data from the lab

---

## Next Documentation Files

Suggested first documents to complete:
- `docs/00-project-scope.md`
- `docs/01-architecture.md`
- `docs/02-baseline.md`
- `docs/03-decisions.md`

---

## License

This project is currently for educational, lab, and portfolio purposes.
A formal license may be added later.

---

## Author

Dávid Biró  
Engineering Informatics student / Sysadmin-focused lab builder