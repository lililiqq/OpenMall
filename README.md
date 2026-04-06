# OpenMall

> 一个基于 **Spring Boot 3.x + Vue 3** 的前后端分离模拟淘宝项目，包含 **用户端** 与 **商家端** 两套前端页面，支持商品浏览、购物车、下单、支付模拟，以及商家侧商品管理、订单管理等核心能力。

---

## 1. 项目简介

OpenMall 是一个面向学习与作品集展示的电商项目，参考淘宝的核心购物流程进行设计。

项目目标不是完整复刻真实淘宝，而是在合理规模下实现一个结构清晰、功能闭环完整、便于扩展的模拟电商系统。

本项目采用：

- **用户端**：面向普通用户，负责浏览商品、加入购物车、提交订单、支付模拟、查询订单
- **商家端**：面向商家，负责店铺信息维护、商品管理、库存管理、订单处理
- **后端服务**：负责统一提供 RESTful API 与核心业务逻辑

---

## 2. 项目目标

本项目主要用于：

- 学习 Spring Boot 项目分层设计
- 学习 Vue3 前后端分离开发模式
- 掌握电商系统的核心业务建模思路
- 理解 Spring Security + JWT、MyBatis-Plus、Redis、RabbitMQ、阿里云 OSS、Docker 等技术在业务系统中的典型用法
- 打造一个适合校招、实习、毕业设计或个人作品集展示的完整项目

---

## 3. 核心功能

### 3.1 用户端功能

- 用户注册与登录
- 商品分类浏览
- 商品列表与商品详情查看
- 商品 SKU 选择
- 加入购物车
- 购物车管理
- 提交订单
- 支付模拟
- 订单列表与订单详情查询
- 取消未支付订单
- 收货地址管理

### 3.2 商家端功能

- 商家登录
- 店铺信息维护
- 商品新增、编辑、上下架
- 商品库存与价格管理
- 店铺订单列表查询
- 订单详情查看
- 发货与订单状态更新

---

## 4. 技术栈

### 4.1 后端

- Java 17
- Spring Boot 3.x
- Spring Security + JWT
- MyBatis-Plus
- Knife4j
- Druid
- Maven

### 4.2 前端

- Vue 3
- Vite
- Vue Router
- Pinia
- Axios
- Element Plus

### 4.3 基础设施

- MySQL 8.0.34
- Redis
- Spring Cache
- RabbitMQ
- 阿里云 OSS
- Nginx
- Docker
- Git

### 4.4 技术栈说明

- **Spring Boot 3.x**：后端核心开发框架
- **Spring Security + JWT**：用户端与商家端统一认证鉴权
- **MyBatis-Plus**：简化持久层 CRUD 与分页开发
- **Knife4j**：在线接口文档与联调测试
- **MySQL 8.0.34**：核心业务数据存储
- **Redis + Spring Cache**：热点数据缓存与缓存管理
- **Druid**：数据库连接池与 SQL 监控
- **RabbitMQ**：订单超时关闭、库存回补等异步场景
- **阿里云 OSS**：商品图片、店铺资源等文件存储
- **Vue 3**：构建用户端与商家端前端页面
- **Nginx**：静态资源托管与反向代理
- **Docker**：开发、测试、演示环境快速部署
- **Git**：版本控制与协作管理

---

## 5. 系统架构说明

本项目采用 **前后端分离 + 模块化单体** 架构。

### 5.1 架构组成

- **用户端前端**：面向消费者
- **商家端前端**：面向店铺商家
- **Spring Boot 后端**：统一承载业务逻辑
- **Spring Security + JWT**：负责用户端与商家端身份认证、接口权限控制
- **MyBatis-Plus + Druid**：负责数据访问与数据库连接管理
- **MySQL 8.0.34**：存储用户、商品、订单、支付等核心数据
- **Redis + Spring Cache**：用于缓存、登录态、热点数据、幂等控制
- **RabbitMQ**：用于订单超时关闭、库存回补、异步通知等场景
- **阿里云 OSS**：用于商品图片、店铺 Logo、富文本图片等文件存储
- **Knife4j**：用于接口文档展示与接口调试

