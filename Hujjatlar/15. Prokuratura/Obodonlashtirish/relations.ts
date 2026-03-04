import { relations } from "drizzle-orm/relations"
import {
  soato, organizationType, organizationTypePosition, organization,
  organizationCrossAccess, file, user, userOrganization,
  staff, brigade,
  device, faceEnrollment, faceDeviceSync, attendanceEvent, dailyAttendance,
  territory, staffTerritory,
  equipmentType, equipment, gpsDevice, gpsTracking, staffEquipment,
  taskType, task, taskAssignment,
  // NEW: Face Recognition Service
  faceRecognitionService, faceRecognitionJob
} from "./schema"

// ==================== FACE RECOGNITION SERVICE RELATIONS ====================
export const faceRecognitionServiceRelations = relations(faceRecognitionService, ({many}) => ({
  jobs: many(faceRecognitionJob),
}))

export const faceRecognitionJobRelations = relations(faceRecognitionJob, ({one}) => ({
  attendanceEvent: one(attendanceEvent, {
    fields: [faceRecognitionJob.attendanceEventId],
    references: [attendanceEvent.id]
  }),
  service: one(faceRecognitionService, {
    fields: [faceRecognitionJob.serviceId],
    references: [faceRecognitionService.id]
  }),
  matchedStaff: one(staff, {
    fields: [faceRecognitionJob.matchedStaffId],
    references: [staff.id]
  }),
}))

// ==================== CORE RELATIONS ====================
export const soatoRelations = relations(soato, ({one, many}) => ({
  parent: one(soato, {
    fields: [soato.parentId],
    references: [soato.id],
    relationName: "soato_parentId_soato_id"
  }),
  children: many(soato, {
    relationName: "soato_parentId_soato_id"
  }),
  organizations: many(organization),
}))

export const organizationTypeRelations = relations(organizationType, ({many}) => ({
  positions: many(organizationTypePosition),
  organizations: many(organization),
}))

export const organizationTypePositionRelations = relations(organizationTypePosition, ({one, many}) => ({
  type: one(organizationType, {
    fields: [organizationTypePosition.typeId],
    references: [organizationType.id]
  }),
  userOrganizations: many(userOrganization),
  staffs: many(staff),
}))

export const organizationRelations = relations(organization, ({one, many}) => ({
  soato: one(soato, {
    fields: [organization.soatoId],
    references: [soato.id]
  }),
  type: one(organizationType, {
    fields: [organization.typeId],
    references: [organizationType.id]
  }),
  parent: one(organization, {
    fields: [organization.parentId],
    references: [organization.id],
    relationName: "organization_parentId_organization_id"
  }),
  children: many(organization, {
    relationName: "organization_parentId_organization_id"
  }),
  crossAccessesViewer: many(organizationCrossAccess, {
    relationName: "organizationCrossAccess_viewerId_organization_id"
  }),
  crossAccessesTarget: many(organizationCrossAccess, {
    relationName: "organizationCrossAccess_targetId_organization_id"
  }),
  userOrganizations: many(userOrganization),
  staffs: many(staff),
  brigades: many(brigade),
  devices: many(device),
  faceEnrollments: many(faceEnrollment),
  attendanceEvents: many(attendanceEvent),
  dailyAttendances: many(dailyAttendance),
  territories: many(territory),
  equipments: many(equipment),
  gpsDevices: many(gpsDevice),
  tasks: many(task),
}))

export const organizationCrossAccessRelations = relations(organizationCrossAccess, ({one}) => ({
  viewer: one(organization, {
    fields: [organizationCrossAccess.viewerId],
    references: [organization.id],
    relationName: "organizationCrossAccess_viewerId_organization_id"
  }),
  target: one(organization, {
    fields: [organizationCrossAccess.targetId],
    references: [organization.id],
    relationName: "organizationCrossAccess_targetId_organization_id"
  }),
}))

export const fileRelations = relations(file, ({many}) => ({
  users: many(user),
  staffs: many(staff),
  faceEnrollments: many(faceEnrollment),
  attendanceEvents: many(attendanceEvent),
  territories: many(territory),
}))

export const userRelations = relations(user, ({one, many}) => ({
  photo: one(file, {
    fields: [user.photoId],
    references: [file.id]
  }),
  userOrganizations: many(userOrganization),
  staffs: many(staff),
  createdTasks: many(task),
  taskAssignments: many(taskAssignment),
  dailyAttendances: many(dailyAttendance),
}))

