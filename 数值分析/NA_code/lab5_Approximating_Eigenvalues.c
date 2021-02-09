#include <stdio.h>

#define MAX_SIZE 10

int EigenV(int n, double a[][MAX_SIZE], double *lambda, double v[], double TOL, int MAXN);

int main()
{
    int n, MAXN, m, i, j, k;
    double a[MAX_SIZE][MAX_SIZE], v[MAX_SIZE];
    double lambda, TOL;

    scanf("%d", &n);
    for (i=0; i<n; i++) 
        for (j=0; j<n; j++) 
            scanf("%lf", &a[i][j]);
    scanf("%lf %d", &TOL, &MAXN);
    scanf("%d", &m);
    for (i=0; i<m; i++) {
        scanf("%lf", &lambda);
        for (j=0; j<n; j++)
            scanf("%lf", &v[j]);
        switch (EigenV(n, a, &lambda, v, TOL, MAXN)) {
            case -1: 
                printf("%12.8f is an eigenvalue.\n", lambda );
                break;
            case 0:
                printf("Maximum number of iterations exceeded.\n");
                break;
            case 1:
                printf("%12.8f\n", lambda );
                for (k=0; k<n; k++)
                    printf("%12.8f ", v[k]);
                printf("\n");
                break;
        }
    }

    return 0;
}

/* Your function will be put here */
#include <math.h>

int EigenV(int n, double a[][MAX_SIZE], double* lambda, double v[], double TOL, int MAXN)
{
    int i = 0;
    int j = 0;
    int k = 0;
    int p = 0;
    double miu = 0;
    double maxx = 0;
    double maxv = 0;
    int flag = 1;
    for (i = 0; i < n; i++)
    {
        if (fabs(v[i]) > maxx) {
            maxx = fabs(v[i]);
            p = i;
        }
    }
    for (i = 0; i < n; i++)
    {
        v[i] /= maxx;
    }

    double l[MAX_SIZE][MAX_SIZE] = { 0 }, u[MAX_SIZE][MAX_SIZE] = { 0 };
    double t[MAX_SIZE][MAX_SIZE] = { 0 };
    int cnt = 1;
    while (cnt <= MAXN)
    {
        flag = 1;
       
        for (i = 0; i < n; i++)
            for (j = 0; j < n; j++)
                t[i][j] = a[i][j];
        for (i = 0; i < n; i++)
            t[i][i] -= *lambda;
        //LU
        for (i = 0; i < n; i++)
        {
            l[i][i] = 1;
            for (j = i; j < n; j++)
            {
                double sum = 0;
                for (k = 0; k < i; k++) {
                    sum += l[i][k] * u[k][j];
                }
                u[i][j] = t[i][j] - sum;
            }
            for (j = i + 1; j < n; j++)
            {
                double sum = 0;
                for (k = 0; k < i; k++)
                {
                    sum += l[j][k] * u[k][i];
                }
                if (u[i][i] == 0)
                    return -1;
                l[j][i] = (t[j][i] - sum) / u[i][i];
            }
        }

        double y[MAX_SIZE] = { 0 };
        for (i = 0; i < n; i++)
        {
            double sum = 0;
            for (j = 0; j < i; j++) {
                sum += l[i][j] * y[j];
            }
            y[i] = v[i] - sum;
        }

        double v2[MAX_SIZE] = { 0 };
        for (i = n - 1; i >= 0; i--)
        {
            if (u[i][i] == 0) return -1;
            double sum = 0;
            for (j = i + 1; j < n; j++) {
                sum += u[i][j] * v2[j];
            }
            v2[i] = (y[i] - sum) / u[i][i];
        }

        maxv = 0;
        for (i = 0; i < n; i++)
        {
            if (fabs(v2[i]) > maxv) {
                maxv = fabs(v2[i]);
                p = i;
            }
        }
        miu = v2[p];

        for (i = 0; i < n; i++)
        {
            if (fabs(v[i] - v2[i] / v2[p]) >= TOL)
                flag = 0;
            v[i] = v2[i] / v2[p];
        }

        if (flag) {
            miu = (1 / miu) + (*lambda);
            if (miu == *lambda)
                return -1;
            *lambda = miu;
            return 1;
        }
        cnt++;
    }
    return 0;
}