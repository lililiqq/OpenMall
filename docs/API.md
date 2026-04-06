# OpenMall API 接口文档

> 本文档用于描述 OpenMall 项目的核心接口设计，覆盖 **用户端** 与 **商家端** 两套业务接口。当前接口体系基于 **Spring Boot 3.x + Spring Security + JWT + MyBatis-Plus + Knife4j** 设计，实际字段可在开发过程中根据业务需要微调。

---

## 1. 文档说明

### 1.1 文档目标

本接口文档用于：

- 明确前后端交互边界
- 统一接口命名与返回格式
- 为后端开发、前端联调、接口测试提供依据
- 为 Knife4j 接口文档生成、前后端联调和接口测试提供基础

### 1.2 接口风格约定

- 风格：RESTful API
- 数据格式：JSON
- 字符编码：UTF-8
- 请求方式：GET / POST / PUT / DELETE
- 文档展示工具：Knife4j

### 1.3 接口文档访问说明

项目在开发环境接入 Knife4j 后，接口文档通常可通过以下地址访问：

```text
http://localhost:8080/doc.html
```

说明：

- 用户端与商家端接口可在同一文档系统中按分组展示
- 建议按照“用户端接口”“商家端接口”“公共接口”进行分组
- 文档中的请求示例、响应示例应与本文件保持一致

### 1.4 基础路径约定

#### 用户端接口前缀

```text
/api/v1
```

#### 商家端接口前缀

```text
/merchant/api/v1
```

### 1.5 认证方式约定

- 用户端：登录成功后返回 Token，后续请求在 Header 中携带
- 商家端：商家登录成功后返回 Token，后续请求在 Header 中携带
- 认证框架：Spring Security
- Token 方案：JWT
- Token 过期时，后端应返回未登录或 Token 无效对应的业务码，例如 `4002`
- 若项目后续实现刷新机制，可增加 Token 刷新接口，由前端在过期前或收到失效响应后按约定触发

示例：

```http
Authorization: Bearer <token>
```

### 1.6 认证与权限分组说明

- 用户端接口使用用户身份认证上下文
- 商家端接口使用商家身份认证上下文
- 商家只能访问自己店铺下的商品、库存、订单数据
- 用户与商家的 Token 不可混用
- 商家端接口不仅要校验 Token 存在，还应校验当前身份具备商家角色或商家权限

### 1.7 文件上传接口说明

项目中的文件上传能力建议通过后端统一接入阿里云 OSS，接口文档中如涉及商品图片、店铺 Logo、富文本图片上传，应明确以下要点：

- 上传文件由后端统一校验类型、大小、业务归属
- 文件实际存储于阿里云 OSS
- 数据库可选记录文件元数据，如 `objectKey`、文件 URL、业务类型、上传人
- 商家端上传的商品图片与店铺图片必须与当前商家身份绑定
- 建议按业务类型区分文件用途，例如 `PRODUCT_MAIN`、`PRODUCT_ALBUM`、`SKU_IMAGE`、`SHOP_LOGO`、`EDITOR_IMAGE`

---

## 2. 统一响应格式

### 2.1 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "timestamp": 1712034000000
}
```

### 2.2 失败响应示例

```json
{
  "code": 4001,
  "message": "参数校验失败",
  "data": null,
  "timestamp": 1712034000000
}
```

### 2.3 分页响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pageNum": 1,
    "pageSize": 10,
    "total": 100,
    "list": [],
    "hasNextPage": true
  },
  "timestamp": 1712034000000
}
```

### 2.4 与 MyBatis-Plus 分页的关系说明

项目后端持久层使用 MyBatis-Plus，因此分页查询接口在后端可基于 MyBatis-Plus 分页能力实现。对前端暴露时，建议统一转换为：

- `pageNum`
- `pageSize`
- `total`
- `list`
- `hasNextPage`（可选，用于前端快速判断是否继续加载）

避免直接暴露底层框架返回结构，保证接口响应稳定性。

---

## 3. 通用状态码约定

