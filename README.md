# Authentication Re-Imagined
#### Team: 202 ACCEPTED

Hackathon Submission for the UIDAI Hackathon 2021

### General

This is a project submitted to the UIDAI Aadhar Authentication Hackathon. We try to explore authentication options in a variety of ways, while providing a seamless transition from online to offline. The methods of Authentication are:
- Fingerprint Matching (Simulated due to lack of fingerprint sensors)
- Aadhar based OTP matching (Via SMS or email)
- Stateless eKYC Matching

The navigational structure of the project looks something like this

```
resident_app
├── android/..
├── assets/..
├── lib
│   ├── camera_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── main.dart
│   └── resident_data.dart
├── pubspec.lock
└── pubspec.yaml
```

with the files in `lib` containing the important application data

![Architecture Diagram](architecture_diagram.png)

### Approach

#### Offline Fingerprint Authentication
* UIDAI server generates a secure hash of the recorded fingerprint and sends it to the resident application as unique id (at setup).
* Verifier accepts hash value from resident application using QR code.
* Verifier also takes actual fingerprint and computes its hash.
* If both hashes match, authenticity is proven completely offline (extremely fast).

#### Offline eKYC Match
* If fingerprint authentication not possible, Offline Stateless eKYC match implemented from the API
* Resident app will obtain eKYC XML from UIDAI server (at setup).
* Stateless match performed as already supported in the Verifier App.

<br>

### Tech Stack
We use a modified Flutter (Kotlin/Swift) Techstack implemented mostly in flutter with a few calls to Native code in Kotlin. All use of API's is limited to those provided by the UIDAI for the purposes of the Hackathon due to safety reasons.

#### API Usage
- OTP API to simulate Fingerprint Hash (as mentioned in the docs)
- OTP API for Mobile phone Auth
- eKYC API for Stateless Matching.
- Aadhaar Auth API

<br>

### About Us
- Omkar Prabhune, CSE Junior at VIT Pune
- Atharva Rajadhyaksha, Instrumentation Junior at VIT Pune
