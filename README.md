# 🎓 UniSphere ERP — University Management Database System

> **Database Systems Project** | Faculty of Computers & Information Technology | Academic Year 2025 / 2026

---

## 👥 Project Team

| Name | Student ID |
|---|---|
| **Abdullah Hossam** | 24030072 |
| **Nada Ibrahim** | 24030046 |
| **Rewan Tamer** | 24030140 |
| **Menna Ahmed** | 24030183 |

---

## 📋 Project Overview

**UniSphere ERP** is a fully relational database system designed to digitize and centralize the core academic and administrative operations of a university. The system covers:

- 🏛️ **Academic Management** — Departments, Courses, Semesters, Schedules, Enrollments
- 👨‍💼 **Human Resources** — Employees, Salary Records
- 🎓 **Student Services** — Student Profiles, GPA, Attendance, Scholarships
- 💰 **Financial Operations** — Tuition Fees, Payment Status, Outstanding Balances
- 🏫 **Facility Management** — Rooms, Capacity, Room Types
- 📝 **Examinations** — Midterm & Final Exam Scheduling

---

## 🗂️ Project Deliverables

| Deliverable | Link |
|---|---|
| 📊 **ERD Diagram** | [View ERD on diagrams.net](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&layers=1&nav=1&title=ERD.drawio&dark=1#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1uywlEpeLD5BTNmWbXMEjl49jqqhSCtlx%26export%3Ddownload) |
| 🗃️ **Schema Diagram** | [View Schema on diagrams.net](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&layers=1&nav=1&title=Schema.drawio&dark=auto#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1OlUAHVMwL-2cDfyvtwoWDI2lbDuafMic%26export%3Ddownload) |
| 💾 **SQL Code File** | [University_Management_Database_System.sql](https://drive.google.com/file/d/1Pd4sLS9lohkpEYahC4enLD6iGXbErDk6/view?usp=sharing) |
| 📄 **Proposal** | [UniSphere_ERP_Proposal.docx](./Proposal/UniSphere_ERP_Proposal.docx) |
| 🤝 **Acknowledgement** | [Acknowledgement.md](./Acknowledgement.md) |

---

## 🗄️ Database Structure

The database consists of **12 interrelated tables**:

| # | Table | Description |
|---|---|---|
| 1 | `Departments` | University departments and their deans |
| 2 | `Semesters` | Academic semesters with start and end dates |
| 3 | `Rooms` | Physical rooms with type and capacity |
| 4 | `Employees` | Academic and non-academic staff records |
| 5 | `Students` | Student personal and academic information |
| 6 | `Courses` | Course catalog linked to departments |
| 7 | `Schedule` | Class sessions linking courses, instructors, rooms, semesters |
| 8 | `Enrollments` | Student course registrations with grades and status |
| 9 | `Exams` | Midterm and final exam scheduling |
| 10 | `Fees` | Tuition fee records and payment status |
| 11 | `Scholarships` | Scholarship awards per student |
| 12 | `Attendance` | Session-level attendance records |

---

## ⚙️ Key Features

- ✅ Fully normalized schema **(3NF)**
- ✅ **12 tables** with full referential integrity via foreign keys
- ✅ **CHECK constraints** on every table (GPA range, room types, payment validation, etc.)
- ✅ **UNIQUE constraints** preventing duplicate enrollments and attendance records
- ✅ Circular FK between `Departments` ↔ `Employees` resolved via `ALTER TABLE`
- ✅ **17 analytical SQL queries** (JOINs, GROUP BY, correlated subqueries, conditional aggregation)
- ✅ **3 database views** (`vw_StudentProfile`, `vw_ActiveEnrollments`, `vw_OutstandingFees`)
- ✅ Realistic **sample data** inserted for all 12 tables

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Microsoft SQL Server (T-SQL) | Core database engine |
| SQL Server Management Studio (SSMS) | Development & query testing |
| draw.io (diagrams.net) | ERD & Schema design |
| Node.js + Express + TypeScript | Backend REST API |
| React 19 + Vite + Tailwind CSS | Frontend application |
| GitHub | Version control & hosting |

---

## 📁 Repository Structure

```
University-Database/
│
├── 📄 University_Management_Database_System.sql
├── 📄 Acknowledgement.md
├── 📄 README.md
└── 📁 Proposal/
    └── UniSphere_ERP_Proposal.docx
```

---

> Faculty of Computers & Information Technology — Academic Year 2025 / 2026
