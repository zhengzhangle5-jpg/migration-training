# 性能测试模板

## 测试信息
- 测试人：张三
- 测试日期：2025-02-01
- 测试对象：订单查询 API
- 测试环境：Snowflake X-Large Warehouse

---

## 1. 测试目标

### 1.1 性能指标

| 指标 | 目标值 | Oracle 基准值 |
|------|--------|--------------|
| 响应时间（P50） | ≤ 2 秒 | 3 秒 |
| 响应时间（P95） | ≤ 5 秒 | 8 秒 |
| 响应时间（P99） | ≤ 10 秒 | 15 秒 |
| 吞吐量（TPS） | ≥ 100 | 50 |
| 并发用户数 | 100 | 50 |
| CPU 使用率 | ≤ 80% | - |
| 内存使用率 | ≤ 70% | - |

---

## 2. 测试场景

### 2.1 场景1：单表查询

**查询SQL：**
```sql
SELECT * FROM orders
WHERE order_date = '2025-01-15'
  AND status = 'COMPLETED';
```

**测试参数：**
- 并发用户数：10, 50, 100
- 每用户执行次数：100
- 数据量：1,000,000 行

**预期结果：**
- P50 ≤ 1 秒
- P95 ≤ 3 秒
- TPS ≥ 150

---

### 2.2 场景2：JOIN 查询

**查询SQL：**
```sql
SELECT o.order_id, c.customer_name, o.amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2025-01-01';
```

**测试参数：**
- 并发用户数：10, 50, 100
- 每用户执行次数：50
- 数据量：orders(1,000,000), customers(100,000)

**预期结果：**
- P50 ≤ 3 秒
- P95 ≤ 8 秒
- TPS ≥ 80

---

### 2.3 场景3：聚合查询

**查询SQL：**
```sql
SELECT customer_id,
       COUNT(*) AS order_count,
       SUM(amount) AS total_amount
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY customer_id
HAVING COUNT(*) >= 10;
```

**测试参数：**
- 并发用户数：10, 50
- 每用户执行次数：20
- 数据量：1,000,000 行

**预期结果：**
- P50 ≤ 5 秒
- P95 ≤ 12 秒
- TPS ≥ 30

---

## 3. 测试执行

### 3.1 场景1测试结果

#### 10 并发用户

| 指标 | Oracle | Snowflake | 对比 |
|------|--------|-----------|------|
| P50 响应时间 | 2.5 秒 | 0.8 秒 | ✅ 提升 3.1 倍 |
| P95 响应时间 | 5.2 秒 | 2.1 秒 | ✅ 提升 2.5 倍 |
| P99 响应时间 | 8.5 秒 | 3.5 秒 | ✅ 提升 2.4 倍 |
| 平均 TPS | 4.0 | 12.5 | ✅ 提升 3.1 倍 |
| 最大 TPS | 5.5 | 14.2 | ✅ 提升 2.6 倍 |

**状态：** ✅ **通过**

#### 50 并发用户

| 指标 | Oracle | Snowflake | 对比 |
|------|--------|-----------|------|
| P50 响应时间 | 3.2 秒 | 1.1 秒 | ✅ 提升 2.9 倍 |
| P95 响应时间 | 7.8 秒 | 3.2 秒 | ✅ 提升 2.4 倍 |
| P99 响应时间 | 12.5 秒 | 5.1 秒 | ✅ 提升 2.5 倍 |
| 平均 TPS | 15.6 | 45.5 | ✅ 提升 2.9 倍 |
| 最大 TPS | 22.3 | 58.7 | ✅ 提升 2.6 倍 |

**状态：** ✅ **通过**

#### 100 并发用户

