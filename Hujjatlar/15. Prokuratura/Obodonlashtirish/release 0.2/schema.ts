import { 
  pgTable, 
  foreignKey, 
  integer, 
  numeric, 
  text, 
  timestamp, 
  boolean, 
  date, 
  time, 
  uniqueIndex, 
  unique, 
  index, 
  pgEnum, 
  jsonb,
  uuid
} from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"

// ==================== ENUMS (Static - o'zgarmas) ====================
export const attendanceStatus = pgEnum("attendance_status", ['PRESENT', 'ABSENT', 'LATE', 'LEFT_EARLY', 'EXCUSED'])
export const crossAccessType = pgEnum("cross_access_type", ['READ', 'WRITE'])
export const deviceDirection = pgEnum("device_direction", ['IN', 'OUT', 'BOTH'])
export const deviceStatus = pgEnum("device_status", ['online', 'offline', 'error'])
export const eventType = pgEnum("event_type", ['FACE_RECOGNIZED', 'FACE_UNRECOGNIZED', 'MANUAL'])
export const faceOwnerType = pgEnum("face_owner_type", ['staff'])
export const staffType = pgEnum("staff_type", ['EMPLOYEE', 'BRIGADIER', 'SECURITY', 'ADMIN', 'MANAGER'])
export const equipmentStatus = pgEnum("equipment_status", ['ACTIVE', 'MAINTENANCE', 'INACTIVE', 'RETIRED'])
export const taskPriority = pgEnum("task_priority", ['LOW', 'MEDIUM', 'HIGH', 'URGENT'])
export const taskStatus = pgEnum("task_status", ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'])
export const taskAssignmentStatus = pgEnum("task_assignment_status", ['ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED'])
export const faceRecognitionStatus = pgEnum("face_recognition_status", ['PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'])

// ==================== DYNAMIC TYPE TABLES (Lookup Tables) ====================

// Equipment Type - Maxsus texnika turlari (Dynamic)
export const equipmentType = pgTable("equipment_type", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  nameUz: text("name_uz").notNull(),
  nameRu: text("name_ru"),
  nameEn: text("name_en"),
  code: text().notNull(), // TRACTOR, TRUCK, LOADER, etc.
  color: text(), // Xaritada ko'rsatish uchun rang
  icon: text(), // Icon nomi
  description: text(),
  sortOrder: integer("sort_order").default(0),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  unique("equipment_type_code_key").on(table.code),
  index("equipment_type_is_active_idx").using("btree", table.isActive.asc().nullsLast().op("bool_ops")),
])

// Task Type - Topshiriq turlari (Dynamic)
export const taskType = pgTable("task_type", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  nameUz: text("name_uz").notNull(),
  nameRu: text("name_ru"),
  nameEn: text("name_en"),
  code: text().notNull(), // CLEANING, PLANTING, REPAIR, etc.
  color: text(), // Dashboard uchun rang
  icon: text(), // Icon nomi
  description: text(),
  defaultPriority: taskPriority("default_priority").default('MEDIUM'),
  sortOrder: integer("sort_order").default(0),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  unique("task_type_code_key").on(table.code),
  index("task_type_is_active_idx").using("btree", table.isActive.asc().nullsLast().op("bool_ops")),
])

// ==================== FACE RECOGNITION SERVICE CONFIG ====================

// Python Face API Service Configuration
export const faceRecognitionService = pgTable("face_recognition_service", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  baseUrl: text("base_url").notNull(), // http://python-service:8000
  apiKey: text("api_key"), // Authentication uchun
  modelVersion: text("model_version"), // face_recognition model versiyasi
  confidenceThreshold: numeric("confidence_threshold", { precision: 3, scale: 2 }).default('0.60'),
  maxRetries: integer("max_retries").default(3),
  timeout: integer().default(30000), // milliseconds
  isActive: boolean("is_active").default(true),
  lastHealthCheckAt: timestamp("last_health_check_at", { mode: 'string' }),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  unique("face_recognition_service_name_key").on(table.name),
  index("face_recognition_service_is_active_idx").using("btree", table.isActive.asc().nullsLast().op("bool_ops")),
])