| code | 含义 |
| --- | --- |
| 0 | 请求成功 |
| 4000 | 通用业务失败 |
| 4001 | 参数校验失败 |
| 4002 | 未登录或 Token 无效 |
| 4003 | 无权限访问 |
| 4004 | 资源不存在 |
| 4005 | 状态不允许当前操作 |
| 4006 | 库存不足 |
| 4007 | 文件上传失败 |
| 4008 | OSS 访问异常 |
| 5000 | 系统内部错误 |

---

## 4. 用户端接口

---

## 4.1 用户认证模块

### 4.1.1 用户注册

- **接口地址**：`POST /api/v1/auth/register`
- **接口说明**：用户注册新账号
- **是否鉴权**：否

#### 请求参数

```json
{
  "username": "zhangsan",
  "password": "123456",
  "confirmPassword": "123456",
  "phone": "13800000000"
}
```

#### 参数说明

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| confirmPassword | string | 是 | 确认密码 |
| phone | string | 是 | 手机号 |

#### 成功响应示例

```json
{
  "code": 0,
  "message": "注册成功",
  "data": {
    "userId": 10001,
    "username": "zhangsan"
  }
}
```

---

### 4.1.2 用户登录

- **接口地址**：`POST /api/v1/auth/login`
- **接口说明**：用户登录系统
- **是否鉴权**：否

#### 请求参数

```json
{
  "username": "zhangsan",
  "password": "123456"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "登录成功",
  "data": {
    "token": "xxxx.yyyy.zzzz",
    "tokenHead": "Bearer",
    "userInfo": {
      "id": 10001,
      "username": "zhangsan",
      "phone": "13800000000"
    }
  }
}
```

---

### 4.1.3 刷新 Token（可选增强）

- **接口地址**：`POST /api/v1/auth/refresh`
- **接口说明**：用于刷新即将过期或已失效的访问令牌。若当前版本未实现，可在前后端约定中明确收到 `4002` 后跳转登录。
- **是否鉴权**：是 / 或根据刷新策略单独校验刷新凭证

#### 请求参数

```json
{
  "refreshToken": "refresh-token-example"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "刷新成功",
  "data": {
    "token": "new-access-token",
    "refreshToken": "new-refresh-token"
  },
  "timestamp": 1712034000000
}
```

---

### 4.1.4 获取当前用户信息

- **接口地址**：`GET /api/v1/users/me`
- **接口说明**：获取当前登录用户信息
- **是否鉴权**：是

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 10001,
    "username": "zhangsan",
    "phone": "13800000000",
    "avatar": "https://example.com/avatar.png"
  }
}
```

---

## 4.2 地址管理模块

### 4.2.1 获取地址列表

- **接口地址**：`GET /api/v1/addresses`
- **接口说明**：获取当前用户所有收货地址
- **是否鉴权**：是

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "receiverName": "张三",
      "receiverPhone": "13800000000",
      "province": "上海市",
      "city": "上海市",
      "district": "浦东新区",
      "detailAddress": "世纪大道100号",
      "isDefault": true
    }
  ]
}
```

---

### 4.2.2 新增地址

- **接口地址**：`POST /api/v1/addresses`
- **接口说明**：新增收货地址
- **是否鉴权**：是

#### 请求参数

```json
{
  "receiverName": "张三",
  "receiverPhone": "13800000000",
  "province": "上海市",
  "city": "上海市",
  "district": "浦东新区",
  "detailAddress": "世纪大道100号",
  "isDefault": true
}
```

---

### 4.2.3 修改地址

- **接口地址**：`PUT /api/v1/addresses/{id}`
- **接口说明**：修改指定地址
- **是否鉴权**：是

---

### 4.2.4 删除地址

- **接口地址**：`DELETE /api/v1/addresses/{id}`
- **接口说明**：删除指定地址
- **是否鉴权**：是

---

## 4.3 商品模块

### 4.3.1 获取分类列表

