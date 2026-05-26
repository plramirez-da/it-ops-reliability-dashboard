import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Configuración de reproducibilidad
np.random.seed(42)

# ==========================================
# 1. TABLAS DE DIMENSIONES
# ==========================================

# Dim_Proyectos
proyectos_data = {
    'Proyecto_ID': [f'PRJ-{i:03d}' for i in range(1, 11)],
    'Nombre_Proyecto': ['Alpha Core', 'Beta Mobile', 'Gamma Cloud', 'Delta Security', 'Epsilon Data', 
                        'Zeta Web', 'Eta DevOps', 'Theta Portal', 'Iota Integration', 'Kappa CRM'],
    'Cliente': ['Global Bank', 'Telco Corp', 'HealthInc', 'LogiTrans', 'EduTech', 'RetailGiant', 'FinPrime', 'InsurCo', 'EnergySys', 'SmartGov'],
    'SLA_Bug_Minutos': [240, 180, 120, 60, 180, 240, 120, 180, 60, 120], # Tiempo límite resolución bug crítico
    'SLA_Uptime_Goal': [99.5, 99.9, 99.9, 99.99, 99.5, 99.0, 99.9, 99.5, 99.95, 99.0] # % Uptime contractual
}
df_proyectos = pd.DataFrame(proyectos_data)

# Dim_Empleados
roles = ['QA Engineer', 'Automation QA', 'DevOps Engineer', 'SRE Engineer', 'Software Developer', 'Data Analyst']
regiones = ['LATAM', 'INDIA', 'EUROPE']
costos_por_rol = {'QA Engineer': 35, 'Automation QA': 45, 'DevOps Engineer': 55, 'SRE Engineer': 60, 'Software Developer': 50, 'Data Analyst': 40}

empleados_data = []
for i in range(1, 51): # 50 empleados distribuidos globalmente
    rol = np.random.choice(roles)
    region = np.random.choice(regiones)
    costo = costos_por_rol[rol]
    # Ajuste de costo por región
    if region == 'LATAM': costo *= 0.85
    elif region == 'INDIA': costo *= 0.65
    
    empleados_data.append({
        'Empleado_ID': f'EMP-{i:03d}',
        'Nombre_Empleado': f'Ingeniero_{i}',
        'Rol': rol,
        'Region': region,
        'Costo_Hora': round(costo, 2)
    })
df_empleados = pd.DataFrame(empleados_data)

# ==========================================
# 2. TABLAS DE HECHOS (FACT TABLES)
# ==========================================
fecha_inicio = datetime(2026, 1, 1)
dias_simulacion = 120 # ~4 meses de datos diarios

# --- FACT 1: Fact_Tiempos (~12,000 registros) ---
# Simula las horas diarias que cada empleado carga a los proyectos
tiempos_list = []
for dia in range(dias_simulacion):
    current_date = fecha_inicio + timedelta(days=dia)
    if current_date.weekday() < 5: # Solo días laborables
        for emp_id in df_empleados['Empleado_ID']:
            # Cada empleado puede trabajar en 1 o 2 proyectos al día
            num_proyectos = np.random.choice([1, 2], p=[0.7, 0.3])
            projs = np.random.choice(df_proyectos['Proyecto_ID'], size=num_proyectos, replace=False)
            
            if num_proyectos == 1:
                tiempos_list.append({
                    'Tiempo_ID': len(tiempos_list) + 1,
                    'Fecha': current_date.strftime('%Y-%m-%d'),
                    'Empleado_ID': emp_id,
                    'Proyecto_ID': projs[0],
                    'Horas_Facturadas': 8.0
                })
            else:
                tiempos_list.append({
                    'Tiempo_ID': len(tiempos_list) + 1,
                    'Fecha': current_date.strftime('%Y-%m-%d'),
                    'Empleado_ID': emp_id,
                    'Proyecto_ID': projs[0],
                    'Horas_Facturadas': 4.0
                })
                tiempos_list.append({
                    'Tiempo_ID': len(tiempos_list) + 2,
                    'Fecha': current_date.strftime('%Y-%m-%d'),
                    'Empleado_ID': emp_id,
                    'Proyecto_ID': projs[1],
                    'Horas_Facturadas': 4.0
                })
df_fact_tiempos = pd.DataFrame(tiempos_list)

# --- FACT 2: Fact_Bugs (~2,500 registros) ---
bugs_list = []
qa_empleados = df_empleados[df_empleados['Rol'].str.contains('QA')]['Empleado_ID'].values
dev_empleados = df_empleados[df_empleados['Rol'] == 'Software Developer']['Empleado_ID'].values

