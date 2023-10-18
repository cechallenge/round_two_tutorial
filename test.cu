#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

#define checkCudaErrors(call)                                 \
  do {                                                        \
    cudaError_t err = call;                                   \
    if (err != cudaSuccess) {                                 \
      printf("CUDA error at %s %d: %s\n", __FILE__, __LINE__, \
             cudaGetErrorString(err));                        \
      exit(EXIT_FAILURE);                                     \
    }                                                         \
  } while (0)

__global__ void gpuVecAdd(float *A, float *B, float *C) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    C[tid] = A[tid] + B[tid];
}

void init(float *V, int N) {
    for (int i = 0; i < N; i++) {
        V[i] = i + 1.0;
    }
}

void calc_cpu(float* a, float* b, float* c, int N) {
    for (int i = 0; i < N; i++) {
        c[i] = a[i] + b[i];
    }
}

void validation(float* cpu, float* gpu, int N) {
    for (int i = 0; i < N; i++) {
        if (cpu[i] - gpu[i] > 1e-05) {
            printf("failed! index : %d\n", i);
            printf("cpu : %f, gpu : %f\n", cpu[i], gpu[i]);
            break;
        }
    }
}

int main() {
    int GPU_N = 0;
    checkCudaErrors(cudaGetDeviceCount(&GPU_N));
    printf("CUDA-capable device count : %d\n", GPU_N);

    int N = 1048576 * 32;
    float *A = nullptr;
    float *B = nullptr;
    float **C = nullptr;
    float **cpu = nullptr;

    A = (float*)malloc(sizeof(float) * N);
    B = (float*)malloc(sizeof(float) * N);
    C = (float**)malloc(sizeof(float*) * GPU_N);
    cpu = (float**)malloc(sizeof(float*) * GPU_N);
    init(A, N);
    init(B, N);

    for (int i = 0; i < GPU_N; i++) {
        C[i] = (float*)malloc(sizeof(float) * N);
        cpu[i] = (float*)malloc(sizeof(float) * N);
        calc_cpu(A, B, cpu[i], N);
    }
    //memory objects alloc
    printf("Starting a vector addition in gpu\n");
    float *d_A[GPU_N], *d_B[GPU_N], *d_C[GPU_N];
    for (int i = 0; i < GPU_N; i++) {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaMalloc(&d_A[i], sizeof(float) * N));
        checkCudaErrors(cudaMalloc(&d_B[i], sizeof(float) * N));
        checkCudaErrors(cudaMalloc(&d_C[i], sizeof(float) * N));
    }

    for (int i = 0; i < GPU_N; i++) {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaMemcpy(d_A[i], A, sizeof(float) * N, cudaMemcpyHostToDevice));
        checkCudaErrors(cudaMemcpy(d_B[i], B, sizeof(float) * N, cudaMemcpyHostToDevice));
    }

    dim3 dimBlock(32,1);
    dim3 dimGrid(N / 32, 1);

    for (int i = 0; i < GPU_N; i++) {
        checkCudaErrors(cudaSetDevice(i));
        gpuVecAdd<<< dimGrid, dimBlock, 0 >>> (d_A[i], d_B[i], d_C[i]);
        checkCudaErrors(cudaMemcpy(C[i], d_C[i], sizeof(float) * N, cudaMemcpyDeviceToHost));
    }

    printf("Start validation\n");
    for (int i = 0; i < GPU_N; i++) {
        checkCudaErrors(cudaSetDevice(i));
        validation(cpu[i], C[i], N);
    }
    printf("End validation!\n");

    for (int i = 0; i < GPU_N; i++) {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaFree(d_A[i]));
        checkCudaErrors(cudaFree(d_B[i]));
        checkCudaErrors(cudaFree(d_C[i]));
    }

    free(A);
    free(B);
    for (int i = 0; i < GPU_N; i++) {
        free(C[i]);
        free(cpu[i]);
    }
    return 0;
}
