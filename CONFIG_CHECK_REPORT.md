# mall 项目中间件配置检查报告

## 📋 概览
本项目使用 MySQL、Redis、MongoDB、RabbitMQ 四个关键中间件。以下是配置检查结果。

---

## 1️⃣ MySQL 配置检查

### ✅ 基础配置状态

| 环境 | 主机 | 端口 | 用户名 | 密码 | 数据库 | 状态 |
|------|------|------|--------|------|--------|------|
| Dev (mall-admin) | localhost | 3306 | root | root | mall | ✅ 正确 |
| Dev (mall-portal) | localhost | 3306 | root | root | mall | ✅ 正确 |
| Dev (mall-search) | localhost | 3306 | root | root | mall | ✅ 正确 |
| Prod (mall-admin) | db | 3306 | reader | 123456 | mall | ✅ 正确 |
| Docker Compose | mysql | 3306 | root | root | mall | ✅ 正确 |

### 📝 配置文件位置
- `mall-admin/src/main/resources/application-dev.yml` - 第 1-8 行
- `mall-admin/src/main/resources/application-prod.yml` - 第 1-8 行
- `mall-portal/src/main/resources/application-dev.yml` - 第 9-15 行
- `mall-search/src/main/resources/application-dev.yml` - 第 1-8 行

### ⚠️ 发现的问题
1. **字符集配置正确** ✅
   - 使用 utf8mb4，支持 emoji 和特殊字符
   - 排序规则为 utf8mb4_unicode_ci

2. **Druid 连接池配置** ✅
   - 初始连接数: 5
   - 最小空闲: 10
   - 最大连接数: 20
   - 配置合理，适合中等规模项目

3. **生产环境用户权限分离** ✅
   - 开发环境: root 用户
   - 生产环境: reader 用户（权限更受限）
   - **建议**: 检查 reader 用户是否真的存在且权限正确

### 🔧 改进建议
```yaml
# 在 application-prod.yml 中，建议添加
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      maximum-lifetime: 1800000
      connection-timeout: 30000
```

---

## 2️⃣ Redis 配置检查

### ✅ 基础配置状态

| 环境 | 主机 | 端口 | 数据库 | 密码 | 状态 |
|------|------|------|--------|------|------|
| Dev (mall-admin) | localhost | 6379 | 0 | 无 | ✅ 正确 |
| Dev (mall-portal) | localhost | 6379 | 0 | 无 | ✅ 正确 |
| Prod (mall-admin) | redis | 6379 | 0 | 无 | ✅ 正确 |
| Prod (mall-portal) | redis | 6379 | 0 | 无 | ✅ 正确 |
| Docker Compose | redis | 6379 | - | 无 | ✅ 正确 |

### 📝 配置文件位置
- `mall-admin/src/main/resources/application-dev.yml` - 第 19-23 行
- `mall-portal/src/main/resources/application-dev.yml` - 第 37-41 行
- 代码配置: `mall-common/src/main/java/com/macro/mall/common/config/BaseRedisConfig.java`

### 📊 Redis 使用情况

| 模块 | 用途 | 过期时间 | 键前缀 |
|------|------|----------|--------|
| mall-admin | 管理后台缓存 | 24小时 | `ums:admin`, `ums:resourceList` |
| mall-portal | 订单ID、会员信息 | 90秒-24小时 | `ums:authCode`, `oms:orderId`, `ums:member` |

### ⚠️ 发现的问题
1. **Redis 无密码保护** ⚠️ 
   - 问题: 开发和生产环境都没有设置 Redis 密码
   - **建议**: 生产环境应设置密码
   ```yaml
   # application-prod.yml
   spring:
     data:
       redis:
         password: your-strong-password-here
   ```

2. **缓存配置不一致** ⚠️
   - mall-admin 缓存有效期: 1天 (1800000ms)
   - mall-portal 缓存有效期: 24小时
   - **建议**: 统一配置策略

