package com.example.tuition_service.service.impl;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.tuition_service.client.NotificationServiceClient;
import com.example.tuition_service.client.StudentServiceClient;
import com.example.tuition_service.dto.*;
import com.example.tuition_service.model.Tuition;
import com.example.tuition_service.repository.TuitionRepository;
import com.example.tuition_service.service.OtpService;
import com.example.tuition_service.service.TuitionService;
import com.example.tuition_service.util.TuitionValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TuitionServiceImpl implements TuitionService {
    
    @Autowired
    private TuitionRepository tuitionRepository;
    
    @Autowired
    private StudentServiceClient studentServiceClient;
    
    @Autowired
    private TuitionValidator tuitionValidator;  // Thêm validator

    @Autowired
    private OtpService otpService;

    @Autowired
    private NotificationServiceClient notificationServiceClient;

    @Override
    public TuitionDTO updateTuitionStatus(String tuitionId, StatusUpdateDTO statusUpdateDTO) {
        Tuition tuition = tuitionRepository.findById(tuitionId)
                .orElseThrow(() -> new ApiException(ErrorCode.TUITION_NOT_FOUND));
        tuition.setStatus(statusUpdateDTO.getStatus());
        tuition = tuitionRepository.save(tuition);
        // Trả về đầy đủ thông tin
        return convertToDTO(tuition);
    }
    
    @Override
    public TuitionMajorResponse createTuitionByMajor(TuitionMajorRequest request) {
        // Validate input
        tuitionValidator.validateSemester(request.getSemester());
        LocalDate dueDate = tuitionValidator.validateAndParseDueDate(request.getDueDate());
        
        // Lấy danh sách sinh viên theo ngành
        List<StudentDTO> students;
        try {
            students = studentServiceClient.getStudentsByMajor(request.getMajorCode());
        } catch (HttpClientErrorException.NotFound e) {
            // Xử lý riêng lỗi 404 từ student-service
            throw new ApiException(ErrorCode.MAJOR_NOT_FOUND, 
                "Major with code '" + request.getMajorCode() + "' not found");
        } catch (Exception e) {
            // Xử lý các lỗi khác (500, timeout, ...)
            throw new ApiException(ErrorCode.INTERNAL_ERROR, 
                "Failed to get students for major '" + request.getMajorCode() + "': " + e.getMessage());
        }
        
        // Kiểm tra ngành học có sinh viên hay không (chỉ chạy khi không có exception ở trên)
        if (students == null || students.isEmpty()) {
            throw new ApiException(ErrorCode.BAD_REQUEST, 
                "Major '" + request.getMajorCode() + "' exists but has no students");
        }
        
        List<TuitionResponse> tuitionResponses = new ArrayList<>();

        for (StudentDTO student : students) {
            String tuitionCode = request.getSemester() + student.getStudentCode();

            // Kiểm tra đã tồn tại học phí cho sinh viên này trong học kỳ chưa
            if (tuitionRepository.existsById(tuitionCode)) {
                throw new ApiException(ErrorCode.BAD_REQUEST, 
                    "Tuition already exists for student " + student.getStudentCode() + 
                    " in semester " + request.getSemester());
            }

            Tuition tuition = new Tuition();
            tuition.setTuitionId(tuitionCode);
            tuition.setStudentCode(student.getStudentCode());
            tuition.setSemester(request.getSemester());
            tuition.setAmount(BigDecimal.valueOf(request.getAmount()));
            tuition.setStatus("Chưa thanh toán");
            tuition.setDueDate(dueDate);  // Sử dụng dueDate từ request
            tuition = tuitionRepository.save(tuition);

            TuitionResponse tuitionResponse = new TuitionResponse(
                tuition.getTuitionId(),
                student.getStudentCode(),
                student.getName(),
                student.getMajorCode(),
                request.getAmount(),
                tuition.getStatus()
            );
            tuitionResponses.add(tuitionResponse);
        }

        TuitionMajorResponse response = new TuitionMajorResponse();
        response.setSemester(request.getSemester());
        response.setMajorCode(request.getMajorCode());
        response.setTuitions(tuitionResponses);
        return response;
    }
    
    @Override
    public TuitionDTO getTuitionByCode(String tuitionCode) {
        return tuitionRepository.findById(tuitionCode)
                .map(this::convertToDTO)
                .orElse(null);
    }
    
    @Override
    public StudentTuitionResponse getStudentTuitions(int studentId) {
        // Lấy thông tin sinh viên từ StudentService
        StudentDTO studentDTO = studentServiceClient.getStudentById(studentId);

        // Lấy danh sách học phí từ DB
        List<Tuition> tuitions = tuitionRepository.findByStudentCode(studentDTO.getStudentCode());

        // Chuẩn bị response
        StudentTuitionResponse response = new StudentTuitionResponse();

        StudentTuitionResponse.StudentInfo studentInfo = new StudentTuitionResponse.StudentInfo();
        studentInfo.setStudentCode(studentDTO.getStudentCode());
        studentInfo.setName(studentDTO.getName());
        studentInfo.setMajorCode(studentDTO.getMajorCode());
        studentInfo.setMajorName(studentDTO.getMajorName());
        studentInfo.setEmail(studentDTO.getEmail());
        response.setStudent(studentInfo);

        List<StudentTuitionResponse.TuitionInfo> tuitionInfos = tuitions.stream().map(t -> {
            StudentTuitionResponse.TuitionInfo info = new StudentTuitionResponse.TuitionInfo();
            info.setTuitionId(t.getTuitionId());
            info.setSemester(t.getSemester());
            info.setAmount(t.getAmount());
            info.setStatus(t.getStatus());
            info.setDueDate(t.getDueDate());
            info.setCreatedAt(t.getCreatedAt());
            return info;
        }).collect(Collectors.toList());

        response.setTuitions(tuitionInfos);

        return response;
    }
    
    private TuitionDTO convertToDTO(Tuition tuition) {
        TuitionDTO dto = new TuitionDTO();
        dto.setTuitionCode(tuition.getTuitionId());
        dto.setStudentCode(tuition.getStudentCode());
        dto.setSemester(tuition.getSemester());
        dto.setAmount(tuition.getAmount());
        dto.setStatus(tuition.getStatus());
        return dto;
    }

    @Override
    public void deleteTuition(String tuitionId) {
        if (!tuitionRepository.existsById(tuitionId)) {
            throw new ApiException(ErrorCode.TUITION_NOT_FOUND);
        }
        tuitionRepository.deleteById(tuitionId);
    }

    @Override
    public TuitionDTO updateTuition(String tuitionId, TuitionDTO updateDTO) {
        Tuition tuition = tuitionRepository.findById(tuitionId)
            .orElseThrow(() -> new ApiException(ErrorCode.TUITION_NOT_FOUND));
        if (updateDTO.getAmount() != null) {
            tuition.setAmount(updateDTO.getAmount());
        }
        if (updateDTO.getStatus() != null) {
            tuition.setStatus(updateDTO.getStatus());
        }
        if (updateDTO.getSemester() != null) {
            tuition.setSemester(updateDTO.getSemester());
        }
        tuition = tuitionRepository.save(tuition);
        return convertToDTO(tuition);
    }

    @Override
    public List<TuitionDTO> getAllTuition() {
        List<Tuition> tuitions = tuitionRepository.findAll();
        return tuitions.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public void requestTuitionInquiry(String studentCode) {
        // Lấy thông tin sinh viên
        StudentDTO student;
        try {
            student = studentServiceClient.getStudentByCode(studentCode);
        } catch (Exception e) {
            if (e instanceof ApiException) {
                throw e;
            }
            throw new ApiException(ErrorCode.STUDENT_NOT_FOUND, 
                "Student with code '" + studentCode + "' not found");
        }
        
        // Sinh OTP
        String otpCode = otpService.generateOtp(studentCode);
        

        try {
            notificationServiceClient.sendInquiryOtp(student.getEmail(), otpCode, student.getName());
        } catch (Exception e) {
            throw new ApiException(ErrorCode.INTERNAL_ERROR, 
                "Failed to send OTP email: " + e.getMessage());
        }
    }

    @Override
    public StudentTuitionResponse verifyOtpAndGetTuitions(String studentCode, String otpCode) {
        // Verify OTP
        if (!otpService.verifyOtp(studentCode, otpCode)) {
            throw new ApiException(ErrorCode.INVALID_OTP, "Invalid or expired OTP");
        }
        
        // Lấy thông tin sinh viên
        StudentDTO student;
        try {
            student = studentServiceClient.getStudentByCode(studentCode);
        } catch (Exception e) {
            if (e instanceof ApiException) {
                throw e;
            }
            throw new ApiException(ErrorCode.STUDENT_NOT_FOUND, 
                "Student with code '" + studentCode + "' not found");
        }
        
        // Lấy danh sách học phí
        List<Tuition> tuitions = tuitionRepository.findByStudentCode(studentCode);
        
        // Chuẩn bị response
        StudentTuitionResponse response = new StudentTuitionResponse();
        
        StudentTuitionResponse.StudentInfo studentInfo = new StudentTuitionResponse.StudentInfo();
        studentInfo.setStudentCode(student.getStudentCode());
        studentInfo.setName(student.getName());
        studentInfo.setMajorCode(student.getMajorCode());
        studentInfo.setMajorName(student.getMajorName());
        studentInfo.setEmail(student.getEmail());
        response.setStudent(studentInfo);
        
        List<StudentTuitionResponse.TuitionInfo> tuitionInfos = tuitions.stream().map(t -> {
            StudentTuitionResponse.TuitionInfo info = new StudentTuitionResponse.TuitionInfo();
            info.setTuitionId(t.getTuitionId());
            info.setSemester(t.getSemester());
            info.setAmount(t.getAmount());
            info.setStatus(t.getStatus());
            info.setDueDate(t.getDueDate());
            info.setCreatedAt(t.getCreatedAt());
            return info;
        }).collect(Collectors.toList());
        
        response.setTuitions(tuitionInfos);
        
        // Xóa OTP sau khi verify thành công
        otpService.removeOtp(studentCode);
        
        return response;
    }
}