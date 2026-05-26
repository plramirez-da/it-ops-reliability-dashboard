-- Create the database schema if it doesn't exist
CREATE DATABASE IF NOT EXISTS it_operations_db;
USE it_operations_db;

-- ========================================================
-- 1. DIMENSION TABLES (Master Data & Context)
-- ========================================================

-- Table: Dim_Proyectos (Project and Client Meta-data)
CREATE TABLE Dim_Proyectos (
    Proyecto_ID VARCHAR(10) PRIMARY KEY, -- Unique project identifier
    Nombre_Proyecto VARCHAR(50) NOT NULL, -- Internal project code name
    Cliente VARCHAR(50) NOT NULL,        -- Global corporate client name
    SLA_Bug_Minutos INT,                 -- Contractual SLA resolution time for critical bugs (in minutes)
    SLA_Uptime_Goal DECIMAL(5,2)         -- Contractual platform availability target percentage (e.g., 99.90)
);

-- Table: Dim_Empleados (Global Engineering Resources)
CREATE TABLE Dim_Empleados (
    Empleado_ID VARCHAR(10) PRIMARY KEY, -- Unique employee identifier (e.g., EMP-001)
    Nombre_Empleado VARCHAR(50) NOT NULL, -- Employee resource name
    Rol VARCHAR(50) NOT NULL,             -- Technical specialization (QA, DevOps, Developer, SRE, Data Analyst)
    Region VARCHAR(15) NOT NULL,          -- Offshore delivery hub location (LATAM, INDIA, EUROPE)
    Costo_Hora DECIMAL(6,2) NOT NULL      -- Internal hourly cost rate in USD (adjusted by regional baseline)
);

-- ========================================================
-- 2. FACT TABLES (Transactional & Event Data)
-- ========================================================

-- Table: Fact_Tiempos (Timesheet & Resource Capacity Utilization)
CREATE TABLE Fact_Tiempos (
    Tiempo_ID INT PRIMARY KEY,            -- Unique sequential transaction ID
    Fecha DATE NOT NULL,                  -- Date of the logged working hours (YYYY-MM-DD)
    Empleado_ID VARCHAR(10),              -- Resource identifier (FK to Dim_Empleados)
    Proyecto_ID VARCHAR(10),              -- Targeted project identifier (FK to Dim_Proyectos)
    Horas_Facturadas DECIMAL(4,2),        -- Total billable hours logged on this date for this project
    FOREIGN KEY (Empleado_ID) REFERENCES Dim_Empleados(Empleado_ID),
    FOREIGN KEY (Proyecto_ID) REFERENCES Dim_Proyectos(Proyecto_ID)
);

-- Table: Fact_Bugs (Quality Assurance & Defect Tracking Log)
CREATE TABLE Fact_Bugs (
    Bug_ID VARCHAR(10) PRIMARY KEY,       -- Unique Jira/ticket identifier (e.g., BUG-0001)
    Proyecto_ID VARCHAR(10),              -- Project where the defect was found (FK to Dim_Proyectos)
    Reporter_ID VARCHAR(10),              -- QA Engineer who discovered and logged the defect (FK to Dim_Empleados)
    Developer_ID VARCHAR(10),             -- Software Developer assigned to fix the defect (FK to Dim_Empleados)
    Entorno VARCHAR(20),                  -- Environment breakthrough tier (QA, UAT, PRODUCTION)
    Severidad VARCHAR(15),                -- Business impact triage (CRITICAL, HIGH, MEDIUM, LOW)
    Fecha_Creacion DATETIME,              -- Exact timestamp when the ticket was opened
    Tiempo_Resolucion_Minutos INT,       -- Total turnaround time until the defect was verified and closed
    Horas_Retrabajo DECIMAL(6,2),         -- Developer hours invested in writing the fix (Used for Cost of Quality)
    FOREIGN KEY (Proyecto_ID) REFERENCES Dim_Proyectos(Proyecto_ID),
    FOREIGN KEY (Reporter_ID) REFERENCES Dim_Empleados(Empleado_ID),
    FOREIGN KEY (Developer_ID) REFERENCES Dim_Empleados(Empleado_ID)
);

-- Table: Fact_Alertas_Servidor (Infrastructure Logs & Site Reliability Logs)
CREATE TABLE Fact_Alertas_Servidor (
    Alerta_ID VARCHAR(10) PRIMARY KEY,     -- Unique automated log trace identifier (e.g., ALT-00001)
    Proyecto_ID VARCHAR(10),              -- Client infrastructure environment affected (FK to Dim_Proyectos)
    Componente VARCHAR(30),               -- Technical layer affected (Database, API Gateway, Frontend UI, etc.)
    Tipo_Alerta VARCHAR(20),              -- Event severity categorization (INFO, WARNING_SPIKE, CRITICAL_DOWN)
    Fecha_Alerta DATETIME,                -- System timestamp when the event triggered
    Downtime_Minutos INT,                 -- System offline duration in minutes (Only triggers for CRITICAL_DOWN)
    Minutos_Hasta_Resolucion INT,         -- Mean Time to Resolution (MTTR) metrics in minutes
    Asignado_A VARCHAR(15),               -- DevOps/SRE Engineer ID handling the triage, or SYSTEM_AUTO
    FOREIGN KEY (Proyecto_ID) REFERENCES Dim_Proyectos(Proyecto_ID)
);

-- Audit query to verify successful ingestion and row counts across all modules
SELECT 'Dim_Proyectos' AS target_table, COUNT(*) AS total_rows_ingested FROM Dim_Proyectos
UNION
SELECT 'Dim_Empleados', COUNT(*) FROM Dim_Empleados
UNION
SELECT 'Fact_Tiempos', COUNT(*) FROM Fact_Tiempos
UNION
SELECT 'Fact_Bugs', COUNT(*) FROM Fact_Bugs
UNION
SELECT 'Fact_Alertas_Servidor', COUNT(*) FROM Fact_Alertas_Servidor;