export const userOrganizationRelations = relations(userOrganization, ({one}) => ({
  user: one(user, {
    fields: [userOrganization.userId],
    references: [user.id]
  }),
  organization: one(organization, {
    fields: [userOrganization.organizationId],
    references: [organization.id]
  }),
  position: one(organizationTypePosition, {
    fields: [userOrganization.positionId],
    references: [organizationTypePosition.id]
  }),
}))

// ==================== STAFF RELATIONS ====================
export const staffRelations = relations(staff, ({one, many}) => ({
  photo: one(file, {
    fields: [staff.photoId],
    references: [file.id]
  }),
  organization: one(organization, {
    fields: [staff.organizationId],
    references: [organization.id]
  }),
  user: one(user, {
    fields: [staff.userId],
    references: [user.id]
  }),
  position: one(organizationTypePosition, {
    fields: [staff.positionId],
    references: [organizationTypePosition.id]
  }),
  brigade: one(brigade, {
    fields: [staff.brigadeId],
    references: [brigade.id]
  }),
  brigadesLed: many(brigade),
  faceEnrollments: many(faceEnrollment),
  dailyAttendances: many(dailyAttendance),
  territories: many(staffTerritory),
  equipments: many(staffEquipment),
  taskAssignments: many(taskAssignment),
  faceRecognitionJobs: many(faceRecognitionJob, {
    relationName: "faceRecognitionJob_matchedStaffId_staff_id"
  }),
}))

export const brigadeRelations = relations(brigade, ({one, many}) => ({
  leader: one(staff, {
    fields: [brigade.leaderId],
    references: [staff.id]
  }),
  organization: one(organization, {
    fields: [brigade.organizationId],
    references: [organization.id]
  }),
  members: many(staff),
  taskAssignments: many(taskAssignment),
}))

// ==================== ATTENDANCE RELATIONS ====================
export const deviceRelations = relations(device, ({one, many}) => ({
  organization: one(organization, {
    fields: [device.organizationId],
    references: [organization.id]
  }),
  territory: one(territory, {
    fields: [device.territoryId],
    references: [territory.id]
  }),
  faceDeviceSyncs: many(faceDeviceSync),
  attendanceEvents: many(attendanceEvent),
}))

export const faceEnrollmentRelations = relations(faceEnrollment, ({one, many}) => ({
  staff: one(staff, {
    fields: [faceEnrollment.staffId],
    references: [staff.id]
  }),
  faceImage: one(file, {
    fields: [faceEnrollment.faceImageId],
    references: [file.id]
  }),
  organization: one(organization, {
    fields: [faceEnrollment.organizationId],
    references: [organization.id]
  }),
  faceDeviceSyncs: many(faceDeviceSync),
  attendanceEvents: many(attendanceEvent),
}))

export const faceDeviceSyncRelations = relations(faceDeviceSync, ({one}) => ({
  faceEnrollment: one(faceEnrollment, {
    fields: [faceDeviceSync.faceEnrollmentId],
    references: [faceEnrollment.id]
  }),
  device: one(device, {
    fields: [faceDeviceSync.deviceId],
    references: [device.id]
  }),
}))

export const attendanceEventRelations = relations(attendanceEvent, ({one, many}) => ({
  device: one(device, {
    fields: [attendanceEvent.deviceId],
    references: [device.id]
  }),
  faceEnrollment: one(faceEnrollment, {
    fields: [attendanceEvent.faceEnrollmentId],
    references: [faceEnrollment.id]
  }),
  snapshot: one(file, {
    fields: [attendanceEvent.snapshotId],
    references: [file.id]
  }),
  organization: one(organization, {
    fields: [attendanceEvent.organizationId],
    references: [organization.id]
  }),
  faceRecognitionJob: one(faceRecognitionJob, {
    fields: [attendanceEvent.faceRecognitionJobId],
    references: [faceRecognitionJob.id]
  }),
  dailyAttendancesFirstIn: many(dailyAttendance, {
    relationName: "dailyAttendance_firstInEventId_attendanceEvent_id"
  }),
  dailyAttendancesLastOut: many(dailyAttendance, {
    relationName: "dailyAttendance_lastOutEventId_attendanceEvent_id"
  }),
}))