// Face Recognition Job - Async processing tracking
export const faceRecognitionJob = pgTable("face_recognition_job", {
  id: uuid().primaryKey().defaultRandom(),
  attendanceEventId: uuid("attendance_event_id").notNull(),
  serviceId: uuid("service_id").notNull(),
  status: faceRecognitionStatus().default('PENDING').notNull(),
  requestPayload: jsonb("request_payload"), // Python API ga yuborilgan data
  responsePayload: jsonb("response_payload"), // Python API dan kelgan javob
  matchedStaffId: uuid("matched_staff_id"), // Topilgan xodim
  confidenceScore: numeric("confidence_score", { precision: 5, scale: 4 }),
  processingTimeMs: integer("processing_time_ms"), // Qancha vaqt ketdi
  errorMessage: text("error_message"),
  retryCount: integer("retry_count").default(0),
  startedAt: timestamp("started_at", { mode: 'string' }),
  completedAt: timestamp("completed_at", { mode: 'string' }),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
}, (table) => [
  index("face_recognition_job_attendance_event_id_idx").using("btree", table.attendanceEventId.asc().nullsLast().op("uuid_ops")),
  index("face_recognition_job_status_idx").using("btree", table.status.asc().nullsLast().op("enum_ops")),
  index("face_recognition_job_created_at_idx").using("btree", table.createdAt.asc().nullsLast().op("timestamp_ops")),
  foreignKey({
    columns: [table.attendanceEventId],
    foreignColumns: [attendanceEvent.id],
    name: "face_recognition_job_attendance_event_id_fkey"
  }),
  foreignKey({
    columns: [table.serviceId],
    foreignColumns: [faceRecognitionService.id],
    name: "face_recognition_job_service_id_fkey"
  }),
  foreignKey({
    columns: [table.matchedStaffId],
    foreignColumns: [staff.id],
    name: "face_recognition_job_matched_staff_id_fkey"
  }),
])

// ==================== CORE TABLES ====================

// SOATO - Hudud klassifikatori
export const soato = pgTable("soato", {
  id: integer().primaryKey().notNull(), // SOATO ID integer bo'lishi kerak (davlat klassifikatori)
  parentId: integer("parent_id"),
  orderNum: integer("order_num"),
  latitude: numeric({ precision: 9, scale: 6 }),
  longitude: numeric({ precision: 9, scale: 6 }),
  nameUz: text("name_uz").notNull(),
  nameUzc: text("name_uzc").notNull(),
  nameEn: text("name_en").notNull(),
  nameRu: text("name_ru").notNull(),
  shortNameUz: text("short_name_uz").notNull(),
  shortNameUzc: text("short_name_uzc").notNull(),
  shortNameRu: text("short_name_ru").notNull(),
  shortNameEn: text("short_name_en").notNull(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.parentId],
    foreignColumns: [table.id],
    name: "soato_parent_id_fkey"
  }),
])

// Organization Type - Tashkilot turlari
export const organizationType = pgTable("organization_type", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  nameUz: text("name_uz"),
  nameRu: text("name_ru"),
  nameEn: text("name_en"),
  code: text(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
})

// Organization Type Position - Lavozimlar
export const organizationTypePosition = pgTable("organization_type_position", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  nameUz: text("name_uz"),
  nameRu: text("name_ru"),
  nameEn: text("name_en"),
  typeId: uuid("type_id").notNull(),
  code: text(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.typeId],
    foreignColumns: [organizationType.id],
    name: "organization_type_position_type_id_fkey"
  }),
])

// Organization - Tashkilotlar
export const organization = pgTable("organization", {
  id: uuid().primaryKey().defaultRandom(),
  soatoId: integer("soato_id").notNull(),
  name: text().notNull(),
  typeId: uuid("type_id").notNull(),
  phoneNumber: text("phone_number").notNull(),
  address: text().notNull(),
  parentId: uuid("parent_id"),
  isEducational: boolean("is_educational").default(false).notNull(),
  activationDate: date("activation_date").notNull(),
  isLock: boolean("is_lock").default(false).notNull(),
  defaultWorkdayStart: time("default_workday_start").default('09:00:00').notNull(),
  defaultWorkdayEnd: time("default_workday_end").default('18:00:00').notNull(),
  defaultWorkdayCount: integer("default_workday_count").default(6).notNull(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.soatoId],
    foreignColumns: [soato.id],
    name: "organization_soato_id_fkey"
  }),
  foreignKey({
    columns: [table.typeId],
    foreignColumns: [organizationType.id],
    name: "organization_type_id_fkey"
  }),
  foreignKey({
    columns: [table.parentId],
    foreignColumns: [table.id],
    name: "organization_parent_id_fkey"
  }),
])

