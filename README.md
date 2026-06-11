# Verilog-Based AES-128 Fault Injection & Mitigation Framework

An Automated framework designed to evaluate the hardwrare vulnerability of AES-128 cryptographic processor against Transient Faults and validate hardware-level mitigation techniques (TMR & Parity check).

## 1. Project Overview
본 프로젝트는 AES-128 코어가 노이즈 및 의도적인 Fault Injection을 받았을 때 발생하는 취약성을 정량적으로 분석한다. 이를 방어하기 위한 하드웨어 레벨의 신뢰성 향상 기법(TMR, Parity Check)를 적용하고, 보안성 개선 효과와 하드웨어 오버헤드 간의 Trade-off를 정량적으로 비교 및 검증하는 연구용 프레임워크이다.

### Key Objectives
* **하드웨어 취약성 분석:** AES-128 핵심 레지스터에 비트 반전 오류를 주입하여 암포 시스템에 미치는 영향 정량화
* **방어 메커니즘 검증:** TMR 및 Parity Check 회롤를 통한 일시적인 오류 차단 능력 검증
* **하드웨어 비용 평가:** 방어 로직 추가에 따른 면적(LUT/FF) 증가량 및 최대 동작 주파수 저하율 측정

## 2. Environment & Tools
* **HDL Language:** Verilog
* **Simulator:** Icarus Verilog (iverilog) & vvp / GTKWave (파형분석)
* **Automation:** Python (CLI 제어 및 'subprocess'모듈 기반 몬테 카를로 시뮬레이션 제어)
* **Synthesis:** Xilinx Vivado (CLI 스크립트 모드)
* ** OS Environment:** Linux (Ubuntu)

## 3. HW Architecture & DUT Structure
### 1) 기본형 코어 (Unprotected Model)
* 방어로직이 없는 순수 10-Round 구조의 AES-128 암호화 코어
* **FSM control:** 'STATE\_IDLE' -> 'STATE\_INIT' -> 'STATE\_ROUND' -> 'STATE\_FINAL' -> 'STATE\_DONE'
* 핵심 데이터 경로 레지스터인 'state\_reg'와 'key\_reg'를 중심으로 라운드 함수 연산 반복

### 2) 보호형 코어(Protected Model)
* **Single Event Upset 방어:** 핵심 제어 및 데이터 상태 레지스터에 **TMR(Triple Modular Redundancy)** 및 **Majority Voter** 회로를 적용하여 하드웨어 내부에서 오류를 실시간 복구
* **실시간 에러 탐지:** 데이터 경로 및 Round Key 레지스터 전반에 **Parity Checker**를 통합 구축하여, 결함 발생 즉시 외부 핀으로 플래그 출력하고 오염된 데이터 출력 차단 

## 4. Automated Fault Injection Framework
### Injection Mechanism
: Verilog Testbench 내부에 'force' 및 'release' 구문을 계층형 구조로 구현한다. 시뮬레이션 동작 중, 임의의 라운드 및 클록 시점에 특정 내부 플립플롭 값을 강제로 반전시켜 일시적 오류를 모사한다.

### Automation Loop (Monte Carlo Simulation)
    (1) 마스터 Python 스크립트가 무작위 인자 생성
    (2) Python 'subprocess'를 통해 Icarus Verilog 시뮬레이터를 **1000회 이상 반복 구동**
    (3) 출력 로그 파일 분석 스크립트가 시뮬레이션 결과를 취합하여 정량적 지표 도출

## 5. Key Metrics
### 1) Fault Classification 
시뮬레이션 결과를 분석하여 주입된 결함의 거동을 3가지 영역으로 분류한다.
* **Masked:** 결함이 주입되었으나 조합논리 구조 혹은 TMR에 의해 상쇄되어 최종 출력 암호문이 정상 정답지와 일치 
* **Detected:** 보호 로직이 에러를 감지하여 'err\_detected == 1'을 정상적으로 출력하고 오염된 데이터 유출 차단 (보안 동작 성공)
* **SDC(Silent Data Corruption):** 에러 감지 플래그가 발생하지 않았음에도 최종 암호문이 오염되어 출력됨 (**치명적인 보안 취약점**)

### 2) HW Overhead
* **Area:** 논리 합성 리포트를 기준으로 기본형 대비 보호형의 LUT 및 FF Count 증가율 측정
* **Timing:** Critical Path Delay 분석을 통한 최대 동작 주파수 저하율 분석

