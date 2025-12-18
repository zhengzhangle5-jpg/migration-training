CREATE TABLE oracle_result AS
SELECT emp_id, emp_name, dept_name, org_level, total_amount, amt_rank
FROM (
SELECT *
   FROM (
   SELECT e.emp_id,
   e.emp_name,
   DECODE(e.department_id, 10, 'Admin', 20, 'Sales', 'Other') AS dept_name,
   LEVEL AS org_level,
   NVL(SUM(o.amount), 0) AS total_amount,
   ADD_MONTHS(TRUNC(SYSDATE), 3) AS review_date,
   RANK() OVER (ORDER BY NVL(SUM(o.amount),0) DESC) AS amt_rank
   FROM emp_oracle e
   LEFT JOIN orders_oracle o
   ON e.emp_id = o.emp_id
   WHERE TRUNC(o.order_date(+)) >= ADD_MONTHS(TRUNC(SYSDATE), -6)
   START WITH e.manager_id IS NULL
   CONNECT BY PRIOR e.emp_id = e.manager_id
   GROUP BY e.emp_id,
   e.emp_name,
   e.department_id,
   LEVEL
   ORDER BY amt_rank
   )
   WHERE ROWNUM <= 3;
);

CREATE OR REPLACE TEMP TABLE sf_result AS
SELECT emp_id, emp_name, dept_name, org_level, total_amount, amt_rank
FROM (
WITH RECURSIVE emp_hierarchy AS (
   SELECT emp_id,
   emp_name,
   manager_id,
   department_id,
   1 AS org_level
   FROM emp_sf
   WHERE manager_id IS NULL


   UNION ALL


   SELECT e.emp_id,
   e.emp_name,
   e.manager_id,
   e.department_id,
   h.org_level + 1
   FROM emp_sf e
   JOIN emp_hierarchy h
   ON e.manager_id = h.emp_id
   ),


   agg AS (
   SELECT h.emp_id,
   h.emp_name,
   CASE h.department_id
   WHEN 10 THEN 'Admin'
   WHEN 20 THEN 'Sales'
   ELSE 'Other'
   END AS dept_name,
   h.org_level,
   COALESCE(SUM(o.amount), 0) AS total_amount
   FROM emp_hierarchy h
   LEFT JOIN orders_sf o
   ON h.emp_id = o.emp_id
   AND o.order_date >= DATEADD(month, -6, DATE_TRUNC('month', CURRENT_DATE()))
   GROUP BY h.emp_id, h.emp_name, h.department_id, h.org_level
   )


   SELECT emp_id,
   emp_name,
   dept_name,
   org_level,
   total_amount,
   DATEADD(month, 3, DATE_TRUNC('day', CURRENT_DATE())) AS review_date,
   RANK() OVER (ORDER BY total_amount DESC) AS amt_rank
   FROM agg
   QUALIFY amt_rank <= 3
   ORDER BY amt_rank;
);

SELECT * FROM oracle_result
MINUS
SELECT * FROM sf_result;