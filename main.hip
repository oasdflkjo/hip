#include "msvc_defines.h"
#include <hip/hip_runtime.h>
#include <iostream>
#include <string>
#include <chrono>
#include <thread>
#include <random>
#include <vector>
#include <numeric>

#define HIP_CHECK(status) \
    if (status != hipSuccess) { \
        std::cerr << "HIP error: " << hipGetErrorString(status) << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
        exit(1); \
    }

// Constants for GPU stress test
const int NUM_ELEMENTS = 500000000;  // 500 million elements
const int BLOCK_SIZE = 256;
const int NUM_ITERATIONS = 10000;
const int NUM_RUNS = 5;  // Number of times to run each stress test

// Kernel with simple multiplication
__global__ void multiplyKernel(float* data, int numElements, int numIterations) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numElements) {
        float value = data[idx];
        for (int i = 0; i < numIterations; ++i) {
            value = value * 1.000001f;  // Slight offset to prevent compiler optimizations
        }
        data[idx] = value;
    }
}

// Kernel with simple addition
__global__ void addKernel(float* data, int numElements, int numIterations) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numElements) {
        float value = data[idx];
        for (int i = 0; i < numIterations; ++i) {
            value = value + 0.000001f;  // Slight offset to prevent compiler optimizations
        }
        data[idx] = value;
    }
}

double runStressTest(float* d_data, int gridSize, void (*kernel)(float*, int, int)) {
    auto start = std::chrono::high_resolution_clock::now();
    
    kernel<<<gridSize, BLOCK_SIZE>>>(d_data, NUM_ELEMENTS, NUM_ITERATIONS);
    HIP_CHECK(hipDeviceSynchronize());
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end - start;

    // Each iteration performs one floating-point operation (multiplication or addition)
    double operations = (double)NUM_ELEMENTS * NUM_ITERATIONS;
    double gigaFlops = operations / (elapsed.count() * 1e9);
    return gigaFlops;
}

void runBenchmark(const char* name, float* d_data, int gridSize, void (*kernel)(float*, int, int)) {
    std::cout << "\nRunning " << name << " benchmark:" << std::endl;
    std::vector<double> scores;
    for (int i = 0; i < NUM_RUNS; ++i) {
        double gigaFlops = runStressTest(d_data, gridSize, kernel);
        scores.push_back(gigaFlops);
        std::cout << "Run " << i+1 << " Throughput: " << gigaFlops << " GFLOPS" << std::endl;
    }

    double avgScore = std::accumulate(scores.begin(), scores.end(), 0.0) / NUM_RUNS;
    std::cout << "Average " << name << " Throughput: " << avgScore << " GFLOPS" << std::endl;
}

int main() {
    // Device properties
    hipDeviceProp_t devProp;
    HIP_CHECK(hipGetDeviceProperties(&devProp, 0));
    std::cout << "Device name: " << devProp.name << std::endl;

    // Allocate memory on host and device
    float *h_data, *d_data;
    size_t size = NUM_ELEMENTS * sizeof(float);
    h_data = new float[NUM_ELEMENTS];
    HIP_CHECK(hipMalloc(&d_data, size));

    // Initialize data with random values
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);
    for (int i = 0; i < NUM_ELEMENTS; ++i) {
        h_data[i] = dis(gen);
    }

    // Copy data to device
    HIP_CHECK(hipMemcpy(d_data, h_data, size, hipMemcpyHostToDevice));

    // Launch kernel
    int gridSize = (NUM_ELEMENTS + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    // Run multiplication benchmark
    runBenchmark("Multiplication", d_data, gridSize, multiplyKernel);

    // Run addition benchmark
    runBenchmark("Addition", d_data, gridSize, addKernel);

    // Clean up
    delete[] h_data;
    HIP_CHECK(hipFree(d_data));

    return 0;
}
