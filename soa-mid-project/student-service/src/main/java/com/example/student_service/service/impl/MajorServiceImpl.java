package com.example.student_service.service.impl;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.student_service.dto.MajorDTO;
import com.example.student_service.model.Major;
import com.example.student_service.repository.MajorRepository;
import com.example.student_service.service.MajorService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MajorServiceImpl implements MajorService {

    private final MajorRepository majorRepository;

    public MajorServiceImpl(MajorRepository majorRepository) {
        this.majorRepository = majorRepository;
    }

    @Override
    public List<MajorDTO> getAllMajors() {
        return majorRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public MajorDTO getMajorById(int id) {
        Major major = majorRepository.findById(id)
                .orElseThrow(() -> new ApiException(ErrorCode.MAJOR_NOT_FOUND));
        return convertToDTO(major);
    }

    @Override
    public MajorDTO getMajorByCode(String code) {
        Major major = majorRepository.findByCode(code)
                .orElseThrow(() -> new ApiException(ErrorCode.MAJOR_NOT_FOUND));
        return convertToDTO(major);
    }

    @Override
    public MajorDTO createMajor(MajorDTO majorDTO) {
        if (majorRepository.existsByCode(majorDTO.getCode())) {
            throw new ApiException(ErrorCode.MAJOR_ALREADY_EXISTS);
        }
        
        Major major = new Major();
        major.setCode(majorDTO.getCode());
        major.setName(majorDTO.getName());
        
        Major savedMajor = majorRepository.save(major);
        return convertToDTO(savedMajor);
    }

    @Override
    public MajorDTO updateMajor(int id, MajorDTO majorDTO) {
        Major major = majorRepository.findById(id)
                .orElseThrow(() -> new ApiException(ErrorCode.MAJOR_NOT_FOUND));
        
        major.setCode(majorDTO.getCode());
        major.setName(majorDTO.getName());
        
        Major updatedMajor = majorRepository.save(major);
        return convertToDTO(updatedMajor);
    }

    @Override
    public void deleteMajor(int id) {
        if (!majorRepository.existsById(id)) {
            throw new ApiException(ErrorCode.MAJOR_NOT_FOUND);
        }
        majorRepository.deleteById(id);
    }

    private MajorDTO convertToDTO(Major major) {
        return new MajorDTO(major.getId(), major.getCode(), major.getName());
    }
}
