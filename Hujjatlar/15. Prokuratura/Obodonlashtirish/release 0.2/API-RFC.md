# 📑 API RFC Hujjatlari - Obodonlashtirish Tizimi

## RFC-001: Authentication & User Management

### RFC-001.1: User Login

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-001.1 |
| **Title** | User Login |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/auth/login
```

**Authentication:** None (Public)

**Request Body:**
```typescript
{
  phoneNumber: string; // +998901234567 format
  password: string;    // Min 8 characters
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    user: {
      id: string;           // UUID
      fullname: string;
      phoneNumber: string;
      photoUrl?: string;
      isActive: boolean;
      lastLoginAt?: string; // ISO 8601
    };
    tokens: {
      accessToken: string;  // JWT, 15min expiry
      refreshToken: string; // JWT, 7days expiry
      expiresIn: number;    // seconds
    };
    organizations: Array<{
      id: string;
      name: string;
      positionId: string;
      positionName: string;
      isPrimary: boolean;
    }>;
  };
}
```

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_PHONE_FORMAT | Phone number format noto'g'ri |
| 401 | INVALID_CREDENTIALS | Login yoki parol noto'g'ri |
| 403 | USER_INACTIVE | Foydalanuvchi bloklangan |
| 429 | TOO_MANY_REQUESTS | Rate limit exceeded (5 attempts/min) |

**Validation Rules:**
- `phoneNumber`: Must start with +998, 12 digits total
- `password`: Min 8 characters, will be trimmed
- Rate limiting: 5 failed attempts per minute per IP

---

### RFC-001.2: Refresh Token

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-001.2 |
| **Title** | Refresh Access Token |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/auth/refresh
```

**Authentication:** Bearer Token (Refresh Token)

**Request Body:**
```typescript
{
  refreshToken: string;
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    accessToken: string;
    expiresIn: number;
  };
}
```

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 401 | INVALID_TOKEN | Refresh token yaroqsiz |
| 401 | TOKEN_EXPIRED | Refresh token muddati tugagan |
| 403 | USER_INACTIVE | Foydalanuvchi bloklangan |

---

### RFC-001.3: Get Current User

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-001.3 |
| **Title** | Get Current User Profile |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/users/me
```

**Authentication:** Bearer Token (Access Token)

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    fullname: string;
    phoneNumber: string;
    photoUrl?: string;
    isActive: boolean;
    lastLoginAt?: string;
    createdAt: string;
    organizations: Array<{
      id: string;
      name: string;
      positionId: string;
      positionName: string;
      isPrimary: boolean;
    }>;
    permissions: string[];
  };
}
```

---

## RFC-002: Organization Management

### RFC-002.1: Get Organization Tree

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-002.1 |
| **Title** | Get Organization Hierarchy |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/organizations/tree
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rootId` | UUID | No | Boshlang'ich tashkilot ID |
| `depth` | number | No | Maksimum chuqurlik (default: 10) |
| `includeStats` | boolean | No | Statistika qo'shish (default: false) |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    name: string;
    typeId: string;
    typeName: string;
    soatoId: number;
    soatoName: string;
    phoneNumber: string;
    address: string;
    parentId?: string;
    children?: OrganizationTree[]; // Recursive
    stats?: {
      staffCount: number;
      brigadeCount: number;
      equipmentCount: number;
      todayAttendance: {
        present: number;
        absent: number;
        late: number;
      };
    };
  }[];
}
```

**Permissions:**
- `organization:read` - Own organization only
- `organization:read:all` - All organizations (Cross Access)

---

### RFC-002.2: Create Organization

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-002.2 |
| **Title** | Create New Organization |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/organizations
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  name: string;                    // Required, max 255 chars
  typeId: string;                  // Required, UUID
  soatoId: number;                 // Required, SOATO classifier
  phoneNumber: string;             // Required, +998 format
  address: string;                 // Required, max 500 chars
  parentId?: string;               // Optional, UUID (parent organization)
  isEducational?: boolean;         // Default: false
  activationDate?: string;         // ISO Date, default: today
  defaultWorkdayStart?: string;    // HH:MM:SS, default: 09:00:00
  defaultWorkdayEnd?: string;      // HH:MM:SS, default: 18:00:00
  defaultWorkdayCount?: number;    // 1-7, default: 6
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    name: string;
    typeId: string;
    soatoId: number;
    phoneNumber: string;
    address: string;
    parentId?: string;
    createdAt: string;
  };
}
```

**Permissions:** `organization:create` (Super Admin or Parent Org Admin)

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_SOATO | SOATO kod mavjud emas |
| 400 | INVALID_PARENT | Parent organization topilmadi |
| 403 | INSUFFICIENT_PERMISSIONS | Ruxsat yo'q |
| 409 | ORGANIZATION_EXISTS | Shunday nomli tashkilot mavjud |

---

### RFC-002.3: Get Cross Access Organizations

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-002.3 |
| **Title** | Get Cross Access Organizations |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/organizations/cross-access
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `accessType` | enum | No | READ | WRITE (default: READ) |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: [{
    id: string;
    name: string;
    accessType: 'READ' | 'WRITE';
    grantedAt: string;
    grantedBy: {
      id: string;
      fullname: string;
    };
  }];
}
```