export const dailyAttendanceRelations = relations(dailyAttendance, ({one}) => ({
  staff: one(staff, {
    fields: [dailyAttendance.staffId],
    references: [staff.id]
  }),
  organization: one(organization, {
    fields: [dailyAttendance.organizationId],
    references: [organization.id]
  }),
  firstInEvent: one(attendanceEvent, {
    fields: [dailyAttendance.firstInEventId],
    references: [attendanceEvent.id],
    relationName: "dailyAttendance_firstInEventId_attendanceEvent_id"
  }),
  lastOutEvent: one(attendanceEvent, {
    fields: [dailyAttendance.lastOutEventId],
    references: [attendanceEvent.id],
    relationName: "dailyAttendance_lastOutEventId_attendanceEvent_id"
  }),
  overrideUser: one(user, {
    fields: [dailyAttendance.overrideBy],
    references: [user.id]
  }),
}))

// ==================== TERRITORY RELATIONS ====================
export const territoryRelations = relations(territory, ({one, many}) => ({
  organization: one(organization, {
    fields: [territory.organizationId],
    references: [organization.id]
  }),
  kmzFile: one(file, {
    fields: [territory.kmzFileId],
    references: [file.id]
  }),
  staffs: many(staffTerritory),
  devices: many(device),
  tasks: many(task),
}))

export const staffTerritoryRelations = relations(staffTerritory, ({one}) => ({
  staff: one(staff, {
    fields: [staffTerritory.staffId],
    references: [staff.id]
  }),
  territory: one(territory, {
    fields: [staffTerritory.territoryId],
    references: [territory.id]
  }),
}))

// ==================== EQUIPMENT & GPS RELATIONS ====================
export const equipmentTypeRelations = relations(equipmentType, ({many}) => ({
  equipments: many(equipment),
}))

export const equipmentRelations = relations(equipment, ({one, many}) => ({
  type: one(equipmentType, {
    fields: [equipment.typeId],
    references: [equipmentType.id]
  }),
  organization: one(organization, {
    fields: [equipment.organizationId],
    references: [organization.id]
  }),
  gpsDevice: one(gpsDevice, {
    fields: [equipment.gpsDeviceId],
    references: [gpsDevice.id]
  }),
  staffs: many(staffEquipment),
}))

export const gpsDeviceRelations = relations(gpsDevice, ({one, many}) => ({
  equipment: one(equipment, {
    fields: [gpsDevice.equipmentId],
    references: [equipment.id]
  }),
  organization: one(organization, {
    fields: [gpsDevice.organizationId],
    references: [organization.id]
  }),
  trackings: many(gpsTracking),
}))

export const gpsTrackingRelations = relations(gpsTracking, ({one}) => ({
  gpsDevice: one(gpsDevice, {
    fields: [gpsTracking.gpsDeviceId],
    references: [gpsDevice.id]
  }),
}))

export const staffEquipmentRelations = relations(staffEquipment, ({one}) => ({
  staff: one(staff, {
    fields: [staffEquipment.staffId],
    references: [staff.id]
  }),
  equipment: one(equipment, {
    fields: [staffEquipment.equipmentId],
    references: [equipment.id]
  }),
}))

// ==================== TASK RELATIONS ====================
export const taskTypeRelations = relations(taskType, ({many}) => ({
  tasks: many(task),
}))

export const taskRelations = relations(task, ({one, many}) => ({
  type: one(taskType, {
    fields: [task.typeId],
    references: [taskType.id]
  }),
  organization: one(organization, {
    fields: [task.organizationId],
    references: [organization.id]
  }),
  createdByUser: one(user, {
    fields: [task.createdBy],
    references: [user.id]
  }),
  territory: one(territory, {
    fields: [task.territoryId],
    references: [territory.id]
  }),
  assignments: many(taskAssignment),
}))

export const taskAssignmentRelations = relations(taskAssignment, ({one}) => ({
  task: one(task, {
    fields: [taskAssignment.taskId],
    references: [task.id]
  }),
  staff: one(staff, {
    fields: [taskAssignment.staffId],
    references: [staff.id]
  }),
  brigade: one(brigade, {
    fields: [taskAssignment.brigadeId],
    references: [brigade.id]
  }),
  assignedByUser: one(user, {
    fields: [taskAssignment.assignedBy],
    references: [user.id]
  }),
}))