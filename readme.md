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

