# API Documentation - ITM LA VISION Parent Portal

## Base Configuration

**Base URL:** `http://localhost:8000` (à remplacer par l'URL réelle)  
**API Prefix:** `/api/v1`  
**Content-Type:** `application/json`

---

## 1. AUTHENTICATION ENDPOINTS

### Login
```
POST /api/v1/auth/login
```
**Description:** Authentification du parent

**Request Body:**
```json
{
  "email": "parent@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Parent Name",
      "email": "parent@example.com",
      "role": "parent",
      "phone": "+228 XXXXXXXXXX",
      "avatar": null,
      "is_active": true,
      "last_login_at": "2026-04-11T21:44:12.000000Z"
    },
    "token": "5|PRvdK3kCJaKZs3b8dQrQiTBYPdf2it4l7oqDk8Wy29dde4a3",
    "token_type": "Bearer"
  }
}
```

### Logout
```
POST /api/v1/auth/logout
Authorization: Bearer {token}
```
**Description:** Déconnexion et révocation du token

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

### Logout All Devices
```
POST /api/v1/auth/logout-all
Authorization: Bearer {token}
```
**Description:** Déconnexion de tous les appareils

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out from all devices"
}
```

### Refresh Token
```
POST /api/v1/auth/refresh
Authorization: Bearer {token}
```
**Description:** Renouvellement du token d'authentification

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed",
  "data": {
    "token": "new_token_here",
    "token_type": "Bearer"
  }
}
```

---

## 2. PARENT PROFILE ENDPOINTS

### Get Parent Profile
```
GET /api/v1/parent/profile
Authorization: Bearer {token}
```
**Description:** Récupération du profil du parent connecté

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile retrieved",
  "data": {
    "id": 1,
    "name": "Parent Name",
    "email": "parent@example.com",
    "phone": "+228 XXXXXXXXXX",
    "avatar": "https://example.com/avatars/user1.jpg",
    "role": "parent",
    "is_active": true,
    "last_login_at": "2026-04-11T21:44:12.000000Z",
    "language": "fr"
  }
}
```

### Update Parent Profile
```
PUT /api/v1/parent/profile
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "name": "New Name",
  "email": "newemail@example.com",
  "phone": "+228 XXXXXXXXXX",
  "language": "fr"
}
```

**Success Response (200):** Profil mis à jour

### Get Children
```
GET /api/v1/parent/children?year=2024
Authorization: Bearer {token}
```
**Description:** Liste des enfants du parent

**Query Parameters:**
- `year` (optionnel): Année scolaire

**Success Response (200):**
```json
{
  "success": true,
  "message": "Children retrieved",
  "data": [
    {
      "id": 1,
      "name": "KOSSI Ayélé Jessica",
      "matricule": "MAT001",
      "class": "1ère D",
      "stream": "Lycée Moderne",
      "enrollment_status": "active",
      "photo": "https://example.com/students/student1.jpg",
      "enrollment_date": "2023-09-01"
    }
  ]
}
```

### Get Child Details
```
GET /api/v1/parent/children/{childId}
Authorization: Bearer {token}
```
**Description:** Détails d'un enfant spécifique

---

## 3. ACADEMIC ENDPOINTS

### Get Grades
```
GET /api/v1/academic/children/{childId}/grades?semester=1&year=2026
Authorization: Bearer {token}
```
**Description:** Notes de l'enfant par semestre

**Query Parameters:**
- `semester` (optionnel): 1 ou 2
- `year` (optionnel): Année scolaire

**Success Response (200):**
```json
{
  "success": true,
  "message": "Grades retrieved",
  "data": {
    "general_average": 14.20,
    "semester": 1,
    "year": 2026,
    "min_class_average": 12.5,
    "max_class_average": 16.8,
    "subjects": [
      {
        "id": 1,
        "name": "Mathématiques",
        "teacher": "M. Koussie",
        "coefficient": 4,
        "average": 14.5,
        "class_average": 12.2,
        "grades": [
          {
            "evaluation_name": "Devoir 1",
            "score": 15,
            "max_score": 20,
            "date": "2026-03-15",
            "teacher": "M. Koussie",
            "comment": "Bon travail"
          }
        ]
      }
    ]
  }
}
```

### Get Subject Grades
```
GET /api/v1/academic/children/{childId}/grades/{subjectId}?semester=1
Authorization: Bearer {token}
```
**Description:** Détail complet des notes pour une matière

### Get Bulletins
```
GET /api/v1/academic/children/{childId}/bulletins?year=2026
Authorization: Bearer {token}
```
**Description:** Liste des bulletins disponibles

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bulletins retrieved",
  "data": [
    {
      "id": 1,
      "semester": 1,
      "year": 2026,
      "average": 14.20,
      "created_at": "2026-04-10T10:30:00Z",
      "file_url": "https://example.com/bulletins/bulletin1.pdf",
      "rank": "1/45",
      "total_students": 45
    }
  ]
}
```