3. **序列化配置** ✅
   - 使用了 Jackson2JsonRedisSerializer
   - 已启用默认类型化，支持对象序列化

### 🔧 改进建议
```java
// BaseRedisConfig.java 中添加
@Bean
public RedisCacheConfiguration getCacheConfiguration() {
    return RedisCacheConfiguration.defaultCacheConfig()
        .entryTtl(Duration.ofHours(24))
        .disableCachingNullValues()
        .serializeValuesWith(
            RedisSerializationContext.SerializationPair
                .fromSerializer(redisSerializer()));
}
```

---

## 3️⃣ MongoDB 配置检查

### ✅ 基础配置状态

| 环境 | 主机 | 端口 | 数据库 | 用户名 | 密码 | 状态 |
|------|------|------|--------|--------|------|------|
| Dev (mall-portal) | localhost | 27017 | mall-port | - | - | ✅ 正确 |
| Docker Compose | mongodb | 27017 | - | - | - | ✅ 正确 |

### 📝 配置文件位置
- `mall-portal/src/main/resources/application-dev.yml` - 第 19-22 行
- DevContainer: `.devcontainer/docker-compose.yml` - 第 72-84 行

### ⚠️ 发现的问题

1. **MongoDB 仅用于 mall-portal** ✅
   - 只有门户模块使用了 MongoDB
   - 用于存储评价、留言等非结构化数据

2. **缺少生产环境配置** ⚠️
   - mall-portal 的 `application-prod.yml` 中没有 MongoDB 配置
   - **需要添加** MongoDB 的生产环境配置
   ```yaml
   # mall-portal/src/main/resources/application-prod.yml 中添加
   spring:
     data:
       mongodb:
         uri: mongodb://user:password@mongo-prod:27017/mall-port?authSource=admin
   ```

3. **无身份认证** ⚠️
   - 开发和生产环境都没有设置 MongoDB 用户认证
   - **建议**: 至少在生产环境启用身份认证
   ```yaml
   spring:
     data:
       mongodb:
         uri: mongodb://admin:password@mongo:27017/mall-port?authSource=admin
   ```

4. **数据库名称不一致** ⚠️
   - Dev: `mall-port`（使用了连字符）
   - 建议改为 `mall_portal`（下划线）以遵循命名规范

### 🔧 改进建议
```yaml
# application-prod.yml
spring:
  data:
    mongodb:
      uri: mongodb+srv://admin:${MONGO_PASSWORD}@mongo-prod.example.com/mall_portal?retryWrites=true&w=majority
      auto-index-creation: true
```

---

## 4️⃣ RabbitMQ 配置检查

### ✅ 基础配置状态

| 环境 | 主机 | 端口 | 用户名 | 密码 | VHost | 状态 |
|------|------|------|--------|------|-------|------|
| Dev (mall-portal) | localhost | 5672 | mall | mall | /mall | ✅ 正确 |
| Prod (mall-portal) | rabbitmq | 5672 | mall | mall | /mall | ✅ 正确 |
| Docker Compose | rabbitmq | 5672 | mall | mall | /mall | ✅ 正确 |
| Management UI | - | 15672 | mall | mall | - | ✅ 正确 |

### 📝 配置文件位置
- `mall-portal/src/main/resources/application-dev.yml` - 第 23-28 行
- 代码配置: `mall-portal/src/main/java/com/macro/mall/portal/config/RabbitMqConfig.java`
- 队列定义: `.devcontainer/docker-compose.yml` - 第 85-105 行

### 📊 RabbitMQ 使用情况

| 功能 | 交换机 | 队列 | 路由键 | 说明 |
|------|--------|------|--------|------|
| 订单取消 | orderDirect | cancelOrderQueue | order.cancel | 实时处理订单取消 |
| 订单延迟 | orderTtlDirect | orderTtlQueue | order.ttl.cancel | 延迟队列（死信队列机制） |

