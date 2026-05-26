# IT Operations & SLA Compliance Command Center
An End-to-End Enterprise Data Engineering and Business Intelligence Case Study addressing Software Quality Assurance (QA) Technical Debt, Infrastructure Vulnerabilities, and Offshore Resource Constraints.

## 📌 Executive Summary
This project simulates a real-world enterprise crisis: a global IT delivery organization experiencing critical operational anomalies, cost overruns, and systemic contractual SLA breaches. As a combined Software QA professional and Data Analyst, I built a robust, end-to-end analytical pipeline to diagnose and solve these bottlenecks. 

By generating an interdependent relational dataset in Python, structuring an optimized Star Schema in MySQL, abstracting complexity via strategic SQL Views, and engineering a premium double-page dashboard in Power BI, this project uncovers the true root cause of the organization's bleeding: a vicious technical debt loop where developers spend more billable time fixing critical QA leakage than building core platform stability.

## 🛠️ Skills & Tech Stack Demonstrated
* **Advanced Data Engineering & Simulation:** Python (Pandas, NumPy) for programmatic generation of coherent, multi-table transactional relational data with real-world logical constraints.
* **Database Modeling & Architecture:** MySQL Workbench, Star Schema design, implementation of Primary/Foreign Key constraints, data type normalization, and indexing.
* **Analytical SQL (Data Abstraction):** Common Table Expressions (CTEs), Window Functions, complex relational, and data translation into enterprise-ready English views.
* **Advanced Business Intelligence & DAX:** Power BI Desktop, custom corporate Dark Mode UI/UX themes, advanced context manipulation, and dynamic project scaling.
* **Data-to-Value Storytelling:** Translating dry technical log entries into a valuable and meaningful dashboard.

## 📐 Methodology & Project Architecture
The project follows a rigorous, industry-standard data lifecycle split into four major integrated layers:

* **Layer 1: Programmatic Python Generation:** Automated script generating multi-table transactional relational data files, ensuring exact business-logic constraints.
* **Layer 2: MySQL Relational Storage:** Database structure containing transactional data, executing analytical queries, and validating structural behavior.
* **Layer 3: Semantic Data Views:** Production of standard SQL Views to rename technical elements into business terms and prepare clean inputs for Power BI ingestion.
* **Layer 4: Interactive BI Interface:** Designing a specialized front-end dashboard with direct color mapping linked to business urgency (Red = Alerts/Losses, Cyan/Teal = Efficiencies).

## 💼 Business Problem
The organization is facing a massive financial and operational crisis. Despite steady billable client hours, platform uptimes across multiple high-profile projects have plummeted below contractual agreements, triggering severe SLA penalties. 

Executive leadership lacks visibility into why infrastructure components are failing, how QA defect leakage to production environments affects financial bottom lines, and how offshore engineering resources are allocated. The overarching business objective is to transition from firefighting technical incidents to data-driven operational predictability.

