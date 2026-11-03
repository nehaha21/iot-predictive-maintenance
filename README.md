# Industrial Predictive Maintenance System

A database-driven web application for monitoring industrial machine sensor readings, identifying potential equipment risks, and managing maintenance activities.

The system combines **MySQL** for structured relational data and **MongoDB** for sensor readings and risk alerts. It includes authentication, role-based access control, CRUD operations, and threshold-based risk assessment.

---

## 1. Project Overview

Industrial machines generate sensor data such as temperature, vibration, and pressure. Abnormal readings can indicate potential equipment problems.

This project provides a centralized application to:

- Monitor industrial machine information.
- Store and retrieve sensor readings.
- Identify potential machine risks using threshold-based screening.
- Generate risk alerts for medium- and high-risk readings.
- Manage maintenance records.
- Provide secure access based on user roles.

## 2. Technology Stack

| Component | Technology |
|---|---|
| Frontend | Next.js 14, React 18 |
| Programming Language | TypeScript |
| Styling | CSS |
| Relational Database | MySQL 8 |
| NoSQL Database | MongoDB Community Server |
| MongoDB Driver | MongoDB Node.js Driver |
| Authentication | JWT |
| Password Hashing | bcrypt |
| Validation | Zod |
| SQL Driver | mysql2 |
| JWT Library | jose |

## 3. System Architecture

The application uses a hybrid database architecture.

### MySQL – Relational Database

MySQL stores structured and relational information, including:

- Users
- Machines
- Maintenance records

Database concepts implemented include:

- Primary keys and foreign keys
- Unique and check constraints
- Indexes
- Views
- Stored procedures
- Triggers
- Transactions

### MongoDB – NoSQL Database

MongoDB stores sensor readings and risk alerts.

**Collection 1: `sensor_readings`**

Stores machine sensor measurements and calculated risk information.

Fields include:

- `_id`
- `machineId`
- `temperature`
- `vibration`
- `pressure`
- `recordedAt`
- `risk`
- `score`
- `reasons`

**Collection 2: `risk_alerts`**

Stores alerts generated for medium- and high-risk sensor readings.

Fields include:

- `_id`
- `readingId`
- `machineId`
- `risk`
- `score`
- `temperature`
- `vibration`
- `reasons`
- `createdAt`

The `readingId` field links an alert to its corresponding sensor reading.

## 4. Risk Assessment System

The application uses threshold-based risk assessment to identify potentially abnormal sensor readings.

### Risk Thresholds

| Parameter | Risk Condition |
|---|---|
| Temperature | ≥ 85°C |
| Vibration | ≥ 7 mm/s |
| Pressure | Below 2 or above 10 bar |

### Risk Score Calculation

The risk score is calculated as:

- 40 points for each triggered risk condition.
- Additional 20 points if temperature is ≥ 95°C.
- Additional 20 points if vibration is ≥ 10 mm/s.
- Maximum score is capped at 100.

### Risk Classification

| Risk Score | Classification |
|---|---|
| 0–29 | LOW |
| 30–59 | MEDIUM |
| 60–100 | HIGH |

### Alert Generation

- LOW-risk readings are stored without generating alerts.
- MEDIUM-risk readings generate alerts.
- HIGH-risk readings generate alerts.
- When a reading is updated, its risk classification is recalculated and the corresponding alert is synchronized.
- When a reading is deleted, its associated alert is also deleted.

**Note:** Risk assessment is currently rule-based and threshold-driven. It does not use a trained machine learning model or calibrated failure probability.

## 5. MongoDB Features

The MongoDB implementation includes:

### CRUD Operations

| Operation | HTTP Method | Endpoint |
|---|---|---|
| Create sensor reading | POST | `/api/readings` |
| Retrieve sensor readings | GET | `/api/readings` |
| Update sensor reading | PATCH | `/api/readings/[id]` |
| Delete sensor reading | DELETE | `/api/readings/[id]` |

Additional functionality includes:

- MongoDB document insertion and retrieval.
- Sensor reading validation.
- ObjectId-based document identification.
- Risk recalculation after updates.
- Automatic synchronization of associated risk alerts.
- Deletion of associated alerts when readings are deleted.

### MongoDB Indexing

Compound indexes are implemented to improve query performance.

**sensor_readings**

```javascript
{ machineId: 1, recordedAt: -1 }
{ risk: 1, recordedAt: -1 }
```

**risk_alerts**

```javascript
{ risk: 1, recordedAt: -1 }
{ machineId: 1, recordedAt: -1 }
```

Index initialization script:

```text
mongodb/init.js
```

Run it using:

```bash
mongosh mongodb/init.js
```

Historical sensor readings are retained. No TTL expiration index is enabled.

## 6. Authentication and Application Security

The application implements authentication and authorization using JWT and bcrypt.

### Authentication Features

- Password verification using bcrypt.
- JWT-based session management.
- HS256 signing algorithm.
- Eight-hour token expiration.
- HTTP-only session cookies.
- SameSite cookie protection.
- Secure cookies in production.
- Logout functionality that clears the session cookie.

### Role-Based Access Control (RBAC)

Two user roles are implemented:

| Role | Permissions |
|---|---|
| Admin | Access to protected operations, including machine management and reading deletion |
| Technician | Access to permitted application operations and sensor reading management |

Administrative operations are protected using role checks.

### API Security

The application includes:

- Authentication middleware/helper functions.
- Role-based authorization checks.
- Parameterized SQL queries.
- Zod input validation.
- ObjectId validation.
- Active-user verification.
- Appropriate HTTP error responses.

