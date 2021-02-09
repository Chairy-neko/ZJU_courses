#include <stdio.h>

void Series_Sum(double sum[]);

int main()
{
    int i;
    double x, sum[3001];

    Series_Sum(sum);

    x = 0.0;
    for (i = 0; i < 3001; i++)
        printf("%6.2f %16.12f\n", x + (double)i * 0.10, sum[i]);

    return 0;
}

/* Your function will be put here */
void Series_Sum(double sum[])
{
    double x = 0.0;
    double n = 10000;

    for (int i = 0; i < 10; ++i) {
        sum[i] = 0;
        for (double j = 1; j < n; ++j)
        {
            sum[i] += 1.0 / (j * (j + x) * (j + 1));
        }
        sum[i] = (1-x) * (sum[i] + 1 / (2 * n * n)) + 1;
        x += 0.1;
    }

    x = 1.0;
    for (int i = 10; i < 3001; ++i) {
        sum[i] = ((x-1)*sum[i-10]+1/x) / x;
        x += 0.1;
    }
}