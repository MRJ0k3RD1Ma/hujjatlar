import {
  pgTable, uuid, varchar, text, timestamp, boolean,
  integer, jsonb, pgEnum, index, uniqueIndex
} from 'drizzle-orm/pg-core';

// 1. FOYDALANUVCHILAR (AUTH & RBAC) - TZ 3.9, 6.1
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  username: varchar('username', { length: 50 }).notNull().unique(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: userRoleEnum('role').notNull().default('operator'),
  isActive: boolean('is_active').notNull().default(true),
  isDeleted: boolean('is_deleted').notNull().default(false),
  deletedAt: timestamp('deleted_at', { withTimezone: true }), // ✅ ISO Timestamp
  lastLoginAt: timestamp('last_login_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(), // ✅ ISO
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull() // ✅ ISO
}, (table) => ({
  idxRole: index('idx_users_role').on(table.role),
  idxIsActive: index('idx_users_is_active').on(table.isActive)
}));

// 2. OPERATOR PROFILI (FreePBX Extension & Status) - TZ 3.4
export const operatorProfiles = pgTable('operator_profiles', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }), // ✅ UUID FK
  extension: varchar('extension', { length: 10 }).notNull().unique(),
  currentStatus: operatorStatusEnum('current_status').notNull().default('offline'),
  lastStatusChange: timestamp('last_status_change', { withTimezone: true }).defaultNow(),
  isDeleted: boolean('is_deleted').notNull().default(false),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxUserId: uniqueIndex('idx_operator_user_id').on(table.userId)
}));

// 3. KONTAKTLAR (CRM) - TZ 3.5
export const contacts = pgTable('contacts', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  phoneNumber: varchar('phone_number', { length: 20 }).notNull(),
  firstName: varchar('first_name', { length: 100 }),
  lastName: varchar('last_name', { length: 100 }),
  address: jsonb('address').$type<{ tuman: string; kocha: string; uy: string }>(),
  notes: text('notes'),
  isDeleted: boolean('is_deleted').notNull().default(false),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxPhone: uniqueIndex('idx_contacts_phone').on(table.phoneNumber),
  idxFirstName: index('idx_contacts_first_name').on(table.firstName),
  idxLastName: index('idx_contacts_last_name').on(table.lastName)
}));

// 4. QO'NG'IROQLAR TARIXI (CALL LOGS) - TZ 3.7
export const calls = pgTable('calls', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  direction: callDirectionEnum('direction').notNull(),
  callerNumber: varchar('caller_number', { length: 20 }).notNull(),
  calleeExtension: varchar('callee_extension', { length: 10 }),
  contactId: uuid('contact_id').references(() => contacts.id, { onDelete: 'set null' }), // ✅ UUID FK
  operatorId: uuid('operator_id').references(() => users.id, { onDelete: 'set null' }), // ✅ UUID FK
  ticketId: uuid('ticket_id').references(() => tickets.id, { onDelete: 'set null' }), // ✅ UUID FK
  status: callStatusEnum('status').notNull(),
  duration: integer('duration').default(0),
  recordingPath: text('recording_path'),
  aiStatus: aiStatusEnum('ai_status').default('pending'),
  startedAt: timestamp('started_at', { withTimezone: true }).notNull(), // ✅ ISO
  endedAt: timestamp('ended_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxCaller: index('idx_calls_caller').on(table.callerNumber),
  idxOperator: index('idx_calls_operator').on(table.operatorId),
  idxCreatedAt: index('idx_calls_created_at').on(table.createdAt),
  idxContact: index('idx_calls_contact').on(table.contactId),
  idxTicket: index('idx_calls_ticket').on(table.ticketId),
  idxStatus: index('idx_calls_status').on(table.status),
  idxDirection: index('idx_calls_direction').on(table.direction)
}));

// 5. TICKETLAR (Murojaatlar) - TZ 3.6, 8.1
export const tickets = pgTable('tickets', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  contactId: uuid('contact_id').notNull().references(() => contacts.id), // ✅ UUID FK
  createdBy: uuid('created_by').notNull().references(() => users.id), // ✅ UUID FK
  subject: varchar('subject', { length: 255 }).notNull(),
  description: text('description').notNull(),
  category: varchar('category', { length: 100 }),
  priority: ticketPriorityEnum('priority').notNull().default('medium'),
  status: ticketStatusEnum('status').notNull().default('new'),
  mnazoratRefId: varchar('mnazorat_ref_id', { length: 100 }).unique(),
  aiSummary: text('ai_summary'),
  aiSentiment: sentimentEnum('ai_sentiment'),
  aiCategories: jsonb('ai_categories').$type<string[]>(),
  aiConfidence: integer('ai_confidence'),
  aiAnalysisId: uuid('ai_analysis_id').references(() => aiAnalyses.id), // ✅ UUID FK
  isDeleted: boolean('is_deleted').notNull().default(false),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  closedAt: timestamp('closed_at', { withTimezone: true })
}, (table) => ({
  idxMnazorat: uniqueIndex('idx_tickets_mnazorat').on(table.mnazoratRefId),
  idxStatus: index('idx_tickets_status').on(table.status),
  idxContact: index('idx_tickets_contact').on(table.contactId),
  idxCreatedBy: index('idx_tickets_created_by').on(table.createdBy),
  idxCreatedAt: index('idx_tickets_created_at').on(table.createdAt),
  idxPriority: index('idx_tickets_priority').on(table.priority)
}));