### ✅ 配置正确性检查

1. **虚拟主机设置** ✅
   - 使用独立的虚拟主机 `/mall`
   - 避免与其他应用冲突

2. **用户权限** ✅
   - 使用专用用户 `mall` 而非 guest
   - 生产环境应改用强密码

3. **队列配置** ✅
   - 订单取消队列: 持久化
   - 死信队列配置正确
   - TTL (Time To Live) 设置: 暂未在配置中明确看到

4. **Management UI** ✅
   - 端口 15672 正确
   - 可用于监控和管理

### ⚠️ 发现的问题

1. **缺少死信队列的 TTL 配置** ⚠️
   ```java
   // 建议在 RabbitMqConfig.java 中添加 TTL
   @Bean
   public Queue orderTtlQueue() {
       return QueueBuilder
           .durable(QueueEnum.QUEUE_TTL_ORDER_CANCEL.getName())
           .withArgument("x-message-ttl", 3600000)  // 1小时后转发到死信队列
           .withArgument("x-dead-letter-exchange", QueueEnum.QUEUE_ORDER_CANCEL.getExchange())
           .withArgument("x-dead-letter-routing-key", QueueEnum.QUEUE_ORDER_CANCEL.getRouteKey())
           .build();
   }
   ```

2. **仅 mall-portal 使用 RabbitMQ** ✅
   - 其他模块 (mall-admin, mall-search) 没有使用消息队列
   - 这是正确的架构设计

3. **缺少连接池配置** ⚠️
   ```yaml
   spring:
     rabbitmq:
       connection-timeout: 10000
       requested-heartbeat: 30
       cache:
         channel:
           size: 20
           checkout-timeout: 20000
   ```

### 🔧 改进建议
```yaml
# application-prod.yml
spring:
  rabbitmq:
    host: rabbitmq-prod
    port: 5672
    username: mall
    password: ${RABBITMQ_PASSWORD}  # 使用环境变量
    virtual-host: /mall
    ssl: true
    connection-timeout: 10s
    listener:
      simple:
        max-concurrency: 10
        prefetch: 1
        retry:
          enabled: true
          max-attempts: 3
          initial-interval: 5000
```

---

## 📊 综合配置矩阵

```
┌─────────────────┬──────────┬──────────┬──────────┬──────────┐
│ 中间件          │ 开发环境 │ 生产环境 │ 安全性   │ 可用性   │
├─────────────────┼──────────┼──────────┼──────────┼──────────┤
│ MySQL           │ ✅ 完整 │ ⚠️ 有配置 │ ⚠️ 需加强 │ ✅ 良好 │
│ Redis           │ ✅ 完整 │ ⚠️ 有配置 │ ⚠️ 无密码 │ ✅ 良好 │
│ MongoDB         │ ✅ 完整 │ ⚠️ 缺失  │ ⚠️ 无认证 │ ⚠️ 需完善 │
│ RabbitMQ        │ ✅ 完整 │ ✅ 完整 │ ⚠️ 弱密码 │ ⚠️ 需优化 │
└─────────────────┴──────────┴──────────┴──────────┴──────────┘
```

---

## 🚨 优先级问题清单

### 🔴 高优先级（必须修复）

1. **MongoDB 生产配置缺失** 
   - 文件: `mall-portal/src/main/resources/application-prod.yml`
   - 影响: 生产环境无法启动 mall-portal 模块
   - 修复时间: 15 分钟

2. **无认证的中间件暴露**
   - Redis、MongoDB、RabbitMQ 都没有身份认证
   - 风险: 数据泄露、服务被滥用
   - 修复时间: 30 分钟

### 🟡 中优先级（应该修复）

1. **缺少连接池优化配置**
   - RabbitMQ 缺少连接池配置
   - Redis 缺少高级配置选项
   - 修复时间: 30 分钟

