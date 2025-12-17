# SQL 基础语法对比：Oracle vs Snowflake

## 培训学员信息
- 姓名：郑章乐
- 日期：2025-12-16
- 任务：Day 02 - SQL 语法对比练习

---

## 1. 基础查询语法

### 1.1 FROM 子句差异

**Oracle：**
```sql
-- Oracle 需要 DUAL 表来执行无表查询
SELECT SYSDATE FROM DUAL;
SELECT 1 + 1 FROM DUAL;
SELECT USER FROM DUAL;
```

**Snowflake：**
```sql
-- Snowflake 不需要 DUAL 表
SELECT CURRENT_TIMESTAMP();
SELECT 1 + 1;
SELECT CURRENT_USER();
```


| 功能     | Oracle | Snowflake | 差异          |
|--------|--------|-----------|-------------|
| 伪表dual | `SELECT 1 FROM DUAL` | `SELECT 1` | oracle 需要伪表 |
---

## 2. 日期和时间函数

### 2.1 获取当前时间

| 功能 | Oracle | Snowflake | 差异             |
|------|--------|-----------|----------------|
| 当前日期 | `SYSDATE` | `CURRENT_TIMESTAMP()` | 有时区差异          |
| 当前时间戳 | `SYSTIMESTAMP` | `CURRENT_TIMESTAMP()` | Snowflake 精度更高 |

**示例对比：**
```sql
-- Oracle
SELECT SYSDATE,           -- 2025-01-17 10:53:02
FROM DUAL;

-- Snowflake
SELECT CURRENT_TIMESTAMP(),      -- 2025-12-16 17:53:03.085 -0800
```

### 2.2 日期计算

| 功能    | Oracle | Snowflake | 差异                       |
|-------|--------|-----------|--------------------------|
| 修改天数  | `SELECT SYSDATE + 7 FROM DUAL` | `SELECT DATEADD(day, 7, CURRENT_DATE)` | oracle能够直接加减             |
| 修改月/年 | `SELECT ADD_MONTHS(SYSDATE, 3) FROM DUAL` | `SELECT DATEADD(year, 1, CURRENT_DATE)` | snowflake通过参数指定修改对象，写法统一 |

**Oracle：**
```sql
-- 加减天数：直接 +/- 数字
SELECT SYSDATE + 7 ,
       SYSDATE - 30 
FROM DUAL;

-- 加减月份/年份：使用 ADD_MONTHS
SELECT ADD_MONTHS(SYSDATE, 3) 
FROM DUAL;
```

**Snowflake：**
```sql
-- 使用 DATEADD 函数，第一个参数指定日/月/年
SELECT DATEADD(DAY, 7, CURRENT_DATE()),
       DATEADD(DAY, -30, CURRENT_DATE()),
       DATEADD(MONTH, 3, CURRENT_DATE());

```

---

## 3. 字符串处理

### 3.1 字符串拼接

**Oracle：**
```sql
-- 使用 || 运算符
SELECT 'Hello' || ' ' || 'World' AS greeting FROM DUAL;
-- 结果：Hello World

-- 使用 CONCAT 函数（仅支持两个参数）
SELECT CONCAT('Hello', 'World') AS greeting FROM DUAL;
-- 结果：HelloWorld
```

**Snowflake：**
```sql
-- 使用 || 运算符（推荐）
SELECT 'Hello' || ' ' || 'World' AS greeting;
-- 结果：Hello World

-- 使用 CONCAT 函数（支持多个参数）
SELECT CONCAT('Hello', ' ', 'World') AS greeting;
-- 结果：Hello World
```

**差异总结：**
- Snowflake 的 `CONCAT` 函数支持多个参数，而一般的sql中的只支持两个
- 推荐使用 `||` 运算符迁移项目，避免`CONCAT`多层嵌套

### 3.2 字符串截取

**Oracle：**
```sql
SELECT SUBSTR('Snowflake', 1, 4) AS result FROM DUAL;
-- 结果：Snow（索引从 1 开始）
```

**Snowflake：**
```sql
SELECT SUBSTR('Snowflake', 1, 4) AS result;
-- 结果：Snow（索引从 1 开始）

-- 也支持 SUBSTRING（标准 SQL）
SELECT SUBSTRING('Snowflake', 1, 4) AS result;
-- 结果：Snow
```

**差异总结：**
- 无明显差异

---

## 4. NULL 处理

### 4.1 NULL 值替换

