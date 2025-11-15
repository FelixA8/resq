# ResQ App - Supabase Database Schema

## Overview
This document describes the PostgreSQL database schema for the ResQ disaster response application.

**Project**: resq-app  
**Project ID**: mirisslaptcomtnuuzeh  
**Database Version**: PostgreSQL 17  
**Region**: ap-southeast-1

---

## Tables

### 1. `users` - User Accounts
Stores information about app users.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| user_id | uuid | NOT NULL | Primary Key |
| role | varchar(64) | NULL | User role (e.g., 'citizen', 'admin') |
| phone_number | varchar(16) | NULL | User's phone number |
| username | varchar(255) | NULL | Username |
| city | varchar(255) | NULL | User's city |

**Relationships:**
- Has many `otp_code` records (one-to-many)
- Has many `contacts` records (one-to-many)
- Has many `sos_events` records (one-to-many)

---

### 2. `otp_code` - OTP Verification
Stores OTP codes for phone verification.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| verification_id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NULL | Foreign Key → users.user_id |
| otp_code | char(4) | NULL | 4-digit OTP code |
| is_valid | boolean | NULL | Whether the OTP is still valid |
| created_at | date | NULL | When OTP was created |
| expires_at | date | NULL | When OTP expires |

**Relationships:**
- Belongs to `users` (many-to-one)

---

### 3. `contacts` - Emergency Contacts
Stores emergency contacts for users.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| user_id | uuid | NOT NULL | Foreign Key → users.user_id |
| contact_name | varchar(255) | NOT NULL | Contact name |
| phone_number | varchar(16) | NULL | Contact's phone number |

**Primary Key:** (user_id, contact_name) - Composite key  
**Relationships:**
- Belongs to `users` (many-to-one)

---

### 4. `disasters` - Disaster Events
Stores information about natural disasters.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| disaster_id | uuid | NOT NULL | Primary Key |
| occurred_at | date | NULL | When disaster occurred |
| center_lat | real | NULL | Latitude of disaster center |
| center_lng | real | NULL | Longitude of disaster center |
| magnitude | real | NULL | Magnitude (for earthquakes) |
| depth | varchar(255) | NULL | Depth (for earthquakes) |
| shakemap | varchar(255) | NULL | Shakemap data |

**Relationships:**
- Has many `disasters_response_teams` records (one-to-many)

---

### 5. `response_teams` - Response Team Accounts
Stores information about response team members.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| response_team_id | uuid | NOT NULL | Primary Key |
| role | varchar(64) | NULL | Team member role |
| password | varchar(64) | NULL | Hashed password |

**Relationships:**
- Has many `evacuation_points` records (one-to-many)
- Has many `sos_assignments` records (one-to-many)
- Has many `disasters_response_teams` records (one-to-many)

---

### 6. `evacuation_points` - Evacuation Points
Stores location information for evacuation points.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| evacuation_id | uuid | NOT NULL | Primary Key |
| response_team_id | uuid | NULL | Foreign Key → response_teams.response_team_id |
| location_lat | real | NULL | Latitude |
| location_lng | real | NULL | Longitude |
| city | varchar(255) | NULL | City name |

**Relationships:**
- Belongs to `response_teams` (many-to-one)

---

### 7. `sos_events` - SOS Emergency Events
Stores SOS button press events from users.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| sos_id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NULL | Foreign Key → users.user_id |
| sos_pressed | boolean | NULL | Whether SOS was pressed |
| location_lat | real | NULL | User's location latitude |
| location_lng | real | NULL | User's location longitude |

**Relationships:**
- Belongs to `users` (many-to-one)
- Has one `sos_assignments` record (one-to-one)

---

### 8. `sos_assignments` - SOS Task Assignments
Stores assignments of SOS events to response teams.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| sos_id | uuid | NOT NULL | Primary Key, Foreign Key → sos_events.sos_id |
| response_team_id | uuid | NULL | Foreign Key → response_teams.response_team_id |
| assigned_at | date | NULL | When assigned |
| resolved_at | date | NULL | When resolved |
| is_current | boolean | NULL | Whether this is the current assignment |

**Relationships:**
- Belongs to `sos_events` (one-to-one)
- Belongs to `response_teams` (many-to-one)

---

### 9. `disasters_response_teams` - Disaster Response Assignments
Junction table linking disasters to assigned response teams.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| disaster_id | uuid | NOT NULL | Foreign Key → disasters.disaster_id |
| response_team_id | uuid | NOT NULL | Foreign Key → response_teams.response_team_id |

**Primary Key:** (disaster_id, response_team_id) - Composite key  
**Relationships:**
- Belongs to `disasters` (many-to-one)
- Belongs to `response_teams` (many-to-one)

---

## Entity Relationship Diagram

```
users
  ├── otp_code (one-to-many)
  ├── contacts (one-to-many)
  └── sos_events (one-to-many)

sos_events ──┬── sos_assignments ──┬── response_teams
              │                      │
              │                      ├── evacuation_points
              │                      │
              └──────────────────────┴── disasters_response_teams
                                            │
                                            ├── disasters
                                            └── response_teams
```

---

## Security Notes

⚠️ **Current Status:** RLS (Row Level Security) is **disabled** on all tables.

🔒 **Security Recommendations:**

1. **Enable Row Level Security** on all tables
2. **Set up RLS policies** to control access:
   - Users should only see their own data
   - Response teams should only access assigned tasks
   - Public data (like disasters) should be readable by all
3. **Add authentication** - Consider using Supabase Auth
4. **Hash passwords** - Currently stored in plain text in `response_teams.password`
5. **Use Supabase functions** for sensitive operations instead of direct client access

---

## Index Recommendations

Consider adding indexes on frequently queried columns:

```sql
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_sos_events_user ON sos_events(user_id);
CREATE INDEX idx_sos_events_location ON sos_events(location_lat, location_lng);
CREATE INDEX idx_disasters_location ON disasters(center_lat, center_lng);
CREATE INDEX idx_disasters_date ON disasters(occurred_at);
```

---

## Data Types Summary

- **uuid**: Unique identifiers (Primary keys, Foreign keys)
- **varchar(n)**: Variable-length strings
- **char(n)**: Fixed-length strings
- **real**: Floating-point numbers (4 bytes)
- **boolean**: True/false values
- **date**: Date values (without time)

---

## Notes

1. **Timestamps**: Consider adding `created_at` and `updated_at` timestamp fields to all tables for better tracking
2. **Soft deletes**: Consider adding `deleted_at` columns instead of hard deletes
3. **Data validation**: Consider adding CHECK constraints for data validation
4. **Performance**: The schema currently has no indexes - consider adding based on query patterns