## 6. Directory Structure
```text
aes128-fault-injection-framework/   
|---- design/               # RTL 소스 코드 레포지토리
|  |---- include/               # 글로벌 정의 및 파라미터 셋
|  |---- unprotected/           # 기본형 AES-128 코어 소스
|  |---- protected/             # TMR 및 Parity 탑재 보호형 코어 소스
|---- verification/         # 시뮬레이션 및 검증 환경
|  |---- tb_aes_top.v           # force/release 구문 기반 결함 주입 통합 TB
|  |---- vectors.hex            # NIST 표준 명세 기반 정답 테스트 벡터
|---- scripts/              # 자동화 프레임워크 스크립트
|  |---- run_fault_sim.py       # 몬테카를로 결함 주입 시뮬레이션 구동 스크립트
|  |---- parse_logs.py          # 시뮬레이션 결과 로그 파싱 및 통계화 스크립트
|----results/               # 데이터 분석 및 리포트 출력물
|  |---- fault_summary.csv      # 결함 주입 실험 수치 결과 데이터
|  |---- metrics_graph.png      # 분석 결과 시각화 그래프 파일
|  |---- syntheesis_report/     # Vivado 논리 합성 결과 리포트
|---- README.md             # 프로젝트 메인 대문 (본문서)

## 7. Results
### 1) 기본 AES 코어 구현 및 NIST Vector Test.
: Unprotected AES에 NIST 표준 테스트 벡터를 주입하여 FSM 상태 천이 및 최종 암호화 일치 여부를 검증한 결과.
```text
VCD info: dumpfile results/aes_simulation.vcd opened for output.
[SIM_INFO] 암호화 시작 - Plaintext: 00112233445566778899aabbccddeeff
[SIM_INFO] 암호화 시작 - Input Key: 000102030405060708090a0b0c0d0e0f
[ROUND_LOG] Clock 5 | Round: 0 | State_Reg: 00000000000000000000000000000000 | Keg_Reg: 000102030405060708090a0b0c0d0e0f
[ROUND_LOG] Clock 6 | Round: 1 | State_Reg: 00102030405060708090a0b0c0d0e0f0 | Keg_Reg: 000102030405060708090a0b0c0d0e0f
[ROUND_LOG] Clock 7 | Round: 2 | State_Reg: 89d810e8855ace682d1843d8cb128fe4 | Keg_Reg: d6aa74fdd2af72fadaa678f1d6ab76fe
[ROUND_LOG] Clock 8 | Round: 3 | State_Reg: 4915598f55e5d7a0daca94fa1f0a63f7 | Keg_Reg: b692cf0b643dbdf1be9bc5006830b3fe
[ROUND_LOG] Clock 9 | Round: 4 | State_Reg: fa636a2825b339c940668a3157244d17 | Keg_Reg: b6ff744ed2c2c9bf6c590cbf0469bf41
[ROUND_LOG] Clock 10 | Round: 5 | State_Reg: 247240236966b3fa6ed2753288425b6c | Keg_Reg: 47f7f7bc95353e03f96c32bcfd058dfd
[ROUND_LOG] Clock 11 | Round: 6 | State_Reg: c81677bc9b7ac93b25027992b0261996 | Keg_Reg: 3caaa3e8a99f9deb50f3af57adf622aa
[ROUND_LOG] Clock 12 | Round: 7 | State_Reg: c62fe109f75eedc3cc79395d84f9cf5d | Keg_Reg: 5e390f7df7a69296a7553dc10aa31f6b
[ROUND_LOG] Clock 13 | Round: 8 | State_Reg: d1876c0f79c4300ab45594add66ff41f | Keg_Reg: 14f9701ae35fe28c440adf4d4ea9c026
[ROUND_LOG] Clock 14 | Round: 9 | State_Reg: fde3bad205e5d0d73547964ef1fe37f1 | Keg_Reg: 47438735a41c65b9e016baf4aebf7ad2
[ROUND_LOG] Clock 15 | Round: 10 | State_Reg: bd6e7c3df2b5779e0b61216e8b10b689 | Keg_Reg: 549932d1f08557681093ed9cbe2c974e
[ROUND_LOG] Clock 16 | Round: 10 | State_Reg: 69c4e0d86a7b0430d8cdb78070b4c55a | Keg_Reg: 13111d7fe3944a17f307a78b4d2b30c5
[SIM_INFO] 암호화 완료 / 연산 종료 완료.
[RESULT] Output Ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a
[EXPECT] Golden Ciphertext: 69c4e0d86a7b0430d8cdb78070b3c55a
==================================================
[FAIL] NIST 표준 벡터와 결과 불일치 (BUG DETECTED)
[DEBUG] XOR Mismatch Mask: 00000000000000000000000000070000
==================================================
verification/tb/tb_aes_top.v:80: $finish called at 470000 (1ps)

