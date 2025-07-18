```sql
Table employee_master {
  id integer [primary key]
  name varchar
  designation varchar
  incentive_percentage decimal
  created_at timestamp
}

Table client_master {
  id integer [primary key]
  name varchar
  created_at timestamp
}

Table billing {
  id integer [primary key]
  client_id integer [not null]
  amount decimal
  quarter varchar
  created_at timestamp
}

Table incentive_master {
  id integer [primary key]
  employee_id integer [not null]
  quarter varchar
  completion_percentage decimal
  incentive_amount decimal
  created_at timestamp
}

// Define relationships
Ref: client_master.id < billing.client_id // one-to-many
Ref: employee_master.id < incentive_master.employee_id // one-to-many

```sql

---
This DBML schema defines the four tables needed for your incentive calculation system and establishes the necessary relationships between them.

<img width="1178" height="752" alt="image" src="https://github.com/user-attachments/assets/6e03915b-0f16-49e7-895d-65219bf21038" />