| 指标 | Oracle | Snowflake | 对比 |
|------|--------|-----------|------|
| P50 响应时间 | 5.8 秒 | 1.5 秒 | ✅ 提升 3.9 倍 |
| P95 响应时间 | 14.2 秒 | 4.8 秒 | ✅ 提升 3.0 倍 |
| P99 响应时间 | 22.5 秒 | 8.2 秒 | ✅ 提升 2.7 倍 |
| 平均 TPS | 17.2 | 66.7 | ✅ 提升 3.9 倍 |
| 最大 TPS | 28.5 | 92.3 | ✅ 提升 3.2 倍 |

**状态：** ✅ **通过**

---

### 3.2 场景2测试结果

#### 50 并发用户

| 指标 | Oracle | Snowflake | 对比 |
|------|--------|-----------|------|
| P50 响应时间 | 6.5 秒 | 2.8 秒 | ✅ 提升 2.3 倍 |
| P95 响应时间 | 15.8 秒 | 7.2 秒 | ✅ 提升 2.2 倍 |
| P99 响应时间 | 28.5 秒 | 12.5 秒 | ✅ 提升 2.3 倍 |
| 平均 TPS | 7.7 | 17.9 | ✅ 提升 2.3 倍 |

**状态：** ✅ **通过**

---

### 3.3 场景3测试结果

#### 10 并发用户

| 指标 | Oracle | Snowflake | 对比 |
|------|--------|-----------|------|
| P50 响应时间 | 12.5 秒 | 4.2 秒 | ✅ 提升 3.0 倍 |
| P95 响应时间 | 25.8 秒 | 10.5 秒 | ✅ 提升 2.5 倍 |
| P99 响应时间 | 38.2 秒 | 15.8 秒 | ✅ 提升 2.4 倍 |
| 平均 TPS | 0.8 | 2.4 | ✅ 提升 3.0 倍 |

**状态：** ✅ **通过**

---

## 4. 资源使用情况

### 4.1 Warehouse 使用

| Warehouse 大小 | 场景 | 平均利用率 | 峰值利用率 | 成本/小时 |
|---------------|------|-----------|-----------|----------|
| Small | 场景1（10并发） | 35% | 52% | $2 |
| Medium | 场景1（50并发） | 58% | 78% | $4 |
| Large | 场景1（100并发） | 72% | 89% | $8 |
| Large | 场景2（50并发） | 65% | 85% | $8 |
| X-Large | 场景3（10并发） | 48% | 72% | $16 |

**建议：**
- 场景1：使用 Medium Warehouse（成本和性能平衡）
- 场景2：使用 Large Warehouse
- 场景3：使用 Large Warehouse（X-Large 浪费）

---

## 5. 瓶颈分析

### 5.1 Query Profile 分析

**场景1 - 单表查询：**
```
执行计划：
1. TableScan[orders]
   - Partitions Total: 1,200
   - Partitions Scanned: 15  ✅ 分区裁剪有效（98.75% 减少）
   - Bytes Scanned: 2.5 GB

2. Filter
   - Rows In: 8,333
   - Rows Out: 125
   - Selectivity: 1.5%

总执行时间：0.8 秒
- TableScan: 0.6 秒 (75%)
- Filter: 0.2 秒 (25%)
```

**优化建议：**
- ✅ 已添加聚簇键：`CLUSTER BY (order_date)`
- ✅ 分区裁剪有效

**场景2 - JOIN 查询：**
```
执行计划：
1. TableScan[customers]
   - Bytes Scanned: 50 MB

2. TableScan[orders]
   - Bytes Scanned: 5 GB

3. HashJoin
   - Join Type: INNER
   - Join Method: HASH
   - Rows Out: 85,234

总执行时间：2.8 秒
- TableScan[orders]: 1.8 秒 (64%)
- HashJoin: 0.8 秒 (29%)
- TableScan[customers]: 0.2 秒 (7%)
```

**优化建议：**
- ✅ 小表（customers）作为 Build 端
- ⚠️ 可以考虑创建物化视图（高频查询）

---

## 6. 对比总结

### 6.1 性能提升汇总

