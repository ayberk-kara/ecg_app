# ENS492 – Graduation Project  
## Real-Time 12-Lead ECG/Cardiogoniometry Viewer for Mobile Devices

![App Screenshot](screenshots/live_plot.png)

This repository contains the **Flutter-based mobile application** developed as part of the **ENS 492 – Graduation Project** at Sabancı University. The app allows real-time visualization of **12-lead ECG data** entirely **offline** on **any Android smartphone**, supporting robust and smooth interaction.

---

## 📌 Project Info

- **Project Title**: Development of a Mobile Application for ECG/Cardiogoniometry Data Display & Analysis  
- **Course**: ENS 492 – Graduation Project  
- **Student**: Ayberk Kara  
- **Supervisor**: Prof. Dr. Ayhan Bozkurt  
- **Date**: 19.05.2025  

---

## 🧠 Why We Did This

- Cardiovascular diseases are the **#1 cause of death** globally.
- **12-lead ECG** is the gold standard for diagnosis, but current machines are **bulky, expensive**, and often **non-portable**.
- Existing mobile apps:
  - Show **only 1–2 leads**
  - Require **cloud upload**, introducing **latency and privacy risks**
- Our goal: A **handheld, multi-lead, offline** ECG viewer for any consumer smartphone.

---

## 🎯 Key Objectives

- **Reliable stream**: ≥250 samples/sec per lead, **no drops for 20 minutes**
- **12-lead real-time plotting** at **60 FPS** on mid-range Android
- **Calibrated medical-style grid**, smooth pan/zoom, pause/inspect
- **Offline-only**, ≤50MB APK, battery-conscious
- Compliant with **GDPR / HIPAA**
- Works with **non-technical staff**, designed for **usability**

---

## 🏗️ System Architecture

```mermaid
graph LR
A[ECG Signal Generator] --> B[Microcontroller with ADC (STM32)]
B --> C[USB Serial Stream]
C --> D[Flutter App]
D --> E[Real-Time ECG Rendering]