- **接口地址**：`GET /api/v1/categories`
- **接口说明**：获取商品分类树或分类列表
- **是否鉴权**：否

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "手机数码",
      "children": [
        {
          "id": 11,
          "name": "手机"
        }
      ]
    }
  ]
}
```

---

### 4.3.2 分页查询商品列表

- **接口地址**：`GET /api/v1/products`
- **接口说明**：分页查询商品列表，支持分类、关键词筛选
- **是否鉴权**：否

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| pageNum | int | 否 | 页码，默认 1 |
| pageSize | int | 否 | 每页数量，默认 10 |
| categoryId | long | 否 | 分类 ID |
| keyword | string | 否 | 搜索关键字 |
| sort | string | 否 | 排序方式，如 priceAsc / salesDesc |

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pageNum": 1,
    "pageSize": 10,
    "total": 1,
    "hasNextPage": false,
    "list": [
      {
        "productId": 1001,
        "spuName": "iPhone 15",
        "mainImage": "https://example.com/iphone15.png",
        "price": 5999,
        "shopName": "苹果旗舰店",
        "sales": 999
      }
    ]
  },
  "timestamp": 1712034000000
}
```

---

### 4.3.3 获取商品详情

- **接口地址**：`GET /api/v1/products/{id}`
- **接口说明**：获取商品详情、SKU 列表、图文信息
- **是否鉴权**：否

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "productId": 1001,
    "spuName": "iPhone 15",
    "shopId": 2001,
    "shopName": "苹果旗舰店",
    "mainImage": "https://example.com/iphone15.png",
    "albumImages": [
      "https://example.com/1.png",
      "https://example.com/2.png"
    ],
    "detail": "商品图文详情",
    "skuList": [
      {
        "skuId": 3001,
        "skuName": "黑色 128G",
        "specJson": {
          "颜色": "黑色",
          "容量": "128G"
        },
        "price": 5999,
        "stock": 100
      }
    ]
  }
}
```

---

## 4.4 购物车模块

### 4.4.1 获取购物车商品列表

- **接口地址**：`GET /api/v1/cart/items`
- **接口说明**：获取当前用户购物车数据。后端应基于最新 SKU 价格返回展示金额，若与前端缓存价格不一致，以服务端返回结果为准。
- **是否鉴权**：是

---

### 4.4.2 加入购物车

- **接口地址**：`POST /api/v1/cart/items`
- **接口说明**：将指定 SKU 加入购物车。若当前用户购物车中已存在相同 `skuId`，则累加数量；若不存在，则新增一条购物车记录。
- **是否鉴权**：是

#### 请求参数

```json
{
  "skuId": 3001,
  "quantity": 2
}
```

---

### 4.4.3 修改购物车商品数量

- **接口地址**：`PUT /api/v1/cart/items/{id}`
- **接口说明**：修改购物车商品购买数量
- **是否鉴权**：是

#### 请求参数

```json
{
  "quantity": 3,
  "checked": true
}
```

---

### 4.4.4 删除购物车商品

- **接口地址**：`DELETE /api/v1/cart/items/{id}`
- **接口说明**：删除购物车中的指定商品
- **是否鉴权**：是

---

## 4.5 订单模块

### 4.5.1 订单预览

- **接口地址**：`POST /api/v1/orders/preview`
- **接口说明**：根据购物车勾选商品或立即购买信息生成订单预览。该接口用于价格与库存重校验，不在此阶段锁定库存。
- **是否鉴权**：是

#### 请求参数

```json
{
  "addressId": 1,
  "cartItemIds": [10, 11]
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "shopList": [
      {
        "shopId": 2001,
        "shopName": "苹果旗舰店",
        "items": [
          {
            "skuId": 3001,
            "skuName": "黑色 128G",
            "price": 5999,
            "quantity": 1,
            "amount": 5999
          }
        ]
      }
    ],
    "totalAmount": 5999,
    "freightAmount": 0,
    "payAmount": 5999
  }
}
```

---

#### 处理要求

- 订单预览阶段必须校验最新地址、商品状态、库存与最新价格
- 若商品价格发生变化，应在响应中返回最新价格结果，前端以服务端返回金额为准
- 订单预览结果仅作为结算参考，提交订单时仍需再次校验

---

### 4.5.2 创建订单

- **接口地址**：`POST /api/v1/orders`
- **接口说明**：提交订单并生成订单数据。订单创建成功后应锁定库存，并进入待支付状态。
- **是否鉴权**：是

#### 请求参数

```json
{
  "addressId": 1,
  "cartItemIds": [10, 11],
  "remark": "请尽快发货"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "下单成功",
  "data": {
    "orderId": 9001,
    "orderNo": "OM202604020001",
    "orderStatus": "UNPAID",
    "payAmount": 5999
  }
}
```

---

#### 处理要求

- 创建订单时必须再次校验最新地址、商品状态、库存与最新价格
- 订单创建成功后应锁定库存，不在加入购物车或订单预览阶段占用库存
- 订单明细应保存商品名称、规格、主图、下单单价等成交快照
- 未支付订单建议设置 15 分钟支付有效期；超时后可通过 RabbitMQ 等延迟任务机制自动关闭订单并释放锁定库存

---

### 4.5.3 查询订单列表

- **接口地址**：`GET /api/v1/orders`
- **接口说明**：分页查询当前用户订单列表
- **是否鉴权**：是

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| pageNum | int | 否 | 页码 |
| pageSize | int | 否 | 每页数量 |
| status | string | 否 | 订单状态 |

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pageNum": 1,
    "pageSize": 10,
    "total": 1,
    "hasNextPage": false,
    "list": [
      {
        "orderId": 9001,
        "orderNo": "OM202604020001",
        "orderStatus": "UNPAID",
        "payStatus": "UNPAID",
        "deliveryStatus": "PENDING_DELIVERY",
        "payAmount": 5999,
        "createTime": "2026-04-02 18:00:00"
      }
    ]
  },
  "timestamp": 1712034000000
}
```