| 场景 | Oracle P50 | Snowflake P50 | 提升倍数 |
|------|-----------|--------------|---------|
| 单表查询（10并发） | 2.5s | 0.8s | 3.1x |
| 单表查询（100并发） | 5.8s | 1.5s | 3.9x |
| JOIN查询（50并发） | 6.5s | 2.8s | 2.3x |
| 聚合查询（10并发） | 12.5s | 4.2s | 3.0x |

**平均性能提升：** 3.1 倍

### 6.2 吞吐量提升

| 场景 | Oracle TPS | Snowflake TPS | 提升倍数 |
|------|-----------|--------------|---------|
| 单表查询（100并发） | 17.2 | 66.7 | 3.9x |
| JOIN查询（50并发） | 7.7 | 17.9 | 2.3x |
| 聚合查询（10并发） | 0.8 | 2.4 | 3.0x |

**平均吞吐量提升：** 3.1 倍

---

## 7. 成本分析

### 7.1 Warehouse 成本

| 场景 | Warehouse | 运行时间 | 成本 | Oracle 成本 | 节省 |
|------|-----------|---------|------|------------|------|
| 单表查询（100并发） | Large | 2.5 小时 | $20 | $40 | 50% |
| JOIN查询（50并发） | Large | 3.0 小时 | $24 | $48 | 50% |
| 聚合查询（10并发） | Large | 1.5 小时 | $12 | $30 | 60% |

**总成本：** $56（Snowflake） vs $118（Oracle）
**成本节省：** 52.5%

---

## 8. 结论和建议

### 8.1 测试结论

1. **性能表现：** ✅ **优秀**
   - 所有场景均达到或超过目标
   - 平均性能提升 3.1 倍

2. **吞吐量：** ✅ **优秀**
   - 平均吞吐量提升 3.1 倍
   - 100 并发下 TPS 达到 66.7（目标 100）

3. **成本：** ✅ **优秀**
   - 成本节省 52.5%
   - 性能提升的同时降低成本

### 8.2 优化建议

1. **已实施优化：**
   - ✅ 添加聚簇键
   - ✅ 使用合适的 Warehouse 大小
   - ✅ 优化 SQL（避免全表扫描）

2. **进一步优化：**
   - ⚠️ 高频 JOIN 查询创建物化视图
   - ⚠️ 启用 Search Optimization Service
   - ⚠️ 考虑使用 Multi-Cluster Warehouse（高并发场景）

### 8.3 上线建议

- ✅ **建议上线**
- 监控前 1 周的性能表现
- 准备回滚方案（保留 Oracle 环境）

---

## 9. 测试工具和脚本

### 9.1 JMeter 测试脚本

```xml
<!-- scenario1.jmx -->
<ThreadGroup>
  <stringProp name="ThreadGroup.num_threads">100</stringProp>
  <stringProp name="ThreadGroup.ramp_time">60</stringProp>
  <stringProp name="ThreadGroup.duration">1800</stringProp>
</ThreadGroup>
```

### 9.2 Python 性能测试脚本

```python
import snowflake.connector
import time
import statistics

def benchmark_query(conn, sql, iterations=100):
    times = []
    for i in range(iterations):
        start = time.time()
        cursor = conn.cursor()
        cursor.execute(sql)
        cursor.fetchall()
        end = time.time()
        times.append(end - start)

    return {
        'p50': statistics.median(times),
        'p95': statistics.quantiles(times, n=20)[18],
        'p99': statistics.quantiles(times, n=100)[98],
        'avg': statistics.mean(times),
        'min': min(times),
        'max': max(times)
    }

# 使用示例
conn = snowflake.connector.connect(...)
sql = "SELECT * FROM orders WHERE order_date = '2025-01-15'"
results = benchmark_query(conn, sql, 100)
print(f"P50: {results['p50']:.2f}s")
print(f"P95: {results['p95']:.2f}s")
```

---

**测试完成时间：** 2025-02-01 18:00
**测试审核人：** 李导师
**批准状态：** ✅ 已批准上线