---

## RFC-003: Staff & Brigade Management

### RFC-003.1: Get Staff List

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-003.1 |
| **Title** | Get Staff List with Pagination |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/staff
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 20 | Items per page (max: 100) |
| `organizationId` | UUID | No | - | Filter by organization |
| `brigadeId` | UUID | No | - | Filter by brigade |
| `search` | string | No | - | Search by fullname/phone |
| `type` | enum | No | - | EMPLOYEE | BRIGADIER | SECURITY |
| `isActive` | boolean | No | true | Filter by active status |
| `sortBy` | string | No | createdAt | Sort field |
| `sortOrder` | enum | No | DESC | ASC | DESC |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      fullname: string;
      phoneNumber?: string;
      photoUrl?: string;
      organizationId: string;
      organizationName: string;
      positionId?: string;
      positionName?: string;
      brigadeId?: string;
      brigadeName?: string;
      type: 'EMPLOYEE' | 'BRIGADIER' | 'SECURITY' | 'ADMIN' | 'MANAGER';
      jobEntryDate?: string;
      isActive: boolean;
      hasFaceEnrollment: boolean;
      createdAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
      hasNext: boolean;
      hasPrev: boolean;
    };
  };
}
```

**Permissions:** `staff:read` (Own org + Cross Access)

---

### RFC-003.2: Create Staff

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-003.2 |
| **Title** | Create New Staff |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/staff
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  fullname: string;              // Required, max 255 chars
  phoneNumber?: string;          // Optional, +998 format
  jobEntryDate?: string;         // ISO Date
  organizationId: string;        // Required, UUID
  positionId?: string;           // Optional, UUID
  type?: 'EMPLOYEE' | 'BRIGADIER' | 'SECURITY' | 'ADMIN' | 'MANAGER';
  brigadeId?: string;            // Optional, UUID
  photoFileId?: string;          // Optional, UUID (uploaded file)
  userId?: string;               // Optional, UUID (link to user account)
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    fullname: string;
    phoneNumber?: string;
    organizationId: string;
    positionId?: string;
    type: string;
    brigadeId?: string;
    createdAt: string;
  };
}
```

**Permissions:** `staff:create` (Own organization)

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_ORGANIZATION | Organization topilmadi |
| 400 | INVALID_POSITION | Position organizationga tegishli emas |
| 409 | STAFF_PHONE_EXISTS | Phone number allaqachon mavjud |
| 403 | INSUFFICIENT_PERMISSIONS | Ruxsat yo'q |

---

### RFC-003.3: Create Brigade

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-003.3 |
| **Title** | Create New Brigade |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/brigades
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  name: string;           // Required, max 255 chars
  leaderId: string;       // Required, UUID (staff ID)
  organizationId: string; // Required, UUID
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    name: string;
    leaderId: string;
    leaderName: string;
    organizationId: string;
    memberCount: number;
    createdAt: string;
  };
}
```

**Permissions:** `brigade:create` (Own organization)

**Validation:**
- `leaderId` must be staff of the same organization
- `leaderId` must have type BRIGADIER or MANAGER

---

### RFC-003.4: Assign Staff to Brigade

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-003.4 |
| **Title** | Assign Staff to Brigade |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
PUT /api/v1/staff/:staffId/brigade
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  brigadeId: string | null; // UUID or null (remove from brigade)
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    staffId: string;
    brigadeId: string | null;
    brigadeName: string | null;
    updatedAt: string;
  };
}
```

**Permissions:** `staff:update` (Own organization)

---

## RFC-004: Attendance & Face Recognition