// Organization Cross Access - Tashkilotlararo ruxsat
export const organizationCrossAccess = pgTable("organization_cross_access", {
  id: uuid().primaryKey().defaultRandom(),
  viewerId: uuid("viewer_id").notNull(),
  targetId: uuid("target_id").notNull(),
  accessType: crossAccessType("access_type").notNull(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow().notNull(),
  isDeleted: boolean("is_deleted").default(false).notNull(),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("organization_cross_access_viewer_id_target_id_idx").using(
    "btree",
    table.viewerId.asc().nullsLast().op("uuid_ops"),
    table.targetId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.viewerId],
    foreignColumns: [organization.id],
    name: "organization_cross_access_viewer_id_fkey"
  }),
  foreignKey({
    columns: [table.targetId],
    foreignColumns: [organization.id],
    name: "organization_cross_access_target_id_fkey"
  }),
])

// File - Fayllar saqlash
export const file = pgTable("file", {
  id: uuid().primaryKey().defaultRandom(),
  ext: text().notNull(),
  url: text().notNull(),
  name: text().notNull(),
  size: integer(),
  mimeType: text("mime_type"),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
})

// User - Foydalanuvchilar
export const user = pgTable("user", {
  id: uuid().primaryKey().defaultRandom(),
  fullname: text().notNull(),
  phoneNumber: text("phone_number").notNull(),
  password: text().notNull(), // Bcrypt hash
  photoId: uuid("photo_id"),
  isActive: boolean("is_active").default(true),
  lastLoginAt: timestamp("last_login_at", { mode: 'string' }),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.photoId],
    foreignColumns: [file.id],
    name: "user_photo_id_fkey"
  }),
  unique("user_phone_number_key").on(table.phoneNumber),
])

// User Organization - Foydalanuvchi-tashkilot bog'lanishi
export const userOrganization = pgTable("user_organization", {
  id: uuid().primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull(),
  organizationId: uuid("organization_id").notNull(),
  positionId: uuid("position_id").notNull(),
  isPrimary: boolean("is_primary").default(true),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("user_organization_user_id_organization_id_position_id_idx").using(
    "btree",
    table.userId.asc().nullsLast().op("uuid_ops"),
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.positionId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.userId],
    foreignColumns: [user.id],
    name: "user_organization_user_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "user_organization_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.positionId],
    foreignColumns: [organizationTypePosition.id],
    name: "user_organization_position_id_fkey"
  }),
])

// ==================== STAFF TABLES ====================

// Staff - Xodimlar
export const staff = pgTable("staff", {
  id: uuid().primaryKey().defaultRandom(),
  fullname: text().notNull(),
  phoneNumber: text("phone_number"),
  jobEntryDate: date("job_entry_date"),
  photoId: uuid("photo_id"),
  organizationId: uuid("organization_id").notNull(),
  userId: uuid("user_id"),
  isActive: boolean("is_active").default(true),
  positionId: uuid("position_id"),
  type: staffType(),
  brigadeId: uuid("brigade_id"),
  faceEncodingVersion: text("face_encoding_version"), // Python service model versiyasi
  lastFaceEncodingAt: timestamp("last_face_encoding_at", { mode: 'string' }), // Qachon encoding qilingan
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("staff_organization_id_phone_number_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.phoneNumber.asc().nullsLast().op("text_ops")
  ),
  foreignKey({
    columns: [table.photoId],
    foreignColumns: [file.id],
    name: "staff_photo_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "staff_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.userId],
    foreignColumns: [user.id],
    name: "staff_user_id_fkey"
  }),
  foreignKey({
    columns: [table.positionId],
    foreignColumns: [organizationTypePosition.id],
    name: "staff_position_id_fkey"
  }),
  foreignKey({
    columns: [table.brigadeId],
    foreignColumns: [brigade.id],
    name: "staff_brigade_id_fkey"
  }),
])

