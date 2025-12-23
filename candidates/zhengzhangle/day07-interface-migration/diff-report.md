## 对比文档

### 1 oracle混合查询sql语句
```
----作用：查询id=2的记录
String sql = """
            SELECT
                /* Oracle 专用函数 DECODE，用于行业名称归一化 */
                DECODE(e.INDUSTRY,
                       'Finance', 'FIN',
                       'IT', 'TECH',
                       e.INDUSTRY) AS INDUSTRY,

                COUNT(e.EMPLOYER_ID) AS EMPLOYER_CNT,

                /* Oracle 专用函数 NVL，处理空值 */
                SUM(NVL(e.EMP_COUNT, 0)) AS TOTAL_EMP,

                SUM(NVL(s.TOTAL_SALARY, 0)) AS TOTAL_SALARY
            FROM EMPLOYERS e,
                 EMPLOYER_SALARY s
            WHERE e.EMPLOYER_ID = s.EMPLOYER_ID
              AND s.REPORT_YEAR = ?
            GROUP BY
                DECODE(e.INDUSTRY,
                       'Finance', 'FIN',
                       'IT', 'TECH',
                       e.INDUSTRY)
            ORDER BY TOTAL_SALARY DESC
        """;
```

### 2 snowflake混合查询sql语句
```
----功能，该公司种类分组并查询工资总和，其中种类‘Finance’用‘Fin’代替
String sql = """
    SELECT
        /* from Oracle DECODE(...) -> Snowflake CASE WHEN */
        CASE
            WHEN e.INDUSTRY = 'Finance' THEN 'FIN'
            WHEN e.INDUSTRY = 'IT' THEN 'TECH'
            ELSE e.INDUSTRY
        END AS INDUSTRY,

        COUNT(e.EMPLOYER_ID) AS EMPLOYER_CNT,

        /* from Oracle NVL(e.EMP_COUNT, 0) */
        SUM(COALESCE(e.EMP_COUNT, 0)) AS TOTAL_EMP,

        /* from Oracle NVL(s.TOTAL_SALARY, 0) */
        SUM(COALESCE(s.TOTAL_SALARY, 0)) AS TOTAL_SALARY
            FROM EMPLOYERS e
            JOIN EMPLOYER_SALARY s
                ON e.EMPLOYER_ID = s.EMPLOYER_ID
            WHERE s.REPORT_YEAR = ?
            GROUP BY
        CASE
            WHEN e.INDUSTRY = 'Finance' THEN 'FIN'
            WHEN e.INDUSTRY = 'IT' THEN 'TECH'
            ELSE e.INDUSTRY
        END
    ORDER BY TOTAL_SALARY DESC
""";
```

### 3 对比分析

**3.1 业务接口文件地址：**

**oracle接口1：简单查询**src/main/java/com/example/dao/oracle/EmployerDao.java

**oracle接口2：包含Join和聚合函数的复杂查询**src/main/java/com/example/dao/oracle/EmployerReportDao.java

**snowflake接口1：简单查询**src/main/java/com/example/dao/snowflake/EmployerDao.java

**snowflake接口2：包含Join和聚合函数的复杂查询**src/main/java/com/example/dao/snowflake/EmployerReportDao.java

**3.2 sql语句分析**

**在oracle的业务2特意使用了DECODE、NVL、隐式Join等oracle特有语法，并使用了CASE、COALESCE、JOIN标准ANSI写法进行了替换**

**虽然sql语句中使用了NVL，但仅用作展示，具体数据中并未体现**

**3.3 结果分析**

**oracle-1.png和snowflake-1.png，oracle-2.png和snowflake-2.png分别为业务1迁移前后的执行对比，结果中除了时间显示有差别（但是正确）外，数值包括精度在内均正确无误**