### RFC-004.1: Submit Attendance Event (Mobile)

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-004.1 |
| **Title** | Submit Attendance Event from Mobile |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/attendance/submit
```

**Authentication:** Bearer Token (Access Token) + Device Signature

**Request Body:**
```typescript
{
  deviceId: string;           // Required, UUID
  eventTime: string;          // Required, ISO 8601
  eventType: 'FACE_RECOGNIZED' | 'FACE_UNRECOGNIZED' | 'MANUAL';
  snapshotFileId: string;     // Required, UUID (uploaded photo)
  latitude: number;           // Required, -90 to 90
  longitude: number;          // Required, -180 to 180
  locationVerified: boolean;  // Required, Mobile-side polygon check
  territoryId: string;        // Required, UUID
  confidenceScore?: number;   // Optional, 0.0000 - 1.0000
  rawData?: string;           // Optional, Device raw data
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    attendanceEventId: string;
    faceRecognitionJobId?: string; // If async processing needed
    status: 'PENDING' | 'COMPLETED';
    message: string;
  };
}
```

**Permissions:** `attendance:submit` (Device owner organization)

**Validation:**
- `eventTime` must be within ±5 minutes of server time
- `locationVerified` must be `true` for attendance to count
- Device must be active and assigned to territory

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_DEVICE | Device topilmadi yoki inactive |
| 400 | LOCATION_NOT_VERIFIED | Xodim hududda emas |
| 400 | EVENT_TIME_MISMATCH | Vaqt juda oldingi/keyingi |
| 403 | DEVICE_NOT_ASSIGNED | Device territoryga biriktirilmagan |
| 429 | TOO_MANY_REQUESTS | Max 10 events per minute per device |

---

### RFC-004.2: Get Daily Attendance

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-004.2 |
| **Title** | Get Daily Attendance Records |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/attendance/daily
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date` | date | No | today | YYYY-MM-DD |
| `organizationId` | UUID | No | - | Filter by organization |
| `staffId` | UUID | No | - | Filter by staff |
| `brigadeId` | UUID | No | - | Filter by brigade |
| `status` | enum | No | - | PRESENT | ABSENT | LATE |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 50 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      date: string;
      staff: {
        id: string;
        fullname: string;
        photoUrl?: string;
        positionName?: string;
      };
      organization: {
        id: string;
        name: string;
      };
      brigade?: {
        id: string;
        name: string;
      };
      status: 'PRESENT' | 'ABSENT' | 'LATE' | 'LEFT_EARLY' | 'EXCUSED';
      firstInTime?: string;
      lastOutTime?: string;
      firstInEventId?: string;
      lastOutEventId?: string;
      locationVerified: boolean;
      manualOverride: boolean;
      overrideReason?: string;
      overrideBy?: {
        id: string;
        fullname: string;
      };
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
    summary: {
      total: number;
      present: number;
      absent: number;
      late: number;
      leftEarly: number;
      excused: number;
      attendanceRate: number; // percentage
    };
  };
}
```

**Permissions:** `attendance:read` (Own org + Cross Access)

---

### RFC-004.3: Override Attendance

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-004.3 |
| **Title** | Manual Override Attendance |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/attendance/:attendanceId/override
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  status: 'PRESENT' | 'ABSENT' | 'LATE' | 'LEFT_EARLY' | 'EXCUSED';
  overrideReason: string;     // Required, max 500 chars
  firstInTime?: string;       // Optional, ISO 8601
  lastOutTime?: string;       // Optional, ISO 8601
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    status: string;
    manualOverride: boolean;
    overrideReason: string;
    overrideBy: {
      id: string;
      fullname: string;
    };
    updatedAt: string;
  };
}
```

**Permissions:** `attendance:override` (Manager or Admin only)

---

### RFC-004.4: Get Attendance Events (Raw)

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-004.4 |
| **Title** | Get Raw Attendance Events |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/attendance/events
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `deviceId` | UUID | No | - | Filter by device |
| `startDate` | datetime | No | - | ISO 8601 |
| `endDate` | datetime | No | - | ISO 8601 |
| `eventType` | enum | No | - | FACE_RECOGNIZED | MANUAL |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 100 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      deviceId: string;
      deviceName: string;
      eventType: string;
      eventTime: string;
      snapshotUrl?: string;
      confidenceScore?: number;
      latitude?: number;
      longitude?: number;
      territoryId?: string;
      territoryName?: string;
      faceRecognitionJob?: {
        id: string;
        status: string;
        matchedStaffId?: string;
        matchedStaffName?: string;
        confidenceScore?: number;
      };
      createdAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