// Brigade - Brigada tuzilmasi
export const brigade = pgTable("brigade", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  leaderId: uuid("leader_id").notNull(),
  organizationId: uuid("organization_id").notNull(),
  memberCount: integer("member_count").default(0),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.leaderId],
    foreignColumns: [staff.id],
    name: "brigade_leader_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "brigade_organization_id_fkey"
  }),
])

// ==================== ATTENDANCE TABLES ====================

// Device - Face ID qurilmalari
export const device = pgTable("device", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  serialNumber: text("serial_number").notNull(),
  ipAddress: text("ip_address").notNull(),
  port: integer().default(80),
  direction: deviceDirection().notNull(),
  locationDescription: text("location_description"),
  organizationId: uuid("organization_id").notNull(),
  territoryId: uuid("territory_id"),
  username: text().notNull(),
  password: text().notNull(),
  status: deviceStatus().default('offline'),
  lastHeartbeatAt: timestamp("last_heartbeat_at", { mode: 'string' }),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("device_organization_id_serial_number_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.serialNumber.asc().nullsLast().op("text_ops")
  ),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "device_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.territoryId],
    foreignColumns: [territory.id],
    name: "device_territory_id_fkey"
  }),
  unique("device_serial_number_key").on(table.serialNumber),
])

// Face Enrollment - Yuz ro'yxatga olish
export const faceEnrollment = pgTable("face_enrollment", {
  id: uuid().primaryKey().defaultRandom(),
  ownerType: faceOwnerType("owner_type").notNull(),
  staffId: uuid("staff_id"),
  faceImageId: uuid("face_image_id").notNull(),
  hikvisionFaceId: text("hikvision_face_id"), // Hikvision uchun (agar ishlatilsa)
  organizationId: uuid("organization_id").notNull(),
  faceEncoding: jsonb("face_encoding"), // Python service dan olingan encoding (128 float array)
  faceEncodingVersion: text("face_encoding_version"), // Model versiyasi
  isActive: boolean("is_active").default(true),
  enrolledAt: timestamp("enrolled_at", { mode: 'string' }).defaultNow(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.staffId],
    foreignColumns: [staff.id],
    name: "face_enrollment_staff_id_fkey"
  }),
  foreignKey({
    columns: [table.faceImageId],
    foreignColumns: [file.id],
    name: "face_enrollment_face_image_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "face_enrollment_organization_id_fkey"
  }),
  index("face_enrollment_staff_id_idx").using("btree", table.staffId.asc().nullsLast().op("uuid_ops")),
  index("face_enrollment_is_active_idx").using("btree", table.isActive.asc().nullsLast().op("bool_ops")),
])

// Face Device Sync - Qurilma sinxronizatsiyasi
export const faceDeviceSync = pgTable("face_device_sync", {
  id: uuid().primaryKey().defaultRandom(),
  faceEnrollmentId: uuid("face_enrollment_id").notNull(),
  deviceId: uuid("device_id").notNull(),
  syncedAt: timestamp("synced_at", { mode: 'string' }).defaultNow(),
  isSynced: boolean("is_synced").default(false),
  errorMessage: text("error_message"),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("face_device_sync_face_enrollment_id_device_id_idx").using(
    "btree",
    table.faceEnrollmentId.asc().nullsLast().op("uuid_ops"),
    table.deviceId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.faceEnrollmentId],
    foreignColumns: [faceEnrollment.id],
    name: "face_device_sync_face_enrollment_id_fkey"
  }),
  foreignKey({
    columns: [table.deviceId],
    foreignColumns: [device.id],
    name: "face_device_sync_device_id_fkey"
  }),
])