---

### 4.5.4 查询订单详情

- **接口地址**：`GET /api/v1/orders/{id}`
- **接口说明**：查询指定订单详情
- **是否鉴权**：是

---

### 4.5.5 取消订单

- **接口地址**：`POST /api/v1/orders/{id}/cancel`
- **接口说明**：取消未支付订单。仅允许从 `UNPAID` 状态流转到 `CANCELED`，并释放该订单已锁定的库存。
- **是否鉴权**：是

#### 请求参数

```json
{
  "reason": "不想买了"
}
```

---

## 4.6 支付模块

### 4.6.1 模拟支付

- **接口地址**：`POST /api/v1/payments/{orderNo}/mock-pay`
- **接口说明**：模拟订单支付成功。支付前订单必须处于 `UNPAID` 且未被取消或关闭。
- **是否鉴权**：是

#### 请求参数

```json
{
  "payChannel": "MOCK_ALIPAY"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "支付成功",
  "data": {
    "orderNo": "OM202604020001",
    "payStatus": "PAID",
    "payTime": "2026-04-02 18:30:00"
  }
}
```

---

### 4.6.2 查询支付记录

- **接口地址**：`GET /api/v1/payments/{orderNo}`
- **接口说明**：查询订单支付记录
- **是否鉴权**：是

---

### 4.6.3 支付成功异步回调（内部接口 / 预留）

- **接口地址**：`POST /internal/api/v1/payments/callback`
- **接口说明**：由支付系统或模拟支付逻辑异步回调，用于更新支付状态与订单状态。该接口不面向普通前端开放。
- **是否鉴权**：内部鉴权 / 签名校验

#### 请求参数

```json
{
  "orderNo": "OM202604020001",
  "payNo": "PAY202604020001",
  "payStatus": "PAID",
  "payChannel": "MOCK_ALIPAY",
  "payTime": "2026-04-02 18:30:00"
}
```

#### 处理要求

- 回调处理应具备幂等性
- 已完成支付的订单不应重复更新
- 支付状态更新后，再联动订单主状态流转

---

## 5. 商家端接口

---

## 5.1 商家认证模块

### 5.1.1 商家登录

- **接口地址**：`POST /merchant/api/v1/auth/login`
- **接口说明**：商家登录商家端
- **是否鉴权**：否

#### 请求参数

