SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `openmall`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `openmall`;

DROP TABLE IF EXISTS `file_record`;
DROP TABLE IF EXISTS `payment_record`;
DROP TABLE IF EXISTS `order_item`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_item`;
DROP TABLE IF EXISTS `product_sku`;
DROP TABLE IF EXISTS `product_spu`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `shop`;
DROP TABLE IF EXISTS `merchant`;
DROP TABLE IF EXISTS `user_address`;
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(64) NOT NULL COMMENT '用户名，唯一',
  `password` VARCHAR(128) NOT NULL COMMENT '密码摘要',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `nickname` VARCHAR(64) DEFAULT NULL COMMENT '昵称',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '用户状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_username` (`username`),
  KEY `idx_user_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';

CREATE TABLE `user_address` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `receiver_name` VARCHAR(64) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货手机号',
  `province` VARCHAR(32) NOT NULL COMMENT '省',
  `city` VARCHAR(32) NOT NULL COMMENT '市',
  `district` VARCHAR(32) NOT NULL COMMENT '区',
  `detail_address` VARCHAR(255) NOT NULL COMMENT '详细地址',
  `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认地址，1是 0否',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_address_user_id` (`user_id`),
  KEY `idx_user_address_user_default` (`user_id`, `is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户收货地址表';

CREATE TABLE `merchant` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(64) NOT NULL COMMENT '商家登录账号，唯一',
  `password` VARCHAR(128) NOT NULL COMMENT '密码摘要',
  `contact_name` VARCHAR(64) DEFAULT NULL COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '商家状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_merchant_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商家表';

CREATE TABLE `shop` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
  `shop_name` VARCHAR(128) NOT NULL COMMENT '店铺名称',
  `logo` VARCHAR(255) DEFAULT NULL COMMENT '店铺Logo',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '店铺简介',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '店铺状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shop_merchant_id` (`merchant_id`),
  KEY `idx_shop_name` (`shop_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='店铺表';

CREATE TABLE `category` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` BIGINT NOT NULL DEFAULT 0 COMMENT '父级分类ID，顶级为0',
  `name` VARCHAR(64) NOT NULL COMMENT '分类名称',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_parent_id` (`parent_id`),
  KEY `idx_category_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商品分类表';

CREATE TABLE `product_spu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `shop_id` BIGINT NOT NULL COMMENT '店铺ID',
  `category_id` BIGINT NOT NULL COMMENT '分类ID',
  `spu_name` VARCHAR(128) NOT NULL COMMENT '商品名称',
  `main_image` VARCHAR(255) DEFAULT NULL COMMENT '主图',
  `album_images` JSON DEFAULT NULL COMMENT '轮播图集合',
  `detail` LONGTEXT COMMENT '商品详情',
  `status` VARCHAR(32) NOT NULL DEFAULT 'OFF_SALE' COMMENT '商品状态：ON_SALE/OFF_SALE',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_spu_shop_id` (`shop_id`),
  KEY `idx_product_spu_category_id` (`category_id`),
  KEY `idx_product_spu_status` (`status`),
  KEY `idx_product_spu_shop_status` (`shop_id`, `status`),
  KEY `idx_product_spu_category_status` (`category_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商品SPU表';

CREATE TABLE `product_sku` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spu_id` BIGINT NOT NULL COMMENT 'SPU ID',
  `sku_code` VARCHAR(64) NOT NULL COMMENT 'SKU编码',
  `sku_name` VARCHAR(128) NOT NULL COMMENT 'SKU名称',
  `spec_json` JSON DEFAULT NULL COMMENT 'SKU独有规格属性JSON',
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '销售价',
  `stock` INT NOT NULL DEFAULT 0 COMMENT '当前可售库存',
  `lock_stock` INT NOT NULL DEFAULT 0 COMMENT '锁定库存（待支付占用）',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT 'SKU状态，1启用 0禁用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_sku_code` (`sku_code`),
  KEY `idx_product_sku_spu_id` (`spu_id`),
  KEY `idx_product_sku_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商品SKU表';

CREATE TABLE `cart_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `shop_id` BIGINT NOT NULL COMMENT '店铺ID',
  `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '商品数量',
  `checked` TINYINT NOT NULL DEFAULT 1 COMMENT '是否勾选，1是 0否',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态，1有效 0失效',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cart_item_user_sku` (`user_id`, `sku_id`),
  KEY `idx_cart_item_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='购物车项表';

CREATE TABLE `orders` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` VARCHAR(64) NOT NULL COMMENT '订单编号，唯一',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `shop_id` BIGINT NOT NULL COMMENT '店铺ID',
  `order_status` VARCHAR(32) NOT NULL DEFAULT 'UNPAID' COMMENT '订单状态：UNPAID/PROCESSING/COMPLETED/CANCELED/CLOSED',
  `pay_status` VARCHAR(32) NOT NULL DEFAULT 'UNPAID' COMMENT '支付状态：UNPAID/PAID/FAILED',
  `delivery_status` VARCHAR(32) NOT NULL DEFAULT 'PENDING_DELIVERY' COMMENT '履约状态：PENDING_DELIVERY/SHIPPED/RECEIVED',
  `total_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '商品总金额',
  `freight_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '运费',
  `pay_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '实付金额',
  `receiver_name` VARCHAR(64) NOT NULL COMMENT '收货人',
  `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货手机号',
  `receiver_address` VARCHAR(255) NOT NULL COMMENT '收货地址快照',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '用户备注',
  `logistics_company` VARCHAR(64) DEFAULT NULL COMMENT '物流公司',
  `tracking_no` VARCHAR(64) DEFAULT NULL COMMENT '物流单号',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `cancel_time` DATETIME DEFAULT NULL COMMENT '取消时间',
  `delivery_time` DATETIME DEFAULT NULL COMMENT '发货时间',
  `finish_time` DATETIME DEFAULT NULL COMMENT '完成时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_orders_order_no` (`order_no`),
  KEY `idx_orders_user_id` (`user_id`),
  KEY `idx_orders_shop_id` (`shop_id`),
  KEY `idx_orders_order_status` (`order_status`),
  KEY `idx_orders_user_status` (`user_id`, `order_status`),
  KEY `idx_orders_shop_status` (`shop_id`, `order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='订单主表';

CREATE TABLE `order_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '订单编号',
  `shop_id` BIGINT NOT NULL COMMENT '店铺ID',
  `spu_id` BIGINT NOT NULL COMMENT 'SPU ID',
  `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
  `spu_name` VARCHAR(128) NOT NULL COMMENT '商品名称快照',
  `sku_name` VARCHAR(128) NOT NULL COMMENT 'SKU名称快照',
  `main_image` VARCHAR(255) DEFAULT NULL COMMENT '主图快照',
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '下单单价快照',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '数量',
  `amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '小计金额',
  `spec_text` VARCHAR(255) DEFAULT NULL COMMENT '规格文本快照',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_item_order_id` (`order_id`),
  KEY `idx_order_item_order_no` (`order_no`),
  KEY `idx_order_item_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='订单明细表';

CREATE TABLE `payment_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '订单编号',
  `pay_no` VARCHAR(64) NOT NULL COMMENT '支付流水号',
  `pay_channel` VARCHAR(32) NOT NULL COMMENT '支付渠道',
  `pay_status` VARCHAR(32) NOT NULL DEFAULT 'UNPAID' COMMENT '支付状态：UNPAID/PAID/FAILED',
  `pay_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '支付金额',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `callback_content` TEXT COMMENT '回调内容',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_payment_record_pay_no` (`pay_no`),
  KEY `idx_payment_record_order_no` (`order_no`),
  KEY `idx_payment_record_pay_status` (`pay_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='支付记录表';

CREATE TABLE `file_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `biz_type` VARCHAR(32) NOT NULL COMMENT '业务类型，如 PRODUCT_MAIN / PRODUCT_ALBUM / SKU_IMAGE / SHOP_LOGO / EDITOR_IMAGE',
  `biz_id` BIGINT DEFAULT NULL COMMENT '业务主键ID',
  `original_name` VARCHAR(255) NOT NULL COMMENT '原始文件名',
  `object_key` VARCHAR(255) NOT NULL COMMENT 'OSS对象Key',
  `file_url` VARCHAR(500) NOT NULL COMMENT '文件访问地址',
  `content_type` VARCHAR(100) DEFAULT NULL COMMENT '文件类型',
  `file_size` BIGINT NOT NULL DEFAULT 0 COMMENT '文件大小',
  `uploader_type` VARCHAR(32) NOT NULL COMMENT '上传人类型：USER / MERCHANT / ADMIN',
  `uploader_id` BIGINT DEFAULT NULL COMMENT '上传人ID',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态，1有效 0失效',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_file_record_object_key` (`object_key`),
  KEY `idx_file_record_biz` (`biz_type`, `biz_id`),
  KEY `idx_file_record_uploader` (`uploader_type`, `uploader_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件记录表';

SET FOREIGN_KEY_CHECKS = 1;