### 5.2 当前阶段架构策略

- 优先采用模块化单体架构
- 优先跑通业务闭环
- 在保证结构清晰的前提下再逐步增强缓存与消息队列能力
- 暂不引入微服务拆分，避免项目复杂度过高
- 通过 Nginx + Docker 预留部署扩展能力

---

## 6. 项目结构建议

```bash
OpenMall/
├─ docs/
│  ├─ DESIGN.md
│  ├─ API.md
│  ├─ DB.md
│  ├─ fsd.md
│  ├─ 技术栈说明.md
│  ├─ README-开发规范.md
│  └─ 部署说明.md
├─ sql/
│  └─ openmall.sql
├─ openmall-server/
│  └─ src/main/java/com/openmall/
│     ├─ common/
│     │  ├─ api/
│     │  └─ exception/
│     ├─ config/
│     ├─ modules/
│     │  ├─ user/
│     │  ├─ merchant/
│     │  ├─ shop/
│     │  ├─ address/
│     │  ├─ category/
│     │  ├─ product/
│     │  ├─ cart/
│     │  ├─ order/
│     │  ├─ inventory/
│     │  ├─ payment/
│     │  └─ merchant-center/
├─ openmall-user-web/
├─ openmall-merchant-web/
└─ README.md
```

---

## 7. 数据库设计思路

本项目数据库设计围绕“用户、商家、店铺、商品、购物车、订单、支付”展开。

建议核心表包括：

- `user`：用户表
- `user_address`：用户地址表
- `merchant`：商家表
- `shop`：店铺表
- `category`：商品分类表
- `product_spu`：商品 SPU 表
- `product_sku`：商品 SKU 表
- `cart_item`：购物车项表
- `orders`：订单主表
- `order_item`：订单明细表
- `payment_record`：支付记录表
- `file_record`：文件上传记录表（可选，配合 OSS 使用）

设计要点：

- 商品采用 **SPU + SKU** 模型
- SKU 建议通过 `spec_json` 保存独有规格属性，便于前端动态展示规格组合
- 商品与订单需具备 **店铺归属信息**
- 金额字段建议统一使用 `decimal(12,2)`，后端统一使用 `BigDecimal`
- 订单建议拆分 `order_status`、`pay_status`、`delivery_status` 三个维度
- 订单明细建议保留商品快照字段
- 下单与锁定库存应位于同一事务边界内，未支付订单取消或超时关闭后释放锁定库存
- 文件资源建议统一接入阿里云 OSS，并记录文件元信息
- 购物车可在高频访问场景下通过 Redis 做短期缓存加速，但最终状态仍以 MySQL 为准

---

## 8. 核心 API 示例

接口设计补充说明：

- 统一响应结构建议包含：`code`、`message`、`data`、`timestamp`
- 项目当前采用业务状态码体系，成功为 `0`，未登录或 Token 无效为 `4002`
- 分页接口建议统一返回：`pageNum`、`pageSize`、`total`、`list`、`hasNextPage`
- 用户端与商家端均采用 JWT 鉴权；商家端接口除校验 Token 外，还需校验商家身份与店铺归属
- 购物车“加入商品”建议采用幂等语义：同一 `skuId` 已存在则累加数量，不存在则新增
- 购物车展示价格仅作参考，订单预览与创建订单时都应按最新 SKU 价格重校验
- 订单建议采用 `order_status`、`pay_status`、`delivery_status` 三个维度联合描述状态
- 未支付订单建议设置支付有效期，超时关闭后释放锁定库存
- 支付模块虽然当前为模拟支付，仍建议预留异步回调接口设计，便于后续扩展

### 8.1 用户端接口