// Attendance Event - Davomat voqealari
export const attendanceEvent = pgTable("attendance_event", {
  id: uuid().primaryKey().defaultRandom(),
  deviceId: uuid("device_id").notNull(),
  eventType: eventType("event_type").notNull(),
  eventTime: timestamp("event_time", { mode: 'string' }).notNull(),
  faceEnrollmentId: uuid("face_enrollment_id"),
  snapshotId: uuid("snapshot_id"),
  confidenceScore: numeric("confidence_score", { precision: 5, scale: 4 }), // 0.0000 - 1.0000
  rawData: text("raw_data"),
  latitude: numeric("latitude", { precision: 9, scale: 6 }),
  longitude: numeric("longitude", { precision: 9, scale: 6 }),
  organizationId: uuid("organization_id").notNull(),
  // Python Face API fields
  faceRecognitionJobId: uuid("face_recognition_job_id"), // Async job ID
  isFaceProcessed: boolean("is_face_processed").default(false), // Python API da qayta ishlanganmi
  faceProcessingError: text("face_processing_error"), // Agar xatolik bo'lsa
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
}, (table) => [
  index("attendance_event_device_id_event_time_idx").using(
    "btree",
    table.deviceId.asc().nullsLast().op("uuid_ops"),
    table.eventTime.asc().nullsLast().op("timestamp_ops")
  ),
  index("attendance_event_organization_id_event_time_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.eventTime.asc().nullsLast().op("timestamp_ops")
  ),
  index("attendance_event_face_processed_idx").using("btree", table.isFaceProcessed.asc().nullsLast().op("bool_ops")),
  foreignKey({
    columns: [table.deviceId],
    foreignColumns: [device.id],
    name: "attendance_event_device_id_fkey"
  }),
  foreignKey({
    columns: [table.faceEnrollmentId],
    foreignColumns: [faceEnrollment.id],
    name: "attendance_event_face_enrollment_id_fkey"
  }),
  foreignKey({
    columns: [table.snapshotId],
    foreignColumns: [file.id],
    name: "attendance_event_snapshot_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "attendance_event_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.faceRecognitionJobId],
    foreignColumns: [faceRecognitionJob.id],
    name: "attendance_event_face_recognition_job_id_fkey"
  }),
])

// Daily Attendance - Kunlik davomat
export const dailyAttendance = pgTable("daily_attendance", {
  id: uuid().primaryKey().defaultRandom(),
  date: date().notNull(),
  staffId: uuid("staff_id").notNull(),
  organizationId: uuid("organization_id").notNull(),
  status: attendanceStatus().default('ABSENT').notNull(),
  firstInTime: timestamp("first_in_time", { mode: 'string' }),
  lastOutTime: timestamp("last_out_time", { mode: 'string' }),
  firstInEventId: uuid("first_in_event_id"),
  lastOutEventId: uuid("last_out_event_id"),
  locationVerified: boolean("location_verified").default(false),
  verifiedLatitude: numeric("verified_latitude", { precision: 9, scale: 6 }),
  verifiedLongitude: numeric("verified_longitude", { precision: 9, scale: 6 }),
  manualOverride: boolean("manual_override").default(false),
  overrideReason: text("override_reason"),
  overrideBy: uuid("override_by"),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
}, (table) => [
  index("daily_attendance_date_status_idx").using(
    "btree",
    table.date.asc().nullsLast().op("date_ops"),
    table.status.asc().nullsLast().op("enum_ops")
  ),
  index("daily_attendance_organization_id_date_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.date.asc().nullsLast().op("date_ops")
  ),
  uniqueIndex("uq_staff_daily").using(
    "btree",
    table.date.asc().nullsLast().op("text_ops"),
    table.staffId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.staffId],
    foreignColumns: [staff.id],
    name: "daily_attendance_staff_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "daily_attendance_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.firstInEventId],
    foreignColumns: [attendanceEvent.id],
    name: "daily_attendance_first_in_event_id_fkey"
  }),
  foreignKey({
    columns: [table.lastOutEventId],
    foreignColumns: [attendanceEvent.id],
    name: "daily_attendance_last_out_event_id_fkey"
  }),
  foreignKey({
    columns: [table.overrideBy],
    foreignColumns: [user.id],
    name: "daily_attendance_override_by_fkey"
  }),
])

