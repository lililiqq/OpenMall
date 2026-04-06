# OpenMall 数据库设计文档

> 本文档用于详细说明 OpenMall 项目的数据库设计方案，覆盖核心表结构、字段设计思路、表关系、索引策略、状态字段约定以及一致性设计。当前数据库方案基于 **MySQL 8.0.34**，适用于 OpenMall 当前的 **用户端 + 商家端 + 后端服务** 架构。

---

## 1. 文档目标

本数据库文档主要用于：

- 明确数据库建模思路
- 统一核心数据实体与字段命名
- 为后续建表 SQL 编写提供依据
- 为后端开发、接口设计、测试准备基础数据结构

---

## 2. 数据库设计原则

OpenMall 的数据库设计遵循以下原则：

1. **以业务闭环为核心建模**
2. **主业务数据统一落 MySQL**
3. **缓存不替代数据库事实源**
4. **交易链路优先保证一致性**
5. **字段命名统一、可读性优先**
6. **结构设计为后续扩展预留空间**

当前重点围绕以下业务域展开：

- 用户域
- 商家与店铺域
- 商品域
- 购物车域
- 订单域
- 支付域
- 文件存储元数据域

---

## 3. 数据库总体说明

### 3.1 数据库版本

- MySQL 8.0.34

### 3.2 字符集建议

- 字符集：`utf8mb4`
- 排序规则：`utf8mb4_general_ci`

### 3.3 命名规范

- 表名使用：`小写 + 下划线`
- 字段名使用：`小写 + 下划线`
- 主键统一命名：`id`
- 创建时间：`create_time`
- 更新时间：`update_time`
- 逻辑状态字段：`status`

### 3.4 金额、状态与逻辑删除约定

#### 3.4.1 金额字段约定

- 数据库金额字段建议统一使用 `decimal(12,2)`，满足当前模拟电商项目的常见金额场景
- 后端 Java 金额字段建议统一使用 `BigDecimal`
- 项目必须统一金额单位语义，禁止部分模块使用“元”、部分模块使用“分”而没有明确转换规则
- 若支付对接或高频金额计算场景需要使用“分”为单位的整数进行中间计算，应在服务层统一转换，对外存储与展示仍保持一致

#### 3.4.2 多维状态字段约定

- 订单主状态建议与支付状态、履约状态拆分建模
- 推荐至少区分：
  - `order_status`：订单主生命周期
  - `pay_status`：支付维度状态
  - `delivery_status`：履约/物流维度状态

#### 3.4.3 逻辑删除与审计建议

- 核心业务表建议优先考虑逻辑删除而不是物理删除
- 数据库字段命名建议使用：`deleted` 或 `delete_status`，不建议使用 `is_deleted`
- 订单、支付记录等强审计表应优先保留历史数据，不建议随意物理删除
- 下文表结构重点展示核心业务字段；若项目采用统一逻辑删除方案，可在可软删除表中追加 `deleted` 字段

#### 3.4.4 商品搜索边界建议

- 当前阶段商品搜索建议以 MySQL 的基础关键字过滤、分类筛选与排序能力为主
- Elasticsearch 不作为当前版本数据库设计的必选前提，应视后续搜索复杂度再引入
- 若未来引入 Elasticsearch，应重点关注 MySQL 与搜索索引之间的增量同步与最终一致性问题

---

## 4. 核心表总览

当前阶段建议包含以下核心表：

| 表名 | 说明 |
| --- | --- |
| `user` | 用户表 |
| `user_address` | 用户收货地址表 |
| `merchant` | 商家账号表 |
| `shop` | 店铺表 |
| `category` | 商品分类表 |
| `product_spu` | 商品 SPU 表 |
| `product_sku` | 商品 SKU 表 |
| `cart_item` | 购物车项表 |
| `orders` | 订单主表 |
| `order_item` | 订单明细表 |
| `payment_record` | 支付记录表 |
| `file_record` | 文件记录表（OSS 元数据） |

