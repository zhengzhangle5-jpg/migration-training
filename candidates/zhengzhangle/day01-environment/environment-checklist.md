# 环境准备验证清单

## 培训学员信息
- 姓名：郑章乐
- 完成日期：2025-12-15
---

## 1. Snowflake 账户访问

- [x] 已收到账户邀请邮件
- [x] 成功设置初始密码
- [x] 可以登录 Snowflake Web UI
- [x] 可以访问指定的数据库和 Schema
- [x] 可以使用 Warehouse 执行查询

**账户信息：**
```
Account: PCNZPCZ-QB93968
Username: ZZL
Default Role: DEVELOPER
Default Warehouse: COMPUTE_WH
Default Database: MIGRATION_DB
```

---

## 2. 本地开发工具

### 2.1 IDEA 和编辑器
- [x] IntelliJ IDEA（版本：2024.1.1）
- [ ] VS Code（可选，版本：1.85.0）
- [x] 已安装必要插件：
    - [x] Maven
    - [x] Git
    - [x] Markdown

### 2.2 数据库客户端
- [ ] DBeaver（版本：23.3.0）
- [x] Oracle SQL Developer（版本：23.1）
- [ ] SnowSQL CLI（版本：1.2.28）

### 2.3 版本控制工具
- [x] Git（版本：2.43.0）
- [x] 配置了 Git 用户信息

---

## 3. 网络和权限

- [x] 可以访问公司 VPN
- [x] 可以访问内部 Wiki（wiki.company.com）
- [x] 可以访问 Notion 工作空间
- [x] 可以访问 Git 仓库
- [x] 可以访问 Snowflake 文档（docs.snowflake.com）
- [x] 可以访问 Oracle 文档（docs.oracle.com）

---

## 4. 文档和资源

- [x] 已加入团队 Slack/Teams 频道
- [x] 已获得 Notion 访问权限
- [x] 已阅读 `README.md`（项目根目录）
- [x] 已阅读 `CONTRIBUTING.md`
- [x] 已了解团队的代码规范和 Git 工作流

**重要文档链接：**
- [团队 Wiki](https://wiki.company.com/migration)
- [Notion 工作空间](https://notion.so/company/migration-team)
- [代码仓库](https://github.com/company/snowflake-migration)
- [培训计划](./Java_Migration_Engineer_Onboarding_4weeks.md)

---

## 5. Oracle ↔ Snowflake 查询验证

- [x] 成功在 Oracle 中执行查询语句
- [x] 成功在 Snowflake 中执行查询语句
- [x] 创建了代码对比文档
- [x] 理解了基本的 SQL 语法差异

**执行结果：**
```sql
-- Oracle
Oracle SYSDATE: 2025-12-16 10:08:51.0
-- 

-- Snowflake
Snowflake CURRENT_TIMESTAMP: 2025-12-15 17:08:51.24;
-- 
```

---

## 6. Git 工作流验证

- [x] 成功创建功能分支
- [x] 提交符合规范的 Commit Message
- [x] 创建并提交了第一个 Pull Request
- [x] PR 通过了自动化检查（CI/CD）
- [ ] PR 获得了导师的 Code Review

**第一个 PR：**
- PR 链接：``
- 标题：`- 完成 EnvironmentTest.java，验证 Oracle 和 Snowflake 连接
- 完成 DatabaseComparisonTest.java，对比两个数据库的查询结果
- 记录环境配置问题与解决方案`
- 状态：✅ Merged

---

## 遇到的问题和解决方案

### 问题 1：MFA 设置失败
- **描述：** 扫描二维码后，验证码始终提示错误
- **原因：** 手机时间未同步
- **解决：** 启用手机"自动设置时间"功能
- **耗时：** 15 分钟（包括查找文档时间）

### 问题 2：DBeaver 连接 Snowflake 超时
- **描述：** 连接时提示 Connection timeout
- **原因：** 未连接公司 VPN
- **解决：** 连接 VPN 后重试
- **耗时：** 10 分钟

### 问题 3：Git Push 权限被拒绝
- **描述：** `git push` 时提示 Permission denied (publickey)
- **原因：** SSH Key 未添加到 GitHub
- **解决：** 生成 SSH Key 并添加到 GitHub 账户
- **耗时：** 20 分钟

---

## 审核签字

- [ ] 导师已验证所有环境配置正确
- [ ] 导师已审核 Hello World 代码
- [ ] 导师已审核第一个 PR

**导师签字：** ________________
**日期：** 2025-01-15
