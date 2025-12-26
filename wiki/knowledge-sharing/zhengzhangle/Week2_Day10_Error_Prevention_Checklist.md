# Week 2 错误预防清单（Day10 总结）

## 学员信息
- 姓名：郑章乐
- 周期：Week 2（2025-12-22 至 2025-12-26）

---

## 1. 表结构与数据类型相关错误

### 1.1 NUMBER 精度与业务不匹配

**问题：**
```sql
-- ❌ 错误：金额字段未指定小数位
CREATE TABLE payments (
    amount NUMBER
);
```

**正确做法：**
```sql
-- ✅ 正确：根据业务含义指定精度
CREATE TABLE payments (
    payment_id NUMBER(10,0),
    amount NUMBER(14,2),      -- 金额
    rate NUMBER(6,4)          -- 比率
);
```

**预防措施：**
- [ ] NUMBER 字段必须明确 precision / scale
- [ ] 表设计阶段同步确认业务含义
- [ ] DDL 合入前做静态检查

---

### 1.2 VARCHAR 长度评估不足

**问题：**
```sql
-- ❌ 错误：字段长度偏小
CREATE TABLE users (
    email VARCHAR(30)
);
```

**正确做法：**
```sql
-- ✅ 正确：考虑真实数据长度
CREATE TABLE users (
    email VARCHAR(255)
);
```

**预防措施：**
- [ ] 参考源系统字段长度
- [ ] 为不可预期字段预留冗余

---

### 1.3 时间字段类型选择不当

**问题：**
```sql
-- ❌ 错误：忽略时区影响
CREATE TABLE logs (
    log_time TIMESTAMP
);
```

**正确做法：**
```sql
-- ✅ 正确：根据场景选择
CREATE TABLE logs (
    log_time TIMESTAMP_TZ
);
```

**预防措施：**
- [ ] 明确是否需要时区
- [ ] 统一使用 UTC 存储

---

## 2. SQL 兼容性问题

### 2.1 旧式 JOIN 语法遗留

**问题：**
```sql
-- ❌ 错误：使用 (+)
SELECT * FROM a, b WHERE a.id = b.id(+);
```

**正确做法：**
```sql
-- ✅ 正确：ANSI JOIN
SELECT * FROM a LEFT JOIN b ON a.id = b.id;
```

**预防措施：**
- [ ] 全量替换旧 JOIN 语法
- [ ] Review 时重点关注

---

### 2.2 使用不支持的分页方式

**问题：**
```sql
-- ❌ 错误：ROWNUM
SELECT * FROM orders WHERE ROWNUM < 50;
```

**正确做法：**
```sql
-- ✅ 正确：LIMIT
SELECT * FROM orders LIMIT 50;
```

**预防措施：**
- [ ] 禁止使用 ROWNUM
- [ ] 统一分页方案

---

## 3. 存储过程改造问题

### 3.1 OUT 参数未适配

**问题：**
```sql
-- ❌ 错误：OUT 参数
CREATE PROCEDURE calc_bonus(emp_id IN NUMBER, bonus OUT NUMBER);
```

**正确做法：**
```sql
-- ✅ 正确：使用 RETURNS
CREATE PROCEDURE calc_bonus(emp_id NUMBER)
RETURNS NUMBER
LANGUAGE SQL
AS $$
BEGIN
    RETURN (SELECT bonus FROM employees WHERE employee_id = :emp_id);
END;
$$;
```

**预防措施：**
- [ ] 禁用 OUT 参数
- [ ] 更新调用逻辑

---

### 3.2 变量使用不规范

**问题：**
```sql
-- ❌ 错误：缺少冒号
SELECT bonus INTO v_bonus FROM employees;
```

**正确做法：**
```sql
-- ✅ 正确
SELECT bonus INTO :v_bonus FROM employees;
```

**预防措施：**
- [ ] 强制语法检查

---

## 4. JDBC 调用问题

### 4.1 连接池配置不合理

**问题：**
- 连接数配置过大

**正确做法：**
```java
config.setMaximumPoolSize(15);
config.setMinimumIdle(3);
```

**预防措施：**
- [ ] 根据并发量调整
- [ ] 定期监控

---

### 4.2 存储过程返回值处理错误

**问题：**
- 仍使用 OUT 参数方式

**正确做法：**
```java
ResultSet rs = stmt.executeQuery();
if (rs.next()) {
    double bonus = rs.getDouble(1);
}
```

**预防措施：**
- [ ] 全面回归测试

---

## 5. 数据校验不足

### 5.1 未验证精度和范围

**正确做法：**
```sql
SELECT * FROM payments WHERE amount < 0;
```

**预防措施：**
- [ ] 校验边界值

---

### 5.2 NULL 值检查缺失

**正确做法：**
```sql
SELECT COUNT(*) FROM users WHERE email IS NULL;
```

**预防措施：**
- [ ] 对关键字段做 NULL 检查

---

## 6. 性能与资源使用

### 6.1 未合理使用聚簇键

**正确做法：**
```sql
ALTER TABLE logs CLUSTER BY (log_date);
```

---

### 6.2 Warehouse 使用不合理

**预防措施：**
- [ ] 启用 Auto-Suspend
- [ ] 按需调整规格

---

## 7. 文档与沟通问题

### 7.1 变更未同步

**预防措施：**
- [ ] 更新变更说明文档
- [ ] 提前通知相关方

---

## 8. 总结

### 8.1 本周高频问题 Top 5
1. NUMBER 精度遗漏
2. 存储过程 OUT 参数问题
3. 旧 SQL 语法未清理
4. JDBC 调用方式错误
5. 数据校验不足

### 8.2 改进措施

**技术层面：**
- 自动化 DDL 校验工具
- 单元测试覆盖率 ≥ 80%

**流程层面：**
- 强制 Checklist
- 完整文档与评审

---

**文档版本：** v1.0  
**最后更新：** 2025-12-26  
**作者：** 郑章乐
**审核：** 
