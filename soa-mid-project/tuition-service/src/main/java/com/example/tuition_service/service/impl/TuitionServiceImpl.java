package com.example.tuition_service.service.impl;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.tuition_service.client.StudentServiceClient;
import com.example.tuition_service.dto.*;
import com.example.tuition_service.model.Tuition;
import com.example.tuition_service.repository.TuitionRepository;
import com.example.tuition_service.service.TuitionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
        List<StudentDTO> students = studentServiceClient.getStudentsByMajor(request.getMajorCode());
        List<TuitionResponse> tuitionResponses = new ArrayList<>();

        for (StudentDTO student : students) {
            String tuitionCode = request.getSemester() + student.getStudentCode();

            // Kiểm tra đã tồn tại học phí cho sinh viên này trong học kỳ chưa
            if (tuitionRepository.existsById(tuitionCode)) {
                throw new ApiException(ErrorCode.BAD_REQUEST, "Tuition already exists for student " + student.getStudentCode() + " in semester " + request.getSemester());
            }

            Tuition tuition = new Tuition();
            tuition.setTuitionId(tuitionCode);
            tuition.setStudentCode(student.getStudentCode());
            tuition.setSemester(request.getSemester());
            tuition.setAmount(BigDecimal.valueOf(request.getAmount()));
            tuition.setStatus("Chưa thanh toán");
            tuition.setDueDate(LocalDate.now().plusMonths(1));
            tuitionRepository.save(tuition);

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
}