### Download Bulletin
```
GET /api/v1/academic/children/{childId}/bulletins/{bulletinId}/download
Authorization: Bearer {token}
```
**Description:** Télécharge un bulletin PDF

**Response:** Fichier PDF binaire

### Get General Average
```
GET /api/v1/academic/children/{childId}/general-average?semester=1&year=2026
Authorization: Bearer {token}
```
**Description:** Moyenne générale avec statistiques

---

## 4. ATTENDANCE ENDPOINTS

### Get Absences
```
GET /api/v1/attendance/children/{childId}/absences?month=4&year=2026&justified=0
Authorization: Bearer {token}
```
**Query Parameters:**
- `month` (optionnel): Mois (1-12)
- `year` (optionnel): Année
- `justified` (optionnel): 0 ou 1

**Success Response (200):**
```json
{
  "success": true,
  "message": "Absences retrieved",
  "data": [
    {
      "id": 1,
      "date": "2026-04-01",
      "reason": "Maladie",
      "justified": true,
      "teacher_comment": "Justifiée par parents",
      "justification_file": "https://example.com/docs/justif1.pdf"
    }
  ]
}
```

### Get Tardies
```
GET /api/v1/attendance/children/{childId}/tardies?month=4&year=2026
Authorization: Bearer {token}
```
**Description:** Retards de l'enfant

### Get Attendance Statistics
```
GET /api/v1/attendance/children/{childId}/statistics?semester=1&year=2026
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Attendance statistics retrieved",
  "data": {
    "total_absences": 2,
    "justified_absences": 1,
    "unjustified_absences": 1,
    "total_tardies": 3,
    "attendance_percentage": 96.5,
    "semester": 1,
    "year": 2026
  }
}
```

---

## 5. FINANCIAL ENDPOINTS

### Get Fees
```
GET /api/v1/financial/children/{childId}/fees?year=2026
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Fees retrieved",
  "data": [
    {
      "id": 1,
      "description": "Frais de scolarité",
      "amount": 500000,
      "due_date": "2026-09-15",
      "paid_amount": 250000,
      "status": "partial",
      "category": "tuition"
    }
  ]
}
```

### Get Fees Summary
```
GET /api/v1/financial/children/{childId}/fees-summary?year=2026
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Fees summary retrieved",
  "data": {
    "total_fees": 750000,
    "paid_amount": 250000,
    "remaining_amount": 500000,
    "percentage_paid": 33.33,
    "year": 2026
  }
}
```

### Get Payment History
```
GET /api/v1/financial/children/{childId}/payments?year=2026&limit=20
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Payment history retrieved",
  "data": [
    {
      "id": 1,
      "amount": 250000,
      "date": "2026-03-15",
      "method": "mobile_money",
      "status": "confirmed",
      "receipt_url": "https://example.com/receipts/receipt1.pdf",
      "reference": "PAY20260315001",
      "description": "Acompte frais scolarité"
    }
  ]
}
```

### Create Payment
```
POST /api/v1/financial/children/{childId}/payments
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "amount": 250000,
  "payment_method": "mobile_money",
  "reference": "REF123456",
  "fee_ids": [1, 2]
}
```

**Success Response (200/201):**
```json
{
  "success": true,
  "message": "Payment created",
  "data": {
    "transaction_id": "TXN20260411001",
    "status": "pending_approval",
    "redirect_url": "https://payment-gateway.com/pay/TXN20260411001"
  }
}
```

### Download Receipt
```
GET /api/v1/financial/children/{childId}/payments/{paymentId}/receipt
Authorization: Bearer {token}
```
**Response:** PDF file binary

### Get Unpaid Fees
```
GET /api/v1/financial/children/{childId}/unpaid
Authorization: Bearer {token}
```
**Description:** Frais impayés avec mention "overdue"

---

## 6. MESSAGING ENDPOINTS