```

**Permissions:** `attendance:read` (Own org + Cross Access)

---

## RFC-005: Territory Management

### RFC-005.1: Import Territory from KMZ

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-005.1 |
| **Title** | Import Territory from KMZ File |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/territories/import
```

**Authentication:** Bearer Token (Access Token)

**Request (multipart/form-data):**
```
- file: KMZ file (max 10MB)
- name: string (territory name)
- organizationId: UUID
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    territoryId: string;
    name: string;
    organizationId: string;
    kmzFileId: string;
    area: number;        // in square meters
    perimeter: number;   // in meters
    coordinates: GeoJSON;
    createdAt: string;
  };
}
```

**Permissions:** `territory:create` (Own organization)

**Validation:**
- KMZ file must contain valid polygon
- Max 1000 vertices per polygon
- File size max 10MB

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_KMZ_FORMAT | KMZ fayl noto'g'ri formatda |
| 400 | INVALID_POLYGON | Polygon yopilmagan yoki invalid |
| 400 | TOO_MANY_VERTICES | 1000 dan ko'p vertex |
| 413 | FILE_TOO_LARGE | Fayl 10MB dan katta |

---

### RFC-005.2: Get Territories

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-005.2 |
| **Title** | Get Territory List |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/territories
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organizationId` | UUID | No | - | Filter by organization |
| `staffId` | UUID | No | - | Filter by assigned staff |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 50 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      name: string;
      organizationId: string;
      organizationName: string;
      kmzFileUrl: string;
      area: number;
      perimeter: number;
      coordinates: GeoJSON;
      assignedStaffCount: number;
      assignedStaff?: [{
        id: string;
        fullname: string;
        isPrimary: boolean;
      }];
      createdAt: string;
      updatedAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
```

---

### RFC-005.3: Get My Territories (Mobile)

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-005.3 |
| **Title** | Get Assigned Territories for Mobile |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/territories/my
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `staffId` | UUID | Yes | - | Staff ID |
| `includeCoordinates` | boolean | No | true | Include polygon coordinates |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: [{
    id: string;
    name: string;
    organizationId: string;
    organizationName: string;
    isPrimary: boolean;
    assignedAt: string;
    coordinates?: GeoJSON; // If includeCoordinates=true
    area: number;
    perimeter: number;
  }];
}
```

**Note:** Mobile client uses this for location verification (Point-in-Polygon)

---

### RFC-005.4: Assign Staff to Territory

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-005.4 |
| **Title** | Assign Staff to Territory |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/territories/:territoryId/staff
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  staffId: string;        // Required, UUID
  isPrimary?: boolean;    // Default: true
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    territoryId: string;
    staffId: string;
    staffName: string;
    isPrimary: boolean;
    assignedAt: string;
  };
}
```

**Permissions:** `territory:update` (Own organization)

---

## RFC-006: Equipment & GPS Tracking

### RFC-006.1: Get Equipment List

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-006.1 |
| **Title** | Get Equipment List |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/equipment
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organizationId` | UUID | No | - | Filter by organization |
| `typeId` | UUID | No | - | Filter by equipment type |
| `status` | enum | No | - | ACTIVE | MAINTENANCE | INACTIVE |
| `staffId` | UUID | No | - | Filter by assigned staff |
| `hasGPS` | boolean | No | - | Filter by GPS device |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 50 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      name: string;
      type: {
        id: string;
        name: string;
        code: string;
        color?: string;
        icon?: string;
      };
      serialNumber: string;
      licensePlate?: string;
      organizationId: string;
      organizationName: string;
      status: 'ACTIVE' | 'MAINTENANCE' | 'INACTIVE' | 'RETIRED';
      gpsDevice?: {
        id: string;
        imei: string;
        status: 'online' | 'offline' | 'error';
        lastConnectionAt?: string;
        lastPosition?: {
          latitude: number;
          longitude: number;
          receivedAt: string;
        };
      };
      assignedStaff?: {
        id: string;
        fullname: string;
        assignedAt: string;
        isActive: boolean;
      };
      createdAt: string;
      updatedAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
```

**Permissions:** `equipment:read` (Own org + Cross Access)

---

