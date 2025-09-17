package com.example.tuition_service.service.impl;

import com.example.tuition_service.client.StudentServiceClient;
import com.example.tuition_service.dto.*;
import com.example.tuition_service.model.Tuition;
import com.example.tuition_service.repository.TuitionRepository;
import com.example.tuition_service.service.TuitionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TuitionServiceImpl implements TuitionService {
    
    @Autowired
    private TuitionRepository tuitionRepository;
    
    @Autowired
    private StudentServiceClient studentServiceClient;
    
    @Override
    public Tuition createTuition(Tuition tuition) {
        if (tuition.getTuitionId() == null || tuition.getTuitionId().isEmpty()) {
            tuition.setTuitionId("T" + LocalDateTime.now().getYear() + "-" + 
                    String.format("%03d", (int) (Math.random() * 999) + 1));
        }
        
        if (tuition.getStatus() == null || tuition.getStatus().isEmpty()) {
            tuition.setStatus("Chưa thanh toán");
        }
        
        return tuitionRepository.save(tuition);
    }
    

    
    @Override
    public TuitionDTO updateTuitionStatus(String tuitionId, StatusUpdateDTO statusUpdateDTO) {
        Tuition tuition = tuitionRepository.findById(tuitionId)
                .orElseThrow(() -> new RuntimeException("Tuition not found with id: " + tuitionId));
        
        tuition.setStatus(statusUpdateDTO.getStatus());
        tuition = tuitionRepository.save(tuition);
        
        TuitionDTO responseDTO = new TuitionDTO();
        responseDTO.setTuitionId(tuition.getTuitionId());
        responseDTO.setStatus(tuition.getStatus());
        
        return responseDTO;
    }
    
    @Override
    public TuitionMajorResponse createTuitionByMajor(TuitionMajorRequest request) {
        // Lấy danh sách sinh viên từ StudentService
        List<StudentDTO> students = studentServiceClient.getStudentsByMajor(request.getMajorCode());
        
        // Danh sách để lưu trữ kết quả
        List<TuitionResponse> tuitionResponses = new ArrayList<>();
        
        // Tạo học phí cho từng sinh viên
        for (StudentDTO student : students) {
            // Tạo tuitionCode = semester + studentId
            String tuitionCode = request.getSemester() + student.getStudentId();
            
            // Tạo bản ghi học phí
            Tuition tuition = new Tuition();
            tuition.setTuitionId(tuitionCode);
            tuition.setStudentId(student.getStudentId());
            tuition.setSemester(request.getSemester());
            tuition.setAmount(BigDecimal.valueOf(request.getAmount()));
            tuition.setStatus("Chưa thanh toán");
            tuition.setDueDate(LocalDate.now().plusMonths(1)); // Thời hạn 1 tháng
            
            // Lưu vào database
            tuition = tuitionRepository.save(tuition);
            
            // Tạo response
            TuitionResponse tuitionResponse = new TuitionResponse(
                tuition.getTuitionId(),
                student.getStudentId(),
                student.getName(),
                student.getMajorCode(),
                request.getAmount(),
                tuition.getStatus()
            );
            
            tuitionResponses.add(tuitionResponse);
        }
        
        // Tạo response object
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
        List<Tuition> tuitions = tuitionRepository.findByStudentId(studentDTO.getStudentId());

        // Chuẩn bị response
        StudentTuitionResponse response = new StudentTuitionResponse();

        StudentTuitionResponse.StudentInfo studentInfo = new StudentTuitionResponse.StudentInfo();
        studentInfo.setStudentId(studentDTO.getStudentId());
        studentInfo.setName(studentDTO.getName());
        studentInfo.setMajorCode(studentDTO.getMajorCode());
        response.setStudent(studentInfo);

        List<StudentTuitionResponse.TuitionInfo> tuitionInfos = tuitions.stream().map(t -> {
            StudentTuitionResponse.TuitionInfo info = new StudentTuitionResponse.TuitionInfo();
            info.setTuitionCode(t.getTuitionId());
            info.setSemester(t.getSemester());
            info.setAmount(t.getAmount().doubleValue());
            info.setStatus(t.getStatus());
            return info;
        }).collect(Collectors.toList());

        response.setTuitions(tuitionInfos);

        return response;
    }
    
    private TuitionDTO convertToDTO(Tuition tuition) {
        TuitionDTO dto = new TuitionDTO();
        dto.setTuitionId(tuition.getTuitionId());
        dto.setStudentId(tuition.getStudentId());
        dto.setSemester(tuition.getSemester());
        dto.setAmount(tuition.getAmount());
        dto.setStatus(tuition.getStatus());
        return dto;
    }
}