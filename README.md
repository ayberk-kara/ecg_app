 🩺 ENS492 – Graduation Project  
## Real-Time 12-Lead ECG/Cardiogoniometry Viewer for Mobile Devices

<p align="center">
  <img src="screenshots/live_plot.png" width="70%">
</p>

This repository contains the **Flutter-based mobile application** developed as part of the **ENS 492 – Graduation Project** at Sabancı University.  
The app provides **real-time visualization of 12-lead ECG data**, operating fully **offline** on **any Android smartphone** with smooth, medically accurate rendering.

---

## 📌 Project Info

- **Project Title:** Development of a Mobile Application for ECG/Cardiogoniometry Data Display & Analysis  
- **Course:** ENS 492 – Graduation Project  
- **Student:** Ayberk Kara  
- **Supervisor:** Prof. Dr. Ayhan Bozkurt  
- **Date:** 19.05.2025  

---

## 🧠 Why We Did This

- Cardiovascular diseases are the **#1 global cause of death**.  
- **12-lead ECG** is the clinical gold standard, but current machines are bulky and expensive.  
- Most mobile solutions:
  - Show **only 1–2 leads**
  - Require **cloud upload**, causing **latency + privacy risks**  
- Our goal: A **hand-held, multi-lead, offline** ECG viewer that works on everyday smartphones.

---

## 🎯 Key Objectives

- ≥ **250 samples/sec/lead**, sustained for **20 minutes with zero packet drops**
- **12-lead real-time plotting @ 60 FPS** on mid-range Android devices
- Medically familiar **calibrated grid**, smooth **pan/zoom**, pause/inspect
- **Offline-only**, APK ≤ 50 MB
- Designed for **non-technical staff**, human-centered usability
- Compliant with **GDPR / HIPAA** design principles

---

## 🧩 Hardware

- **ADS1292R** – biopotential front-end (dual-channel)  
- **STM32F103** MCU with TinyUSB CDC  
- **PETG 3D-printed enclosure**  
- **IEC 60601-inspired** analog layout  
- Powered directly from phone (**≤ 80 mA**)  

---

## 💻 Software

- **Flutter / Dart** frontend  
- Custom **ECG Grid + Waveform Engine** (CustomPainter)  
- **Moving Average + IIR Band-Pass Filters**  
- No native code, no cloud, no backend, no database  
- Completely **offline and portable**

---

## 📱 Mobile App Highlights

- 📡 **Live USB connection** & sample counter  
- 🩺 **Real-time 12-lead ECG plot** on medical grid  
- 🔍 Swipe to scroll, pinch-to-zoom, and **Jump-to-Tail (Live Mode)**  
- 📄 **PDF export** for 10-second ECG snapshots  
- ⚡ **< 40 ms latency** from USB → screen  
- 🎯 Stable **60 FPS** on Snapdragon 845  

<p align="center">
  <img src="screenshots/live_view.png" width="45%">
  <img src="screenshots/pdf_result.png" width="45%">
</p>

---

## 📊 Performance & Validation

| Metric | Result |
|--------|--------|
| Packet drops (20 min) | **0** |
| Long-term drift (8h soak test) | **< 0.02%** |
| Rendering FPS | **60 FPS stable** |
| CPU Usage | **< 35%** |
| Power Draw | **≤ 80 mA** |
| PDF Export (10s) | **< 1.5 sec** |
| End-to-end latency | **< 40 ms** |

---

## 🧪 Results & Discussion

- ✅ All core goals achieved  
- ✅ USB chosen over Wi-Fi → **deterministic, robust** performance  
- ✅ Flutter validated for **high-performance biomedical graphics**  
- ⚠️ Limitations: fixed grid scaling, synthetic data used, power profiling pending  
- ⭐ Possibly the **first open-source, cross-platform, fully-offline mobile 12-lead ECG renderer**

---

## 🔬 Scientific & Technical Impact

- **Scientific:** Establishes baseline for real-time mobile ECG visualization  
- **Socio-economic:** **<$100 BOM** → affordable community screening  
- **Engineering:** Demonstrates Flutter viability for high-fidelity medical UIs  
- **Process:** Agile sprints outperformed top-down planning in debugging cycles  

---

## 🔮 Next Steps

- 🔁 Adaptive grid scaling (DPI-aware)  
- 📉 On-device arrhythmia detection (TensorFlow Lite)  
- 🧪 Clinical validation with patient data  
- 🔋 Power profiling & optimizations  

---

## 📦 How to Run

```bash
flutter pub get
flutter run
Expected Data Format
Your ECG hardware must stream:

12 bytes per sample

1 byte per lead

Every 2 ms (≈ 500 Hz)

If using another format, update the parser in main.dart.



## 🙏 Acknowledgements
Special thanks to:

Sabancı University Faculty of Engineering

Prof. Dr. Ayhan Bozkurt (Supervisor)

All testers, reviewers & contributors