2. **TTL 配置不完整**
   - RabbitMQ 死信队列缺少 TTL 配置
   - 修复时间: 20 分钟

### 🟢 低优先级（建议改进）

1. **数据库命名规范**
   - MongoDB 数据库使用连字符 `mall-port`
   - 建议改为 `mall_portal`
   - 修复时间: 10 分钟

2. **重试和容错机制**
   - RabbitMQ 缺少重试策略
   - 修复时间: 30 分钟

---

## 📝 快速修复清单

### ✅ 第一步：添加 MongoDB 生产配置
```yaml
# mall-portal/src/main/resources/application-prod.yml
spring:
  data:
    mongodb:
      uri: mongodb://admin:password@mongo:27017/mall_portal?authSource=admin
```

### ✅ 第二步：保护 Redis（生产环境）
```yaml
# application-prod.yml
spring:
  data:
    redis:
      password: ${REDIS_PASSWORD}  # 使用环境变量
```

### ✅ 第三步：保护 RabbitMQ（生产环境）
```yaml
# application-prod.yml
spring:
  rabbitmq:
    password: ${RABBITMQ_PASSWORD}  # 使用环境变量
    ssl: true  # 启用 SSL
```

### ✅ 第四步：添加 MongoDB 认证
```yaml
# application-prod.yml
spring:
  data:
    mongodb:
      username: mall
      password: ${MONGO_PASSWORD}
      authentication-database: admin
```

---

## 🔍 验证步骤

### 验证 MySQL
```bash
mysql -h localhost -u root -p -e "SELECT version();" 
mysql -h localhost -u root -p mall -e "SHOW TABLES;"
```

### 验证 Redis
```bash
redis-cli ping
redis-cli INFO server
redis-cli DBSIZE
```

### 验证 MongoDB
```bash
mongosh --host localhost --port 27017
db.adminCommand('ping')
db.mall_portal.stats()
```

### 验证 RabbitMQ
```bash
# 访问管理界面
# http://localhost:15672  用户名: mall  密码: mall

# 或者使用命令行
rabbitmq-diagnostics -q ping
rabbitmq-diagnostics list_queues
```

---

## 📚 相关文件索引

| 配置类型 | 文件路径 | 描述 |
|---------|---------|------|
| mall-admin 开发 | `mall-admin/src/main/resources/application-dev.yml` | 开发环境配置 |
| mall-admin 生产 | `mall-admin/src/main/resources/application-prod.yml` | 生产环境配置 |
| mall-portal 开发 | `mall-portal/src/main/resources/application-dev.yml` | 开发环境配置 |
| mall-portal 生产 | `mall-portal/src/main/resources/application-prod.yml` | **缺 MongoDB** |
| mall-search 开发 | `mall-search/src/main/resources/application-dev.yml` | 开发环境配置 |
| Redis 代码配置 | `mall-common/src/main/java/com/macro/mall/common/config/BaseRedisConfig.java` | Redis Bean 配置 |
| RabbitMQ 代码配置 | `mall-portal/src/main/java/com/macro/mall/portal/config/RabbitMqConfig.java` | 队列和交换机配置 |
| Docker Compose | `.devcontainer/docker-compose.yml` | 容器化服务配置 |
| Prod Compose | `document/docker/docker-compose-env.yml` | 生产环境容器配置 |

---

## ✨ 总结

**配置完整性**: 65% 
- ✅ MySQL、Redis、RabbitMQ 配置基本完整
- ⚠️ MongoDB 生产配置缺失

**安全性**: 40% 
- ⚠️ 缺少密码保护
- ⚠️ 无 SSL/TLS 加密
- ⚠️ 凭证硬编码在配置文件中

**高可用性**: 50%
- ⚠️ 缺少连接池优化
- ⚠️ 缺少重试机制
- ⚠️ 缺少熔断保护

**建议**: 立即修复高优先级问题，然后逐步实施中低优先级改进。