### MongoDB Security Limitation

The current local development setup uses MongoDB Community Server on `localhost:27017` without username/password authentication.

Application-level authentication and authorization are implemented, but MongoDB database-level authentication and custom database user roles are not configured.

For production deployment, MongoDB authentication and a dedicated least-privilege database user should be configured. Credentials should be stored securely using environment variables.

## 7. API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/login` | Authenticate a user |
| POST | `/api/auth/logout` | End the user session |
| GET | `/api/readings` | Retrieve sensor readings |
| POST | `/api/readings` | Create a sensor reading |
| PATCH | `/api/readings/[id]` | Update a sensor reading |
| DELETE | `/api/readings/[id]` | Delete a sensor reading |
| PATCH | `/api/machines/[id]` | Update machine information (Admin) |
| DELETE | `/api/machines/[id]` | Delete machine information (Admin) |
| GET | `/api/machines` | Retrieve machines |
| GET | `/api/maintenance` | Retrieve maintenance records |
| GET | `/api/summary` | Retrieve dashboard summary |

## 8. Installation and Setup

### Prerequisites

Install the following:

- Node.js and npm
- MySQL 8
- MongoDB Community Server
- MongoDB Compass (recommended)
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/nehaha21/iot-predictive-maintenance.git
```

Navigate into the project:

```bash
cd iot-predictive-maintenance
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Configure Environment Variables

Create a `.env.local` file in the project root.

Configure the required database connection settings and authentication secrets using the variable names specified in the project's database connection files and existing environment example.

At minimum, the application uses:

```env
MONGODB_URI=mongodb://localhost:27017/industrial_maintenance
JWT_SECRET=your_long_random_secret_at_least_32_characters
```

Configure the MySQL connection variables according to `lib/db.ts`.

Do not commit `.env.local` or expose database passwords and JWT secrets.

### Step 4: Start MongoDB

Ensure that MongoDB Community Server is running locally.

Open MongoDB Compass and connect to:

```text
mongodb://localhost:27017/
```

The project uses the database:

```text
industrial_maintenance
```

### Step 5: Initialize MongoDB Indexes

From the project root, run:

```bash
mongosh mongodb/init.js
```

### Step 6: Configure MySQL

Start MySQL Server.

Create and initialize the project database using the SQL schema and setup scripts provided in the repository.

Ensure the MySQL connection settings in `.env.local` match your local configuration.

### Step 7: Start the Application

Run:

```bash
npm run dev
```

Open the application at:

```text
http://localhost:3000
```

## 9. Testing

The project includes documented test cases in:

```text
docs/TEST_CASES.md
```

Testing performed includes:

- MongoDB sensor reading creation.
- MongoDB sensor reading retrieval.
- MongoDB sensor reading updates.
- MongoDB sensor reading deletion.
- LOW-risk reading verification.
- HIGH-risk alert generation.
- MEDIUM-risk alert synchronization.
- Invalid sensor input rejection.
- Authentication and logout testing.
- Unauthorized API access testing.
- Admin and technician RBAC testing.
- MongoDB index verification.

### Verified Test Results

| Test | Expected Result | Verified Result |
|---|---|---|
| Valid LOW-risk reading | HTTP 201 | PASS |
| Valid HIGH-risk reading | HTTP 201 with alert | PASS |
| Invalid sensor input | HTTP 400 | PASS |
| Retrieve readings | HTTP 200 | PASS |
| Update reading | HTTP 200 | PASS |
| Delete reading and alert | HTTP 200 | PASS |
| Unauthenticated GET | HTTP 401 | PASS |
| Logout | HTTP 200 | PASS |
| GET after logout | HTTP 401 | PASS |
| Technician machine update | HTTP 403 | PASS |
| Technician machine deletion | HTTP 403 | PASS |

Additional test cases and their documented results are available in `docs/TEST_CASES.md`.

## 10. Project Documentation

Detailed project documentation is available in:

```text
docs/PROJECT_DOCUMENTATION.md
```

Test cases and testing results:

```text
docs/TEST_CASES.md
```

MongoDB initialization:

```text
mongodb/init.js
```

## 11. Team Contributions

The project is developed collaboratively.

### Person 1
Responsible for the relational database design and associated SQL implementation, including database schema, relationships, constraints, and SQL concepts.

### Person 2
Responsible for:

- MongoDB integration.
- Sensor reading and risk alert collections.
- MongoDB CRUD API implementation.
- MongoDB compound indexes.
- Risk alert generation and synchronization.
- JWT authentication.
- Bcrypt password verification.
- Role-based access control.
- API validation and security testing.
- MongoDB and security documentation.

## 12. Future Enhancements

Potential future improvements include:

- Integration with physical IoT sensors.
- Machine learning-based predictive maintenance.
- Failure probability estimation.
- Real-time sensor data streaming.
- Advanced analytics and visualization.
- MongoDB database-level authentication and least-privilege roles.
- Automated notifications for high-risk alerts.
- Expanded audit logging.

## 13. Conclusion

The Industrial Predictive Maintenance System demonstrates the use of relational and NoSQL databases in a single web application.

MySQL manages structured industrial information, while MongoDB handles sensor readings and dynamically generated risk alerts.

The project also demonstrates database CRUD operations, indexing, authentication, authorization, validation, and database security concepts through a practical industrial use case.

---

**Project:** Industrial Predictive Maintenance System  
**Repository:** https://github.com/nehaha21/iot-predictive-maintenance  
**Branch merged into main:** `feature/mongodb-security`
