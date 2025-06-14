**High-Level Design Specification (HLDS)**
**Multi-Processor System with Memory Controller and Shared Bus**
**Author**: Viraj Pashte
**Date**: 13th June, 2025
**Version**: 1.0

---

### 1. Introduction

The purpose of this High-Level Design Specification (HLDS) is to define the system architecture and functional behavior of a multi-processor system with a memory controller and shared bus. This design focuses on building a scalable, high-performance computing system that interconnects multiple processing units to a shared memory via an arbitration mechanism. This document outlines all key components, interactions, and verification strategies to be followed during development.

---

### 2. Design Overview

The system comprises:

* **Three Processor Cores** executing arithmetic, load/store, and shift instructions.
* **Instruction Unit** to decode and feed operations to the ALU.
* **ALU** to execute operations.
* **Direct-Mapped Cache** for each processor (128B) with valid and dirty bits.
* **Shared 2KB Memory Subsystem** controlled by a memory controller.
* **Round-Robin Arbiter** to manage access to the memory from multiple cores.
* **Shared Bus** for communication between processors and memory.

The memory controller ensures correct data storage and retrieval, handles eviction policies in cache, and maintains consistency across shared resources.

---

### 3. Modules

* **Top Module**: Instantiates and connects all submodules.
* **Instruction Unit**: Fetches and decodes instructions for the core.
* **ALU**: Performs arithmetic, logical, shift operations.
* **Cache**: Direct-mapped; handles read/write with dirty/valid bit handling.
* **Memory Controller**: Manages read/write requests from multiple processors.
* **Shared Memory**: Stores program and data with partitioned logic.
* **Arbiter**: Implements a round-robin scheme for fair processor access.

---

### 4. Interfaces

* **Processor to Cache**: Internal local access.
* **Cache to Memory**: Via shared bus and arbiter.
* **Memory Controller to Memory**: Direct control.
* **Clock & Reset**: Global synchronized clock and system-wide reset.

---

### 5. Design Constraints

* 2KB memory with 1-byte width.
* 128B direct-mapped cache per core.
* 3-core architecture.
* Fixed instruction size: 28-bit.
* No pipelining; sequential instruction processing.

---

### 6. Verification Plan

**Testbench Style**: UVM-based self-checking testbench.

**Verification Components**:

* **Agents** for processors and memory.
* **Sequencers & Sequences** to generate traffic.
* **Scoreboard** for data comparison.
* **Monitors** to sample interface transactions.

**Test Scenarios**:

* Independent processor instruction tests.
* Cache hit/miss and eviction scenarios.
* Arbiter fairness and bus access checks.
* Error handling for illegal memory access.

**Tools**:

* **QuestaSim** for simulation.
* **SystemVerilog** with UVM.
* **Assertions and Coverage** for quality metrics.

---

### 7. Directory Structure

```
/src        # RTL and design modules
/tb         # UVM testbench components
/sim        # Simulation scripts
/log        # Simulation logs
/results    # Coverage and result reports
/docs       # HLDS and related docs
```

---

### 8. Next Steps

* Begin SystemVerilog implementation of Instruction Unit and ALU.
* Setup top-level testbench with dummy DUT.
* Start cache controller coding and test arbitration logic.

---

*End of HLDS v1.0*