### RFC-006.2: Create Equipment

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-006.2 |
| **Title** | Create New Equipment |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/equipment
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  name: string;              // Required, max 255 chars
  typeId: string;            // Required, UUID
  serialNumber: string;      // Required, max 100 chars
  licensePlate?: string;     // Optional, max 20 chars
  organizationId: string;    // Required, UUID
  gpsDeviceImei?: string;    // Optional, will create GPS device
  status?: 'ACTIVE' | 'MAINTENANCE' | 'INACTIVE' | 'RETIRED';
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    name: string;
    typeId: string;
    serialNumber: string;
    licensePlate?: string;
    organizationId: string;
    gpsDeviceId?: string;
    status: string;
    createdAt: string;
  };
}
```

**Permissions:** `equipment:create` (Own organization)

---

### RFC-006.3: Get GPS History

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-006.3 |
| **Title** | Get GPS Tracking History |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/equipment/:equipmentId/gps
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `startDate` | datetime | No | -24h | ISO 8601 |
| `endDate` | datetime | No | now | ISO 8601 |
| `limit` | number | No | 1000 | Max 10000 |
| `interval` | number | No | - | Minutes (aggregation) |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    equipmentId: string;
    equipmentName: string;
    gpsDeviceId: string;
    imei: string;
    trackings: [{
      id: string;
      latitude: number;
      longitude: number;
      speed?: number;      // km/h
      heading?: number;    // degrees 0-360
      altitude?: number;   // meters
      satellites?: number;
      receivedAt: string;
    }];
    summary: {
      totalPoints: number;
      startDate: string;
      endDate: string;
      maxSpeed?: number;
      avgSpeed?: number;
      distance?: number;   // kilometers (calculated)
    };
  };
}
```

**Permissions:** `equipment:read` (Own org + Cross Access)

**Note:** Data retention is 60 days. Older data is auto-deleted.

---

### RFC-006.4: Get Live GPS Positions

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-006.4 |
| **Title** | Get Live GPS Positions (All Equipment) |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/equipment/live
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organizationId` | UUID | No | - | Filter by organization |
| `status` | enum | No | - | online | offline |
| `typeId` | UUID | No | - | Filter by equipment type |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: [{
    equipmentId: string;
    equipmentName: string;
    type: {
      id: string;
      name: string;
      color?: string;
      icon?: string;
    };
    licensePlate?: string;
    gpsDeviceId: string;
    imei: string;
    status: 'online' | 'offline' | 'error';
    lastConnectionAt?: string;
    position?: {
      latitude: number;
      longitude: number;
      speed?: number;
      heading?: number;
      receivedAt: string;
      age: number;  // seconds since last update
    };
    assignedStaff?: {
      id: string;
      fullname: string;
    };
  }];
}
```

**Permissions:** `equipment:read` (Own org + Cross Access)

**Note:** Recommended polling interval: 30 seconds

---

### RFC-006.5: Assign Equipment to Staff

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-006.5 |
| **Title** | Assign Equipment to Staff |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/equipment/:equipmentId/staff
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  staffId: string;        // Required, UUID
  isActive?: boolean;     // Default: true
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    equipmentId: string;
    equipmentName: string;
    staffId: string;
    staffName: string;
    isActive: boolean;
    assignedAt: string;
  };
}
```

**Permissions:** `equipment:update` (Own organization)

---

## RFC-007: Task Management

### RFC-007.1: Get Task List

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-007.1 |
| **Title** | Get Task List |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/tasks
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organizationId` | UUID | No | - | Filter by organization |
| `status` | enum | No | - | PENDING | IN_PROGRESS | COMPLETED |
| `priority` | enum | No | - | LOW | MEDIUM | HIGH | URGENT |
| `typeId` | UUID | No | - | Filter by task type |
| `territoryId` | UUID | No | - | Filter by territory |
| `assignedToStaffId` | UUID | No | - | Filter by assigned staff |
| `dueDateFrom` | date | No | - | ISO Date |
| `dueDateTo` | date | No | - | ISO Date |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 50 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      title: string;
      description?: string;
      type: {
        id: string;
        name: string;
        code: string;
        color?: string;
        icon?: string;
      };
      priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
      status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
      organizationId: string;
      organizationName: string;
      createdBy: {
        id: string;
        fullname: string;
      };
      territory?: {
        id: string;
        name: string;
      };
      dueDate?: string;
      completedAt?: string;
      assignments?: [{
        staffId: string;
        staffName: string;
        brigadeId?: string;
        brigadeName?: string;
        status: 'ASSIGNED' | 'ACCEPTED' | 'IN_PROGRESS' | 'COMPLETED' | 'REJECTED';
        assignedAt: string;
        completedAt?: string;
      }];
      createdAt: string;
      updatedAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