## 🗂️ Data Dictionary & Relationship Structure
The data model consists of core analytical views designed to optimize performance and data isolation:
* **`v_dim_projects`:** Catalog of client accounts, contracted uptime targets, and regional project owners.
* **`v_dim_employees`:** Corporate employee registry tracking name, offshore region (LATAM, India, Europe), technical role, and hourly cost in USD.
* **`v_fact_bugs`:** Detailed technical bug log tracking `bug_id`, development rework hours, environment tier (`Dev`, `QA`, `UAT`, `Production`), and severity level (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`).
* **`v_fact_infrastructure_logs`:** System monitoring logs tracking infrastructure components, incident alerts (`CRITICAL_DOWN`, `WARNING_SPIKE`, `INFO`), and exact downtime durations.

### 🔗 Model Relationship Map

<img width="793" height="636" alt="model-view" src="https://github.com/user-attachments/assets/d7db7f96-8098-43a9-afd1-5503c26d8070" />

The analytical front-end is bound by a highly tailored Star Schema:
* `v_dim_projects` filters `v_fact_bugs` and `v_fact_infrastructure_logs` via a 1:N relationship on `project_id`.
* `v_dim_employees` filters `v_fact_bugs` via a 1:N relationship on `qa_reporter_id` (Active relation).
* `v_dim_employees` connects to `v_fact_bugs` via a secondary inactive relation on `dev_owner_id` (Activated virtually using senior DAX expressions).

## 🔍 Insights & Business Questions

<img width="1403" height="792" alt="IT Operations   SLA Compliance Command Center" src="https://github.com/user-attachments/assets/e2cb4251-8ca6-4cfc-a51d-6a13c3511f31" />

### 📊 IT Operations & SLA Compliance Command Center (Executive View)
* **Business Questions:**
  1. What is the total financial capital deployed across overall operations vs. the isolated cost of technical debt and development rework?
  2. Which specific IT infrastructure components are acting as the single points of failure dragging down contract metrics?
  3. How does global platform uptime perform when measured against contracted SLA metrics across parallel timelines?
* **Consolidated Insight:** The data uncovers a staggering operational anomaly: out of a total **$2.78M USD** in overall operational investment, an overwhelming **$1.75M USD** is completely consumed by **Rework Cost USD**. This proves that nearly 63% of the entire engineering workforce's capacity is burned on fixing broken code rather than driving platform innovation. 
  
  Furthermore, isolating infrastructure alerts shows that the `Database` and `Frontend UI` components are the primary drivers of system downtime, pushing the company’s global uptime average down to a failing **95.62%** against an aggressive contracted average target of **99.61%**. Concurrently, resource utilization across regions sits at a tight **~80%**, proving that teams are fully loaded but heavily bogged down by this defect leakage.

### 👥 QA Engineering & Ticket Analytics (Operational View)

<img width="1403" height="791" alt="qa-engineering-ticket-analytics" src="https://github.com/user-attachments/assets/41ab836e-82a0-4f16-b8cc-963ada0a3843" />

* **Business Questions:**
  4. What is the True Mean-Time-To-Resolution (MTTR) when breaking down engineering turnaround times by project and severity levels?
  5. In which deployment environment tier is technical debt concentrating most heavily before release, and who are the top developers impacted by rework costs?
  6. Are regional offshore resource utilization rates balanced across active delivery hubs, or are certain teams reaching high-burnout thresholds?
* **Consolidated Insight:**
  By mapping an advanced **Turnaround Time Matrix**, the dashboard reveals that while `CRITICAL` bugs are handled with lightning urgency (~138 minutes), low and medium severity tickets are trapped in an operational backlog, averaging an astronomical **1,694 minutes** to resolve. 
  
  The **Technical Debt Treemap** demonstrates strong defensive QA barriers: **$1.14M USD** of rework is caught early within the internal `QA` environment tier. However, a dangerous **$240K USD** leaked directly into `PRODUCTION`, acting as the core driver behind the critical infrastructure failures and client SLA breaches. 

## 🚀 Results & Data-Driven Recommendations

Based on the empirical findings surfaced across the analytical ecosystem, the following strategic remediation plan was established:

### 1. SLA Rescue Framework
* **Action:** Immediate infrastructure modernization targeting the `Database` and `Frontend UI` stacks. Implement automated load-balancers and high-availability database clustering.
* **Impact:** Eliminating these localized single points of failure will recover an estimated 32,000 minutes of system downtime, instantly pulling the Global Platform Uptime from **95.62% back above the 99.5% contractual SLA line**, saving millions in potential legal and financial penalties.

### 2. Resource Optimization & Mentoring
* **Action:** Address the extreme workload concentration observed in the "Top Developers by Rework Impact" visualization. Codebases managed by the highest-impact engineers must be modularized and peer-reviewed.
* **Impact:** By redistributing highly complex modules across senior staff and introducing pair programming, the business mitigates single-person dependency risks and prevents severe burnout in key offshore delivery hubs.

### 3. QA Guardrails & Deployment Gates (Defect Leakage Mitigation)
* **Action:** Institute a hard deployment gate at the CI/CD pipeline level. No software release can move from the `UAT` tier into `PRODUCTION` if the project’s local Defect Leakage Rate exceeds a **10% maximum threshold** (currently averaging **14.76%**).
* **Impact:** Forcing the resolution of technical debt in lower environments will drastically decrease the $240K production loss margin, ensuring that billable hours are spent on high-margin client deliverables rather than internal unbillable hotfixes.
