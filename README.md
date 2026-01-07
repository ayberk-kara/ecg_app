# ENS492 – Graduation Project  
## Real-Time 12-Lead ECG/Cardiogoniometry Viewer for Mobile Devices



This repository contains the Flutter-based mobile application developed as part of the ENS 492 Graduation Project at Sabancı University.  
The app provides real-time visualization of 12-lead ECG data, entirely offline, running on any Android smartphone.

---

## Project Info

- **Project Title:** Development of a Mobile Application for ECG/Cardiogoniometry Data Display & Analysis   
- **Date:** 19.05.2025  

---

## Why We Did This

- Cardiovascular diseases are the #1 global cause of death.  
- 12-lead ECG is the clinical gold standard, but current machines are bulky and expensive.  
- Existing mobile apps typically:  
  - show only 1–2 leads  
  - require cloud upload → latency + privacy risks  
- Goal: handheld, multi-lead, offline ECG visualizer for any smartphone.

---

## Key Objectives

- ≥ 250 samples/sec per lead for 20 minutes with zero packet drops  
- 12-lead plotting at 60 FPS on mid-range Android  
- Calibrated medical ECG grid with smooth pan/zoom  
- APK ≤ 50 MB, battery-friendly  
- GDPR/HIPAA-conscious design  

---

## Hardware

- ADS1292R biopotential front-end  
- STM32F103 MCU with TinyUSB (CDC)  
- PETG 3D-printed enclosure  
- IEC-inspired analog signal layout  
- Powered from phone (≤ 80 mA)

---

## Software

- Flutter/Dart frontend  
- CustomPainter ECG grid and waveform engine  
- Moving Average + IIR filters   
---

## Mobile App Highlights

- Live USB connection & sample counter  
- Real-time 12-lead ECG on calibrated grid  
- Pinch-to-zoom, swipe scroll, “Jump to Tail” live mode  
- PDF export (10-second snapshot)  
- < 40 ms USB-to-screen latency  
- Stable 60 FPS on Snapdragon 845


---

## Performance & Validation

| Metric | Result |
|--------|--------|
| Packet drops (20 min) | 0 |
| Drift (8-hour soak test) | < 0.02% |
| Rendering FPS | 60 FPS |
| CPU Usage | < 35% |
| Power Draw | ≤ 80 mA |
| PDF Export | < 1.5 sec |
| USB → Screen Latency | < 40 ms |

---

## Results & Discussion

- All core goals achieved  
- USB streaming proved more robust than Wi-Fi  
- Flutter successfully delivered high-performance biomedical UI  
- Limitations: fixed grid scaling, synthetic dataset, no full power profiling  
- Likely one of the first open-source fully offline 12-lead ECG renderers  

---

## Scientific & Technical Impact

- Scientific: establishes mobile ECG performance baseline  
- Socio-economic: <$100 hardware → accessible community screening  
- Engineering: demonstrates Flutter capability for medical-grade graphics  
- Development: agile iteration outperformed top-down planning  

---

## Next Steps

- Adaptive DPI-aware grid scaling  
- On-device arrhythmia detection (TFLite)  
- Clinical validation with real patient data  
- Power profiling & optimizations  

---


