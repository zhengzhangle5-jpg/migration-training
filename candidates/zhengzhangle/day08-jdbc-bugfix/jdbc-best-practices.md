# JDBC 连接最佳实践文档

## 1. 连接池配置

### 1.1 HikariCP 推荐配置

```java
HikariConfig config = new HikariConfig();

// 基础连接参数
config.setJdbcUrl("jdbc:snowflake://account.snowflakecomputing.com");
config.setUsername("USER");
config.setPassword("PASSWORD");

// 连接池大小（根据实际负载调整）
config.setMaximumPoolSize(20);          // 最大连接数
config.setMinimumIdle(5);               // 最小空闲连接数

// 超时设置
config.setConnectionTimeout(30000);     // 30秒连接超时
config.setIdleTimeout(600000);          // 10分钟空闲超时
config.setMaxLifetime(1800000);         // 30分钟最大生命周期

// Snowflake 特定参数
config.addDataSourceProperty("warehouse", "COMPUTE_WH");
config.addDataSourceProperty("db", "MIGRATION_DB");
config.addDataSourceProperty("schema", "PUBLIC");
config.addDataSourceProperty("client_session_keep_alive", "true");

HikariDataSource dataSource = new HikariDataSource(config);
```

---

## 2. 常见陷阱

### 2.1 ❌ 连接数过多

**错误：**
```oracle常用连接数
config.setMaximumPoolSize(100);  // 太大！
```

**问题：** Snowflake 的 Virtual Warehouse 有连接数限制

**正确做法：**
```java
config.setMaximumPoolSize(20);  // 根据 Warehouse 大小调整
```

### 2.2 ❌ 未启用 Keep-Alive

**错误：** 长时间空闲连接会被 Snowflake 自动关闭

**正确做法：**
```java
config.addDataSourceProperty("client_session_keep_alive", "true");
```

---

## 3. 性能优化

### 3.1 使用批量操作

```java
// ✅ 推荐：批量插入
PreparedStatement ps = conn.prepareStatement(
    "INSERT INTO employees VALUES (?, ?, ?)"
);
for (Employee emp : employees) {
    ps.setInt(1, emp.getId());
    ps.setString(2, emp.getName());
    ps.setDate(3, emp.getHireDate());
    ps.addBatch();
}
ps.executeBatch();
```

### 3.2 使用 COPY INTO（大数据量）

```java
// 大数据量推荐使用 COPY INTO
String sql = """
    COPY INTO employees
    FROM @my_stage/employees.csv
    FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1)
    """;
statement.execute(sql);
```

---

## 4. 错误处理

### 4.1 重试机制

```java
public <T> T executeWithRetry(Callable<T> task, int maxRetries) {
    int attempt = 0;
    while (attempt < maxRetries) {
        try {
            return task.call();
        } catch (SnowflakeSQLException e) {
            if (isRetryable(e) && attempt < maxRetries - 1) {
                attempt++;
                Thread.sleep(1000 * attempt);  // 指数退避
            } else {
                throw e;
            }
        }
    }
    throw new RuntimeException("Max retries exceeded");
}

private boolean isRetryable(SnowflakeSQLException e) {
    return e.getMessage().contains("network") ||
           e.getMessage().contains("timeout");
}
```

---

**文档版本**: v1.0
**最后更新**: 2025-12-24
**作者**: 郑章乐
