USE it_operations_db;

-- ========================================================
-- 1. TRANSLATION LAYER FOR DIMENSION TABLES
-- ========================================================

-- View: v_dim_projects (Translates Dim_Proyectos)
CREATE OR REPLACE VIEW v_dim_projects AS
SELECT 
    Proyecto_ID AS project_id,
    Nombre_Proyecto AS project_name,
    Cliente AS client_name,
    SLA_Bug_Minutos AS qa_sla_minutes,
    SLA_Uptime_Goal AS uptime_sla_percentage
FROM Dim_Proyectos;

-- View: v_dim_employees (Translates Dim_Empleados)
CREATE OR REPLACE VIEW v_dim_employees AS
SELECT 
    Empleado_ID AS employee_id,
    Nombre_Empleado AS employee_name,
    Rol AS technical_role,
    Region AS offshore_region,
    Costo_Hora AS hourly_cost_usd
FROM Dim_Empleados;

-- ========================================================
-- 2. TRANSLATION LAYER FOR FACT TABLES
-- ========================================================

-- View: v_fact_timesheets (Translates Fact_Tiempos)
CREATE OR REPLACE VIEW v_fact_timesheets AS
SELECT 
    Tiempo_ID AS timesheet_id,
    Fecha AS log_date,
    Empleado_ID AS employee_id,
    Proyecto_ID AS project_id,
    Horas_Facturadas AS billable_hours
FROM Fact_Tiempos;

-- View: v_fact_bugs (Translates Fact_Bugs)
CREATE OR REPLACE VIEW v_fact_bugs AS
SELECT 
    Bug_ID AS bug_id,
    Proyecto_ID AS project_id,
    Reporter_ID AS qa_reporter_id,
    Developer_ID AS dev_owner_id,
    Entorno AS environment_tier,
    Severidad AS severity_level,
    Fecha_Creacion AS created_timestamp,
    Tiempo_Resolucion_Minutos AS resolution_time_minutes,
    Horas_Retrabajo AS dev_rework_hours
FROM Fact_Bugs;

-- View: v_fact_infrastructure_logs (Translates Fact_Alertas_Servidor)
CREATE OR REPLACE VIEW v_fact_infrastructure_logs AS
SELECT 
    Alerta_ID AS alert_id,
    Proyecto_ID AS project_id,
    Componente AS infrastructure_component,
    Tipo_Alerta AS alert_type,
    Fecha_Alerta AS triggered_timestamp,
    Downtime_Minutos AS system_downtime_minutes,
    Minutos_Hasta_Resolucion AS mttr_minutes,
    Asignado_A AS assigned_engineer_id
FROM Fact_Alertas_Servidor;

-- Testing the English analytics layer
SELECT * FROM v_dim_projects 
LIMIT 5;
