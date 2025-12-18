**练习 1**: 转换 DECODE
   ```sql
   -- Oracle
   SELECT employee_id,
          DECODE(department_id, 10, 'Admin', 20, 'Sales', 'Other') AS dept_name
   FROM employees;

   -- 改写为 Snowflake (请在此处填写)
   SELECT employee_id,
          CASE department_id
               WHEN 10 THEN 'Admin'
               WHEN 20 THEN 'Sales'
               ELSE 'Other'
          END AS dept_name
   FROM employees;
   ```

   **练习 2**: 转换 ROWNUM
   ```sql
   -- Oracle: 查询前 10 条记录
   SELECT * FROM orders WHERE ROWNUM <= 10;

   -- 改写为 Snowflake (请在此处填写)
   SELECT *
   FROM orders
   LIMIT 10;
   ```

   **练习 3**: 转换 ADD_MONTHS
   ```sql
   -- Oracle: 计算 3 个月后的日期
   SELECT order_id, ADD_MONTHS(order_date, 3) AS due_date
   FROM orders;

   -- 改写为 Snowflake (请在此处填写)
   SELECT order_id,
          DATEADD(month, 3, order_date) AS due_date
   FROM orders;
   ```

   **练习 4**: 转换 CONNECT BY（挑战）
   ```sql
   -- Oracle: 查询组织层级
   SELECT employee_id, manager_id, LEVEL
   FROM employees
   START WITH manager_id IS NULL
   CONNECT BY PRIOR employee_id = manager_id;

   -- 改写为 Snowflake 递归 CTE (请在此处填写)
   WITH RECURSIVE emp_hierarchy AS (
       -- 起始层（等价 START WITH）
       SELECT employee_id,
              manager_id,
              1 AS level
       FROM employees
       WHERE manager_id IS NULL

       UNION ALL

       -- 递归层（等价 CONNECT BY）
       SELECT e.employee_id,
              e.manager_id,
              h.level + 1 AS level
       FROM employees e
       JOIN emp_hierarchy h
         ON e.manager_id = h.employee_id
   )
   SELECT *
   FROM emp_hierarchy;

   **练习 5**: 综合转换
   -- oracle原始查询
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
        AND TRUNC(o.order_date) >= ADD_MONTHS(TRUNC(SYSDATE), -6)
       START WITH e.manager_id IS NULL
       CONNECT BY PRIOR e.emp_id = e.manager_id
       GROUP BY e.emp_id,
                e.emp_name,
                e.department_id,
                LEVEL
       ORDER BY amt_rank
   )
   WHERE ROWNUM <= 3;


   -- snowflake等价查询
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