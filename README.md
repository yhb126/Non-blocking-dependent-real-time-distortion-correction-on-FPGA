# Non-blocking Dependent Real-time Distortion Correction on FPGA

**基于 FPGA 的非阻塞依赖实时畸变校正系统**

[![Vivado](https://img.shields.io/badge/Vivado-2018.3-blue)](https://www.xilinx.com)
[![Language](https://img.shields.io/badge/Language-Verilog-orange)](https://en.wikipedia.org/wiki/Verilog)


---

## 📖 Overview | 概述

This project implements a **real-time lens distortion correction (LDC)** system on FPGA using a **non-blocking dependent pipeline architecture**. It corrects radial (barrel/pincushion) distortion in real-time video streams at 1920×1080 (Full HD) resolution, clocked at 150 MHz.

该设计在 FPGA 上实现了**实时镜头畸变校正（LDC）系统**，采用**非阻塞依赖流水线架构**，对实时视频流进行桶形/枕形畸变校正，支持 1920×1080（全高清）分辨率，时钟频率 150 MHz。

### Key Features | 主要特点

| Feature | Description |
|---------|-------------|
| **Resolution** | 1920×1080 @ 150 MHz |
| **Distortion Model** | Radial polynomial correction (K1 coefficient) |
| **Interpolation** | Quadratic (bi-quadratic) interpolation |
| **Pipeline** | 5-stage non-blocking dependent architecture |
| **Buffer** | Ring line buffer with configurable depth |
| **FPGA Platform** | Xilinx (Vivado 2018.3) |
| **I/O Standard** | LVCMOS18 |
| **Synchronization** | FIFO-based inter-stage handshake |

### Architecture | 架构

```
          ┌─────────────────────────────────────────────────────┐
          │                   ldc_top                            │
          │                                                      │
  pixel ─→│───┐                                           ┌─────│→ pixel_out
  sync  ─→│─┐ │        ┌──────────────┐    ┌───────────┐ │      │→ sync_out
           │ │ │        │  fifo_ctrl   │───→│ p_out_ctrl│ │      │
           │ │ │   ┌───→│ (pipeline    │    └───────────┘ │      │
           │ │ │   │    │  sync)       │                   │      │
           │ │ │   │    └──────┬───────┘                   │      │
           │ ↓ ↓   │           │                           │      │
           │ ┌─────┴──┐  ┌─────┴────────┐  ┌─────────────┐│      │
           │ │Loc_map │  │ buffer_ctrl  │  │ Interp_ctrl ││      │
           │ │(coords)│  │ (ring buffer)│  │ (quadratic) ││      │
           │ └────────┘  └──────────────┘  └─────────────┘│      │
           │                                                      │
           └─────────────────────────────────────────────────────┘
```

---

## 🏗 Project Structure | 项目结构

```
├── Src/
│   ├── new/                         # Core RTL source files
│   │   ├── ldc_top.v                # Top-level module
│   │   ├── Location_mapping.v       # Distortion coordinate computation
│   │   ├── buffer_ctrl.v            # Ring line buffer controller
│   │   ├── fifo_ctrl.v              # Pipeline FIFO synchronizer
│   │   ├── Interpolation_ctrl.v     # Interpolation controller
│   │   ├── Quadratic_Interpolation.v# Bi-quadratic interpolator
│   │   ├── pixel_out_ctrl.v         # Pixel output with sync signals
│   │   ├── ring_line_buffer.v       # Ring line buffer memory
│   │   ├── ring_line_buffer_new.v   # Ring line buffer (alternative)
│   │   ├── dpram.v                  # Dual-port RAM wrapper
│   │   ├── buffer_ctrl.v            # Buffer control logic
│   │   └── Parameter.vh             # Global parameters (`WIDTH, `HEIGHT)
│   ├── tb/                          # Testbenches
│   │   ├── tb_ldc.v                 # Top-level testbench
│   │   ├── tb_interpolation.v       # Interpolation testbench
│   │   ├── tb_line_buffer.v         # Line buffer testbench
│   │   └── tb_location_mapping.v    # Location mapping testbench
│   └── ip/                          # Vivado IP cores
│       ├── blk_mem_gen_0/           # Block memory generator
│       ├── data_ctrl_fifo/          # Data FIFO
│       ├── image_data_buffer/       # Image data buffer (BRAM)
│       ├── position_fifo/           # Coordinate FIFO
│       └── ring_ram/               # Ring buffer RAM
├── Prj/
│   └── ldc/                         # Vivado project files
│       └── ldc.srcs/
│           ├── constrs_1/new/       # Timing/Pin constraints (.xdc)
│           └── sources_1/           # HDL sources (Vivado-managed copies)
├── Data/                            # Test data
│   ├── image_origin_data_1280_1.txt # Original image (1280×1280)
│   ├── image_origin_data_1920.txt   # Original image (1920×1920)
│   ├── corrected_img_1280.txt       # Corrected output (1280×1280)
│   └── corrected_img_1920.txt       # Corrected output (1920×1920)
└── Doc/                             # Documentation (empty, placeholder)
```

---

## 🔧 Core Modules | 核心模块详解

### 1. Location Mapping (`Location_mapping.v`)

Computes the corrected pixel coordinates using a radial polynomial distortion model:

$$r^2 = x^2 + y^2$$
$$r_{corrected} = r \cdot (1 - K_1 \cdot r^2)$$

- Divides the image into 4 quadrants around the center, processes one quadrant at a time
- Uses fixed-point arithmetic with configurable `FLOAT_WIDTH`
- Outputs integer + fractional parts for interpolation

### 2. Buffer Controller (`buffer_ctrl.v`)

Manages the ring line buffer that stores multiple scanlines of pixel data, providing parallel read access to the 4 neighboring pixels needed for interpolation.

- Configurable depth (`DEPTH`), width, height, and sync distance (`SYNC`)
- Handles the pipeline latency between read requests and data availability

### 3. FIFO Controller (`fifo_ctrl.v`)

Synchronizes data between the coordinate computation, buffer read, and interpolation stages of the pipeline. Resolves data dependency hazards in the non-blocking pipeline.

### 4. Quadratic Interpolation (`Quadratic_Interpolation.v` + `Interpolation_ctrl.v`)

Performs bi-quadratic interpolation using the 4 nearest neighbor pixels and the fractional coordinates, computing the final corrected pixel value (2-cycle latency).

### 5. Pixel Output Control (`pixel_out_ctrl.v`)

Generates the output video timing (`o_v_sync`, `o_h_sync`) and outputs the corrected pixel stream.

---

## 🔌 I/O Interface | 接口定义

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock (150 MHz) |
| `rst_n` | Input | 1 | Active-low reset |
| `i_v_sync` | Input | 1 | Input vertical sync |
| `i_h_sync` | Input | 1 | Input horizontal sync |
| `i_pixel` | Input | 8 | Input pixel data (grayscale) |
| `o_v_sync` | Output | 1 | Output vertical sync |
| `o_h_sync` | Output | 1 | Output horizontal sync |
| `o_pixel` | Output | 8 | Corrected pixel data |

---

## ⏱ Timing | 时序

- **Clock period**: 6.66 ns (150 MHz)
- **Pipeline latency**: Configurable via `DEPTH` and `SYNC` parameters
- **Coordinate computation**: 5 pipeline stages
- **Interpolation**: 2 pipeline stages

---

## 🧪 Simulation & Testing | 仿真与测试

Run the provided testbenches in Vivado:

```bash
# Simulate top-level module
vivado -mode tcl -source run_sim.tcl

# Or run individual testbenches
# tb_ldc.v                - Full system test
# tb_interpolation.v      - Interpolation module test
# tb_line_buffer.v        - Line buffer test
# tb_location_mapping.v   - Coordinate mapping test
```

Test data in `Data/` includes both 1280×1280 and 1920×1920 image sets for verification.

---

## ⚙ Parameters | 参数配置

Define in `Parameter.vh` or via module parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `WIDTH` | 1920 | Image width (pixels) |
| `HEIGHT` | 1080 | Image height (pixels) |
| `FLOAT_WIDTH` | 24 | Fixed-point fractional bits |
| `K1` | 4 | Radial distortion coefficient |
| `LDC_TYPE` | 0 | 0 = barrel, 1 = pincushion |
| `DEPTH` | 256 | Ring buffer depth (lines) |
| `SYNC` | 580 | Pipeline sync distance |

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

Created by **yhb126** — feel free to open an issue or pull request!
