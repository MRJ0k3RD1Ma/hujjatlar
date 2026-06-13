-- ============================================================
-- POWER SUN v2.1 - MA'LUMOTLAR BAZASI SKRIPTI
-- MySQL 8.0+ / InnoDB / utf8mb4
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. HUDUDLAR (Region & District)
CREATE TABLE `region` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL COMMENT 'Viloyat nomi',
  `status` ENUM('active','disabled','deleted') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_region_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `district` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL COMMENT 'Tuman/shahar nomi',
  `region_id` INT(11) NOT NULL,
  `status` ENUM('active','disabled','deleted') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_district_region` (`region_id`),
  INDEX `idx_district_status` (`status`),
  CONSTRAINT `fk_district_region` FOREIGN KEY (`region_id`) REFERENCES `region`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. FOYDALANUVCHILAR (Ustalar)
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `telegram_id` BIGINT UNIQUE NOT NULL COMMENT 'Telegram foydalanuvchi ID',
  `name` VARCHAR(255) NOT NULL COMMENT 'To''liq ism',
  `phone` VARCHAR(20) NOT NULL COMMENT 'Telefon raqam',
  `customer_type` ENUM('individual','legal','sole_proprietor') DEFAULT 'individual',
  `legal_name` VARCHAR(255) NULL COMMENT 'Yuridik nomi (agar kerak bo''lsa)',
  `region_id` INT(11) NULL,
  `district_id` INT(11) NULL,
  `status` ENUM('active','blocked') DEFAULT 'active',
  `state` VARCHAR(100) NULL COMMENT 'Bot dialog holati (Redis asosiy, bu zaxira)',
  `state_data` JSON NULL COMMENT 'Qisman to''ldirilgan ariza ma''lumotlari',
  `pin_hash` VARCHAR(255) NULL COMMENT 'Chiqim so''rovi uchun PIN (bcrypt hash)',
  `pin_attempts` TINYINT(3) DEFAULT 0 COMMENT 'Noto''g''ri PIN urinishlar soni',
  `pin_locked_until` TIMESTAMP NULL COMMENT 'PIN lockout tugash vaqti',
  `pin_set_at` TIMESTAMP NULL COMMENT 'PIN o''rnatilgan/yangilangan vaqt',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_users_telegram` (`telegram_id`),
  INDEX `idx_users_status` (`status`),
  INDEX `idx_users_region` (`region_id`),
  INDEX `idx_users_district` (`district_id`),
  CONSTRAINT `fk_users_region` FOREIGN KEY (`region_id`) REFERENCES `region`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_district` FOREIGN KEY (`district_id`) REFERENCES `district`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. ADMINISTRATORLAR
CREATE TABLE `admins` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `login` VARCHAR(100) UNIQUE NOT NULL COMMENT 'Email yoki username',
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'bcrypt hash',
  `role` ENUM('superadmin','admin') DEFAULT 'admin',
  `status` ENUM('active','inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_admin_login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. ASOSIY MA'LUMOTNOMALAR (Invertorlar, Materiallar, Sozlamalar)
CREATE TABLE `inverters` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `model` VARCHAR(255) NOT NULL COMMENT 'Invertor modeli',
  `manufacturer` VARCHAR(255) NULL COMMENT 'Ishlab chiqaruvchi',
  `power_kw` DECIMAL(10,2) NULL COMMENT 'Quvvati (faqat ma''lumot uchun)',
  `points_per_unit` INT NOT NULL COMMENT '1 dona uchun ball',
  `status` ENUM('active','inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_inverter_status` (`status`),
  INDEX `idx_inverter_model` (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `materials` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL COMMENT 'Material nomi (masalan: Kabel, Montaj to''plami)',
  `unit` ENUM('meter','piece','set','kg') NOT NULL COMMENT 'O''lchov birligi',
  `points_per_unit` INT NOT NULL COMMENT '1 birlik uchun ball',
  `status` ENUM('active','inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_material_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `settings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `key` VARCHAR(100) UNIQUE NOT NULL,
  `value` TEXT NOT NULL,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Boshlang'ich sozlamalar
INSERT INTO `settings` (`key`, `value`) VALUES
('point_value', '5000'),
('min_kw', '1'),
('max_kw', '1000'),
('max_daily_apps', '3'),
('min_withdrawal_som', '50000'),
('pin_length', '4'),
('pin_max_attempts', '3'),
('pin_lockout_minutes', '30')
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`);

-- 5. ARIZALAR (Installations)
CREATE TABLE `installations` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `inverter_id` INT(11) NOT NULL,
  `location` TEXT NOT NULL COMMENT 'Lokatsiya matni',
  `location_lat` DECIMAL(10,8) NULL,
  `location_lng` DECIMAL(11,8) NULL,
  `address` TEXT NOT NULL COMMENT 'Obyekt manzili',
  `object_type` ENUM('house','factory','office','other') NOT NULL,
  `kw` DECIMAL(10,2) NULL COMMENT 'Quvvat (faqat ma''lumot/validatsiya uchun)',
  `inverter_count` INT NOT NULL COMMENT 'Invertor soni',
  `points_per_unit_snapshot` INT NOT NULL COMMENT 'Ariza paytidagi invertor balli',
  `base_points` INT NOT NULL COMMENT 'points_per_unit_snapshot * inverter_count',
  `material_bonus_points` INT DEFAULT 0 COMMENT 'Materiallardan yig''ilgan qo''shimcha ball',
  `total_points` INT NOT NULL COMMENT 'Jami ball (base + material)',
  `point_value_snapshot` DECIMAL(15,2) NOT NULL COMMENT '1 ball qiymati (so''m)',
  `total_amount` DECIMAL(15,2) NOT NULL COMMENT 'Jami hisoblangan summa',
  `paid_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Ariza bo''yicha to''langan summa',
  `extra_materials_note` TEXT NULL COMMENT 'Qo''lda kiritilgan material izohi',
  `notes` TEXT NULL COMMENT 'Qo''shimcha izoh',
  `status` ENUM('pending','approved','rejected','partially_paid','paid') DEFAULT 'pending',
  `reject_reason` TEXT NULL,
  `version` INT DEFAULT 1 COMMENT 'Optimistic lock',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_inst_user` (`user_id`),
  INDEX `idx_inst_inverter` (`inverter_id`),
  INDEX `idx_inst_status` (`status`),
  INDEX `idx_inst_created` (`created_at`),
  CONSTRAINT `fk_inst_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_inst_inverter` FOREIGN KEY (`inverter_id`) REFERENCES `inverters`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. ARIZAGA BOG'LIQ JADVALAR (Rasmlar, Materiallar, Status Tarixi)
CREATE TABLE `installation_photos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `installation_id` INT(11) NOT NULL,
  `photo_url` VARCHAR(500) NOT NULL COMMENT 'Cloudinary URL',
  `photo_type` ENUM('inverter_close','installed_view','cable_connection','other') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_photo_inst` (`installation_id`),
  CONSTRAINT `fk_photo_inst` FOREIGN KEY (`installation_id`) REFERENCES `installations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `installation_materials` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `installation_id` INT(11) NOT NULL,
  `material_id` INT(11) NOT NULL,
  `quantity` DECIMAL(10,2) NOT NULL COMMENT 'Tanlangan miqdor',
  `points_per_unit_snapshot` INT NOT NULL COMMENT 'Materialning o''sha paytdagi balli',
  `points_earned` INT NOT NULL COMMENT 'quantity * points_per_unit_snapshot',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_instmat_inst` (`installation_id`),
  INDEX `idx_instmat_mat` (`material_id`),
  CONSTRAINT `fk_instmat_inst` FOREIGN KEY (`installation_id`) REFERENCES `installations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_instmat_mat` FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `installation_status_history` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `installation_id` INT(11) NOT NULL,
  `from_status` ENUM('pending','approved','rejected','partially_paid','paid') NULL,
  `to_status` ENUM('pending','approved','rejected','partially_paid','paid') NOT NULL,
  `admin_id` INT(11) NULL,
  `reason` TEXT NULL,
  `context` JSON NULL COMMENT 'To''lov summasi, qoldiq, payment_id va h.k.',
  `notification_status` ENUM('pending','sent','failed') DEFAULT 'pending',
  `notification_error` TEXT NULL,
  `notification_sent_at` TIMESTAMP NULL,
  `changed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_hist_inst_date` (`installation_id`, `changed_at` DESC),
  INDEX `idx_hist_notification` (`notification_status`),
  CONSTRAINT `fk_hist_inst` FOREIGN KEY (`installation_id`) REFERENCES `installations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hist_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. TO'LOVLAR & CHIQIM SO'ROVLARI
CREATE TABLE `payments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `installation_id` INT(11) NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'To''lov summasi',
  `is_final` TINYINT(1) DEFAULT 0 COMMENT '1=to''liq yakunlovchi, 0=qisman',
  `admin_id` INT(11) NOT NULL,
  `paid_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_pay_inst` (`installation_id`),
  INDEX `idx_pay_user` (`user_id`),
  INDEX `idx_pay_admin` (`admin_id`),
  CONSTRAINT `fk_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pay_inst` FOREIGN KEY (`installation_id`) REFERENCES `installations`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pay_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `withdrawal_requests` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `points_amount` INT NOT NULL COMMENT 'Yechilayotgan ball miqdori',
  `amount_som` DECIMAL(15,2) NOT NULL COMMENT 'So''mdagi qiymati',
  `card_number` VARCHAR(20) NOT NULL COMMENT 'Karta raqami (production da shifrlash tavsiya etiladi)',
  `card_holder_name` VARCHAR(255) NOT NULL COMMENT 'Karta egasi ism-familiyasi',
  `status` ENUM('pending','approved','paid','rejected') DEFAULT 'pending',
  `admin_id` INT(11) NULL,
  `rejection_reason` TEXT NULL,
  `paid_confirmed_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_withdraw_user` (`user_id`),
  INDEX `idx_withdraw_status` (`status`),
  INDEX `idx_withdraw_created` (`created_at`),
  CONSTRAINT `fk_withdraw_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_withdraw_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. AUDIT & LOG
CREATE TABLE `action_logs` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `admin_id` INT(11) NULL,
  `action` VARCHAR(100) NOT NULL COMMENT 'approve, reject, pay, withdrawal_create, etc.',
  `entity_type` VARCHAR(50) NOT NULL COMMENT 'installation, user, withdrawal, etc.',
  `entity_id` INT(11) NULL,
  `details` JSON NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_log_admin` (`admin_id`),
  INDEX `idx_log_entity` (`entity_type`, `entity_id`),
  INDEX `idx_log_created` (`created_at`),
  CONSTRAINT `fk_log_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;