```json
{
  "username": "merchant001",
  "password": "123456"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "登录成功",
  "data": {
    "token": "xxxx.yyyy.zzzz",
      "merchantInfo": {
        "merchantId": 5001,
        "username": "merchant001",
        "shopId": 2001,
        "shopName": "苹果旗舰店"
    }
  }
}
```

---

## 5.2 店铺信息模块

### 5.2.1 获取店铺信息

- **接口地址**：`GET /merchant/api/v1/shop/profile`
- **接口说明**：获取当前商家所属店铺信息
- **是否鉴权**：是

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "shopId": 2001,
    "shopName": "苹果旗舰店",
    "logo": "https://example.com/logo.png",
    "description": "主营手机数码产品",
    "status": "ENABLE"
  }
}
```

---

### 5.2.2 更新店铺信息

- **接口地址**：`PUT /merchant/api/v1/shop/profile`
- **接口说明**：更新当前店铺信息
- **是否鉴权**：是

#### 请求参数

```json
{
  "shopName": "苹果旗舰店",
  "logo": "https://example.com/logo.png",
  "description": "主营手机数码产品"
}
```

---

## 5.3 商家商品模块

### 5.3.1 商家商品列表

- **接口地址**：`GET /merchant/api/v1/products`
- **接口说明**：分页查询当前店铺商品列表
- **是否鉴权**：是

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| pageNum | int | 否 | 页码 |
| pageSize | int | 否 | 每页数量 |
| keyword | string | 否 | 商品关键字 |
| status | string | 否 | 上下架状态 |

---

### 5.3.2 新增商品

- **接口地址**：`POST /merchant/api/v1/products`
- **接口说明**：商家新增商品与 SKU 信息
- **是否鉴权**：是

#### 请求参数

```json
{
  "spuName": "iPhone 15",
  "categoryId": 11,
  "mainImage": "https://example.com/iphone15.png",
  "detail": "商品详情描述",
  "status": "ON_SALE",
  "skuList": [
    {
      "skuName": "黑色 128G",
      "specJson": {
        "颜色": "黑色",
        "容量": "128G"
      },
      "price": 5999,
      "stock": 100
    },
    {
      "skuName": "蓝色 256G",
      "specJson": {
        "颜色": "蓝色",
        "容量": "256G"
      },
      "price": 6999,
      "stock": 80
    }
  ]
}
```

---

### 5.3.3 编辑商品

- **接口地址**：`PUT /merchant/api/v1/products/{id}`
- **接口说明**：修改商品基础信息与规格信息
- **是否鉴权**：是

---

### 5.3.4 商品上下架

- **接口地址**：`PUT /merchant/api/v1/products/{id}/status`
- **接口说明**：修改商品上架状态
- **是否鉴权**：是

#### 请求参数

```json
{
  "status": "OFF_SALE"
}
```

---

### 5.3.5 修改 SKU 库存

- **接口地址**：`PUT /merchant/api/v1/skus/{id}/stock`
- **接口说明**：修改指定 SKU 库存
- **是否鉴权**：是

#### 请求参数

```json
{
  "stock": 200
}
```

---

## 5.4 商家订单模块

### 5.4.1 商家订单列表

- **接口地址**：`GET /merchant/api/v1/orders`
- **接口说明**：查询当前店铺订单列表
- **是否鉴权**：是

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| pageNum | int | 否 | 页码 |
| pageSize | int | 否 | 每页数量 |
| status | string | 否 | 订单状态 |
| orderNo | string | 否 | 订单编号 |

#### 成功响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pageNum": 1,
    "pageSize": 10,
    "total": 1,
    "hasNextPage": false,
    "list": [
      {
        "orderId": 9001,
        "orderNo": "OM202604020001",
        "orderStatus": "PROCESSING",
        "payStatus": "PAID",
        "deliveryStatus": "PENDING_DELIVERY",
        "payAmount": 5999,
        "createTime": "2026-04-02 18:00:00"
      }
    ]
  },
  "timestamp": 1712034000000
}
```

---

### 5.4.2 商家订单详情

- **接口地址**：`GET /merchant/api/v1/orders/{id}`
- **接口说明**：查询指定订单详情
- **是否鉴权**：是

---

