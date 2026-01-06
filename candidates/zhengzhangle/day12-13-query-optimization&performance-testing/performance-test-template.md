# Performance Test Template

## 测试信息
- 测试人：郑章乐
- 测试日期：2026-01-06
- 测试环境：Snowflake X-Small Warehouse
- 测试目的：通过典型慢查询场景，分析 Snowflake 查询执行特性并验证优化手段效果

---

## 1. 数据库设计概述

本次测试使用统一的分析型模型，核心表包括：

- users（1,000 行）
- departments（4 行）
- orders（≈1,000,000 行，后期扩容）
- order_items（≈150,000 行）
- products（500 行）
- categories（3 行）
- payments（≈50,000 行）

该模型覆盖了典型的事实表 + 维度表结构，适用于 JOIN、聚合与子查询场景。

---

## 2. 测试场景说明

### 场景 1：复杂多表 JOIN（7 表）

**目的**  
验证多表 JOIN 在 Snowflake 中的执行效率及 JOIN 顺序、过滤条件位置对性能的影响。

#### 原始查询

```sql
SELECT
    o.order_id,
    u.user_name,
    d.department_name,
    p.product_name,
    c.category_name,
    pay.pay_amount
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE pay.status = 'SUCCESS';
```

#### 优化后查询

```sql
SELECT
    o.order_id,
    u.user_name,
    d.department_name,
    p.product_name,
    c.category_name,
    pay.pay_amount
FROM orders o
JOIN payments pay
  ON o.order_id = pay.order_id
 AND pay.status = 'SUCCESS'   -- 过滤条件前移
JOIN users u ON o.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id;
```

#### 优化点分析

- 将高选择性的过滤条件提前到 JOIN 阶段，减少中间结果集
- 利用 Snowflake 自动 JOIN 重排能力
- 减少无效数据参与后续 JOIN

#### 性能对比（X-Small）

| 版本 | 执行时间 | Rows Produced |
|---|---|---|
| 原始 | ≈ 8.1 s | 4,500,000 |
| 优化 | ≈ 6.6 s | 4,500,000 |


**图示：**
---
![](origin-1.png)
---
![](fixed-1.png)
---

### 场景 2：大数据量聚合（GROUP BY + COUNT / SUM）

**目的**  
验证高基数聚合在 Snowflake 中的性能瓶颈，以及通过两阶段聚合进行优化。

#### 原始查询（慢查询）

```sql
SELECT
    u.user_id,
    u.status,
    d.department_name,
    o.order_date,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.order_amount * 1.07) AS total_amount
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id
WHERE o.order_date >= DATEADD(MONTH, -12, CURRENT_DATE)
GROUP BY
    u.user_id,
    u.status,
    d.department_name,
    o.order_date
HAVING SUM(o.order_amount) > 1000;
```

#### 优化后查询（两阶段聚合）

```sql
WITH order_agg AS (
    SELECT
        o.user_id,
        o.order_date,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(o.order_amount * 1.07) AS total_amount
    FROM orders o
    WHERE o.order_date >= DATEADD(MONTH, -12, CURRENT_DATE)
    GROUP BY o.user_id, o.order_date
    HAVING SUM(o.order_amount) > 1000
)
SELECT
    oa.user_id,
    u.status,
    d.department_name,
    oa.order_date,
    oa.order_count,
    oa.total_amount
FROM order_agg oa
JOIN users u ON oa.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id;
```

#### 优化点分析

- 将高基数 GROUP BY 从 4 列降低为 2 列
- 在事实表层完成主要聚合，减少 JOIN 后聚合压力
- 显著减少聚合阶段计算复杂度

#### 性能对比（X-Small）

| 版本 | 执行时间 | Rows Produced |
|---|---|---|
| 原始 | ≈ 1.05 s | 73,000 |
| 优化 | ≈ 0.78 s | 73,000 |

> 结论：在当前数据规模下，Snowflake 已接近物理下限，优化收益有限但可观。

**图示：**
---
![](origin-2.png)
---
![](fixed-2.png)

---

### 场景 3：嵌套子查询（Subquery）

**目的**  
验证 Snowflake 对子查询的自动优化能力。

#### 原始查询

```sql
SELECT
    u.user_id,
    u.user_name,
    u.department_id
FROM users u
WHERE u.user_id IN (
    SELECT o.user_id
    FROM orders o
    WHERE o.order_amount > 4000
      AND o.order_date >= DATEADD(MONTH, -12, CURRENT_DATE)
);
```

#### 优化后查询（JOIN 改写）

```sql
SELECT DISTINCT
    u.user_id,
    u.user_name,
    u.department_id
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.order_amount > 4000
  AND o.order_date >= DATEADD(MONTH, -12, CURRENT_DATE);
```

#### 优化点分析

- 消除嵌套子查询，提升可读性
- 执行计划等价（Semi Join）
- 性能差异极小，体现 Snowflake 自动优化能力

#### 性能对比

| 版本 | 执行时间 | Rows Produced |
|---|---|---|
| 原始 | ≈ 0.64 s | 1,000 |
| 优化 | ≈ 0.50 s | 1,000 |

**图示：**
---
![](origin-3.png)
---
![](fixed-3.png)

---

## 3. 总体结论

1. Snowflake 在多表 JOIN 和子查询场景中具备强大的自动优化能力
2. 对于大数据量聚合，优化空间主要来自于 **降低 GROUP BY 基数**
3. 在数据量较小或可完全内存化的场景中，性能瓶颈往往来自 CPU 聚合而非 I/O
4. Query Profile 是判断是否“还能继续优化”的关键依据

---

## 4. 建议

- 对高频复杂聚合场景，可考虑物化视图
- 高并发环境下建议使用 Multi-Cluster Warehouse
- 不建议过度追求 SQL 微优化，应关注数据规模与资源配置匹配

---

**文档状态：完成**
