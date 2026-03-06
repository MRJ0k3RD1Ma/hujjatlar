import { pgEnum } from 'drizzle-orm/pg-core';

// Foydalanuvchi Rollari (RBAC) - TZ 3.9
export const userRoleEnum = pgEnum('user_role', ['operator', 'admin', 'supervisor']);

// Operator Ish Holati - TZ 3.4
export const operatorStatusEnum = pgEnum('operator_status', ['online', 'offline', 'pause', 'busy']);

// Qo'ng'iroq Yo'nalishi - TZ 3.2, 3.3
export const callDirectionEnum = pgEnum('call_direction', ['inbound', 'outbound']);

// Qo'ng'iroq Holati - TZ 3.7
export const callStatusEnum = pgEnum('call_status', ['ringing', 'answered', 'missed', 'abandoned', 'completed']);

// Ticket Holati - TZ 3.6
export const ticketStatusEnum = pgEnum('ticket_status', ['new', 'in_progress', 'resolved', 'closed', 'reopened']);

// Ticket Prioriteti - TZ 3.6
export const ticketPriorityEnum = pgEnum('ticket_priority', ['low', 'medium', 'high']);

// AI Tahlil Holati - TZ 3.8
export const aiStatusEnum = pgEnum('ai_status', ['pending', 'processing', 'completed', 'failed']);

// Sentiment (Kayfiyat) - TZ 3.8
export const sentimentEnum = pgEnum('sentiment', ['positive', 'neutral', 'negative']);