for i in range(1, 2501):
    proj = np.random.choice(df_proyectos['Proyecto_ID'])
    entorno = np.random.choice(['QA', 'UAT', 'PRODUCTION'], p=[0.65, 0.20, 0.15]) # 15% Defect Leakage
    severidad = np.random.choice(['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'], p=[0.1, 0.25, 0.45, 0.2])
    
    # Tiempos de resolución lógicos basados en severidad (en minutos)
    if severidad == 'CRITICAL': res_time = np.random.randint(30, 240)
    elif severidad == 'HIGH': res_time = np.random.randint(120, 720)
    else: res_time = np.random.randint(480, 2880)
    
    # Calcular horas invertidas en corregir el bug (Rework Hours)
    rework_hours = round(res_time / 60 * np.random.uniform(0.5, 1.2), 2)
    
    fecha_bug = fecha_inicio + timedelta(days=np.random.randint(0, dias_simulacion), hours=np.random.randint(8, 18))
    
    bugs_list.append({
        'Bug_ID': f'BUG-{i:04d}',
        'Proyecto_ID': proj,
        'Reporter_ID': np.random.choice(qa_empleados),
        'Developer_ID': np.random.choice(dev_empleados),
        'Entorno': entorno,
        'Severidad': severidad,
        'Fecha_Creacion': fecha_bug.strftime('%Y-%m-%d %H:%M:%S'),
        'Tiempo_Resolucion_Minutos': res_time,
        'Horas_Retrabajo': rework_hours
    })
df_fact_bugs = pd.DataFrame(bugs_list)

# --- FACT 3: Fact_Alertas_Servidor (~15,000 registros de logs e infraestructura) ---
alertas_list = []
devops_sre = df_empleados[df_empleados['Rol'].isin(['DevOps Engineer', 'SRE Engineer'])]['Empleado_ID'].values
componentes = ['Database', 'API Gateway', 'Frontend UI', 'Auth Service', 'Load Balancer']

for i in range(1, 15001):
    proj = np.random.choice(df_proyectos['Proyecto_ID'])
    componente = np.random.choice(componentes)
    tipo_alerta = np.random.choice(['CRITICAL_DOWN', 'WARNING_SPIKE', 'INFO'], p=[0.08, 0.22, 0.70])
    
    fecha_alerta = fecha_inicio + timedelta(days=np.random.randint(0, dias_simulacion), 
                                           hours=np.random.randint(0, 24), 
                                           minutes=np.random.randint(0, 60))
    
    # Calcular MTTR (Mean Time to Resolution) para alertas no-INFO
    if tipo_alerta == 'CRITICAL_DOWN':
        downtime_minutos = np.random.randint(5, 120)
        mttr = downtime_minutos + np.random.randint(5, 30) # Tiempo de reacción técnica
    elif tipo_alerta == 'WARNING_SPIKE':
        downtime_minutos = 0 # No se cae el sistema, solo hay lentitud
        mttr = np.random.randint(15, 180)
    else:
        downtime_minutos = 0
        mttr = 0
        
    alertas_list.append({
        'Alerta_ID': f'ALT-{i:05d}',
        'Proyecto_ID': proj,
        'Componente': componente,
        'Tipo_Alerta': tipo_alerta,
        'Fecha_Alerta': fecha_alerta.strftime('%Y-%m-%d %H:%M:%S'),
        'Downtime_Minutos': downtime_minutos,
        'Minutos_Hasta_Resolucion': mttr,
        'Asignado_A': np.random.choice(devops_sre) if mttr > 0 else 'SYSTEM_AUTO'
    })
df_fact_alertas = pd.DataFrame(alertas_list)

# ==========================================
# 3. EXPORTAR A CSV
# ==========================================
df_proyectos.to_csv('Dim_Proyectos.csv', index=False)
df_empleados.to_csv('Dim_Empleados.csv', index=False)
df_fact_tiempos.to_csv('Fact_Tiempos.csv', index=False)
df_fact_bugs.to_csv('Fact_Bugs.csv', index=False)
df_fact_alertas.to_csv('Fact_Alertas_Servidor.csv', index=False)

print("¡Archivos CSV generados con éxito!")
print(f"Registros de Tiempos: {len(df_fact_tiempos)}")
print(f"Registros de Bugs: {len(df_fact_bugs)}")
print(f"Registros de Alertas: {len(df_fact_alertas)}")