**Oracle：**
```sql
-- 使用 NVL（Oracle 特有）
SELECT NVL(commission, 0) AS commission FROM employees;

-- 使用 COALESCE（标准 SQL）
SELECT COALESCE(commission, 0) AS commission FROM employees;
```

**Snowflake：**
```sql
-- 推荐使用 COALESCE（标准 SQL）
SELECT COALESCE(commission, 0) AS commission FROM employees;

-- 也支持 IFNULL（MySQL 兼容）
SELECT IFNULL(commission, 0) AS commission FROM employees;

-- 也支持 NVL（Oracle 兼容）
SELECT NVL(commission, 0) AS commission FROM employees;
```

**迁移建议：**
- 将 Oracle 的 `NVL` 替换为 `COALESCE`（更标准）
- Snowflake 也支持 `NVL`，但推荐使用 `COALESCE`

---

## 5. 分页与行号

### 5.1 Pagination & Row Number

| 函数           | Oracle | Snowflake |
|--------------|--------|-----------|
| ROWNUM       | 支持     | 不支持       |
| ROW_NUMBER() | 支持     | 支持        |
| LIMIT/OFFSET | 12c+   | 原生        |

**Oracle：**
```sql
--传统写法
SELECT *
FROM (
  SELECT *
  FROM employees
  ORDER BY employee_id
)
WHERE ROWNUM <= 10;

```

**Snowflake：**
```sql

SELECT *
FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 10;

```

**迁移建议：**
- 统一改成 ROW_NUMBER() 或 LIMIT/OFFSET

---

## 6. 序列与自增列

### 6.1 Sequence vs Identity


| 差异        | Oracle   | Snowflake |
|-----------|----------|-----------|
| 默认方式      | Sequence | Identity  |
| 'NEXTVAL' | 表达式      | 表达式       |
| 事务回滚      | 不回退      | 不回退       |
| 顺序保证      | 强        | 弱(并行)     |

**Oracle：**
```sql
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;

INSERT INTO employees (id, name)
VALUES (emp_seq.NEXTVAL, 'Tom');

```

**snowflake(identity列)：**
```sql
CREATE TABLE employees (
  id INTEGER AUTOINCREMENT,
  name STRING
);

```

**snowflake(Sequence)：**
```sql
CREATE SEQUENCE emp_seq;

INSERT INTO employees
VALUES (emp_seq.NEXTVAL, 'Tom');


```

**迁移建议：**
- OLTP 风格 → Identity
- 需要兼容旧代码 → Sequence

---

## 7. 事务行为

### 7.1 Transaction Behavior


| 功能        | Oracle | Snowflake |
|-----------|--------|-------|
| 自动提交      | ❌      | ✅     |
| SAVEPOINT | ✅      | ❌     |
| 回滚粒度      | 精细     | 粗     |
| OLTP 支持      | 强      | 弱     |

**迁移建议：**
- Snowflake 不适合复杂事务逻辑

---

## 8. DDL行为


| 功能        | Oracle | Snowflake |
|-----------|--------|-----------|
| DDL 自动提交      | ✅      | ❌         |
| DDL 可回滚 | ❌      | ✅         |
| 混合 DDL/DML      | 危险     | 安全        |

**Oracle：**
```sql

--Oracle：DDL = 自动提交
INSERT INTO t VALUES (1);
CREATE TABLE test (id INT);
ROLLBACK;
--插入 不会回滚

```

**Snowflake：**
```sql
--Snowflake：DDL 是事务性的
BEGIN;
CREATE TABLE test (id INT);
ROLLBACK;
--表 不会被创建
```
**迁移建议：**
- DDL/DML 脚本在 Snowflake 更安全，但逻辑需重审

---

## 9. 存储过程 / 函数

**Oracle：**
```sql

--Oracle（PL/SQL）
CREATE OR REPLACE PROCEDURE calc_bonus(p_id NUMBER) AS
BEGIN
  UPDATE employees SET bonus = salary * 0.1 WHERE id = p_id;
END;

--强过程化
--大量业务逻辑在 DB
--游标 / 循环 / 异常

```

**Snowflake：**
```sql
--SQL Procedure（有限）
CREATE OR REPLACE PROCEDURE calc_bonus(p_id INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
  UPDATE employees SET bonus = salary * 0.1 WHERE id = :p_id;
  RETURN 'OK';
$$;

--JavaScript Procedure（主流）
LANGUAGE JAVASCRIPT
```
**迁移建议：**
- 80% PL/SQL 需要下沉到应用层