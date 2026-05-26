# ASIC Hardware Accelerator for LiDAR Ground Segmentation (FESTA)

> Real-time FPGA-based ground segmentation accelerator for ADAS applications — designed in Verilog RTL with AXI4-Stream and AXI4-Lite interfaces.

---

## 🚗 Project Overview

High-resolution LiDAR sensors generate millions of 3D point cloud data points per second. Processing this data in software is too slow and power-hungry for safety-critical embedded automotive systems. This project offloads the computation to dedicated hardware.

This accelerator implements the **FESTA (FPGA-Enabled Ground Segmentation for Automotive LiDAR)** algorithm in Verilog RTL — classifying each incoming LiDAR point as **ground** or **non-ground** in real time, with deterministic latency suitable for ADAS deployment.

---

## 🏗️ System Architecture

```
LiDAR Point Cloud (X, Y, Height)
          │
          ▼
┌─────────────────────────┐
│   Cell Index Calculator  │  ← Converts (X,Y) → Grid Memory Address
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│     Cell Grid Core       │  ← BRAM-based height map storage (4096 cells)
│   (Dual-Port BRAM)       │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Ground Segmentation     │  ← Threshold-based classification
│       Core               │     ground_flag = (height ≤ threshold)
└────────────┬────────────┘
             │
             ▼
     ground_flag + output_valid
```

**Top-level wrapper:** `festa_hw.v` integrates all three cores with AXI4-Stream (data) and AXI4-Lite (control) interfaces.

---

## 📁 Repository Structure

```
festa-lidar-accelerator/
│
├── rtl/
│   ├── cell_index_calculator.v     # Coordinate → grid address converter
│   ├── cell_grid_core.v            # BRAM-based elevation grid memory
│   ├── ground_segmentation_core.v  # Threshold-based ground classifier
│   └── festa_hw.v                  # Top-level AXI4 wrapper
│
├── sim/
│   └── festa_hw_tb.v               # Testbench with ground & non-ground test vectors
│
├── constraints/
│   └── festa_constraints.xdc       # Xilinx Vivado pin & timing constraints
│
├── docs/
│   ├── block_diagram.png           # System architecture diagram
│   ├── schematic.png               # Vivado elaborated design schematic
│   ├── floorplan.png               # FPGA device floor plan (placed design)
│   └── waveform.png                # AXI4 simulation waveform
│
└── README.md
```

---

## 🔧 RTL Modules

### `cell_index_calculator.v`
Converts signed (X, Y) coordinates into a flat grid memory address using parameterizable grid dimensions and cell size. Outputs a `valid` flag — points outside the grid boundary are rejected.

| Parameter | Default | Description |
|---|---|---|
| `GRID_WIDTH` | 64 | Number of columns in the grid |
| `GRID_HEIGHT` | 64 | Number of rows in the grid |
| `CELL_SIZE` | 1 | Spatial resolution per cell |

---

### `cell_grid_core.v`
Synchronous BRAM-based grid memory storing height values for each cell. Supports simultaneous read and write (dual-port behaviour). Resets all memory on `rst`.

| Parameter | Default | Description |
|---|---|---|
| `GRID_SIZE` | 4096 | Total number of grid cells (64×64) |
| `DATA_WIDTH` | 16 | Bit-width of stored height values |

---

### `ground_segmentation_core.v`
Compares incoming point height against a configurable threshold. Registered output ensures clean timing closure.

| Parameter | Default | Description |
|---|---|---|
| `HEIGHT_THRESHOLD` | 50 | Points ≤ threshold classified as ground |

---

### `festa_hw.v` — Top-Level
Integrates all three cores. Exposes:
- **AXI4-Stream slave** — incoming LiDAR point data (`s_axis_tdata`, `s_axis_tvalid`, `s_axis_tready`)
- **AXI4-Lite** — control register access for parameter tuning
- **AXI4-Stream master** — classification output (`m_axis_tdata`, `m_axis_tvalid`)

---

## 🧪 Simulation

The testbench (`festa_hw_tb.v`) applies two test vectors:

| Test | X | Y | Height | Expected Output |
|---|---|---|---|---|
| Ground point | 10 | 20 | 30 | `ground_flag = 1` |
| Non-ground point | 15 | 25 | 120 | `ground_flag = 0` |

**Run in Xilinx Vivado:**
1. Create a new Vivado project targeting your FPGA (tested on Zynq UltraScale+)
2. Add all files under `rtl/` and `sim/` as sources
3. Set `festa_hw_tb` as the simulation top
4. Run Behavioral Simulation → observe waveforms

---

## 📊 Results

| Metric | Value |
|---|---|
| Target FPGA | Zynq UltraScale+ (xczu7ev-ffvc1156-2-e) |
| Design cells | 34 |
| I/O Ports | 104 |
| Nets | 374 |
| Verified interfaces | AXI4-Stream, AXI4-Lite, Dual-Port BRAM |
| Simulation result | Functional ✅ |

Simulation waveforms, floor plan, and elaborated schematic are in `/docs`.

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| Xilinx Vivado 2024.2 | RTL simulation, synthesis, implementation |
| Verilog HDL | RTL design language |
| ROS2 | Algorithm visualization and end-to-end validation |
| LTSpice / MATLAB | Supporting analysis |

---

## 🎯 Key Design Decisions

- **Pipelined FSM architecture** — ensures each stage (index calculation → memory access → classification) is registered, achieving timing closure
- **Parameterized design** — grid size, cell size, and threshold are all configurable at synthesis time for easy tuning
- **BRAM for grid storage** — on-chip BRAM avoids off-chip memory latency, critical for real-time ADAS performance
- **AXI4-Stream** for high-throughput point cloud ingestion; **AXI4-Lite** for low-bandwidth control register access — standard embedded interface protocol for SoC integration

---

## 👥 Team

| Name | Role |
|---|---|
| Mohammed Aadhil M | RTL Design, AXI4 Integration, Verification |
| Arundhathy San | Ground Segmentation Core, Simulation |
| Diya M S | Cell Grid Core, BRAM Verification |
| Joseph Joy | Cell Index Calculator, Testbench |

**Guide:** Prof. Anu Assis, Department of ECE, TKM College of Engineering

---

## 📄 References

- FESTA: FPGA-Enabled Ground Segmentation Algorithm for Automotive LiDAR
- Xilinx UltraScale+ Architecture Reference Manual
- AMBA AXI4 Protocol Specification (ARM IHI0022)

---

## 📬 Contact

**Mohammed Aadhil M**
📧 aadhiltvm@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/mohammed-aadhil-328628316)
