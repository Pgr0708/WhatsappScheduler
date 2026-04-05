# Database.md — TextFlow SMS

## 1. Source of Truth
**CloudKit Private Database** (per user). No server storage of message content.

## 2. CloudKit Schema (Record Types)
(As defined in System Design.md)

## 3. Optional MySQL Schema (Backend)
This database must never store message body or phone numbers.

### Tables

#### users
- id (uuid pk)
- apple_sub (varchar unique)  (hashed)
- created_at
- locale
- timezone

#### events
- id (uuid pk)
- user_id (fk users.id)
- event_name
- event_ts
- properties_json (no PII)

#### remote_config
- key
- value_json
- updated_at

## 4. MySQL Queries (examples)
```sql
SELECT event_name, COUNT(*)
FROM events
WHERE event_ts >= NOW() - INTERVAL 7 DAY
GROUP BY event_name;
```