---

## 5. 业务关系说明

### 5.1 用户与地址

- 一个用户可以拥有多个收货地址
- 一个地址只属于一个用户

### 5.2 商家与店铺

- 一个商家当前阶段默认对应一个店铺
- 一个店铺归属于一个商家

### 5.3 店铺与商品

- 一个店铺可以发布多个商品
- 一个商品（SPU）属于一个店铺
- 一个 SPU 下可以有多个 SKU

### 5.4 用户与购物车

- 一个用户可拥有多个购物车项
- 一个购物车项关联一个 SKU

### 5.5 用户、店铺与订单

- 一个用户可产生多个订单
- 一个店铺可拥有多个订单
- 一个订单包含多个订单明细项

### 5.6 订单与支付

- 一个订单通常对应一条主支付记录
- 若后续扩展退款或多次支付尝试，可扩展多条支付流水

### 5.7 文件与业务资源

- 商品图片、店铺 Logo、富文本图片可统一上传至 OSS
- `file_record` 用于记录对应文件的元信息

---

## 6. 表结构设计

---

## 6.1 用户表 `user`

### 6.1.1 表说明

用于存储普通用户的基础信息与登录信息。

### 6.1.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| username | varchar(64) | 用户名，唯一 |
| password | varchar(128) | 密码摘要 |
| phone | varchar(20) | 手机号 |
| nickname | varchar(64) | 昵称 |
| avatar | varchar(255) | 头像地址 |
| status | tinyint | 用户状态，1启用 0禁用 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.1.3 索引建议

- 唯一索引：`username`
- 普通索引：`phone`

---

## 6.2 用户地址表 `user_address`

### 6.2.1 表说明

用于维护用户收货地址。

### 6.2.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| user_id | bigint | 用户 ID |
| receiver_name | varchar(64) | 收货人姓名 |
| receiver_phone | varchar(20) | 收货手机号 |
| province | varchar(32) | 省 |
| city | varchar(32) | 市 |
| district | varchar(32) | 区 |
| detail_address | varchar(255) | 详细地址 |
| is_default | tinyint | 是否默认地址 |
| status | tinyint | 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.2.3 索引建议

- 普通索引：`user_id`
- 联合索引：`user_id + is_default`

---

## 6.3 商家表 `merchant`

### 6.3.1 表说明

用于存储商家登录账号与基础资料。

### 6.3.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| username | varchar(64) | 商家登录账号，唯一 |
| password | varchar(128) | 密码摘要 |
| contact_name | varchar(64) | 联系人姓名 |
| contact_phone | varchar(20) | 联系电话 |
| status | tinyint | 商家状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.3.3 索引建议

- 唯一索引：`username`

---

## 6.4 店铺表 `shop`

### 6.4.1 表说明

用于存储店铺基础信息。

### 6.4.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| merchant_id | bigint | 商家 ID |
| shop_name | varchar(128) | 店铺名称 |
| logo | varchar(255) | 店铺 Logo |
| description | varchar(500) | 店铺简介 |
| status | tinyint | 店铺状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.4.3 索引建议

- 唯一索引：`merchant_id`
- 普通索引：`shop_name`

---

## 6.5 分类表 `category`

### 6.5.1 表说明

用于商品分类管理，可支持一级分类与二级分类。

### 6.5.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| parent_id | bigint | 父级分类 ID，顶级可为 0 |
| name | varchar(64) | 分类名称 |
| sort | int | 排序值 |
| status | tinyint | 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.5.3 索引建议

- 普通索引：`parent_id`
- 普通索引：`sort`

---

## 6.6 商品 SPU 表 `product_spu`

### 6.6.1 表说明

用于描述商品公共信息。

