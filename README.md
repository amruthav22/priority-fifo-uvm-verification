# 🚀 Priority-Based FIFO Verification using UVM

## 📌 Overview

This project focuses on the **design verification of a Priority-Based FIFO** using **SystemVerilog and UVM methodology**.

Unlike a conventional FIFO, this design supports **multiple priority levels (HIGH, MEDIUM, LOW)**, where higher-priority data is always serviced first. The verification environment ensures correctness under **dynamic conditions such as simultaneous read/write, priority arbitration, and boundary scenarios**.

---

## 🎯 Key Features

* ✅ UVM-based reusable verification environment
* ✅ Priority-aware FIFO validation (HIGH > MEDIUM > LOW)
* ✅ Scoreboard aligned with **`rd_valid` (latency-independent checking)**
* ✅ Assertion-based verification for protocol correctness
* ✅ Multiple directed + randomized test scenarios
* ✅ Clean debugging with detailed logs and error reporting

---

## 🧠 Verification Strategy

### ✔ Scoreboard Design

* Implements **priority queues (HQ, MQ, LQ)** to mirror DUT behavior
* Pops expected data **only when `rd_valid` is asserted**
* Detects:

  * Data mismatches
  * Unexpected reads
  * Missing outputs

---

### ✔ Assertions

Assertions were used to catch critical design issues such as:

* ❌ Invalid `rd_valid` assertion when FIFO is empty
* ❌ Protocol violations during simultaneous read/write
* ❌ Incorrect priority servicing

---

## 🧪 Test Scenarios

### 🔹 Random Sequence

* General randomized traffic for broad coverage

### 🔹 High Priority Burst

* Floods FIFO with HIGH priority data
* Ensures correct ordering during drain

### 🔹 Starvation Test

* MED priority data written first
* HIGH priority flood ensures MED gets delayed
* Verifies no data loss under starvation conditions

### 🔹 Mixed Traffic

* Weighted random distribution of:

  * Read/Write
  * Priority levels
* Ensures all cases are exercised

### 🔹 Empty Read

* Attempts read on empty FIFO
* Ensures no false `rd_valid`

### 🔹 Full FIFO

* Fills FIFO to capacity
* Writes beyond full condition
* Verifies no corruption during overflow

---

## 🐞 Bug Coverage

This environment successfully helped identify:

* Priority handling issues
* Invalid read conditions
* Data ordering mismatches

📄 **Do check out the detailed bug report included in this repository** — it explains the issues, debugging approach, and fixes in depth.

---

## 🛠️ Project Structure

```
├── rtl/        # FIFO Design
├── tb/         # UVM Testbench
│   ├── sequence/
│   ├── driver/
│   ├── monitor/
│   ├── scoreboard/
│   └── env/
├── assertions/ # SVA checks
├── docs/       # Bug reports & analysis
```

---

## ▶️ Simulation

You can run and explore the project here:
🔗 *EDA Playground Link* https://edaplayground.com/x/p5Eu

---

## 📈 Future Improvements

* Latency-aware transaction tracking (ID-based matching)
* Functional coverage integration
* AXI-stream style interface extension

---

## 👩‍💻 Author

**Amrutha Varshini**
VLSI Design Verification Enthusiast

---


