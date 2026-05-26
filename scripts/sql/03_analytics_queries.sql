-- Analysis of QA efficiency and financial impact of bug leakage
WITH project_rework_costs AS (
    SELECT 
        b.project_id,
        -- Calculate total bugs found in Production vs total bugs found everywhere
        COUNT(CASE WHEN b.environment_tier = 'PRODUCTION' THEN 1 END) AS production_bugs,
        COUNT(b.bug_id) AS total_bugs,
        -- Calculate total financial loss due to rework hours multiplied by developer cost
        ROUND(SUM(b.dev_rework_hours * e.hourly_cost_usd), 2) AS total_rework_cost_usd,
        AVG(b.resolution_time_minutes) AS avg_resolution_time_minutes
    FROM v_fact_bugs b
    JOIN v_dim_employees e ON b.dev_owner_id = e.employee_id
    GROUP BY b.project_id
)
SELECT 
    p.project_name,
    p.client_name,
    r.total_bugs,
    r.production_bugs,
    -- Defect Leakage Rate Formula: (Production Bugs / Total Bugs) * 100
    ROUND((r.production_bugs / r.total_bugs) * 100, 2) AS defect_leakage_rate_pct,
    r.total_rework_cost_usd,
    ROUND(r.avg_resolution_time_minutes, 1) AS avg_resolution_time_minutes
FROM project_rework_costs r
JOIN v_dim_projects p ON r.project_id = p.project_id
ORDER BY defect_leakage_rate_pct DESC;


-- Analysis of engineer resource utilization and cost efficiency per region
WITH employee_utilization AS (
    SELECT 
        t.employee_id,
        e.employee_name,
        e.technical_role,
        e.offshore_region,
        SUM(t.billable_hours) AS total_hours_logged,
        -- Assuming a standard baseline of 640 available working hours for the 4-month period
        ROUND((SUM(t.billable_hours) / 640.0) * 100, 2) AS utilization_rate_pct,
        ROUND(SUM(t.billable_hours) * e.hourly_cost_usd, 2) AS total_revenue_generated_usd
    FROM v_fact_timesheets t
    JOIN v_dim_employees e ON t.employee_id = e.employee_id
    GROUP BY t.employee_id, e.employee_name, e.technical_role, e.offshore_region
)
SELECT 
    employee_name,
    technical_role,
    offshore_region,
    utilization_rate_pct,
    total_revenue_generated_usd,
    -- Rank employees inside each region based on their financial revenue generation
    RANK() OVER(PARTITION BY offshore_region ORDER BY total_revenue_generated_usd DESC) AS revenue_rank_in_region
FROM employee_utilization
ORDER BY offshore_region, revenue_rank_in_region;


-- Infrastructure incident log tracking SLA breaches and platform downtime
WITH infra_metrics AS (
    SELECT 
        log.project_id,
        COUNT(CASE WHEN log.alert_type = 'CRITICAL_DOWN' THEN 1 END) AS critical_down_incidents,
        SUM(log.system_downtime_minutes) AS total_downtime_minutes,
        -- Calculate average response time for engineering triage
        AVG(CASE WHEN log.alert_type != 'INFO' THEN log.mttr_minutes END) AS mean_time_to_resolution_mttr,
        -- Total minutes in the 4-month simulation timeline (~172,800 minutes total)
        172800 AS total_period_minutes
    FROM v_fact_infrastructure_logs log
    GROUP BY log.project_id
)
SELECT 
    p.project_name,
    p.uptime_sla_percentage AS contractual_sla_goal,
    -- Real Uptime Formula: ((Total Period Minutes - Downtime Minutes) / Total Period Minutes) * 100
    ROUND(((m.total_period_minutes - m.total_downtime_minutes) / m.total_period_minutes) * 100, 4) AS actual_uptime_pct,
    m.critical_down_incidents,
    ROUND(m.mean_time_to_resolution_mttr, 1) AS mttr_minutes,
    -- Flag if the project breached the contractual SLA agreement
    CASE 
        WHEN ROUND(((m.total_period_minutes - m.total_downtime_minutes) / m.total_period_minutes) * 100, 4) < p.uptime_sla_percentage 
        THEN 'BREACHED' 
        ELSE 'COMPLIANT' 
    END AS sla_status
FROM infra_metrics m
JOIN v_dim_projects p ON m.project_id = p.project_id
ORDER BY actual_uptime_pct ASC;