### Get Conversations
```
GET /api/v1/messaging/conversations?child_id={childId}&limit=20
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Conversations retrieved",
  "data": [
    {
      "id": 1,
      "teacher_name": "M. Koussie",
      "teacher_subject": "Mathématiques",
      "last_message": "Votre enfant fait du bon travail",
      "unread_count": 2,
      "updated_at": "2026-04-11T15:30:00Z",
      "teacher_avatar": "https://example.com/avatars/teacher1.jpg"
    }
  ]
}
```

### Get Messages
```
GET /api/v1/messaging/conversations/{conversationId}/messages?limit=50&page=1
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Messages retrieved",
  "data": [
    {
      "id": 1,
      "sender": "teacher",
      "sender_name": "M. Koussie",
      "message": "Bonjour, votre enfant fait du bon travail",
      "timestamp": "2026-04-11T14:20:00Z",
      "read_at": "2026-04-11T14:25:00Z",
      "attachments": []
    }
  ]
}
```

### Send Message
```
POST /api/v1/messaging/conversations/{conversationId}/messages
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "message": "Merci pour vos retours",
  "attachments": []
}
```

### Get Available Teachers
```
GET /api/v1/messaging/children/{childId}/teachers
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Teachers retrieved",
  "data": [
    {
      "id": 1,
      "name": "M. Koussie",
      "subject": "Mathématiques",
      "email": "koussie@example.com",
      "available": true,
      "avatar": "https://example.com/avatars/teacher1.jpg"
    }
  ]
}
```

### Create Conversation
```
POST /api/v1/messaging/conversations/create
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "teacher_id": 1,
  "child_id": "1",
  "subject": "Question sur les mathématiques"
}
```

### Mark Conversation as Read
```
PUT /api/v1/messaging/conversations/{conversationId}/read
Authorization: Bearer {token}
```

---

## 7. ANNOUNCEMENTS ENDPOINTS

### Get Announcements
```
GET /api/v1/announcements?limit=20&page=1
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Announcements retrieved",
  "data": [
    {
      "id": 1,
      "title": "Fermeture école - Jour fériée",
      "content": "L'école sera fermée le 15 avril...",
      "priority": 3,
      "created_at": "2026-04-10T10:00:00Z",
      "read_at": null,
      "for_class": null,
      "author": "Direction"
    }
  ]
}
```

### Get Child Announcements
```
GET /api/v1/announcements/children/{childId}?limit=20&page=1
Authorization: Bearer {token}
```

### Mark Announcement as Read
```
PUT /api/v1/announcements/{announcementId}/read
Authorization: Bearer {token}
```

---

## 8. NOTIFICATIONS ENDPOINTS

### Register Device Token
```
POST /api/v1/notifications/register-device
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "fcm_token": "device_fcm_token_here",
  "device_type": "android",
  "device_model": "TECNO KG5k"
}
```

### Get Notification Preferences
```
GET /api/v1/notifications/preferences
Authorization: Bearer {token}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Preferences retrieved",
  "data": {
    "push_enabled": true,
    "email_enabled": true,
    "sms_enabled": false,
    "grades": true,
    "attendance": true,
    "announcements": true,
    "messages": true,
    "payments": true
  }
}
```

### Update Notification Preferences
```
PUT /api/v1/notifications/preferences
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "push_enabled": true,
  "email_enabled": true,
  "sms_enabled": false,
  "grades": true,
  "attendance": true,
  "announcements": true,
  "messages": true,
  "payments": true
}
```

---

## 9. HEALTH CHECK

### Health Check
```
GET /api/v1/health
```
**Success Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2026-04-11T21:45:00Z"
}
```

---

## Error Handling

### Common Error Responses

**Unauthorized (401):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "errors": {
    "auth": ["Token invalid or expired"]
  }
}
```

**Validation Error (422):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required"],
    "password": ["Password must be at least 6 characters"]
  }
}
```

**Server Error (500):**
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## Authentication

All protected endpoints require the `Authorization` header:
```
Authorization: Bearer {token}
```

Where `{token}` is the JWT token received from the login endpoint.

---

## Pagination

For endpoints that return lists, pagination is controlled via query parameters:
- `page`: Numéro de page (par défaut 1)
- `limit`: Nombre d'éléments par page (par défaut 20)

---

## Date Format

All timestamps use the ISO 8601 format: `YYYY-MM-DDTHH:MM:SS.sssZ`

Example: `2026-04-11T21:44:12.000000Z`