### 5.4.3 更新订单发货状态

- **接口地址**：`PUT /merchant/api/v1/orders/{id}/delivery-status`
- **接口说明**：商家对已支付订单进行发货处理
- **是否鉴权**：是

#### 请求参数

```json
{
  "deliveryStatus": "SHIPPED",
  "logisticsCompany": "顺丰速运",
  "trackingNo": "SF1234567890"
}
```

#### 成功响应示例

```json
{
  "code": 0,
  "message": "发货成功",
  "data": {
    "orderId": 9001,
    "orderNo": "OM202604020001",
    "deliveryStatus": "SHIPPED"
  }
}
```

---

## 6. 订单状态建议

### 6.1 订单状态

| 状态值 | 含义 |
| --- | --- |
| UNPAID | 待支付 |
| PROCESSING | 已支付待履约 / 处理中 |
| COMPLETED | 已完成 |
| CANCELED | 已取消 |
| CLOSED | 已关闭 |

### 6.2 支付状态

| 状态值 | 含义 |
| --- | --- |
| UNPAID | 未支付 |
| PAID | 已支付 |
| FAILED | 支付失败 |

### 6.3 履约 / 物流状态

| 状态值 | 含义 |
| --- | --- |
| PENDING_DELIVERY | 待发货 |
| SHIPPED | 已发货 |
| RECEIVED | 已签收 |

### 6.4 商品状态

| 状态值 | 含义 |
| --- | --- |
| ON_SALE | 上架 |
| OFF_SALE | 下架 |

### 6.5 状态流转约束建议

- `CANCELED` 只能由 `UNPAID` 流转而来
- `CLOSED` 用于表示未支付订单被系统超时关闭，与用户主动取消区分
- 订单支付成功后，`pay_status` 从 `UNPAID` 变更为 `PAID`，`order_status` 可流转为 `PROCESSING`
- 商家发货前，应保证订单已支付，即 `pay_status = PAID`
- 发货后，`delivery_status` 应从 `PENDING_DELIVERY` 变更为 `SHIPPED`
- 已取消订单不得再进入发货流程
- 已关闭订单不得继续支付

---

## 7. 鉴权与权限说明

### 7.1 用户端权限

- 未登录可访问：商品分类、商品列表、商品详情
- 登录后可访问：购物车、地址、订单、支付等接口

### 7.2 商家端权限

- 未登录可访问：商家登录接口
- 登录后可访问：店铺信息、商品管理、订单管理、库存管理等接口

### 7.3 权限隔离要求

- 用户 Token 不可访问商家端接口
- 商家 Token 不可访问用户端订单、购物车等用户私有接口
- 商家只能访问自己店铺下的商品和订单数据
- 商家端接口必须结合 JWT 中的商家身份与店铺归属做后端校验，不能只信任前端传入的 `merchantId` 或 `shopId`
- 商家端列表接口应按当前商家所属店铺做数据范围过滤
- 商家端详情、修改、发货、库存调整与批量操作都必须校验资源归属

---

## 8. 幂等与异常处理建议

### 8.1 幂等建议

- 创建订单接口建议使用防重复提交 Token
- 模拟支付接口需限制重复支付
- 商家发货接口需校验订单当前状态，避免重复发货

### 8.2 异常场景示例

- 商品不存在
- 商品已下架
- SKU 库存不足
- 地址不存在
- 订单状态异常
- 越权访问其他商家或其他用户的数据

---

## 9. 后续扩展接口建议

后续版本可扩展以下接口：

- 商品评价接口
- 商品收藏接口
- 优惠券接口
- 秒杀活动接口
- 退款接口
- 物流查询接口

---

## 10. 总结

本 API 文档覆盖了 OpenMall 当前阶段的核心接口范围，重点服务于：

- 用户端下单流程闭环
- 商家端商品管理与订单处理流程
- 后续数据库设计、后端编码与前端联调

后续如果进入实际开发阶段，建议在本设计文档基础上继续补充：

- Swagger / OpenAPI 自动生成文档
- 更完整的字段校验规则
- 错误码字典
- 请求与响应 DTO 说明
