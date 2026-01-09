# Oracle → Snowflake 迁移常见坑点手册  
**Day15 Migration Pitfalls Handbook**

---

## Part 1：SQL 语法坑点（10 个）

| 坑点 | Oracle 写法 | 错误的 Snowflake 写法 | 正确的 Snowflake 写法 | 说明 |
|---|---|---|---|---|
| ROWNUM | `WHERE ROWNUM <= 10` | 原样照搬 | `LIMIT 10` / `QUALIFY ROW_NUMBER() <= 10` | Snowflake 不支持 ROWNUM |
| NVL | `NVL(col,0)` | 原样照搬 | `COALESCE(col,0)` | Snowflake 不支持 NVL |
| DECODE | `DECODE(a,1,'Y','N')` | 原样照搬 | `CASE WHEN a=1 THEN 'Y' ELSE 'N' END` | 需改为 CASE |
| SYSDATE | `SYSDATE` | 原样照搬 | `CURRENT_DATE()` / `CURRENT_TIMESTAMP()` | 时间函数不同 |
| DUAL | `SELECT 1 FROM DUAL` | 使用 DUAL | `SELECT 1` | Snowflake 无 DUAL |
| MERGE 语法 | Oracle MERGE | 直接照搬 | Snowflake MERGE（语法略不同） | 关键字顺序不同 |
| CONNECT BY | 层级查询 | 原样照搬 | `WITH RECURSIVE` | Snowflake 不支持 CONNECT BY |
| (+) 外连接 | `A.col = B.col(+)` | 原样照搬 | `LEFT JOIN` | 已废弃语法 |
| TRUNC(date) | `TRUNC(dt)` | 原样照搬 | `DATE_TRUNC('DAY', dt)` | 函数差异 |
| MINUS | `A MINUS B` | 原样照搬 | `A EXCEPT B` | 关键字不同 |

---

## Part 2：数据类型坑点（5 个）

1. **NUMBER 精度**
   - Oracle：`NUMBER` → 默认高精度  
   - Snowflake：`NUMBER` → 默认 `NUMBER(38,0)`  
   ❗ 易丢失小数位

2. **DATE 类型**
   - Oracle DATE 含时分秒  
   - Snowflake DATE 仅日期  

3. **TIMESTAMP**
   - Oracle TIMESTAMP 无时区  
   - Snowflake 默认 `TIMESTAMP_NTZ`  

4. **VARCHAR2**
   - Oracle 使用 VARCHAR2  
   - Snowflake 使用 VARCHAR  

5. **空字符串**
   - Oracle：'' = NULL  
   - Snowflake：'' ≠ NULL  

---

## Part 3：性能优化坑点（6 个）

1. **索引不存在**
   - Oracle：B-Tree / Bitmap Index  
   - Snowflake：无传统索引  
   → 使用 Clustering Key

2. **Hint 无效**
   - Oracle Hint 在 Snowflake 中被忽略  

3. **UPDATE 成本高**
   - Snowflake 更适合 INSERT + CTAS  

4. **全表扫描**
   - Snowflake 可接受但需控制扫描量  

5. **JOIN 顺序**
   - Snowflake 自动优化 JOIN  

6. **集群键（Clustering Key）优化**
   - 使用集群键优化时，需要多次执行才能达到最大效果

---

## Part 4：JDBC 连接坑点（3 个）

1. **URL 参数缺失**
   - 必须包含 db / schema / warehouse  

2. **大小写问题**
   - Snowflake 默认大写对象名  

3. **Session 参数**
   - 未设置 TIMEZONE / QUERY_TAG  

---

---

**作者**：郑章乐  
**日期**：2026-01-09  