### 6.6.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| shop_id | bigint | 店铺 ID |
| category_id | bigint | 分类 ID |
| spu_name | varchar(128) | 商品名称 |
| main_image | varchar(255) | 主图 |
| album_images | text | 轮播图集合，可 JSON 存储 |
| detail | longtext | 商品详情 |
| status | varchar(32) | 商品状态，如 ON_SALE / OFF_SALE |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.6.3 索引建议

- 普通索引：`shop_id`
- 普通索引：`category_id`
- 普通索引：`status`
- 联合索引：`shop_id + status`
- 联合索引：`category_id + status`

---

## 6.7 商品 SKU 表 `product_sku`

### 6.7.1 表说明

用于描述商品具体规格与价格库存信息。

### 6.7.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| spu_id | bigint | SPU ID |
| sku_code | varchar(64) | SKU 编码 |
| sku_name | varchar(128) | SKU 名称 |
| spec_json | json / text | SKU 独有规格属性 JSON，例如颜色、尺码、版本 |
| price | decimal(12,2) | 销售价 |
| stock | int | 当前可售库存 |
| lock_stock | int | 锁定库存（待支付占用） |
| status | tinyint | SKU 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

补充说明：

- `spec_json` 可理解为该 SKU 的 `own_spec`，用于前端动态展示当前选中规格
- 该字段有助于支持“不同规格不同价格、不同库存”的商品详情展示与下单校验
- 若未来出现对 JSON 子字段的高频过滤需求，可进一步通过生成列或派生字段配合索引优化查询性能
- 创建订单时建议原子地减少 `stock` 并增加 `lock_stock`，表示该部分库存已被待支付订单占用
- 用户取消订单或系统超时关闭订单时，应释放对应 `lock_stock` 并回补到 `stock`

### 6.7.3 索引建议

- 唯一索引：`sku_code`
- 普通索引：`spu_id`
- 普通索引：`status`

---

## 6.8 购物车项表 `cart_item`

### 6.8.1 表说明

用于存储用户购物车中的商品项。

补充说明：

- 购物车中的价格更适合作为展示或缓存数据，不建议将其作为最终成交价事实源
- 订单预览与创建订单时，应始终以当前 SKU 最新价格重新校验，最终成交价以 `order_item.price` 快照为准

### 6.8.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| user_id | bigint | 用户 ID |
| shop_id | bigint | 店铺 ID |
| sku_id | bigint | SKU ID |
| quantity | int | 商品数量 |
| checked | tinyint | 是否勾选 |
| status | tinyint | 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.8.3 索引建议

- 普通索引：`user_id`
- 联合唯一索引：`user_id + sku_id`

---

## 6.9 订单主表 `orders`

### 6.9.1 表说明

用于记录订单整体信息。

### 6.9.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| order_no | varchar(64) | 订单编号，唯一 |
| user_id | bigint | 用户 ID |
| shop_id | bigint | 店铺 ID |
| order_status | varchar(32) | 订单状态 |
| pay_status | varchar(32) | 支付状态 |
| delivery_status | varchar(32) | 履约 / 物流状态 |
| total_amount | decimal(12,2) | 商品总金额 |
| freight_amount | decimal(12,2) | 运费 |
| pay_amount | decimal(12,2) | 实付金额 |
| receiver_name | varchar(64) | 收货人 |
| receiver_phone | varchar(20) | 收货手机号 |
| receiver_address | varchar(255) | 收货地址快照 |
| remark | varchar(255) | 用户备注 |
| logistics_company | varchar(64) | 物流公司 |
| tracking_no | varchar(64) | 物流单号 |
| pay_time | datetime | 支付时间 |
| cancel_time | datetime | 取消时间 |
| delivery_time | datetime | 发货时间 |
| finish_time | datetime | 完成时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

补充说明：

- `order_status`、`pay_status`、`delivery_status` 应分别承担不同维度的状态表达职责
- 订单是否已支付、是否已发货、是否已完成，不建议仅依赖单一字段判断
- `CANCELED` 建议表示用户主动取消，`CLOSED` 建议表示系统因超时未支付自动关闭

