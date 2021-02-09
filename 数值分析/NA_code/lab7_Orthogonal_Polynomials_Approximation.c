#include <stdio.h>
#include <math.h>

#define MAX_m 200
#define MAX_n 5

double f1(double x)
{
    return sin(x);
}

double f2(double x)
{
    return exp(x);
}

int OPA(double (*f)(double t), int m, double x[], double w[], double c[], double* eps);

void print_results(int n, double c[], double eps)
{
    int i;

    printf("%d\n", n);
    for (i = 0; i <= n; i++)
        printf("%12.4e ", c[i]);
    printf("\n");
    printf("error = %9.2e\n", eps);
    printf("\n");
}

int main()
{
    int m, i, n;
    double x[MAX_m], w[MAX_m], c[MAX_n + 1], eps;

    m = 90;
    for (i = 0; i < m; i++) {
        x[i] = 3.1415926535897932 * (double)(i + 1) / 180.0;
        w[i] = 1.0;
    }
    eps = 0.001;
    n = OPA(f1, m, x, w, c, &eps);
    print_results(n, c, eps);

    m = 200;
    for (i = 0; i < m; i++) {
        x[i] = 0.01 * (double)i;
        w[i] = 1.0;
    }
    eps = 0.001;
    n = OPA(f2, m, x, w, c, &eps);
    print_results(n, c, eps);

    return 0;
}

/* Your function will be put here */
int OPA(double (*f)(double t), int m, double x[], double w[], double c[], double* eps)
{
    double FI[3][MAX_m] = { 0.0 };//fik(xi)
    double sum1 = 0.0, sum2 = 0.0;
    double err = 0.0;
    double B = 0.0, C = 0.0;
    double a[MAX_n + 1] = { 0.0 }, P[MAX_n + 1] = { 0.0 };
    double b[MAX_n + 1][MAX_m] = { 0.0 };
    //fi0(x) = 1
    for (int i = 0; i < m; i++)
    {
        FI[0][i] = 1;
        sum1 += w[i] * FI[0][i] * f(x[i]);
        sum2 += w[i] * FI[0][i] * FI[0][i];
    }
    a[0] = sum1 / sum2;
    b[0][0] = 1;
    c[0] = a[0] * b[0][0];
    sum1 = sum2 = 0.0;
    for (int i = 0; i < m; i++)
    {
        sum1 += w[i] * f(x[i]) * f(x[i]);
        sum2 += w[i] * (FI[0][i] * f(x[i]));
    }
    err = sum1 - a[0] * sum2;
    //step 2
    //B1 = (x fi0, fi0)/(fi0,fi0)
    sum1 = sum2 = 0.0;
    for (int i = 0; i < m; i++)
    {
        sum1 += w[i] * x[i] * FI[0][i] * FI[0][i];
        sum2 += w[i] * FI[0][i] * FI[0][i];
    }
    B = sum1 / sum2;
    //fi1 = x-B1
    //c1 = (fi1,f)/(fi1,fi1)
    sum1 = sum2 = 0.0;
    for (int i = 0; i < m; i++)
    {
        FI[1][i] = x[i] - B;
        sum1 += w[i] * FI[1][i] * f(x[i]);
        sum2 += w[i] * FI[1][i] * FI[1][i];
    }
    a[1] = sum1 / sum2;
    b[1][0] = -B;
    b[1][1] = 1;
    c[0] += a[1] * b[1][0];
    c[1] = a[1] * b[1][1];
    //err -= a1(fi1,f)
    sum1 = 0.0;
    for (int i = 0; i < m; i++)
    {
        sum1 += w[i] * FI[1][i] * f(x[i]);
    }
    err -= a[1] * sum1;
    
    //step 3,4
    int k = 1;
    while(k < MAX_n && fabs(err) >= *eps)
    {
        k++;
        //Bk = (x fi1,fi1)/(fi1,fi1)
        sum1 = sum2 = 0.0;
        for (int i = 0; i < m; i++)
        {
            sum1 += w[i] * x[i] * FI[1][i] * FI[1][i];
            sum2 += w[i] * FI[1][i] * FI[1][i];
        }
        B = sum1 / sum2;
        //Ck = (x fi1,fi0)/(fi0,fi0)
        sum1 = sum2 = 0.0;
        for (int i = 0; i < m; i++)
        {
            sum1 += w[i] * x[i] * FI[1][i] * FI[0][i];
            sum2 += w[i] * FI[0][i] * FI[0][i];
        }
        C = sum1 / sum2;
        //fi2 = (x-Bk)fi1 - Ckfi0;
        for (int i = 0; i < m; i++)
        {
            sum1 = sum2 = 0.0;
            sum1 = (x[i] - B) * FI[1][i];
            sum2 = C * FI[0][i];
            FI[2][i] = sum1 - sum2;
        }
        //ck= (fi2,f)/(fi2,fi2)
        sum1 = sum2 = 0.0;
        for (int i = 0; i < m; i++)
        {
            sum1 += w[i] * FI[2][i] * f(x[i]);
            sum2 += w[i] * FI[2][i] * FI[2][i];
        }
        a[k] = sum1 / sum2;
        b[k][0] = (-B) * b[k - 1][0] - C * b[k - 2][0];
        c[0] += a[k] * b[k][0];
        for (int i = 1; i <= k-1; i++)
        {
            b[k][i] = b[k - 1][i - 1] - B * b[k - 1][i] - C * b[k - 2][i];
            c[i] += a[k] * b[k][i];
        }
        b[k][k] = b[k - 1][k - 1];
        c[k] = a[k] * b[k][k];
        sum1 = 0.0;
        for (int i = 0; i < m; i++)
        {
            sum1 += w[i] * FI[2][i] * f(x[i]);
        }
        err -= a[k] * sum1;
        //fi0=fi1, fi1 = fi2
        for (int i = 0; i < m; i++)
        {
            FI[0][i] = FI[1][i];
            FI[1][i] = FI[2][i];
        }
    }
    *eps = err;
    

    return k;
}