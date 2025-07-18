<img width="1239" height="760" alt="image" src="https://github.com/user-attachments/assets/96a994bf-9044-4dc8-b3d5-842120de5d29" />

Here's the SQL code to create these tables with their relationships:

```sql
-- Create employee_master table
CREATE TABLE employee_master (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    designation VARCHAR(255),
    incentive_percentage DECIMAL(5,2),
    created_at TIMESTAMP
);

-- Create client_master table with foreign key to employee_master
CREATE TABLE client_master (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP,
    emp_id INT NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employee_master(id)
);

-- Create billing table with foreign key to client_master
CREATE TABLE billing (
    id INT PRIMARY KEY,
    client_id INT NOT NULL,
    amount DECIMAL(10,2),
    quarter VARCHAR(10),
    created_at TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client_master(id)
);

-- Create incentive_master table with foreign key to employee_master
CREATE TABLE incentive_master (
    id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    quarter VARCHAR(10),
    completion_percentage DECIMAL(5,2),
    incentive_amount DECIMAL(10,2),
    created_at TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employee_master(id)
);
```

If you want some extra love, here's an enhanced version with auto-increment IDs and some constraints:

```sql
-- Enhanced version with auto-increment and NOT NULL constraints
CREATE TABLE employee_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    designation VARCHAR(255),
    incentive_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE client_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    emp_id INT NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employee_master(id)
);

CREATE TABLE billing (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    quarter VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client_master(id)
);

CREATE TABLE incentive_master (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    quarter VARCHAR(10) NOT NULL,
    completion_percentage DECIMAL(5,2),
    incentive_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employee_master(id)
);
```
