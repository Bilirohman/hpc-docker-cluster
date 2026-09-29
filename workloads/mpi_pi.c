#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, size, len;
    char node[MPI_MAX_PROCESSOR_NAME];
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Get_processor_name(node, &len);

    long long total = (argc > 1) ? atoll(argv[1]) : 200000000LL;
    long long local = total / size;
    unsigned int seed = 12345u + 7919u * (unsigned int)rank;

    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();

    long long hits = 0;
    for (long long i = 0; i < local; i++) {
        double x = (double)rand_r(&seed) / RAND_MAX;
        double y = (double)rand_r(&seed) / RAND_MAX;
        if (x * x + y * y <= 1.0) hits++;
    }

    long long all_hits = 0;
    MPI_Reduce(&hits, &all_hits, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    double elapsed = MPI_Wtime() - t0;

    printf("  rank %d @ %s: %lld sampel, hits=%lld\n", rank, node, local, hits);

    if (rank == 0) {
        double pi = 4.0 * (double)all_hits / (double)(local * size);
        printf("HASIL: pi ~= %.8f | proses=%d | sampel=%lld | waktu=%.3f detik\n",
               pi, size, local * size, elapsed);
    }

    MPI_Finalize();
    return 0;
}