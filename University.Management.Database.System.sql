-- ============================================================
--        University Management Database System
--        Faculty of Computers & Information Technology
--        Academic Year: 2025/2026
--        Team: Abdullah Hossam, Nada Ibrahim, Menna Ahmed, Rawan Tamer
-- ============================================================

CREATE DATABASE University;
GO

USE University;
GO

-- ============================================================
--                        TABLES
-- ============================================================

-- [1] Departments
CREATE TABLE Departments (
    DepartmentID   INT          PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL,
    DeanID         INT          -- FK added later (circular dependency)
);
GO

-- [2] Semesters
CREATE TABLE Semesters (
    SemesterID   INT         PRIMARY KEY IDENTITY(1,1),
    SemesterName VARCHAR(50) NOT NULL,
    StartDate    DATE        NOT NULL,
    EndDate      DATE        NOT NULL,
    CONSTRAINT CK_Semesters_Dates CHECK (EndDate > StartDate)
);
GO

-- [3] Rooms
CREATE TABLE Rooms (
    RoomID     INT         PRIMARY KEY IDENTITY(1,1),
    RoomNumber VARCHAR(20) NOT NULL,
    Building   VARCHAR(50) NOT NULL,
    Capacity   INT         NOT NULL,
    RoomType   VARCHAR(20) NOT NULL,
    CONSTRAINT CK_Rooms_Capacity  CHECK (Capacity > 0),
    CONSTRAINT CK_Rooms_RoomType  CHECK (RoomType IN ('Lecture', 'Lab', 'Section', 'Electronics Lab'))
);
GO

