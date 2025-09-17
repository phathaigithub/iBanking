package com.example.common_library.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {

    BAD_REQUEST(402, "Bad request"),
    INVALID_CREDENTIALS(401, "Invalid username or password"),
    USER_NOT_FOUND(404, "User not found"),
    ACCOUNT_DISABLED(403, "Account is disabled"),

    STUDENT_NOT_FOUND(404, "Student not found"),
    INSUFFICIENT_BALANCE(410,"Do not enought"),
    INTERNAL_ERROR(500, "Internal server error");

    private final int status;
    private final String message;

}