// 6. AI TAHLIL JARAYONLARI (Queue Tracking) - TZ 3.8
export const aiAnalyses = pgTable('ai_analyses', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  callId: uuid('call_id').notNull().references(() => calls.id, { onDelete: 'cascade' }), // ✅ UUID FK
  status: aiStatusEnum('status').notNull().default('pending'),
  transcript: text('transcript'),
  summary: text('summary'),
  sentiment: sentimentEnum('sentiment'),
  categories: jsonb('categories').$type<string[]>(),
  confidence: integer('confidence'),
  errorMessage: text('error_message'),
  retryCount: integer('retry_count').default(0),
  processedAt: timestamp('processed_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxCallId: uniqueIndex('idx_ai_call_id').on(table.callId),
  idxStatus: index('idx_ai_status').on(table.status),
  idxCreatedAt: index('idx_ai_created_at').on(table.createdAt)
}));

// 7. OPERATOR ISH VAQTI LOGI (Statistika uchun) - TZ 3.4
export const operatorStatusLogs = pgTable('operator_status_logs', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  operatorId: uuid('operator_id').notNull().references(() => operatorProfiles.id, { onDelete: 'cascade' }), // ✅ UUID FK
  status: operatorStatusEnum('status').notNull(),
  startedAt: timestamp('started_at', { withTimezone: true }).notNull(), // ✅ ISO
  endedAt: timestamp('ended_at', { withTimezone: true }),
  duration: integer('duration')
}, (table) => ({
  idxOperator: index('idx_status_logs_operator').on(table.operatorId),
  idxStarted: index('idx_status_logs_started').on(table.startedAt),
  idxStatus: index('idx_status_logs_status').on(table.status)
}));

// 8. AUDIT LOGS (Xavfsizlik) - TZ 6.3, 9.3
export const auditLogs = pgTable('audit_logs', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }), // ✅ UUID FK
  action: varchar('action', { length: 100 }).notNull(),
  entityType: varchar('entity_type', { length: 50 }),
  entityId: uuid('entity_id'), // ✅ UUID
  details: jsonb('details'),
  ipAddress: varchar('ip_address', { length: 45 }),
  userAgent: text('user_agent'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxUser: index('idx_audit_user').on(table.userId),
  idxCreated: index('idx_audit_created').on(table.createdAt),
  idxAction: index('idx_audit_action').on(table.action),
  idxEntityType: index('idx_audit_entity_type').on(table.entityType)
}));

// 9. REFRESH TOKENS (Auth Security) - TZ 6.1
export const refreshTokens = pgTable('refresh_tokens', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }), // ✅ UUID FK
  tokenHash: text('token_hash').notNull(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(), // ✅ ISO
  revoked: boolean('revoked').default(false),
  deviceId: varchar('device_id', { length: 100 }),
  ipAddress: varchar('ip_address', { length: 45 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxUser: index('idx_refresh_user').on(table.userId),
  idxTokenHash: index('idx_refresh_token_hash').on(table.tokenHash),
  idxExpires: index('idx_refresh_expires').on(table.expiresAt)
}));

// 10. SESSION MANAGEMENT (Redis uchun metadata) - TZ 6.1
export const userSessions = pgTable('user_sessions', {
  id: uuid('id').primaryKey().defaultRandom(), // ✅ UUID
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }), // ✅ UUID FK
  sessionId: varchar('session_id', { length: 100 }).notNull().unique(),
  deviceId: varchar('device_id', { length: 100 }),
  ipAddress: varchar('ip_address', { length: 45 }),
  userAgent: text('user_agent'),
  isActive: boolean('is_active').notNull().default(true),
  lastActivityAt: timestamp('last_activity_at', { withTimezone: true }).defaultNow(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull()
}, (table) => ({
  idxUserId: index('idx_sessions_user').on(table.userId),
  idxSessionId: uniqueIndex('idx_sessions_id').on(table.sessionId),
  idxIsActive: index('idx_sessions_active').on(table.isActive)
}));