// ==================== TERRITORY TABLES ====================

// Territory - Hududlar (KMZ import)
export const territory = pgTable("territory", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  organizationId: uuid("organization_id").notNull(),
  kmzFileId: uuid("kmz_file_id").notNull(),
  area: numeric("area", { precision: 10, scale: 2 }),
  perimeter: numeric("perimeter", { precision: 10, scale: 2 }),
  coordinates: jsonb("coordinates"),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "territory_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.kmzFileId],
    foreignColumns: [file.id],
    name: "territory_kmz_file_id_fkey"
  }),
])

// Staff Territory - Xodim-hudud bog'lanishi
export const staffTerritory = pgTable("staff_territory", {
  id: uuid().primaryKey().defaultRandom(),
  staffId: uuid("staff_id").notNull(),
  territoryId: uuid("territory_id").notNull(),
  isPrimary: boolean("is_primary").default(true),
  assignedAt: timestamp("assigned_at", { mode: 'string' }).defaultNow(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("staff_territory_staff_id_territory_id_idx").using(
    "btree",
    table.staffId.asc().nullsLast().op("uuid_ops"),
    table.territoryId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.staffId],
    foreignColumns: [staff.id],
    name: "staff_territory_staff_id_fkey"
  }),
  foreignKey({
    columns: [table.territoryId],
    foreignColumns: [territory.id],
    name: "staff_territory_territory_id_fkey"
  }),
])

// ==================== EQUIPMENT & GPS TABLES ====================

// Equipment - Maxsus texnikalar
export const equipment = pgTable("equipment", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  typeId: uuid("type_id").notNull(),
  serialNumber: text("serial_number").notNull(),
  licensePlate: text("license_plate"),
  organizationId: uuid("organization_id").notNull(),
  gpsDeviceId: uuid("gps_device_id"),
  status: equipmentStatus().default('ACTIVE').notNull(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("equipment_serial_number_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.serialNumber.asc().nullsLast().op("text_ops")
  ),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "equipment_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.gpsDeviceId],
    foreignColumns: [gpsDevice.id],
    name: "equipment_gps_device_id_fkey"
  }),
  foreignKey({
    columns: [table.typeId],
    foreignColumns: [equipmentType.id],
    name: "equipment_type_id_fkey"
  }),
])

// GPS Device - Teltonika MF920
export const gpsDevice = pgTable("gps_device", {
  id: uuid().primaryKey().defaultRandom(),
  imei: text().notNull(),
  equipmentId: uuid("equipment_id"),
  organizationId: uuid("organization_id").notNull(),
  lastConnectionAt: timestamp("last_connection_at", { mode: 'string' }),
  status: deviceStatus().default('offline'),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  unique("gps_device_imei_key").on(table.imei),
  foreignKey({
    columns: [table.equipmentId],
    foreignColumns: [equipment.id],
    name: "gps_device_equipment_id_fkey"
  }),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "gps_device_organization_id_fkey"
  }),
])