-- [4] Employees
CREATE TABLE Employees (
    EmployeeID   INT          PRIMARY KEY IDENTITY(1,1),
    FirstName    VARCHAR(50)  NOT NULL,
    LastName     VARCHAR(50)  NOT NULL,
    Email        VARCHAR(100) UNIQUE NOT NULL,
    Phone        VARCHAR(20),
    HireDate     DATE         NOT NULL,
    JobTitle     VARCHAR(50)  NOT NULL,
    StaffType    VARCHAR(20)  NOT NULL,
    DepartmentID INT,
    Salary       DECIMAL(10,2),
    CONSTRAINT CK_Employees_StaffType CHECK (StaffType IN ('Academic', 'Non-Academic')),
    CONSTRAINT CK_Employees_Salary    CHECK (Salary >= 0),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

-- [5] Students
CREATE TABLE Students (
    StudentID      INT          PRIMARY KEY IDENTITY(1,1),
    FirstName      VARCHAR(50)  NOT NULL,
    LastName       VARCHAR(50)  NOT NULL,
    Email          VARCHAR(100) UNIQUE NOT NULL,
    BirthDate      DATE,
    EnrollmentDate DATE         NOT NULL,
    DepartmentID   INT,
    GPA            DECIMAL(3,2),
    CONSTRAINT CK_Students_GPA CHECK (GPA >= 0.00 AND GPA <= 4.00),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

-- [6] Courses
CREATE TABLE Courses (
    CourseID     INT          PRIMARY KEY IDENTITY(1,1),
    CourseName   VARCHAR(100) NOT NULL,
    CreditHours  INT          NOT NULL,
    DepartmentID INT,
    CONSTRAINT CK_Courses_CreditHours CHECK (CreditHours > 0),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

-- Resolve circular dependency: Departments <-> Employees (DeanID)
ALTER TABLE Departments
ADD CONSTRAINT FK_Departments_Dean
FOREIGN KEY (DeanID) REFERENCES Employees(EmployeeID);
GO

-- [7] Schedule
CREATE TABLE Schedule (
    ScheduleID  INT         PRIMARY KEY IDENTITY(1,1),
    CourseID    INT         NOT NULL,
    EmployeeID  INT         NOT NULL,
    RoomID      INT         NOT NULL,
    SemesterID  INT         NOT NULL,
    Day_Of_Week VARCHAR(20) NOT NULL,
    StartTime   TIME        NOT NULL,
    EndTime     TIME        NOT NULL,
    CONSTRAINT CK_Schedule_Day      CHECK (Day_Of_Week IN ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')),
    CONSTRAINT CK_Schedule_Times    CHECK (EndTime > StartTime),
    FOREIGN KEY (CourseID)   REFERENCES Courses(CourseID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (RoomID)     REFERENCES Rooms(RoomID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID)
);
GO

-- [8] Enrollments
CREATE TABLE Enrollments (
    EnrollmentID INT          PRIMARY KEY IDENTITY(1,1),
    StudentID    INT          NOT NULL,
    ScheduleID   INT          NOT NULL,
    Grade        DECIMAL(5,2),
    Status       VARCHAR(20)  NOT NULL,
    CONSTRAINT CK_Enrollments_Grade  CHECK (Grade IS NULL OR (Grade >= 0 AND Grade <= 100)),
    CONSTRAINT CK_Enrollments_Status CHECK (Status IN ('Active', 'Dropped', 'Completed')),
    CONSTRAINT UQ_Enrollment         UNIQUE (StudentID, ScheduleID),   -- FIX: prevent duplicate enrollment
    FOREIGN KEY (StudentID)  REFERENCES Students(StudentID),
    FOREIGN KEY (ScheduleID) REFERENCES Schedule(ScheduleID)
);
GO

-- [9] Exams
CREATE TABLE Exams (
    ExamID     INT         PRIMARY KEY IDENTITY(1,1),
    ScheduleID INT         NOT NULL,
    ExamDate   DATE        NOT NULL,
    StartTime  TIME        NOT NULL,
    RoomID     INT         NOT NULL,
    ExamType   VARCHAR(20) NOT NULL,
    CONSTRAINT CK_Exams_ExamType CHECK (ExamType IN ('Midterm', 'Final')),
    FOREIGN KEY (ScheduleID) REFERENCES Schedule(ScheduleID),
    FOREIGN KEY (RoomID)     REFERENCES Rooms(RoomID)
);
GO

-- [10] Fees
CREATE TABLE Fees (
    FeeID      INT           PRIMARY KEY IDENTITY(1,1),
    StudentID  INT           NOT NULL,
    SemesterID INT           NOT NULL,
    Amount     DECIMAL(10,2) NOT NULL,
    PaidAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    DueDate    DATE          NOT NULL,
    Status     VARCHAR(20)   NOT NULL,
    CONSTRAINT CK_Fees_Amount     CHECK (Amount > 0),
    CONSTRAINT CK_Fees_PaidAmount CHECK (PaidAmount >= 0 AND PaidAmount <= Amount),
    CONSTRAINT CK_Fees_Status     CHECK (Status IN ('Paid', 'Partial', 'Unpaid')),
    FOREIGN KEY (StudentID)  REFERENCES Students(StudentID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID)
);
GO

-- [11] Scholarships
CREATE TABLE Scholarships (
    ScholarshipID   INT           PRIMARY KEY IDENTITY(1,1),
    StudentID       INT           NOT NULL,
    ScholarshipName VARCHAR(100)  NOT NULL,
    Amount          DECIMAL(10,2) NOT NULL,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NOT NULL,
    CONSTRAINT CK_Scholarships_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Scholarships_Dates  CHECK (EndDate > StartDate),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
GO

-- [12] Attendance
CREATE TABLE Attendance (
    AttendanceID INT         PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT         NOT NULL,
    Date         DATE        NOT NULL,
    Status       VARCHAR(20) NOT NULL,
    CONSTRAINT CK_Attendance_Status CHECK (Status IN ('Present', 'Absent', 'Late')),
    CONSTRAINT UQ_Attendance        UNIQUE (EnrollmentID, Date),   -- FIX: one record per student per day
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollments(EnrollmentID)
);
GO

-- ============================================================
--                        INSERT DATA
-- ============================================================

-- Departments (DeanID set after Employees are inserted)
INSERT INTO Departments (DepartmentName)
VALUES ('Computer Science'),
       ('Engineering'),
       ('Physical Therapy'),
       ('Business'),
       ('Art'),
       ('Nurse');
GO

-- Semesters
INSERT INTO Semesters (SemesterName, StartDate, EndDate)
VALUES ('Fall 2024',   '2025-09-01', '2025-12-31'),
       ('Spring 2025', '2026-02-01', '2026-05-31'),
       ('Summer 2025', '2026-06-01', '2026-08-31');
GO

-- Rooms
INSERT INTO Rooms (RoomNumber, Building, Capacity, RoomType)
VALUES ('A0.1', 'Computer Science', 150, 'Lecture'),
       ('A1.1', 'Computer Science', 150, 'Lecture'),
       ('A2.1', 'Computer Science', 150, 'Lecture'),
       ('B0.1', 'Computer Science',  25, 'Lab'),
       ('B0.2', 'Computer Science',  25, 'Lab'),
       ('B1.1', 'Computer Science',  25, 'Lab'),
       ('B1.2', 'Computer Science',  25, 'Lab'),
       ('B2.1', 'Computer Science',  25, 'Lab'),
       ('B2.2', 'Computer Science',  25, 'Lab'),
       ('C1.1', 'Computer Science',  25, 'Section'),
       ('C2.1', 'Computer Science',  25, 'Section'),
       ('C3.1', 'Computer Science',  25, 'Section'),
       ('C3.2', 'Computer Science',  25, 'Section'),
       ('B3.1', 'Computer Science',  25, 'Electronics Lab');
GO

-- Employees
INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, JobTitle, StaffType, DepartmentID, Salary)
VALUES ('Abdullah', 'Hossam Siam', 'ahjjkljksarfim414@gmail.com', '0155415450', '2026-04-14', 'Professor',           'Academic',     1, 13500),
       ('Ahmed',    'Hassan',      'ahmed.hassan@uni.edu',        '0101234567', '2015-09-01', 'Professor',           'Academic',     4, 15000),
       ('Sara',     'Ali',         'sara.ali@uni.edu',            '0112345678', '2018-03-15', 'Assistant Professor', 'Academic',     5, 12000),
       ('Mohamed',  'Kamal',       'mohamed.kamal@uni.edu',       '0123456789', '2020-01-10', 'Lecturer',            'Academic',     6, 10000),
       ('Nour',     'Ibrahim',     'nour.ibrahim@uni.edu',        '0134567890', '2019-06-01', 'Professor',           'Academic',     3, 15000),
       ('Omar',     'Samir',       'omar.samir@uni.edu',          '0145678901', '2017-11-20', 'Dean',                'Academic',     1, 20000),
       ('Mona',     'Fathy',       'mona.fathy@uni.edu',          '0156789012', '2016-08-05', 'Dean',                'Academic',     2, 20000),
       ('Khaled',   'Mostafa',     'khaled.mostafa@uni.edu',      '0167890123', '2021-02-14', 'HR Manager',          'Non-Academic', NULL, 8100),
       ('Hana',     'Youssef',     'hana.youssef@uni.edu',        '0178901234', '2022-05-01', 'Security',            'Non-Academic', NULL, 4100);
GO

-- Assign Deans to Departments
UPDATE Departments SET DeanID = 6 WHERE DepartmentID = 1;  -- Omar Samir -> CS
UPDATE Departments SET DeanID = 7 WHERE DepartmentID = 2;  -- Mona Fathy -> Engineering
GO

-- Students
INSERT INTO Students (FirstName, LastName, Email, BirthDate, EnrollmentDate, DepartmentID, GPA)
VALUES ('Abdullah', 'Hossam Siam', 'abdullahhossam414@gmail.com', '2006-04-14', '2024-07-15', 1, 2.39),
       ('Ali',      'Mohamed',     'ali.mohamed@uni.edu',         '2002-05-10', '2022-09-01', 1, 3.50),
       ('Nada',     'Ahmed',       'nada.ahmed@uni.edu',          '2003-01-15', '2022-09-01', 2, 3.20),
       ('Omar',     'Khaled',      'omar.khaled@uni.edu',         '2001-11-20', '2021-09-01', 3, 2.90),
       ('Laila',    'Hassan',      'laila.hassan@uni.edu',        '2002-07-08', '2022-09-01', 4, 3.75),
       ('Youssef',  'Ali',         'youssef.ali@uni.edu',         '2003-03-25', '2023-09-01', 5, 3.10),
       ('Mariam',   'Samir',       'mariam.samir@uni.edu',        '2002-09-14', '2022-09-01', 1, 3.60),
       ('Karim',    'Ibrahim',     'karim.ibrahim@uni.edu',       '2001-06-30', '2021-09-01', 2, 2.80),
       ('Dina',     'Mostafa',     'dina.mostafa@uni.edu',        '2003-12-05', '2023-09-01', 3, 3.90),
       ('Tamer',    'Youssef',     'tamer.youssef@uni.edu',       '2002-02-18', '2022-09-01', 4, 3.40),
       ('Salma',    'Fathy',       'salma.fathy@uni.edu',         '2003-08-22', '2023-09-01', 6, 3.55);
GO

-- Courses
INSERT INTO Courses (CourseName, CreditHours, DepartmentID)
VALUES ('Database Systems',        3, 1),
       ('Data Structures',         3, 1),
       ('Operating Systems',       3, 1),
       ('Circuit Analysis',        3, 2),
       ('Thermodynamics',          3, 2),
       ('Human Anatomy',           3, 3),
       ('Physical Rehabilitation', 3, 3),
       ('Financial Accounting',    3, 4),
       ('Marketing Principles',    3, 4),
       ('Drawing Fundamentals',    3, 5),
       ('Nursing Ethics',          3, 6);
GO

-- Schedule
INSERT INTO Schedule (CourseID, EmployeeID, RoomID, SemesterID, Day_Of_Week, StartTime, EndTime)
VALUES ( 1, 1,  1, 1, 'Sunday',    '08:00', '10:00'),
       ( 2, 1,  1, 1, 'Monday',    '10:00', '12:00'),
       ( 3, 2,  2, 1, 'Tuesday',   '08:00', '10:00'),
       ( 4, 3,  3, 1, 'Wednesday', '10:00', '12:00'),
       ( 5, 4,  4, 2, 'Thursday',  '08:00', '10:00'),
       ( 6, 5,  5, 2, 'Sunday',    '12:00', '14:00'),
       ( 7, 5,  6, 2, 'Monday',    '08:00', '10:00'),
       ( 8, 2,  7, 3, 'Tuesday',   '10:00', '12:00'),
       ( 9, 3,  8, 3, 'Wednesday', '08:00', '10:00'),
       (10, 6,  9, 1, 'Thursday',  '10:00', '12:00'),
       (11, 7, 10, 2, 'Sunday',    '08:00', '10:00');
GO

-- Enrollments
INSERT INTO Enrollments (StudentID, ScheduleID, Grade, Status)
VALUES ( 1,  1, 85.00, 'Active'),
       ( 1,  2, 90.00, 'Active'),
       ( 2,  1, 78.00, 'Active'),
       ( 2,  3, 88.00, 'Active'),
       ( 3,  4, 72.00, 'Active'),
       ( 4,  5, 95.00, 'Active'),
       ( 5,  6, 65.00, 'Active'),
       ( 6,  7, 80.00, 'Active'),
       ( 7,  8, 70.00, 'Completed'),
       ( 8,  9, 92.00, 'Completed'),
       ( 9, 10, 55.00, 'Dropped'),
       (10, 11, 88.00, 'Active'),
       (11,  1, 76.00, 'Active');
GO

-- Exams (covers all 11 schedules with Midterm + Final)
INSERT INTO Exams (ScheduleID, ExamDate, StartTime, RoomID, ExamType)
VALUES ( 1, '2025-12-10', '09:00',  1, 'Midterm'),
       ( 2, '2025-12-11', '09:00',  2, 'Midterm'),
       ( 3, '2025-12-12', '09:00',  3, 'Midterm'),
       ( 4, '2025-12-13', '09:00',  4, 'Midterm'),
       ( 5, '2025-12-14', '09:00',  5, 'Midterm'),
       ( 6, '2025-12-15', '09:00',  6, 'Midterm'),
       ( 7, '2025-12-16', '09:00',  7, 'Midterm'),
       ( 8, '2025-12-17', '09:00',  8, 'Midterm'),
       ( 9, '2025-12-18', '09:00',  9, 'Midterm'),
       (10, '2025-12-19', '09:00', 10, 'Midterm'),
       (11, '2025-12-20', '09:00', 11, 'Midterm'),
       ( 1, '2026-01-10', '09:00',  1, 'Final'),
       ( 2, '2026-01-11', '09:00',  2, 'Final'),
       ( 3, '2026-01-12', '09:00',  3, 'Final'),
       ( 4, '2026-01-13', '09:00',  4, 'Final'),
       ( 5, '2026-01-14', '09:00',  5, 'Final'),
       ( 6, '2026-01-15', '09:00',  6, 'Final'),
       ( 7, '2026-01-16', '09:00',  7, 'Final'),
       ( 8, '2026-01-17', '09:00',  8, 'Final'),
       ( 9, '2026-01-18', '09:00',  9, 'Final'),
       (10, '2026-01-19', '09:00', 10, 'Final'),
       (11, '2026-01-20', '09:00', 11, 'Final');
GO

-- Fees
INSERT INTO Fees (StudentID, SemesterID, Amount, PaidAmount, DueDate, Status)
VALUES ( 1, 1, 15000.00, 15000.00, '2025-10-01', 'Paid'),
       ( 2, 1, 15000.00, 10000.00, '2025-10-01', 'Partial'),
       ( 3, 1, 15000.00,     0.00, '2025-10-01', 'Unpaid'),
       ( 4, 2, 15000.00, 15000.00, '2026-03-01', 'Paid'),
       ( 5, 2, 15000.00, 15000.00, '2026-03-01', 'Paid'),
       ( 6, 2, 15000.00,  5000.00, '2026-03-01', 'Partial'),
       ( 7, 1, 15000.00, 15000.00, '2025-10-01', 'Paid'),
       ( 8, 3, 15000.00,     0.00, '2026-07-01', 'Unpaid'),
       ( 9, 1, 15000.00, 15000.00, '2025-10-01', 'Paid'),
       (10, 2, 15000.00, 15000.00, '2026-03-01', 'Paid'),
       (11, 3, 15000.00,  7500.00, '2026-07-01', 'Partial');
GO

-- Scholarships
INSERT INTO Scholarships (StudentID, ScholarshipName, Amount, StartDate, EndDate)
VALUES ( 1, 'Excellence Scholarship', 5000.00, '2024-09-01', '2025-06-30'),
       ( 2, 'Merit Scholarship',      3000.00, '2022-09-01', '2023-06-30'),
       ( 4, 'Need Based Scholarship', 2000.00, '2022-09-01', '2023-06-30'),
       ( 8, 'Excellence Scholarship', 5000.00, '2021-09-01', '2022-06-30'),
       ( 9, 'Sports Scholarship',     1500.00, '2023-09-01', '2024-06-30'),
       (11, 'Merit Scholarship',      3000.00, '2023-09-01', '2024-06-30');
GO

-- Attendance
INSERT INTO Attendance (EnrollmentID, Date, Status)
VALUES ( 1, '2025-09-05', 'Present'),
       ( 1, '2025-09-12', 'Present'),
       ( 1, '2025-09-19', 'Absent'),
       ( 2, '2025-09-05', 'Present'),
       ( 2, '2025-09-12', 'Late'),
       ( 2, '2025-09-19', 'Present'),
       ( 3, '2025-09-05', 'Present'),
       ( 3, '2025-09-12', 'Present'),
       ( 3, '2025-09-19', 'Present'),
       ( 4, '2025-09-05', 'Absent'),
       ( 4, '2025-09-12', 'Present'),
       ( 4, '2025-09-19', 'Late'),
       ( 5, '2025-09-05', 'Present'),
       ( 5, '2025-09-12', 'Present'),
       ( 5, '2025-09-19', 'Present'),
       ( 6, '2025-09-05', 'Late'),
       ( 6, '2025-09-12', 'Present'),
       ( 6, '2025-09-19', 'Absent'),
       ( 7, '2025-09-05', 'Present'),
       ( 7, '2025-09-12', 'Present'),
       ( 8, '2025-09-05', 'Present'),
       ( 8, '2025-09-19', 'Late'),
       ( 9, '2025-09-05', 'Absent'),
       ( 9, '2025-09-12', 'Present'),
       (10, '2025-09-05', 'Present'),
       (10, '2025-09-12', 'Present'),
       (11, '2025-09-05', 'Present'),
       (11, '2025-09-19', 'Present'),
       (12, '2025-09-05', 'Late'),
       (13, '2025-09-05', 'Present');
GO

-- ============================================================
--                        QUERIES
-- ============================================================

-- Q1: All students ordered by GPA ascending
SELECT FirstName, LastName, GPA
FROM Students
ORDER BY GPA ASC;

-- Q2: Students with their department name
SELECT S.FirstName, S.LastName, D.DepartmentID, D.DepartmentName
FROM Students S
JOIN Departments D ON S.DepartmentID = D.DepartmentID;

-- Q3: Students with unpaid fees
SELECT S.StudentID, S.FirstName, S.LastName, F.Status AS FeeStatus
FROM Students S
JOIN Fees F ON S.StudentID = F.StudentID
WHERE F.Status = 'Unpaid';

-- Q4: Employees with their department name
SELECT E.EmployeeID, E.FirstName, E.LastName, D.DepartmentName
FROM Employees E
JOIN Departments D ON E.DepartmentID = D.DepartmentID;

-- Q5: Employees and the courses they teach (by department match)
SELECT E.EmployeeID, E.FirstName, E.LastName, C.CourseName
FROM Employees E
JOIN Courses C ON E.DepartmentID = C.DepartmentID;

-- Q6: Average GPA per department
SELECT D.DepartmentName, AVG(S.GPA) AS AvgGPA
FROM Students S
JOIN Departments D ON S.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY AvgGPA DESC;

-- Q7: Full schedule details (course + instructor + room + semester)
SELECT
    SC.ScheduleID,
    C.CourseName,
    E.FirstName + ' ' + E.LastName AS InstructorName,
    R.RoomNumber,
    R.Building,
    SE.SemesterName,
    SC.Day_Of_Week,
    SC.StartTime,
    SC.EndTime
FROM Schedule SC
JOIN Courses   C  ON SC.CourseID   = C.CourseID
JOIN Employees E  ON SC.EmployeeID = E.EmployeeID
JOIN Rooms     R  ON SC.RoomID     = R.RoomID
JOIN Semesters SE ON SC.SemesterID = SE.SemesterID;

-- Q8: Students enrolled in each course with their grade
SELECT
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    EN.Grade,
    EN.Status AS EnrollmentStatus
FROM Enrollments EN
JOIN Students S  ON EN.StudentID  = S.StudentID
JOIN Schedule SC ON EN.ScheduleID = SC.ScheduleID
JOIN Courses  C  ON SC.CourseID   = C.CourseID
ORDER BY C.CourseName, EN.Grade DESC;

-- Q9: Attendance summary per student (Present / Absent / Late counts)
SELECT
    S.FirstName + ' ' + S.LastName AS StudentName,
    SUM(CASE WHEN A.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
    SUM(CASE WHEN A.Status = 'Absent'  THEN 1 ELSE 0 END) AS AbsentCount,
    SUM(CASE WHEN A.Status = 'Late'    THEN 1 ELSE 0 END) AS LateCount
FROM Attendance A
JOIN Enrollments EN ON A.EnrollmentID = EN.EnrollmentID
JOIN Students    S  ON EN.StudentID   = S.StudentID
GROUP BY S.StudentID, S.FirstName, S.LastName
ORDER BY AbsentCount DESC;

-- Q10: Exam schedule with room and course details
SELECT
    EX.ExamType,
    EX.ExamDate,
    EX.StartTime,
    C.CourseName,
    R.RoomNumber,
    R.Building,
    SE.SemesterName
FROM Exams EX
JOIN Schedule  SC ON EX.ScheduleID = SC.ScheduleID
JOIN Courses   C  ON SC.CourseID   = C.CourseID
JOIN Rooms     R  ON EX.RoomID     = R.RoomID
JOIN Semesters SE ON SC.SemesterID = SE.SemesterID
ORDER BY EX.ExamDate;

-- Q11: Students with scholarships and scholarship details
SELECT
    S.FirstName + ' ' + S.LastName AS StudentName,
    SC.ScholarshipName,
    SC.Amount,
    SC.StartDate,
    SC.EndDate
FROM Scholarships SC
JOIN Students S ON SC.StudentID = S.StudentID;

-- Q12: Fee payment status with remaining balance
SELECT
    S.FirstName + ' ' + S.LastName AS StudentName,
    SE.SemesterName,
    F.Amount,
    F.PaidAmount,
    (F.Amount - F.PaidAmount) AS RemainingAmount,
    F.Status
FROM Fees F
JOIN Students  S  ON F.StudentID  = S.StudentID
JOIN Semesters SE ON F.SemesterID = SE.SemesterID
ORDER BY F.Status, RemainingAmount DESC;

-- Q13: Number of students per department
SELECT D.DepartmentName, COUNT(S.StudentID) AS StudentCount
FROM Departments D
LEFT JOIN Students S ON D.DepartmentID = S.DepartmentID
GROUP BY D.DepartmentName
ORDER BY StudentCount DESC;

-- Q14: Instructors and how many courses they are assigned to teach
SELECT
    E.FirstName + ' ' + E.LastName AS InstructorName,
    E.JobTitle,
    COUNT(SC.ScheduleID) AS CoursesAssigned
FROM Employees E
LEFT JOIN Schedule SC ON E.EmployeeID = SC.EmployeeID
WHERE E.StaffType = 'Academic'
GROUP BY E.EmployeeID, E.FirstName, E.LastName, E.JobTitle
ORDER BY CoursesAssigned DESC;

-- Q15: Students with GPA above department average
SELECT S.FirstName, S.LastName, S.GPA, D.DepartmentName
FROM Students S
JOIN Departments D ON S.DepartmentID = D.DepartmentID
WHERE S.GPA > (
    SELECT AVG(S2.GPA)
    FROM Students S2
    WHERE S2.DepartmentID = S.DepartmentID
)
ORDER BY S.GPA DESC;

-- Q16: Total salary cost per staff type
SELECT StaffType, COUNT(*) AS EmployeeCount, SUM(Salary) AS TotalSalary, AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY StaffType;

-- Q17: Room utilization - how many classes are scheduled per room
SELECT R.RoomNumber, R.Building, R.RoomType, COUNT(SC.ScheduleID) AS ScheduledClasses
FROM Rooms R
LEFT JOIN Schedule SC ON R.RoomID = SC.RoomID
GROUP BY R.RoomID, R.RoomNumber, R.Building, R.RoomType
ORDER BY ScheduledClasses DESC;

-- ============================================================
--                        VIEWS
-- ============================================================

-- View 1: Full student academic profile
CREATE VIEW vw_StudentProfile AS
SELECT
    S.StudentID,
    S.FirstName + ' ' + S.LastName AS FullName,
    S.Email,
    D.DepartmentName,
    S.GPA,
    S.EnrollmentDate
FROM Students S
JOIN Departments D ON S.DepartmentID = D.DepartmentID;
GO

-- View 2: Active enrollments with course and student info
CREATE VIEW vw_ActiveEnrollments AS
SELECT
    EN.EnrollmentID,
    S.FirstName + ' ' + S.LastName AS StudentName,
    C.CourseName,
    SE.SemesterName,
    EN.Grade,
    EN.Status
FROM Enrollments EN
JOIN Students  S  ON EN.StudentID  = S.StudentID
JOIN Schedule  SC ON EN.ScheduleID = SC.ScheduleID
JOIN Courses   C  ON SC.CourseID   = C.CourseID
JOIN Semesters SE ON SC.SemesterID = SE.SemesterID
WHERE EN.Status = 'Active';
GO

-- View 3: Students with outstanding fee balances
CREATE VIEW vw_OutstandingFees AS
SELECT
    S.FirstName + ' ' + S.LastName AS StudentName,
    SE.SemesterName,
    F.Amount,
    F.PaidAmount,
    (F.Amount - F.PaidAmount) AS Balance,
    F.DueDate,
    F.Status
FROM Fees F
JOIN Students  S  ON F.StudentID  = S.StudentID
JOIN Semesters SE ON F.SemesterID = SE.SemesterID
WHERE F.Status IN ('Partial', 'Unpaid');
GO

-- ============================================================
--          VERIFY ALL TABLES (SELECT *)
-- ============================================================
SELECT * FROM Departments;
SELECT * FROM Semesters;
SELECT * FROM Rooms;
SELECT * FROM Employees;
SELECT * FROM Students;
SELECT * FROM Courses;
SELECT * FROM Schedule;
SELECT * FROM Enrollments;
SELECT * FROM Exams;
SELECT * FROM Fees;
SELECT * FROM Scholarships;
SELECT * FROM Attendance;
GO