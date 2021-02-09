#include <stdio.h>
#include <math.h>

#define MAX_SIZE 10
#define bound pow(2, 127)
#define ZERO 1e-9 /* X is considered to be 0 if |X|<ZERO */

///enum bool{ false = 0, true = 1 };
//#define bool enum bool

int Jacobi(int n, double a[][MAX_SIZE], double b[], double x[], double TOL, int MAXN);

int Gauss_Seidel(int n, double a[][MAX_SIZE], double b[], double x[], double TOL, int MAXN);

int main()
{
    int n, MAXN, i, j, k;
    double a[MAX_SIZE][MAX_SIZE], b[MAX_SIZE], x[MAX_SIZE];
    double TOL;

    scanf("%d", &n);
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++)
            scanf("%lf", &a[i][j]);
        scanf("%lf", &b[i]);
    }
    scanf("%lf %d", &TOL, &MAXN);

    printf("Result of Jacobi method:\n");
    for (i = 0; i < n; i++)
        x[i] = 0.0;
    k = Jacobi(n, a, b, x, TOL, MAXN);
    switch (k) {
    case -2:
        printf("No convergence.\n");
        break;
    case -1:
        printf("Matrix has a zero column.  No unique solution exists.\n");
        break;
    case 0:
        printf("Maximum number of iterations exceeded.\n");
        break;
    default:
        printf("no_iteration = %d\n", k);
        for (j = 0; j < n; j++)
            printf("%.8f\n", x[j]);
        break;
    }
    printf("Result of Gauss-Seidel method:\n");
    for (i = 0; i < n; i++)
        x[i] = 0.0;
    k = Gauss_Seidel(n, a, b, x, TOL, MAXN);
    switch (k) {
    case -2:
        printf("No convergence.\n");
        break;
    case -1:
        printf("Matrix has a zero column.  No unique solution exists.\n");
        break;
    case 0:
        printf("Maximum number of iterations exceeded.\n");
        break;
    default:
        printf("no_iteration = %d\n", k);
        for (j = 0; j < n; j++)
            printf("%.8f\n", x[j]);
        break;
    }

    return 0;
}

/* Your function will be put here */
int Jacobi(int n, double a[][MAX_SIZE], double b[], double x[], double TOL, int MAXN)
{
    int i = 0;
    int j = 0;
    int t = 0;
    //check if a[i][i] is zero;
    double max = 0;
    int max_row = 0;
    int row[MAX_SIZE];
    for (i = 0; i < n; i++)
    {
        row[i] = i;
    }

    for (j = 0; j < n; j++)
    {
        max = 0;
        for (i = j; i < n; i++)
        {
            if (fabs(a[row[i]][j]) > max)
            {
                max = fabs(a[row[i]][j]);
                max_row = i;
            }
        }
        if (max != 0)
        {
            t = row[max_row];
            row[max_row] = row[j];
            row[j] = t;
        }
        else//max == 0
        {
            for (i = j - 1; i >= 0; i--)
            {
                if (fabs(a[row[i]][j]) > max)
                {
                    max = fabs(a[row[i]][j]);
                    max_row = i;
                }
            }
            if (max == 0)
                return -1;
            else
            {
                for (i = 0; i < n; i++)
                    a[row[j]][i] += a[max_row][i];
                b[row[j]] += b[max_row];
            }
        }
    }

    int k = 1;
    double sum = 0;
    double xp[MAX_SIZE];
    int flag = 1;
    while (k <= MAXN)
    {
        flag = 1;
        for ( i = 0; i < n; i++)
        {
            sum = 0;
            for ( j = 0;  j < n;  j++)
            {
                if (j == i)
                    continue;
                sum += a[row[i]][j] * x[j];
            }
            xp[i] = (b[row[i]] - sum) / a[row[i]][i];
            if (fabs(xp[i]) > bound)
                return -2;
            if (fabs(x[i] - xp[i]) >= TOL)
                flag = 0;
        }
        if (flag)
            break;
        else {
            for (i = 0; i < n; i++)
                x[i] = xp[i];
            k++;
        }
    }
    if (k > MAXN)
        return 0;
    else 
        return k;
}

int Gauss_Seidel(int n, double a[][MAX_SIZE], double b[], double x[], double TOL, int MAXN)
{
    int i = 0;
    int j = 0;
    int t = 0;
    //check if a[i][i] is zero;
    double max = 0;
    int max_row = 0;
    int row[MAX_SIZE];
    for (i = 0; i < n; i++)
    {
        row[i] = i;
    }

    for (j = 0; j < n; j++)
    {
        max = 0;
        for (i = j; i < n; i++)
        {
            if (fabs(a[row[i]][j]) > max)
            {
                max = fabs(a[row[i]][j]);
                max_row = i;
            }
        }
        if (max != 0)
        {
            t = row[max_row];
            row[max_row] = row[j];
            row[j] = t;
        }
        else//max == 0
        {
            for (i = j - 1; i >= 0; i--)
            {
                if (fabs(a[row[i]][j]) > max)
                {
                    max = fabs(a[row[i]][j]);
                    max_row = i;
                }
            }
            if (max == 0)
                return -1;
            else
            {
                for (i = 0; i < n; i++)
                    a[row[j]][i] += a[max_row][i];
                b[row[j]] += b[max_row];
            }
        }
    }

    int k = 1;
    double sum1, sum2;
    double xp[MAX_SIZE];
    int flag = 1;
    while (k <= MAXN)
    {
        flag = 1;
        for (i = 0; i < n; i++)
        {
            sum1 = sum2 = 0;
            for (j = 0; j < i; j++)
            {
                sum1 += a[row[i]][j] * xp[j];
            }
            for (j = i+1; j < n; j++)
            {
                sum2 += a[row[i]][j] * x[j];
            }
            xp[i] = (b[row[i]] - sum1 - sum2) / a[row[i]][i];
            if (fabs(xp[i]) > bound)
                return -2;
            if (fabs(x[i] - xp[i]) >= TOL)
                flag = 0;
        }
        if (flag)
            break;
        else {
            for (i = 0; i < n; i++)
                x[i] = xp[i];
            k++;
        }
    }
    if (k > MAXN)
        return 0;
    else
        return k;
}