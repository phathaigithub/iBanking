package com.example.tuition_service.util;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

@Component
public class TuitionValidator {
    
    private static final Pattern SEMESTER_PATTERN = Pattern.compile("^[1-3]20[0-9]{2}$");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd-MM-yyyy");
    
    /**
     * Validate semester format: [1-3][YYYY]
     * VD: 12025, 22025, 32025
     */
    public void validateSemester(String semester) {
        if (semester == null || semester.trim().isEmpty()) {
            throw new ApiException(ErrorCode.BAD_REQUEST, "Semester cannot be empty");
        }
        
        if (!SEMESTER_PATTERN.matcher(semester).matches()) {
            throw new ApiException(ErrorCode.INVALID_SEMESTER_FORMAT, 
                "Semester must follow format [1-3][YYYY]. Example: 12025 (semester 1, year 2025)");
        }
        
        // Kiểm tra năm hợp lệ (không quá xa trong tương lai)
        int year = Integer.parseInt(semester.substring(1));
        int currentYear = LocalDate.now().getYear();
        if (year < currentYear || year > currentYear + 10) {
            throw new ApiException(ErrorCode.INVALID_SEMESTER_FORMAT, 
                "Year must be between " + currentYear + " and " + (currentYear + 10));
        }
    }
    
    /**
     * Validate và parse due date format: dd-MM-yyyy
     * VD: 15-10-2025
     */
    public LocalDate validateAndParseDueDate(String dueDate) {
        if (dueDate == null || dueDate.trim().isEmpty()) {
            throw new ApiException(ErrorCode.BAD_REQUEST, "Due date cannot be empty");
        }
        
        try {
            LocalDate parsedDate = LocalDate.parse(dueDate, DATE_FORMATTER);
            
            // Kiểm tra ngày không được trong quá khứ
            if (parsedDate.isBefore(LocalDate.now())) {
                throw new ApiException(ErrorCode.INVALID_DUE_DATE, "Due date cannot be in the past");
            }
            
            return parsedDate;
        } catch (DateTimeParseException e) {
            throw new ApiException(ErrorCode.INVALID_DUE_DATE, 
                "Invalid due date format. Expected: dd-MM-yyyy (e.g., 15-10-2025)");
        }
    }
}