### 6.9.3 索引建议

- 唯一索引：`order_no`
- 普通索引：`user_id`
- 普通索引：`shop_id`
- 普通索引：`order_status`
- 联合索引：`user_id + order_status`
- 联合索引：`shop_id + order_status`

---

## 6.10 订单明细表 `order_item`

### 6.10.1 表说明

用于记录订单中的商品明细与商品快照。

补充说明：

- `order_item.price` 应作为最终成交单价快照保存，不应在订单创建后随商品价格变化而被覆盖

### 6.10.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| order_id | bigint | 订单 ID |
| order_no | varchar(64) | 订单编号 |
| shop_id | bigint | 店铺 ID |
| spu_id | bigint | SPU ID |
| sku_id | bigint | SKU ID |
| spu_name | varchar(128) | 商品名称快照 |
| sku_name | varchar(128) | SKU 名称快照 |
| main_image | varchar(255) | 主图快照 |
| price | decimal(12,2) | 下单单价 |
| quantity | int | 数量 |
| amount | decimal(12,2) | 小计金额 |
| spec_text | varchar(255) | 规格文本快照 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.10.3 索引建议

- 普通索引：`order_id`
- 普通索引：`order_no`
- 普通索引：`shop_id`

---

## 6.11 支付记录表 `payment_record`

### 6.11.1 表说明

用于记录订单支付流水。

### 6.11.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| order_id | bigint | 订单 ID |
| order_no | varchar(64) | 订单编号 |
| pay_no | varchar(64) | 支付流水号 |
| pay_channel | varchar(32) | 支付渠道 |
| pay_status | varchar(32) | 支付状态 |
| pay_amount | decimal(12,2) | 支付金额 |
| pay_time | datetime | 支付时间 |
| callback_content | text | 回调内容 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.11.3 索引建议

- 唯一索引：`pay_no`
- 普通索引：`order_no`
- 普通索引：`pay_status`

---

## 6.12 文件记录表 `file_record`

### 6.12.1 表说明

用于记录上传到阿里云 OSS 的文件元信息。

### 6.12.2 关键字段建议

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| biz_type | varchar(32) | 业务类型，如 PRODUCT_MAIN / PRODUCT_ALBUM / SKU_IMAGE / SHOP_LOGO / EDITOR_IMAGE |
| biz_id | bigint | 业务主键 ID |
| original_name | varchar(255) | 原始文件名 |
| object_key | varchar(255) | OSS 对象 Key |
| file_url | varchar(500) | 文件访问地址 |
| content_type | varchar(100) | 文件类型 |
| file_size | bigint | 文件大小 |
| uploader_type | varchar(32) | 上传人类型 USER / MERCHANT / ADMIN |
| uploader_id | bigint | 上传人 ID |
| status | tinyint | 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 6.12.3 索引建议

- 普通索引：`biz_type + biz_id`
- 普通索引：`uploader_type + uploader_id`
- 唯一索引：`object_key`

---

## 7. 状态字段设计建议

### 7.1 用户状态

| 值 | 含义 |
| --- | --- |
| 1 | 启用 |
| 0 | 禁用 |

### 7.2 商品状态

| 值 | 含义 |
| --- | --- |
| ON_SALE | 上架 |
| OFF_SALE | 下架 |

### 7.3 订单状态

| 值 | 含义 |
| --- | --- |
| UNPAID | 待支付 |
| PROCESSING | 已支付待履约 / 处理中 |
| COMPLETED | 已完成 |
| CANCELED | 已取消 |
| CLOSED | 已关闭 |

### 7.4 支付状态

| 值 | 含义 |
| --- | --- |
| UNPAID | 未支付 |
| PAID | 已支付 |
| FAILED | 支付失败 |

### 7.5 履约 / 物流状态

| 值 | 含义 |
| --- | --- |
| PENDING_DELIVERY | 待发货 |
| SHIPPED | 已发货 |
| RECEIVED | 已签收 |