#### 认证与用户
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/users/me`

#### 地址管理
- `GET /api/v1/addresses`
- `POST /api/v1/addresses`
- `PUT /api/v1/addresses/{id}`
- `DELETE /api/v1/addresses/{id}`

#### 商品模块
- `GET /api/v1/categories`
- `GET /api/v1/products`
- `GET /api/v1/products/{id}`

#### 购物车模块
- `GET /api/v1/cart/items`
- `POST /api/v1/cart/items`
- `PUT /api/v1/cart/items/{id}`
- `DELETE /api/v1/cart/items/{id}`

#### 订单模块
- `POST /api/v1/orders/preview`
- `POST /api/v1/orders`
- `GET /api/v1/orders`
- `GET /api/v1/orders/{id}`
- `POST /api/v1/orders/{id}/cancel`

#### 支付模块
- `POST /api/v1/payments/{orderNo}/mock-pay`
- `GET /api/v1/payments/{orderNo}`

### 8.2 商家端接口

- `POST /merchant/api/v1/auth/login`
- `GET /merchant/api/v1/shop/profile`
- `PUT /merchant/api/v1/shop/profile`
- `GET /merchant/api/v1/products`
- `POST /merchant/api/v1/products`
- `PUT /merchant/api/v1/products/{id}`
- `PUT /merchant/api/v1/products/{id}/status`
- `PUT /merchant/api/v1/skus/{id}/stock`
- `GET /merchant/api/v1/orders`
- `GET /merchant/api/v1/orders/{id}`
- `PUT /merchant/api/v1/orders/{id}/delivery-status`

---

## 9. 业务流程概览

### 9.1 用户下单流程

1. 用户注册或登录
2. 浏览商品列表与详情
3. 选择 SKU 并加入购物车
4. 在购物车中勾选商品并进入订单预览
5. 系统校验最新库存与价格
6. 创建订单并锁定库存
7. 用户发起模拟支付
8. 系统更新订单状态，超时未支付订单自动关闭并释放锁定库存

### 9.2 商家履约流程

1. 商家登录商家端
2. 查看店铺订单列表
3. 查看订单详情与收货信息
4. 处理发货
5. 更新订单状态

---

## 10. 快速启动

### 10.1 环境要求

- JDK 17+
- Node.js 18+
- MySQL 8.0.34
- Redis 6.x+
- RabbitMQ 3.x+
- Maven 3.9+
- Nginx
- Docker（推荐）
- Git

### 10.2 后端启动

```bash
# 1. 导入数据库脚本
mysql -uroot -p < sql/openmall.sql

# 2. 修改配置文件
openmall-server/src/main/resources/application.yml

# 3. 启动后端
cd openmall-server
mvn spring-boot:run
```

### 10.3 用户端启动

```bash
cd openmall-user-web
npm install
npm run dev
```

### 10.4 商家端启动

```bash
cd openmall-merchant-web
npm install
npm run dev
```

---

## 11. 版本规划

### V1.0

- 用户注册与登录
- 商品浏览与商品详情
- 购物车管理
- 创建订单
- 支付模拟
- 订单查询与取消

### V1.1

- 商家端商品管理
- 商家端订单管理
- Redis 商品缓存
- 接口文档完善

### V1.2

- RabbitMQ 订单超时关闭
- 库存回补
- 商品评价
- 收藏功能

---

## 12. 文档说明

项目文档见：

- `docs/DESIGN.md`
- `docs/API.md`
- `docs/DB.md`
- `docs/fsd.md`
- `docs/技术栈说明.md`
- `docs/README-开发规范.md`
- `docs/部署说明.md`

---

## 13. 后续扩展方向

- 商品评价系统
- 优惠券系统
- 秒杀活动
- 搜索能力
- 商家入驻系统增强
- 推荐系统
- 微服务拆分

---

## 14. License

本项目仅用于学习与交流，禁止用于商业用途。
