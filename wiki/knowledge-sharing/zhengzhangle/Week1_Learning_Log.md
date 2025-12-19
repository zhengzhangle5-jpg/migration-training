# Week 1 学习总结

## 学员信息
- 姓名：郑章乐
- 周期：2025-12-15 至 2025-12-19（第 1 周）

---

## 1. 本周学习内容概览

| 日期 | 主题 | 状态 |
|------|------|------|
| Day 01 | 环境准备 | ✅ 完成 |
| Day 02 | SQL 语法对比 | ✅ 完成 |
| Day 03 | 数据类型映射 | ✅ 完成 |
| Day 04 | Bug Bash | ✅ 完成 |
| Day 05 | 周总结与知识分享 | ✅ 完成 |

---

## 2. 完成的任务和成果

### Day 01 - 环境准备

**成果：**
- ✅ 配置 Snowflake 账户（启用 MFA）
- ✅ 安装开发工具（oracle）
- ✅ 完成 database-comparsion 对比程序

**文档输出：**
- `candidates/zhengzhangle/day01-environment/README.md`
- `candidates/zhengzhangle/day01-environment/environment-checklist.md`

---

### Day 02 - SQL 语法对比

**成果：**
- ✅ 完成 10 组 SQL 对比练习
- ✅ 理解 JOIN、日期函数、字符串函数差异
- ✅ 编写对比文档

**关键收获：**
- `SYSDATE` → `CURRENT_TIMESTAMP()`
- `NVL` → `COALESCE`（更标准）
- `SUBSTR` 函数兼容，但推荐使用 `SUBSTRING`

**文档输出：**
- `candidates/zhengzhangle/day02-sql-basics/SQL_Comparison.md`

---

### Day 03 - 数据类型映射

**成果：**
- ✅ 修复 NUMBER 精度丢失 Bug
- ✅ 学习数据类型映射规则
- ✅ 编写 Bug 修复报告

**Bug 修复案例：**
- **问题：** 订单金额小数丢失
- **原因：** `NUMBER` 类型精度误差
- **解决：** 改为 `NUMBER(12, 4)`

**文档输出：**
- `candidates/zhang-san/day03-datatype-mapping/bugfix-report.md`

---

### Day 04 - Bug Bash

**成果：**
- ✅ 修复 5 个数据类型相关 Bug

**Bug 清单：**
1. `ORDERS` 表 `price` 列精度丢失
2. `ORDERS` 表 `amount` 列精度丢失
3. `ORAERS` 表 `SUM` 查询结果精度丢失

---

### Day 05 - 周总结与知识分享

**成果：**
- ✅ 编写 Week 1 学习总结（本文档）

---

## 4. top3技术难点

### 困难 1：数据库连接失败，snowflake内部映射与高版本java的模块系统不兼容

**问题描述：** 连接语句没有任何错误的情况下，显示‘模块访问异常’

**解决过程：**
1. 查阅 Snowflake 文档，查询 chatgpt AI 
2. 发现snowflake jdbc大量使用反射，但是java引入了模块系统后禁止第三方库通过反射访问
3. 在run-setting中添加JVM参数

**耗时：** 25 分钟

**学习点：** 遇到问题先查文档，再独立研究 15 分钟（15 分钟规则）

---

### 困难 2：oracle 的listener假服务问题

**问题描述：** oracle的listener存在，且服务显示正常运行，但并没有在监听工作

**解决过程：**
1. 阅读官方文档，无果再询问AI以及同事
2. 尝试多种解决方法，如强行挂载lisetener、重启listerner服务等
3. 找到原因是：listener没有正确解析“127.0.0.1”这个本地地址（目前原因不明，可能是ipv6的问题），监听的地址中只要一个没有正确解析，那么所有的监听都不工作
4. 删除解析错误的地址，用先前测试多的正确地址连接

**学习点：**
- orcle的listener的基本工作原理
- listener服务失效的排查方法

**耗时：** 60 分钟

---

### 困难 3：函数执行顺序问题

**问题描述：** 在函数等价实现的一个练习中，排查了所有可能的错误，发现结果仍对不上。

**解决过程：**
1. 认真对比oracle原始查询代码和snowflake等价代码的功能差异。
2. 询问AI，和同事讨论可能的原因。
3. 定位错误，是复现oracle的（ROWNUM+ORDERBY）组合查询的等价代码的执行顺序与原版本有偏差。
4. 分析原因，oracle的这组语法，在不用括号（）强制规范执行顺序时，会导致ROWNUM先执行；而snowflake则默认先排序再取行号，因此导致结果偏差。

**学习点：**
- 学习函数的差异并不只局限于这个数据库特有某些函数、函数参数不同、写法稍有区别、默认的精度问题等。还需要多加注意不同函数组合执行时产生的意想不到的差异。

**耗时：** 100 分钟

---

## 4. Oracle → Snowflake 转换速查表

