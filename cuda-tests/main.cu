#include <chrono>
#include <iostream>

int main(void) {
    // measure creation of vector
    std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
    const size_t nElements = 8192;
    int* array = new int[nElements];
    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "[µs]" << std::endl; 

    // copy vector to gpu
    begin = std::chrono::steady_clock::now();
    int* gpuArray = NULL;
    auto err = cudaMalloc(&gpuArray, sizeof(int) * nElements);
    end = std::chrono::steady_clock::now();
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "[µs]" << std::endl; 

    begin = std::chrono::steady_clock::now();
    cudaMemcpy(gpuArray, array, sizeof(int) * nElements, ::cudaMemcpyHostToDevice);
    end = std::chrono::steady_clock::now();
    std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << "[µs]" << std::endl;

}