```

**Permissions:** `task:read` (Own org + Cross Access)

---

### RFC-007.2: Create Task

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-007.2 |
| **Title** | Create New Task |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/tasks
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  title: string;              // Required, max 255 chars
  description?: string;       // Optional, max 2000 chars
  typeId: string;             // Required, UUID
  priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  organizationId: string;     // Required, UUID
  territoryId?: string;       // Optional, UUID
  dueDate?: string;           // Optional, ISO Date
  assignments?: [{
    staffId?: string;         // Optional, UUID
    brigadeId?: string;       // Optional, UUID
  }];
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    title: string;
    typeId: string;
    priority: string;
    status: 'PENDING';
    organizationId: string;
    territoryId?: string;
    dueDate?: string;
    assignmentCount: number;
    createdAt: string;
  };
}
```

**Permissions:** `task:create` (Own organization)

---

### RFC-007.3: Assign Task to Staff/Brigade

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-007.3 |
| **Title** | Assign Task to Staff or Brigade |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/tasks/:taskId/assign
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  staffId?: string;    // Optional, UUID (either staffId or brigadeId)
  brigadeId?: string;  // Optional, UUID (either staffId or brigadeId)
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    assignmentId: string;
    taskId: string;
    staffId?: string;
    staffName?: string;
    brigadeId?: string;
    brigadeName?: string;
    status: 'ASSIGNED';
    assignedBy: {
      id: string;
      fullname: string;
    };
    assignedAt: string;
  };
}
```

**Permissions:** `task:assign` (Own organization)

**Validation:**
- Either `staffId` or `brigadeId` must be provided (not both)
- Staff/Brigade must belong to the same organization as the task

---

### RFC-007.4: Update Task Status

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-007.4 |
| **Title** | Update Task Status |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
PATCH /api/v1/tasks/:taskId/status
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  comment?: string;  // Optional, max 500 chars
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    taskId: string;
    status: string;
    completedAt?: string;
    updatedAt: string;
  };
}
```

**Permissions:** `task:update` (Task creator or organization admin)

---

## RFC-008: Dashboard & Reports

### RFC-008.1: Get Dashboard Statistics

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-008.1 |
| **Title** | Get Dashboard Statistics (Today) |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/dashboard/stats
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date` | date | No | today | YYYY-MM-DD |
| `organizationId` | UUID | No | - | Filter by organization |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    date: string;
    organizationId: string;
    organizationName: string;
    attendance: {
      totalStaff: number;
      present: number;
      absent: number;
      late: number;
      leftEarly: number;
      excused: number;
      attendanceRate: number;  // percentage
      onTimeRate: number;      // percentage
    };
    equipment: {
      total: number;
      active: number;
      online: number;
      offline: number;
      maintenance: number;
    };
    tasks: {
      total: number;
      pending: number;
      inProgress: number;
      completed: number;
      overdue: number;
    };
    brigades: {
      total: number;
      activeToday: number;
    };
    territories: {
      total: number;
      coveredToday: number;  // Has attendance events
    };
    updatedAt: string;
  };
}
```

**Permissions:** `dashboard:read` (Own org + Cross Access)

---