| 功能     | Oracle             | Snowflake                | 差别 / 迁移注意点         |
| ------ | ------------------ | ------------------------ | ------------------ |
| 空值替换   | `NVL(a,b)`         | `COALESCE(a,b)`          | Snowflake 不支持 NVL  |
| 空值判断分支 | `NVL2(a,b,c)`      | `IFF(a IS NOT NULL,b,c)` | 语义一致               |
| 简单条件映射 | `DECODE(expr,...)` | `CASE WHEN`              | Snowflake 无 DECODE |
| 条件判断   | `CASE WHEN`        | `CASE WHEN`              | ANSI 标准            |
| 相等返回空  | `NULLIF(a,b)`      | `NULLIF(a,b)`            | 行为一致               |
| 条件表达式  | `DECODE`           | `CASE`                   | 推荐统一 CASE          |
| 当前日期   | `SYSDATE`         | `CURRENT_DATE()`         | Oracle DATE 含时间  |
| 当前时间戳  | `SYSTIMESTAMP`    | `CURRENT_TIMESTAMP()`    | Snowflake 显式时区   |
| 日期截断   | `TRUNC(d)`        | `DATE_TRUNC('day', d)`   | Snowflake 必须指定粒度 |
| 月初     | `TRUNC(d,'MM')`   | `DATE_TRUNC('month', d)` | 一致               |
| 日期加月   | `ADD_MONTHS(d,n)` | `DATEADD(month,n,d)`     | 参数顺序不同           |
| 日期差（月） | `MONTHS_BETWEEN`  | `DATEDIFF(month,...)`    | Oracle 可返回小数     |
| 月末     | `LAST_DAY(d)`     | `LAST_DAY(d)`            | 一致               |
| 下一个工作日 | `NEXT_DAY`        | `NEXT_DAY`               | Snowflake 仅英文    |
| 子字符串 | `SUBSTR`        | `SUBSTR`        | 一致         |
| 查找位置 | `INSTR`         | `POSITION`      | 函数名不同      |
| 字符长度 | `LENGTH`        | `LENGTH`        | 一致         |
| 去空格  | `TRIM`          | `TRIM`          | 一致         |
| 左右裁剪 | `LTRIM / RTRIM` | `LTRIM / RTRIM` | 一致         |
| 字符替换 | `REPLACE`       | `REPLACE`       | 一致         |
| 正则匹配 | `REGEXP_LIKE`   | `REGEXP_LIKE`   | 引擎细节差异     |
| 正则截取 | `REGEXP_SUBSTR` | `REGEXP_SUBSTR` | 基本一致       |
| 四舍五入     | `ROUND`             | `ROUND`        | 一致               |
| 截断       | `TRUNC`             | `TRUNC`        | 一致               |
| 取模       | `MOD`               | `MOD`          | 一致               |
| 求和       | `SUM`               | `SUM`          | Snowflake 保留精度更高 |
| 平均       | `AVG`               | `AVG`          | 精度表现不同           |
| 排名       | `RANK()`            | `RANK()`       | 并列规则一致           |
| 连续排名     | `DENSE_RANK()`      | `DENSE_RANK()` | 一致               |
| 行编号      | `ROW_NUMBER()`      | `ROW_NUMBER()` | 一致               |
| Top-N 聚合 | `KEEP (DENSE_RANK)` | `QUALIFY`      | Snowflake 无 KEEP |
| 层级查询 | `CONNECT BY`          | `WITH RECURSIVE` | Snowflake 必须显式 |
| 层级起点 | `START WITH`          | 锚点 `WHERE`       | 写法变化           |
| 层级深度 | `LEVEL`               | 手动维护             | 无内置变量          |
| 根节点  | `CONNECT_BY_ROOT`     | 递归传值             | 手工实现           |
| 路径拼接 | `SYS_CONNECT_BY_PATH` | `LISTAGG`        | 需自行组合          |
| 防循环  | `NOCYCLE`             | 手动判断             | Snowflake 不自动  |
| 行限制     | `ROWNUM`      | `ROW_NUMBER()`    | Oracle 是物理截断   |
| Top-N   | `ROWNUM <= N` | `QUALIFY rn <= N` | 必须配排序          |
| 排序后取前 N | 子查询 + ROWNUM  | 窗口函数              | Snowflake 强制显式 |
| 并列控制    | 隐式            | 显式                | Snowflake 更严格  |
| 虚拟表  | `DUAL`     | 不需要               | Snowflake 任意 SELECT |
| 当前用户 | `USER`     | `CURRENT_USER()`  | 一致                  |
| 行标识  | `ROWID`    | `METADATA$ROW_ID` | 不可等价                |
| 哈希   | `ORA_HASH` | `HASH()`          | 算法不同                |
| 字符转换   | `TO_CHAR`                 | `TO_VARCHAR`    | Snowflake 兼容 TO_CHAR |
| 数字转换   | `TO_NUMBER`               | `TO_NUMBER`     | 一致                   |
| 类型转换   | `CAST`                    | `CAST`          | 一致                   |
| 日期类型   | `DATE`                    | `DATE`          | Oracle DATE 含时间      |
| 本地时区时间 | `TIMESTAMP WITH LOCAL TZ` | `TIMESTAMP_LTZ` | 显式区分                 |


---

## 5. 下周计划

### Week 2 目标

| 日期 | 主题 | 预期成果 |
|------|------|---------|
| Day 06 | 工具链配置 | 配置 Ora2Pg, SnowConvert |
| Day 07 | 接口修改 | 完成 1 个接口修改练习 |
| Day 08 | JDBC 连接 | 修复 JDBC 连接问题 |
| Day 09 | 单元测试 | 单元测试覆盖率 ≥ 80% |
| Day 10 | 周总结 | Week 2 学习总结 |

### 学习重点

1. **工具链熟练度**：掌握 Ora2Pg 和 SnowConvert
2. **接口修改流程**：理解 SOP 和 Checklist
3. **JDBC 最佳实践**：连接池配置、性能优化
4. **测试驱动开发**：先写测试，再写代码

---

**总结完成日期：** 2025-012-19
