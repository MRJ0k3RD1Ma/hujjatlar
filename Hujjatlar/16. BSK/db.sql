-- ============================================================================
-- LOYIHA: BSK FaceID Kirish Nazorati Tizimi
-- VERSIYA: 3.0 (SOATO Integratsiyasi + Xavfsizlik Optimallashtiruvi)
-- DB: PostgreSQL 15+
-- MUALLIF: Senior Software Architect Team
-- HOLAT: Production Ready
-- ============================================================================

-- 1. KERAKLI KENGAYTMALAR (EXTENSIONS)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Matnli qidiruvni yaxshilash uchun (Ism, Manzil)

-- 2. ENUM Tiplari (Ma'lumotlar yaxlitligi uchun)
-- ============================================================================
CREATE TYPE user_status AS ENUM ('active', 'blocked', 'pending', 'deleted');
CREATE TYPE resident_status AS ENUM ('active', 'blocked', 'archived', 'deleted');
CREATE TYPE terminal_status AS ENUM ('online', 'offline', 'maintenance', 'error');
CREATE TYPE event_type AS ENUM (
    'DOOR_OPEN_SUCCESS', 'DOOR_OPEN_DENIED', 'DOOR_OPEN_MANUAL',
    'LIVENESS_FAIL', 'DEVICE_ONLINE', 'DEVICE_OFFLINE',
    'SYNC_COMPLETE', 'USER_ADDED', 'USER_DELETED', 'USER_TRANSFERRED',
    'SUSPICIOUS_ATTEMPT', 'DOOR_FORCED', 'HEARTBEAT'
);
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'failed', 'read');
CREATE TYPE otp_purpose AS ENUM ('PASSWORD_RESET', 'LOGIN_VERIFY', 'PHONE_CONFIRM', 'GUEST_ACCESS');
CREATE TYPE sync_status AS ENUM ('pending', 'processing', 'completed', 'failed');