### RFC-008.2: Get Attendance Report

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-008.2 |
| **Title** | Get Attendance Report (Date Range) |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/reports/attendance
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `startDate` | date | Yes | - | YYYY-MM-DD |
| `endDate` | date | Yes | - | YYYY-MM-DD |
| `organizationId` | UUID | No | - | Filter by organization |
| `staffId` | UUID | No | - | Filter by staff |
| `brigadeId` | UUID | No | - | Filter by brigade |
| `groupBy` | enum | No | day | day | week | month | org | staff |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    startDate: string;
    endDate: string;
    groupBy: string;
    rows: [{
      period: string;         // Date or group identifier
      organizationId?: string;
      organizationName?: string;
      staffId?: string;
      staffName?: string;
      brigadeId?: string;
      brigadeName?: string;
      totalDays: number;
      present: number;
      absent: number;
      late: number;
      leftEarly: number;
      excused: number;
      attendanceRate: number;
      avgFirstInTime?: string;  // HH:MM
      avgLastOutTime?: string;  // HH:MM
    }];
    summary: {
      totalDays: number;
      totalStaff: number;
      present: number;
      absent: number;
      late: number;
      attendanceRate: number;
    };
  };
}
```

**Permissions:** `reports:read` (Own org + Cross Access)

**Export:** Add `?format=csv` or `?format=xlsx` for file download

---

### RFC-008.3: Get Equipment GPS Report

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-008.3 |
| **Title** | Get Equipment GPS Report |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/reports/gps
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `startDate` | datetime | Yes | - | ISO 8601 |
| `endDate` | datetime | Yes | - | ISO 8601 |
| `equipmentId` | UUID | No | - | Filter by equipment |
| `organizationId` | UUID | No | - | Filter by organization |
| `typeId` | UUID | No | - | Filter by equipment type |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    startDate: string;
    endDate: string;
    equipment: [{
      equipmentId: string;
      equipmentName: string;
      type: {
        id: string;
        name: string;
      };
      licensePlate?: string;
      assignedStaff?: {
        id: string;
        fullname: string;
      };
      stats: {
        totalPoints: number;
        onlineDuration: number;   // hours
        offlineDuration: number;  // hours
        maxSpeed: number;         // km/h
        avgSpeed: number;         // km/h
        distance: number;         // km
        firstPosition: {
          latitude: number;
          longitude: number;
          receivedAt: string;
        };
        lastPosition: {
          latitude: number;
          longitude: number;
          receivedAt: string;
        };
      };
    }];
    summary: {
      totalEquipment: number;
      totalDistance: number;
      avgOnlineDuration: number;
    };
  };
}
```

**Permissions:** `reports:read` (Own org + Cross Access)

---

## RFC-009: Device Management

### RFC-009.1: Get Device List

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-009.1 |
| **Title** | Get Face Recognition Device List |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/devices
```

**Authentication:** Bearer Token (Access Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organizationId` | UUID | No | - | Filter by organization |
| `territoryId` | UUID | No | - | Filter by territory |
| `status` | enum | No | - | online | offline | error |
| `direction` | enum | No | - | IN | OUT | BOTH |
| `isActive` | boolean | No | true | Filter by active status |
| `page` | number | No | 1 | Page number |
| `limit` | number | No | 50 | Items per page |

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    items: [{
      id: string;
      name: string;
      serialNumber: string;
      ipAddress: string;
      port: number;
      direction: 'IN' | 'OUT' | 'BOTH';
      locationDescription?: string;
      organizationId: string;
      organizationName: string;
      territoryId?: string;
      territoryName?: string;
      status: 'online' | 'offline' | 'error';
      lastHeartbeatAt?: string;
      isActive: boolean;
      enrolledFaceCount: number;
      lastSyncAt?: string;
      createdAt: string;
    }];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
```

**Permissions:** `device:read` (Own org + Cross Access)

---

### RFC-009.2: Create Device

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-009.2 |
| **Title** | Register New Face Recognition Device |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/devices
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  name: string;              // Required, max 255 chars
  serialNumber: string;      // Required, max 100 chars
  ipAddress: string;         // Required, valid IP
  port?: number;             // Default: 80
  direction?: 'IN' | 'OUT' | 'BOTH';
  locationDescription?: string;
  organizationId: string;    // Required, UUID
  territoryId?: string;      // Optional, UUID
  username: string;          // Required, device API username
  password: string;          // Required, device API password
}
```

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    name: string;
    serialNumber: string;
    ipAddress: string;
    organizationId: string;
    territoryId?: string;
    status: 'offline';  // Initial status
    createdAt: string;
  };
}
```

**Permissions:** `device:create` (Own organization)

---

### RFC-009.3: Sync Face Enrollments to Device

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-009.3 |
| **Title** | Sync Face Enrollments to Device |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/devices/:deviceId/sync
```

**Authentication:** Bearer Token (Access Token)

**Request Body:**
```typescript
{
  faceEnrollmentIds?: string[];  // Optional, specific enrollments
  fullSync?: boolean;            // Default: false (incremental)
}
```

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    deviceId: string;
    syncJobId: string;
    status: 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';
    totalEnrollments: number;
    syncedCount: number;
    failedCount: number;
    startedAt: string;
    completedAt?: string;
  };
}
```

**Permissions:** `device:sync` (Own organization)

**Note:** This triggers async job via BullMQ queue

---

## RFC-010: File Upload

### RFC-010.1: Upload File

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-010.1 |
| **Title** | Upload File (Photo, KMZ, etc.) |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
POST /api/v1/files/upload
```

