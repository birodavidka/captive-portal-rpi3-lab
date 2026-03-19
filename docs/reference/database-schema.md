# Adatbázis séma

Ez a dokumentum a captive portal MVP adatmodelljét rögzíti MySQL formátumban.

**Célok**
- Voucher alapú engedélyezés támogatása.
- Session életciklus és auditálhatóság.
- Forgalmi metrikák idősoros tárolása.

**Táblák röviden**
- `admin_users`: admin fiókok és szerepkörök.
- `vouchers`: voucher kódok és érvényesség.
- `devices`: eszköz metaadatok (MAC, hostname, vendor).
- `sessions`: session életciklus és forgalmi összesítők.
- `session_stats`: idősoros metrika.
- `auth_events`: auth események részletes naplója.
- `audit_logs`: admin műveletek auditja.

**Indoklás**
- A `sessions` a központi üzleti entitás, a dashboard nézetek többsége erre épül.
- A `session_stats` külön táblában marad, így könnyebb idősorokat és aggregációkat számolni.
- A `devices` csak technikai azonosító, a MAC randomizáció miatt nem identitás.
- Az `auth_events` és `audit_logs` a szakdolgozat szempontjából auditálhatóvá teszi a rendszert.

**Kapcsolatok**
- Egy `admin_user` több `voucher`‑t hozhat létre.
- Egy `voucher` több `session`‑höz kapcsolódhat.
- Egy `device` több `session`‑t indíthat.
- Egy `session` több `session_stats` rekordot kaphat.
- Egy `session`, `voucher` és `device` több `auth_event` rekordban is szerepelhet.
- Egy `admin_user` több `audit_log` bejegyzést generálhat.

**Megjegyzések**
- A metrikák forrása lehet nftables számláló vagy RADIUS accounting.
- Az „milyen oldalakat nézett” jellegű naplózás scope‑on kívül marad adatvédelmi okokból.

```sql
CREATE TABLE admin_users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(120) NOT NULL,
    role ENUM('super_admin', 'admin', 'viewer') NOT NULL DEFAULT 'admin',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vouchers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code_hash CHAR(64) NOT NULL UNIQUE,
    code_hint VARCHAR(16) NULL,
    label VARCHAR(120) NULL,
    status ENUM('draft', 'active', 'expired', 'revoked', 'exhausted') NOT NULL DEFAULT 'active',
    max_uses INT UNSIGNED NOT NULL DEFAULT 1,
    used_count INT UNSIGNED NOT NULL DEFAULT 0,
    valid_from DATETIME NULL,
    valid_to DATETIME NULL,
    session_time_limit_sec INT UNSIGNED NULL,
    traffic_quota_mb INT UNSIGNED NULL,
    notes TEXT NULL,
    created_by_admin_id BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_vouchers_created_by
        FOREIGN KEY (created_by_admin_id) REFERENCES admin_users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE devices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    mac_address CHAR(17) NOT NULL UNIQUE,
    oui_vendor VARCHAR(120) NULL,
    dhcp_hostname VARCHAR(255) NULL,
    first_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_uuid CHAR(36) NOT NULL UNIQUE,
    voucher_id BIGINT UNSIGNED NULL,
    device_id BIGINT UNSIGNED NOT NULL,
    client_ip VARCHAR(45) NULL,
    gateway_ip VARCHAR(45) NULL,
    ssid VARCHAR(64) NULL,
    auth_method ENUM('voucher', 'clickthrough', 'radius', 'manual') NOT NULL DEFAULT 'voucher',
    state ENUM('pending', 'authorized', 'expired', 'revoked', 'closed', 'failed') NOT NULL DEFAULT 'pending',
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    authorized_at DATETIME NULL,
    ended_at DATETIME NULL,
    end_reason VARCHAR(64) NULL,
    rx_bytes_total BIGINT UNSIGNED NOT NULL DEFAULT 0,
    tx_bytes_total BIGINT UNSIGNED NOT NULL DEFAULT 0,
    collector_source ENUM('nftables', 'radius', 'manual') NOT NULL DEFAULT 'nftables',
    CONSTRAINT fk_sessions_voucher
        FOREIGN KEY (voucher_id) REFERENCES vouchers(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_sessions_device
        FOREIGN KEY (device_id) REFERENCES devices(id)
        ON DELETE RESTRICT,
    INDEX idx_sessions_state (state),
    INDEX idx_sessions_started_at (started_at),
    INDEX idx_sessions_voucher_id (voucher_id),
    INDEX idx_sessions_device_id (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE session_stats (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT UNSIGNED NOT NULL,
    captured_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rx_bytes_total BIGINT UNSIGNED NOT NULL DEFAULT 0,
    tx_bytes_total BIGINT UNSIGNED NOT NULL DEFAULT 0,
    rx_bps BIGINT UNSIGNED NULL,
    tx_bps BIGINT UNSIGNED NULL,
    CONSTRAINT fk_session_stats_session
        FOREIGN KEY (session_id) REFERENCES sessions(id)
        ON DELETE CASCADE,
    INDEX idx_session_stats_session_time (session_id, captured_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT UNSIGNED NULL,
    voucher_id BIGINT UNSIGNED NULL,
    device_id BIGINT UNSIGNED NULL,
    event_type ENUM('attempt', 'success', 'deny', 'timeout', 'logout', 'deauth') NOT NULL,
    reason_code VARCHAR(64) NULL,
    details_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auth_events_session
        FOREIGN KEY (session_id) REFERENCES sessions(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_auth_events_voucher
        FOREIGN KEY (voucher_id) REFERENCES vouchers(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_auth_events_device
        FOREIGN KEY (device_id) REFERENCES devices(id)
        ON DELETE SET NULL,
    INDEX idx_auth_events_created_at (created_at),
    INDEX idx_auth_events_event_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_type ENUM('admin', 'system') NOT NULL DEFAULT 'system',
    actor_admin_id BIGINT UNSIGNED NULL,
    action VARCHAR(120) NOT NULL,
    entity_type VARCHAR(64) NOT NULL,
    entity_id BIGINT UNSIGNED NULL,
    source_ip VARCHAR(45) NULL,
    details_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_admin
        FOREIGN KEY (actor_admin_id) REFERENCES admin_users(id)
        ON DELETE SET NULL,
    INDEX idx_audit_logs_created_at (created_at),
    INDEX idx_audit_logs_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```