-- 3. GEOGRAFIYA VA SOATO (Yangi - soato.json asosida)
-- ============================================================================
-- TT 1.2: Binolar joylashuvini aniq aniqlash va hududiy hisobotlar uchun
CREATE TABLE soato_regions (
    id BIGINT PRIMARY KEY,             -- soato.json dagi id
    parent_id BIGINT,                  -- soato.json dagi parentId
    code VARCHAR(20),                  -- Ichki kod
    name_uz VARCHAR(255) NOT NULL,     -- O'zbekcha nomi
    name_ru VARCHAR(255),              -- Ruscha nomi
    name_en VARCHAR(255),              -- Inglizcha nomi
    type VARCHAR(50),                  -- 'region', 'district', 'city', 'settlement'
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT TRUE,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_soato_parent ON soato_regions(parent_id);
CREATE INDEX idx_soato_type ON soato_regions(type);
-- Trigram index for search
CREATE INDEX idx_soato_name_uz_trgm ON soato_regions USING gin (name_uz gin_trgm_ops);

-- 4. TASHKILOTLAR VA ROLLAR
-- ============================================================================
-- TT 3-bo'lim: Tashkilot turlari (GASN, BSK, IIV va h.k.)
CREATE TABLE organization_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE, -- 'management_company', 'gasn', 'prokuratura', 'iiv', 'construction'
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    -- Huquqlar flaglari
    can_view_all_buildings BOOLEAN DEFAULT FALSE,
    can_manage_residents BOOLEAN DEFAULT FALSE,
    can_view_logs BOOLEAN DEFAULT FALSE,
    can_access_api BOOLEAN DEFAULT FALSE, -- Tashqi integratsiya uchun
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    organization_type_id INTEGER NOT NULL REFERENCES organization_types(id),
    soato_id BIGINT REFERENCES soato_regions(id), -- Hududiy bog'lanish
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES organizations(id), -- Holding tuzilmasi uchun
    inn VARCHAR(50), -- Soliq ID
    is_bsk BOOLEAN DEFAULT FALSE, -- Boshqaruv Service Kompaniyasi belgisi
    is_active BOOLEAN DEFAULT TRUE,
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_org_type ON organizations(organization_type_id);
CREATE INDEX idx_org_soato ON organizations(soato_id);
CREATE INDEX idx_org_bsk ON organizations(is_bsk);

-- 5. FOYDALANUVCHILAR (Admins, Operators)
-- ============================================================================
-- TT 4.1: Telefon + Parol, Xavfsizlik
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    -- Xavfsizlik: Telefon raqam (Application level encryption)
    phone_hash VARCHAR(64) NOT NULL UNIQUE, -- SHA256(phone) - Qidiruv uchun
    phone_encrypted BYTEA NOT NULL,         -- AES-256(phone) - Ko'rsatish uchun
    password_hash VARCHAR(255) NOT NULL,
    auth_key VARCHAR(255),
    access_token VARCHAR(255),
    
    full_name VARCHAR(255),
    email VARCHAR(255),
    status user_status DEFAULT 'pending',
    
    -- Xavfsizlik sozlamalari
    last_login_at INTEGER,
    last_login_ip INET,
    failed_login_attempts SMALLINT DEFAULT 0,
    locked_until INTEGER,
    
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_users_phone_hash ON users(phone_hash);
CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_name_trgm ON users USING gin (full_name gin_trgm_ops);

-- 5.1. Foydalanuvchi - Bino Bog'lanishi (Operatorlar uchun)
-- TT 3-bo'lim: Bino operatori faqat o'z binosini ko'radi
CREATE TABLE user_buildings (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    building_id INTEGER NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
    granted_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    granted_by INTEGER REFERENCES users(id),
    PRIMARY KEY (user_id, building_id)
);

CREATE INDEX idx_user_buildings_user ON user_buildings(user_id);
CREATE INDEX idx_user_buildings_building ON user_buildings(building_id);

-- 5.2. API Kalitlari (Tashqi tizimlar: GASN, IIV uchun)
-- TT 6.2: Tashqi integratsiya
CREATE TABLE api_credentials (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    name VARCHAR(100) NOT NULL, -- 'GASN Integration', 'IIV Bot'
    api_key_hash VARCHAR(64) NOT NULL UNIQUE,
    secret_key_encrypted BYTEA NOT NULL,
    permissions JSONB, -- ['read_logs', 'read_residents']
    ip_whitelist INET[], -- Faqat ma'lum IP dan kirish
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at INTEGER,
    expires_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_api_key_hash ON api_credentials(api_key_hash);

-- 6. BINOLAR VA TERMINALLAR
-- ============================================================================
-- TT 1.2: Ko'p qavatli binolar
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    soato_id BIGINT REFERENCES soato_regions(id), -- Aniq hudud
    name VARCHAR(255) NOT NULL,
    address TEXT,
    cadastre_code VARCHAR(50), -- GASN Kadastri
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    total_floors INTEGER,
    total_entrances INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_buildings_org ON buildings(organization_id);
CREATE INDEX idx_buildings_soato ON buildings(soato_id);
CREATE INDEX idx_buildings_location ON buildings USING gist (ll_to_earth(latitude, longitude));

-- TT 2.1: FaceID Qurilmalari
CREATE TABLE terminals (
    id SERIAL PRIMARY KEY,
    building_id INTEGER NOT NULL REFERENCES buildings(id),
    entrance_number INTEGER, -- Qaysi подъezd
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100),
    ip_address INET,
    mac_address VARCHAR(50),
    firmware_version VARCHAR(20),
    status terminal_status DEFAULT 'offline',
    
    -- Sinxronizatsiya
    last_sync_at INTEGER,
    last_heartbeat_at INTEGER,
    config_json JSONB, -- Sensitivity, timeout va boshqalar
    
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_terminals_building ON terminals(building_id);
CREATE INDEX idx_terminals_status ON terminals(status);
CREATE INDEX idx_terminals_serial ON terminals(serial_number);

-- 7. REZIDENTLAR VA KIRISH HUQUQLARI
-- ============================================================================
-- TT 2.3: Pasport yo'q, faqat Telefon
CREATE TABLE residents (
    id SERIAL PRIMARY KEY,
    -- Xavfsizlik
    phone_hash VARCHAR(64) NOT NULL,
    phone_encrypted BYTEA NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    
    -- Joylashuv
    current_building_id INTEGER REFERENCES buildings(id),
    apartment_number VARCHAR(20),
    floor_number INTEGER,
    
    status resident_status DEFAULT 'active',
    deleted_at INTEGER,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE UNIQUE INDEX idx_residents_phone_hash ON residents(phone_hash);
CREATE INDEX idx_residents_building ON residents(current_building_id);
CREATE INDEX idx_residents_name_trgm ON residents USING gin (full_name gin_trgm_ops);

-- TT 2.3.4: Ko'chish tarixi
CREATE TABLE resident_building_history (
    id BIGSERIAL PRIMARY KEY,
    resident_id INTEGER NOT NULL REFERENCES residents(id),
    building_id INTEGER NOT NULL REFERENCES buildings(id),
    apartment_number VARCHAR(20),
    moved_in_at INTEGER NOT NULL,
    moved_out_at INTEGER,
    reason TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_history_resident ON resident_building_history(resident_id);

-- TT 2.1.2: Yuz Shablonlari (Shifrlangan)
CREATE TABLE face_templates (
    id SERIAL PRIMARY KEY,
    resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
    template_data BYTEA NOT NULL, -- AES-256 shifrlangan vector
    photo_url VARCHAR(500),       -- MinIO/S3 havolasi
    photo_thumb_url VARCHAR(500),
    is_primary BOOLEAN DEFAULT FALSE,
    quality_score DECIMAL(5, 2),
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_face_resident ON face_templates(resident_id);

-- TT 2.3.1: Access Rights
CREATE TABLE resident_terminal_access (
    id SERIAL PRIMARY KEY,
    resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
    terminal_id INTEGER NOT NULL REFERENCES terminals(id) ON DELETE CASCADE,
    access_start INTEGER,
    access_end INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    updated_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    UNIQUE(resident_id, terminal_id)
);

CREATE INDEX idx_access_resident ON resident_terminal_access(resident_id);
CREATE INDEX idx_access_terminal ON resident_terminal_access(terminal_id);

-- TT 2.3.5: Mehmonlar (QR/PIN)
CREATE TABLE guest_passes (
    id SERIAL PRIMARY KEY,
    host_resident_id INTEGER NOT NULL REFERENCES residents(id),
    terminal_id INTEGER REFERENCES terminals(id), -- NULL bo'lsa barcha terminal
    guest_name VARCHAR(255),
    guest_phone_hash VARCHAR(64),
    access_code VARCHAR(20) NOT NULL UNIQUE, -- QR content yoki PIN
    valid_from INTEGER NOT NULL,
    valid_until INTEGER NOT NULL,
    usage_limit INTEGER DEFAULT 1,
    usage_count INTEGER DEFAULT 0,
    status SMALLINT DEFAULT 1, -- 1=active, 0=used, -1=expired
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_guest_code ON guest_passes(access_code);
CREATE INDEX idx_guest_host ON guest_passes(host_resident_id);

-- 8. LOGLAR VA AUDIT (Xavfsizlik)
-- ============================================================================
-- TT 2.4: Partitioning (oylik)
CREATE TABLE access_logs (
    id BIGSERIAL PRIMARY KEY,
    terminal_id INTEGER NOT NULL REFERENCES terminals(id),
    resident_id INTEGER, -- NULL bo'lsa tanilmagan
    phone_hash VARCHAR(64), -- Skaner qilingan raqam hashi
    event_type event_type NOT NULL,
    photo_url VARCHAR(500),
    metadata JSONB, -- { "confidence": 0.98, "temperature": 36.6 }
    decision_reason VARCHAR(100),
    is_masked BOOLEAN DEFAULT TRUE,
    integrity_hash VARCHAR(64), -- Log yaxlitligi uchun hash
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
) PARTITION BY RANGE (created_at);

-- Indexes for Access Logs
CREATE INDEX idx_logs_terminal ON access_logs(terminal_id);
CREATE INDEX idx_logs_created ON access_logs(created_at);
CREATE INDEX idx_logs_event ON access_logs(event_type);
CREATE INDEX idx_logs_resident ON access_logs(resident_id);

-- TT 5.2: Admin Audit
CREATE TABLE system_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    user_role VARCHAR(50),
    action_category VARCHAR(50) NOT NULL,
    action_name VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id INTEGER,
    target_details VARCHAR(255),
    diff_data JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(128),
    request_id UUID DEFAULT gen_random_uuid(),
    signature_hash VARCHAR(64),
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_audit_user ON system_audit_logs(user_id);
CREATE INDEX idx_audit_action ON system_audit_logs(action_name);
CREATE INDEX idx_audit_created ON system_audit_logs(created_at);

-- TT 3-bo'lim: Maxsus organlar kirishi
CREATE TABLE security_access_logs (
    id BIGSERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES organizations(id),
    user_id INTEGER REFERENCES users(id),
    access_reason TEXT NOT NULL,
    access_document_ref VARCHAR(100), -- So'rovnomasi raqami
    queried_data_type VARCHAR(50),
    query_params JSONB,
    results_count INTEGER,
    ip_address INET,
    signature_hash VARCHAR(64),
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_security_org ON security_access_logs(organization_id);
CREATE INDEX idx_security_created ON security_access_logs(created_at);

-- TT 2.4.2: Log Integrity Chain
CREATE TABLE log_chains (
    id BIGSERIAL PRIMARY KEY,
    log_type VARCHAR(50) NOT NULL,
    log_id BIGINT NOT NULL,
    prev_hash VARCHAR(64),
    current_hash VARCHAR(64) NOT NULL,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE UNIQUE INDEX idx_chain_log ON log_chains(log_type, log_id);

-- 9. BILDIRISHNOMALAR VA OTP
-- ============================================================================
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    status notification_status DEFAULT 'pending',
    external_id VARCHAR(100),
    error_message TEXT,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    sent_at INTEGER,
    read_at INTEGER
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);

CREATE TABLE otp_codes (
    id BIGSERIAL PRIMARY KEY,
    phone_hash VARCHAR(64) NOT NULL,
    code_hash VARCHAR(64) NOT NULL,
    purpose otp_purpose NOT NULL,
    expires_at INTEGER NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    ip_address INET,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER
);

CREATE INDEX idx_otp_phone ON otp_codes(phone_hash);
CREATE INDEX idx_otp_expires ON otp_codes(expires_at);

-- 10. SINXRONIZATSIYA (Offline Mode)
-- ============================================================================
CREATE TABLE sync_queues (
    id BIGSERIAL PRIMARY KEY,
    terminal_id INTEGER NOT NULL REFERENCES terminals(id),
    action_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    status sync_status DEFAULT 'pending',
    retry_count SMALLINT DEFAULT 0,
    error_message TEXT,
    created_at INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::INTEGER,
    processed_at INTEGER
);

CREATE INDEX idx_sync_terminal ON sync_queues(terminal_id);
CREATE INDEX idx_sync_status ON sync_queues(status);

-- 11. YII2 RBAC (Standart)
-- ============================================================================
CREATE TABLE auth_item (
    name VARCHAR(64) PRIMARY KEY,
    type INTEGER NOT NULL,
    description TEXT,
    rule_name VARCHAR(64),
    data BYTEA,
    created_at INTEGER,
    updated_at INTEGER
);

CREATE TABLE auth_item_child (
    parent VARCHAR(64) NOT NULL,
    child VARCHAR(64) NOT NULL,
    PRIMARY KEY (parent, child),
    FOREIGN KEY (parent) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (child) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE auth_assignment (
    item_name VARCHAR(64) NOT NULL,
    user_id INTEGER NOT NULL,
    created_at INTEGER,
    PRIMARY KEY (item_name, user_id),
    FOREIGN KEY (item_name) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE auth_rule (
    name VARCHAR(64) PRIMARY KEY,
    data BYTEA,
    created_at INTEGER,
    updated_at INTEGER
);

-- 12. FUNKSIYALAR VA TRIGGERLAR
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = EXTRACT(EPOCH FROM NOW())::INTEGER;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggerlarni o'rnatish
CREATE TRIGGER update_org_types_updated_at BEFORE UPDATE ON organization_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_org_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_buildings_updated_at BEFORE UPDATE ON buildings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_terminals_updated_at BEFORE UPDATE ON terminals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_residents_updated_at BEFORE UPDATE ON residents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_access_updated_at BEFORE UPDATE ON resident_terminal_access FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 13. DASTLABKI MA'LUMOTLAR (MIGRATION EXAMPLE)
-- ============================================================================
-- Organization Types
INSERT INTO organization_types (name, code, description, can_view_all_buildings, can_manage_residents, can_view_logs, can_access_api, created_at, updated_at) VALUES
('Boshqaruv Service Kompaniyasi', 'management_company', 'Bino boshqaruv kompaniyasi', FALSE, TRUE, TRUE, TRUE, EXTRACT(EPOCH FROM NOW())::INTEGER, EXTRACT(EPOCH FROM NOW())::INTEGER),
('GASN', 'gasn', 'Davlat Arxitektura va Qurilish Nazorati', TRUE, FALSE, TRUE, TRUE, EXTRACT(EPOCH FROM NOW())::INTEGER, EXTRACT(EPOCH FROM NOW())::INTEGER),
('Prokuratura', 'prokuratura', 'Prokuratura organlari', TRUE, FALSE, TRUE, TRUE, EXTRACT(EPOCH FROM NOW())::INTEGER, EXTRACT(EPOCH FROM NOW())::INTEGER),
('IIV', 'iiv', 'Ichki Ishlar Vazirligi', TRUE, FALSE, TRUE, TRUE, EXTRACT(EPOCH FROM NOW())::INTEGER, EXTRACT(EPOCH FROM NOW())::INTEGER),
('Qurilish Boshqarmasi', 'construction', 'Qurilish va ta''mirlash boshqarmasi', FALSE, FALSE, TRUE, FALSE, EXTRACT(EPOCH FROM NOW())::INTEGER, EXTRACT(EPOCH FROM NOW())::INTEGER);

-- ============================================================================
-- QO'SHIMCHA TAVSIYALAR (ARCHITECT NOTES)
-- ============================================================================
-- 1. Partitioning: access_logs jadvali uchun har oy alohida partition yaratish kerak.
--    Masalan: CREATE TABLE access_logs_2025_01 PARTITION OF access_logs FOR VALUES FROM (1735689600) TO (1738368000);
-- 2. Shifrlash: phone_encrypted va template_data maydonlariga yozish/oshish PHP tarafda (OpenSSL) amalga oshiriladi.
-- 3. SOATO: soato.json faylini parse qilib, ushbu jadvalga to'liq import qilish kerak.
-- 4. Backup: Kunlik to'liq backup, soatlik incremental backup tavsiya etiladi.
-- 5. Monitoring: pg_stat_statements kengaytmasini yoqish sekin so'rovlarni aniqlash uchun foydali.