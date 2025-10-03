package com.example.student_service.service;

import com.example.student_service.dto.MajorDTO;
import java.util.List;

public interface MajorService {
    List<MajorDTO> getAllMajors();
    MajorDTO getMajorById(int id);
    MajorDTO getMajorByCode(String code);
    MajorDTO createMajor(MajorDTO majorDTO);
    MajorDTO updateMajor(int id, MajorDTO majorDTO);
    void deleteMajor(int id);
}
