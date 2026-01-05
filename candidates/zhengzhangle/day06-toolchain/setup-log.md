# 迁移工具链配置日志

## 学员信息
- 姓名：郑章乐
- 日期：2025-12-22
- 任务：Day 06 - 迁移工具链配置

---
## 工具配置

**工具包名称：** `common`
**位置：** `com/migration/tools/`
**功能：** `其下有两个java类，分别用于返回oracle和snowflake的连接`

**工具包名称：** `dataexporter`
**位置：** `com/migration/tools/`
**功能：** `用于读取oracle的记录`

**工具包名称：** `dataloader`
**位置：** `com/migration/tools/`
**功能：** `用于输出DDL到snowflake中执行`

**工具包名称：** `ddlconverter`
**位置：** `com/migration/tools/`
**功能：** `用于读取oracle中表的结构定义并转换为snowflake版本，结果输出对应的sql文件`

**工具包名称：** `sqltranslator`（本例未使用）
**位置：** `com/migration/tools/`
**功能：** `用于修改select查询语句，在该例子中只涉及建表和转移数据，故未使用`


## 1. 转移表结构工具实现

### 1.1 Oracle 表结构读取

使用 java.sql.DatabaseMetaData从 Oracle 数据库中动态读取列信息：

**为此定义了统一的列元数据模型：**
```
ColumnMeta
- name   : 列名
- type   : Oracle 原始类型
- size   : 精度 / 长度
- scale  : 小数位数

```

### 1.2 Oracle → Snowflake 类型映射规则

**当前实现的自动转换规则如下：**

| Oracle 类型   | Snowflake 类型 |
| ----------- | ------------ |
| VARCHAR2(n) | VARCHAR(n)   |
| NUMBER(p,s) | NUMBER(p,s)  |
| NUMBER(p)   | NUMBER(p)    |
| DATE        | DATE         |


### 1.3 原始建表语句/查询结果一览

```oracle原始语句
CREATE TABLE EMPLOYERS (
EMPLOYER_ID   NUMBER(10),
EMPLOYER_NAME VARCHAR2(100),
INDUSTRY      VARCHAR2(50),
EMP_COUNT     NUMBER(8),
CREATED_DATE  DATE
);
```




### 1.4 表结构转化，DDL 文件生成

**工具名称：** `OracleConnectionUtil`
**位置：** `src/main/java/com/migration/tools/common/OracleConnectionUtil.java`
**功能：** `获取oracle数据库连接`

**工具名称：** `OracleTableMetadataReader`
**位置：** `src/main/java/com/migration/tools/ddlconverter/OracleTableMetadataReader.java`
**功能：** `读取表的结构信息`

**工具名称：** `SnowflakeDdlGenerator`
**位置：** `src/main/java/com/migration/tools/ddlconverter/SnowflakeDdlGenerator.java`
**功能：** `按规则对建表DDL进行转换，得到snowflake版本DDL`

**当前实现的自动转换规则如下：**

| Oracle 类型   | Snowflake 类型 | 对应字段名        |
| ----------- | ------------ |--------------|
| VARCHAR2(n) | VARCHAR(n)   | EMPLOYER_ID |
| NUMBER(p,s) | NUMBER(p,s)  | REPORT_YEAR  |
| NUMBER(p)   | NUMBER(p)    | EMPLOYER_ID |
| DATE        | DATE         | CREATED_DATE |


---

## 2. 在snowflake中建表

### 2.1 oracle建表语句一览

```
CREATE TABLE EMPLOYERS (
EMPLOYER_ID   NUMBER(10),
EMPLOYER_NAME VARCHAR2(100),
INDUSTRY      VARCHAR2(50),
EMP_COUNT     NUMBER(8),
CREATED_DATE  DATE
);
```

### 2.2 经工具转换后得到的snowflake建表语句

**由工具链修改生成的DDL如下：**
**文件位置：** EMPLOYERS_snowflake.sql（codes仓库中）
```
CREATE TABLE EMPLOYERS (
  EMPLOYER_ID NUMBER(10),
  EMPLOYER_NAME VARCHAR(100),
  INDUSTRY VARCHAR(50),
  EMP_COUNT NUMBER(8),
  CREATED_DATE DATE
);
```

### 2.3 结果分析

1. **工具正确处理了varchar2类型的变换**
2. **工具正确处理了number整数形式的变换**

### 2.4 人工介入点（如需要）

**主键 / 索引**

**NOT NULL / DEFAULT**

**表分区**

**表空间等 Oracle 特有属性**

---

## 3. Oracle → Snowflake 数据迁移

### 3.1 实现方式

**Oracle：**
```
JDBC 读取 ResultSet（流式）
```

**Java：**
```
使用 getTimestamp() 读取 DATE 类型

避免 java.sql.Date 引发的时区问题
```

**Snowflake：**
```
使用 PreparedStatement 逐行插入
```

### 3.1 数据正确率分析

**规模：** 
**字段**4
**记录数**4

**正确率：**
```
75%
```

**总结：** 因测试记录数过少，数据转移初步判定没有问题；data转换设计存在时区隐患，故正确率为75%

**解决方案：** 统一使用 Timestamp 类型读写

### 3.2 后续优化方向：
**减少硬编码，将表名和数据库连接信息从代码中分离出来**
**date多种时间类型差异**
**oracle还有多种字符类型，CHAR,NCHAR,CLOB等**
**NOT NULL / DEFAULT / COMMENT 这些建表语句后的补充部分尚未解析**
**同样的，主键、索引等（这部分由人工操作）**


---

**配置完成日期：** 2025-12-22
