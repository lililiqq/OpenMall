package com.openmall.common.api;

/**
 * 统一业务状态码定义。
 */
public enum ErrorCode {

    SUCCESS(0, "success"),
    BAD_REQUEST(4001, "参数校验失败"),
    UNAUTHORIZED(4002, "未登录或令牌无效"),
    FORBIDDEN(4003, "无权限访问"),
    NOT_FOUND(4004, "资源不存在"),
    ILLEGAL_STATE(4005, "状态不允许当前操作"),
    STOCK_NOT_ENOUGH(4006, "库存不足"),
    BUSINESS_ERROR(4000, "业务处理失败"),
    SYSTEM_ERROR(5000, "系统异常");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
