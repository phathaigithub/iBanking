package com.example.student_service.controller;

import com.example.student_service.dto.MajorDTO;
import com.example.student_service.service.MajorService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/majors")
public class MajorController {

    private final MajorService majorService;

    public MajorController(MajorService majorService) {
        this.majorService = majorService;
    }

    // Lấy tất cả ngành học
    @GetMapping
    public ResponseEntity<List<MajorDTO>> getAllMajors() {
        List<MajorDTO> majors = majorService.getAllMajors();
        return ResponseEntity.ok(majors);
    }

    // Lấy ngành học theo ID
    @GetMapping("/{id}")
    public ResponseEntity<MajorDTO> getMajorById(@PathVariable("id") int id) {
        MajorDTO major = majorService.getMajorById(id);
        return ResponseEntity.ok(major);
    }

    // Lấy ngành học theo code
    @GetMapping("/code/{code}")
    public ResponseEntity<MajorDTO> getMajorByCode(@PathVariable("code") String code) {
        MajorDTO major = majorService.getMajorByCode(code);
        return ResponseEntity.ok(major);
    }

    // Tạo ngành học mới
    @PostMapping
    public ResponseEntity<MajorDTO> createMajor(@RequestBody MajorDTO majorDTO) {
        MajorDTO createdMajor = majorService.createMajor(majorDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdMajor);
    }

    // Cập nhật ngành học
    @PutMapping("/{id}")
    public ResponseEntity<MajorDTO> updateMajor(@PathVariable("id") int id, @RequestBody MajorDTO majorDTO) {
        MajorDTO updatedMajor = majorService.updateMajor(id, majorDTO);
        return ResponseEntity.ok(updatedMajor);
    }

    // Xóa ngành học
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMajor(@PathVariable("id") int id) {
        majorService.deleteMajor(id);
        return ResponseEntity.noContent().build();
    }
}