---

## 8. 索引设计原则

数据库索引建议遵循以下原则：

1. 高频查询字段建立索引
2. 唯一业务标识建立唯一索引
3. 联合索引按最左匹配原则设计
4. 避免在低区分度字段上滥建索引
5. 订单、商品、店铺、用户等核心查询路径优先优化

重点索引建议：

- `user.username`
- `merchant.username`
- `shop.merchant_id`
- `product_spu.shop_id + status`
- `product_spu.category_id + status`
- `product_sku.spu_id`
- `cart_item.user_id + sku_id`
- `orders.order_no`
- `orders.user_id + order_status`
- `orders.shop_id + order_status`
- `payment_record.pay_no`

---

## 9. 一致性与事务设计

### 9.1 下单事务

创建订单时建议包含以下操作：

1. 校验商品状态
2. 校验库存
3. 校验最新价格
4. 创建订单主表
5. 创建订单明细
6. 锁定库存
7. 清理对应购物车项

上述操作建议放在同一事务中处理。

### 9.2 支付回写

支付成功后应：

1. 写入支付记录
2. 更新订单支付状态
3. 更新订单业务状态
4. 确认锁定库存进入有效成交结果

避免只更新部分状态，造成脏数据。

### 9.3 取消订单

取消订单时应：

1. 校验订单状态是否允许取消
2. 更新订单状态为已取消
3. 释放锁定库存

若引入 RabbitMQ，可异步处理库存回补或延迟关闭订单。

---

## 10. 缓存与数据库协作说明

虽然项目使用 Redis + Spring Cache，但数据库仍然是主事实源：

- 商品详情缓存失效后应回源查询 MySQL
- 用户登录、订单、支付等强业务数据必须以 MySQL 为准
- 不应将库存主状态完全交给 Redis 管理

推荐缓存策略：

- 商品详情：Cache Aside
- 商品分类：可适当长期缓存
- 热门商品列表：短期缓存
- 购物车：当前文档以 MySQL 为主持久化模型；在高频访问场景下，可引入 Redis Hash 做会话级加速或短期缓存，但最终状态仍应以数据库回写结果为准

---

## 11. 与 OSS 的数据协作说明

阿里云 OSS 负责实际文件存储，数据库负责元数据管理：

- OSS 存储真实文件对象
- `file_record` 存储业务引用关系与元数据
- 删除业务资源时，可根据业务规则决定是否同步删除 OSS 文件
- 商品资源建议至少区分 SPU 主图、SPU 图集、SKU 规格图与富文本详情图

建议文件目录前缀：

- `product/`
- `sku/`
- `shop/`
- `editor/`
- `avatar/`

---

## 12. 建表顺序建议

建议按以下顺序建表：

1. `user`
2. `merchant`
3. `shop`
4. `category`
5. `user_address`
6. `product_spu`
7. `product_sku`
8. `cart_item`
9. `orders`
10. `order_item`
11. `payment_record`
12. `file_record`

---

## 13. 后续可扩展表

随着项目后续迭代，可继续补充：

- `product_comment`：商品评价表
- `favorite_product`：商品收藏表
- `coupon`：优惠券表
- `order_log`：订单操作日志表
- `stock_log`：库存流水表
- `message_record`：消息通知记录表

---

## 14. 总结

OpenMall 当前数据库设计围绕“用户、商家、店铺、商品、购物车、订单、支付、文件”八个核心方向展开，既满足模拟淘宝项目的基础业务需求，也为后续扩展评价、营销、库存日志、消息通知等能力预留了空间。

当前阶段建议优先完成：

- 核心表设计确认
- 建表 SQL 编写
- 基础测试数据准备
- 与接口文档、设计文档保持一致

后续如果你需要，我可以直接继续为你生成：

- `sql/openmall.sql`
- 带字段类型与索引的完整建表 SQL
- 初始化测试数据脚本
