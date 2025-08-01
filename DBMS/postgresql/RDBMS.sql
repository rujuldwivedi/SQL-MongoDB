-- Schema with constraints & relationships
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dept_id INT REFERENCES departments(dept_id),
    salary NUMERIC(10,2) CHECK (salary > 0),
    manager_id INT REFERENCES employees(emp_id)
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    budget NUMERIC(12,2)
);

CREATE TABLE employee_project (
    emp_id INT REFERENCES employees(emp_id),
    project_id INT REFERENCES projects(project_id),
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id)
);

-- Insert data
INSERT INTO departments (name) VALUES ('Engineering'), ('HR'), ('Marketing');

INSERT INTO employees (name, dept_id, salary, manager_id) VALUES
('Alice', 1, 90000, NULL),
('Bob', 1, 75000, 1),
('Charlie', 2, 65000, NULL),
('Diana', 3, 70000, NULL);

INSERT INTO projects (title, budget) VALUES
('Alpha', 100000),
('Beta', 50000);

INSERT INTO employee_project (emp_id, project_id, hours_worked) VALUES
(1, 1, 30),
(2, 1, 20),
(2, 2, 10),
(3, 2, 25);

-- Inner Join: Employees with departments
SELECT e.name, d.name AS department
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Left Join: Projects and assigned employees
SELECT p.title, e.name
FROM projects p
LEFT JOIN employee_project ep ON p.project_id = ep.project_id
LEFT JOIN employees e ON ep.emp_id = e.emp_id;

-- Self Join: Managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Transaction block
BEGIN;
UPDATE employees SET salary = salary * 1.1 WHERE dept_id = 1;
COMMIT;

-- Locking & Isolation
BEGIN;
SELECT * FROM employees WHERE dept_id = 1 FOR UPDATE;
COMMIT;

-- Set isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT COUNT(*) FROM employees;
COMMIT;

-- View
CREATE VIEW high_earners AS
SELECT name, salary FROM employees WHERE salary > 80000;

-- Index
CREATE INDEX idx_emp_salary ON employees(salary);

-- Window Function: Running total
SELECT name, salary,
       SUM(salary) OVER (PARTITION BY dept_id ORDER BY salary) AS dept_salary_total
FROM employees;

-- CTE
WITH avg_salaries AS (
    SELECT dept_id, AVG(salary) AS avg_salary FROM employees GROUP BY dept_id
)
SELECT e.name, e.salary, a.avg_salary
FROM employees e
JOIN avg_salaries a ON e.dept_id = a.dept_id;