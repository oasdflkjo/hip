# HIP (Heterogeneous-Compute Interface for Portability) - Day 1

This readme documents the initial setup and first steps with AMD's HIP (Heterogeneous-Compute Interface for Portability).

## Setup Instructions

1. Install HIP from the AMD website.
2. Compile the Visual Studio example project to ensure proper installation.

## Project Initialization

1. Create a new folder for the project.
2. Initialize a Git repository in the folder.

## Compilation

### With Visual Studio
Compile the example project using Visual Studio.

### Without Visual Studio
Use the following command to compile without Visual Studio:


hipcc.bin --offload-arch=gfx1030 main.hip -o main.exe

```bash
C:\projects\hip
 .\main.exe
Device name: AMD Radeon RX 6800

Running Multiplication benchmark:
Run 1 Throughput: 2985.68 GFLOPS
Run 2 Throughput: 2988.82 GFLOPS
Run 3 Throughput: 2987.94 GFLOPS
Run 4 Throughput: 2991.49 GFLOPS
Run 5 Throughput: 2991.01 GFLOPS
Average Multiplication Throughput: 2988.99 GFLOPS

Running Addition benchmark:
Run 1 Throughput: 2991.85 GFLOPS
Run 2 Throughput: 2992.67 GFLOPS
Run 3 Throughput: 2993.06 GFLOPS
Run 4 Throughput: 2993.29 GFLOPS
Run 5 Throughput: 2993.54 GFLOPS
Average Addition Throughput: 2992.88 GFLOPS
```