// GPS Tracking - GPS treking ma'lumotlari
export const gpsTracking = pgTable("gps_tracking", {
  id: uuid().primaryKey().defaultRandom(),
  gpsDeviceId: uuid("gps_device_id").notNull(),
  latitude: numeric("latitude", { precision: 9, scale: 6 }).notNull(),
  longitude: numeric("longitude", { precision: 9, scale: 6 }).notNull(),
  speed: numeric("speed", { precision: 5, scale: 2 }),
  heading: integer(),
  altitude: numeric("altitude", { precision: 7, scale: 2 }),
  satellites: integer(),
  rawPayload: text("raw_payload"),
  receivedAt: timestamp("received_at", { mode: 'string' }).notNull(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
}, (table) => [
  index("gps_tracking_device_time_idx").using(
    "btree",
    table.gpsDeviceId.asc().nullsLast().op("uuid_ops"),
    table.receivedAt.asc().nullsLast().op("timestamp_ops")
  ),
  foreignKey({
    columns: [table.gpsDeviceId],
    foreignColumns: [gpsDevice.id],
    name: "gps_tracking_gps_device_id_fkey"
  }),
])

// Staff Equipment - Xodim-texnika bog'lanishi
export const staffEquipment = pgTable("staff_equipment", {
  id: uuid().primaryKey().defaultRandom(),
  staffId: uuid("staff_id").notNull(),
  equipmentId: uuid("equipment_id").notNull(),
  assignedAt: timestamp("assigned_at", { mode: 'string' }).defaultNow(),
  returnedAt: timestamp("returned_at", { mode: 'string' }),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  uniqueIndex("staff_equipment_staff_id_equipment_id_idx").using(
    "btree",
    table.staffId.asc().nullsLast().op("uuid_ops"),
    table.equipmentId.asc().nullsLast().op("uuid_ops")
  ),
  foreignKey({
    columns: [table.staffId],
    foreignColumns: [staff.id],
    name: "staff_equipment_staff_id_fkey"
  }),
  foreignKey({
    columns: [table.equipmentId],
    foreignColumns: [equipment.id],
    name: "staff_equipment_equipment_id_fkey"
  }),
])

// ==================== TASK TABLES ====================

// Task - Topshiriqlar
export const task = pgTable("task", {
  id: uuid().primaryKey().defaultRandom(),
  title: text().notNull(),
  description: text(),
  typeId: uuid("type_id").notNull(),
  priority: taskPriority().default('MEDIUM').notNull(),
  organizationId: uuid("organization_id").notNull(),
  createdBy: uuid("created_by").notNull(),
  territoryId: uuid("territory_id"),
  dueDate: date("due_date"),
  status: taskStatus().default('PENDING').notNull(),
  completedAt: timestamp("completed_at", { mode: 'string' }),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  index("task_organization_id_status_idx").using(
    "btree",
    table.organizationId.asc().nullsLast().op("uuid_ops"),
    table.status.asc().nullsLast().op("enum_ops")
  ),
  foreignKey({
    columns: [table.organizationId],
    foreignColumns: [organization.id],
    name: "task_organization_id_fkey"
  }),
  foreignKey({
    columns: [table.createdBy],
    foreignColumns: [user.id],
    name: "task_created_by_fkey"
  }),
  foreignKey({
    columns: [table.territoryId],
    foreignColumns: [territory.id],
    name: "task_territory_id_fkey"
  }),
  foreignKey({
    columns: [table.typeId],
    foreignColumns: [taskType.id],
    name: "task_type_id_fkey"
  }),
])

// Task Assignment - Topshiriq taqsimoti
export const taskAssignment = pgTable("task_assignment", {
  id: uuid().primaryKey().defaultRandom(),
  taskId: uuid("task_id").notNull(),
  staffId: uuid("staff_id").notNull(),
  brigadeId: uuid("brigade_id"),
  assignedBy: uuid("assigned_by").notNull(),
  assignedAt: timestamp("assigned_at", { mode: 'string' }).defaultNow(),
  completedAt: timestamp("completed_at", { mode: 'string' }),
  status: taskAssignmentStatus().default('ASSIGNED').notNull(),
  comment: text(),
  createdAt: timestamp("created_at", { mode: 'string' }).defaultNow(),
  updatedAt: timestamp("updated_at", { mode: 'string' }).defaultNow(),
  isDeleted: boolean("is_deleted").default(false),
  deletedAt: timestamp("deleted_at", { mode: 'string' }),
}, (table) => [
  index("task_assignment_task_id_status_idx").using(
    "btree",
    table.taskId.asc().nullsLast().op("uuid_ops"),
    table.status.asc().nullsLast().op("enum_ops")
  ),
  foreignKey({
    columns: [table.taskId],
    foreignColumns: [task.id],
    name: "task_assignment_task_id_fkey"
  }),
  foreignKey({
    columns: [table.staffId],
    foreignColumns: [staff.id],
    name: "task_assignment_staff_id_fkey"
  }),
  foreignKey({
    columns: [table.brigadeId],
    foreignColumns: [brigade.id],
    name: "task_assignment_brigade_id_fkey"
  }),
  foreignKey({
    columns: [table.assignedBy],
    foreignColumns: [user.id],
    name: "task_assignment_assigned_by_fkey"
  }),
])