**Authentication:** Bearer Token (Access Token)

**Request (multipart/form-data):**
```
- file: File (binary)
- type: enum (PHOTO | KMZ | DOCUMENT | SNAPSHOT)
```

**File Constraints:**
| Type | Max Size | Allowed Extensions |
|------|----------|-------------------|
| PHOTO | 5MB | jpg, jpeg, png |
| KMZ | 10MB | kmz |
| DOCUMENT | 10MB | pdf, doc, docx |
| SNAPSHOT | 2MB | jpg, jpeg, png |

**Response (201 Created):**
```typescript
{
  success: boolean;
  data: {
    fileId: string;
    url: string;
    name: string;
    ext: string;
    size: number;
    mimeType: string;
    createdAt: string;
  };
}
```

**Permissions:** `file:upload` (All authenticated users)

**Error Responses:**
| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_FILE_TYPE | Fayl turi ruxsat etilmagan |
| 413 | FILE_TOO_LARGE | Fayl hajmi katta |
| 415 | UNSUPPORTED_MEDIA_TYPE | MIME type noto'g'ri |

---

### RFC-010.2: Get File URL

| Maydon | Qiymat |
|--------|--------|
| **RFC ID** | RFC-010.2 |
| **Title** | Get File Download URL |
| **Status** | ✅ Approved |
| **Version** | 1.0 |

**Endpoint:**
```
GET /api/v1/files/:fileId
```

**Authentication:** Bearer Token (Access Token)

**Response (200 OK):**
```typescript
{
  success: boolean;
  data: {
    id: string;
    url: string;
    name: string;
    ext: string;
    size: number;
    mimeType: string;
    createdAt: string;
  };
}
```

**Permissions:** `file:read` (File owner or organization member)

---

## 📋 Umumiy Response Format

Barcha API responses quyidagi formatda bo'ladi:

### Success Response:
```typescript
{
  success: true;
  data: T;  // Type depends on endpoint
  message?: string;  // Optional
  timestamp: string; // ISO 8601
}
```

### Error Response:
```typescript
{
  success: false;
  error: {
    code: string;      // Machine-readable error code
    message: string;   // Human-readable message
    details?: object;  // Additional error details
    stack?: string;    // Only in development mode
  };
  timestamp: string;
}
```

---

## 🔐 Authentication & Authorization

### JWT Token Structure:
```typescript
// Access Token Payload
{
  sub: string;        // User ID
  phoneNumber: string;
  organizations: [{
    id: string;
    positionId: string;
  }];
  permissions: string[];
  iat: number;
  exp: number;
}

// Refresh Token Payload
{
  sub: string;        // User ID
  type: 'refresh';
  iat: number;
  exp: number;
}
```

### Permission Format:
```
<resource>:<action>[:scope]

Examples:
- organization:read
- organization:create
- staff:read
- staff:create
- attendance:submit
- attendance:override
- task:assign
- dashboard:read
- reports:read
```

### Cross Access:
Tashkilotlararo ruxsat `organizationCrossAccess` jadvali orqali boshqariladi. User o'z tashkilotidan tashqari boshqa tashkilotlarga READ/WRITE ruxsatga ega bo'lishi mumkin.

---

## 📊 Rate Limiting

| Endpoint Category | Limit | Window |
|------------------|-------|--------|
| Authentication | 5 requests | 1 minute |
| Attendance Submit | 10 requests | 1 minute (per device) |
| File Upload | 20 requests | 1 hour |
| General API | 100 requests | 1 minute |
| Reports | 10 requests | 1 minute |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642089600
```

---

## 📝 Versioning

API versioning URL path orqali amalga oshiriladi:
```
/api/v1/...
/api/v2/... (future)
```

Breaking changes yangi version da chiqariladi. Minor changes backward compatible bo'ladi.

---

## ✅ RFC Status Legend

| Status | Description |
|--------|-------------|
| ✅ Approved | Tasdiqlangan, implementatsiya qilish mumkin |
| 🔄 In Review | Ko'rib chiqilmoqda |
| 📝 Draft | Hali tayyorlanmoqda |
| ❌ Rejected | Rad etilgan |
| 🚀 Implemented | Implementatsiya qilingan |

---

**Hujjat Versiyasi:** 1.0  
**Oxirgi Yangilanish:** 2025  
**Jami RFC:** 10 ta modul, 35+ endpoint
