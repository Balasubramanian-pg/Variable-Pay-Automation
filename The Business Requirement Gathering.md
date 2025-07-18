# Business Requirement Document: Automated Incentive Calculation System

## 1. Introduction
The purpose of this document is to outline the requirements for an automated system to calculate employee incentives based on the completion of a 90-day plan and designation-based percentages of client billing.

## 2. Scope
### In Scope:
- Employee master data management.
- Client master data management.
- Mapping employees to clients.
- Calculation of incentives based on billing and designation.
- Reporting of incentives per employee per quarter.

### Out of Scope:
- Real-time data processing.
- Integration with external HR systems (initially).

## 3. Business Requirements
### Employee Master Data
- Create and maintain a database of all employees with their designations.
- Designations include Principal Consultant, Client Engagement Manager, etc.

### Client Master Data
- Maintain a database of all clients with their billing information.
- Billing data should be available quarterly.

### Employee-Client Mapping
- Map employees to the clients they have worked on.
- Ensure accurate tracking of employee involvement per client.

### Billing Data
- Access and utilize quarterly billing data for each client.
- Ensure billing data is up-to-date and accurate.

### Designation-Based Incentives
- Define and maintain incentive percentages for each designation.
- Example: Principal Consultant - 4.75%, Client Engagement Manager - 2.25%.

## 4. Functional Requirements
### Data Input Requirements
- Input fields for employee details including designation.
- Input fields for client billing details on a quarterly basis.
- Mapping interface for assigning employees to clients.

### Calculation Logic
- System should calculate incentives using the formula:
  Incentive = (Employee Designation Percentage) * (Client Quarterly Billing)
- Example Calculations:
  - Employee X (Client Engagement Manager) with 2.25% on 6 lakhs INR billing: Incentive = 2.25% of 6,00,000 = 13,500 INR
  - Employee X2 (Principal Consultant) with 4.75% on 6 lakhs INR billing: Incentive = 4.75% of 6,00,000 = 28,500 INR

### Reporting
- Generate detailed reports showing incentives calculated per employee per quarter.
- Reports should be exportable in common formats (e.g., Excel, PDF).

## 5. Non-Functional Requirements
- The system should be scalable to handle increasing amounts of data.
- Ensure secure handling of sensitive employee and billing data.
- The interface should be user-friendly for data input and report generation.

## 6. Assumptions
- All employees have a clearly defined designation with a corresponding incentive percentage.
- Quarterly billing data is accurate and readily available.
- Employees are accurately mapped to the clients they worked on.

## 7. Constraints
- The system must adhere to data privacy regulations.
- The solution must be implemented using existing data storage and processing capabilities.

## 8. Workflow Diagram
```mermaid
graph LR
    A[Input Employee Data] --> B[Input Client Billing Data]
    B --> C[Map Employees to Clients]
    C --> D[Calculate Incentives]
    D --> E[Generate Reports]
```

## 9. Glossary
- **90-day plan**: A quarterly plan that employees are expected to complete.
- **Designation percentage**: The percentage of variable pay an employee is eligible for based on their designation.
- **Quarterly billing**: The total billing amount for a client over a quarter (three months).
