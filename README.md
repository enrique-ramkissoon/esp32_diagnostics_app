# ESP32 Diagnostics Application

This is one of two repositories which make up the ESP32-based Diagnostic System for ECNG3020
This repository contains the mobile application code.

Accompanied by code which runs on an ESP32 microcontroller: https://github.com/enrique-ramkissoon/esp32-mass-measuring

## Setup

These instructions are intended for use on Linux.

### Step 1 - Install Flutter Build Tools
- Follow the install guide at: https://flutter.dev/docs/get-started/install

### Step 2 - Download Bluetooth Plugin
- Navigate to the root repository directory and run the command: `flutter pub get`

### Step 3 - Compile and Flash Application to Mobile Device
- Connect a mobile device through a USB port
- Ensure that the device is connected by running the command: `flutter devices`
    - If the mobile device is not detected, then enable USB Debugging in the device's developer settings.
- Flash the application to the mobile device by running the command: `flutter run`
- Before using the application, ensure that Bluetooth and Location services are enabled on the mobile device.
    - As of Android 6.0, the Location service is required for applications to scan for Bluetooth servers. 
