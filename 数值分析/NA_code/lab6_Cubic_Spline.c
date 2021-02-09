#include <stdio.h>

#define MAX_N 10

void Cubic_Spline(int n, double x[], double f[], int Type, double s0, double sn, double a[], double b[], double c[], double d[]);

double S(double t, double Fmax, int n, double x[], double a[], double b[], double c[], double d[]);

int main()
{
    int n, Type, m, i;
    double x[MAX_N], f[MAX_N], a[MAX_N], b[MAX_N], c[MAX_N], d[MAX_N];
    double s0, sn, Fmax, t0, tm, h, t;

    scanf("%d", &n);
    for (i = 0; i <= n; i++)
        scanf("%lf", &x[i]);
    for (i = 0; i <= n; i++)
        scanf("%lf", &f[i]);
    scanf("%d %lf %lf %lf", &Type, &s0, &sn, &Fmax);

    Cubic_Spline(n, x, f, Type, s0, sn, a, b, c, d);
    for (i = 1; i <= n; i++)
        printf("%12.8e %12.8e %12.8e %12.8e \n", a[i], b[i], c[i], d[i]);

    scanf("%lf %lf %d", &t0, &tm, &m);
    h = (tm - t0) / (double)m;
    for (i = 0; i <= m; i++) {
        t = t0 + h * (double)i;
        printf("f(%12.8e) = %12.8e\n", t, S(t, Fmax, n, x, a, b, c, d));
    }

    return 0;
}

/* Your functions will be put here */
void Cubic_Spline(int n, double x[], double f[], int Type, double s0, double sn, double a[], double b[], double c[], double d[])
{
    double h[MAX_N], alpha[MAX_N], l[MAX_N], miu[MAX_N], z[MAX_N];

    for (int i = 0; i <= n; i++)
    {
        a[i] = f[i];
    }
    for (int i = 0; i <= n-1; i++)
    {
        h[i] = x[i + 1] - x[i];
    }
    if (Type == 1)//1 corresponds to the clamped boundary condition 
    {
        alpha[0] = 3 * (a[1] - a[0]) / h[0] - 3 * s0;
        alpha[n] = 3 * sn - 3 * (a[n] - a[n - 1]) / h[n - 1];
        l[0] = 2 * h[0];
        miu[0] = 0.5;
    }
    else 
    {//2 corresponds to the natural boundary condition 注意s0和sn不一定等于0，参考Crout分解修改算法中相应的值
        alpha[0] = s0 / 2;
        alpha[n] = sn / 2;
        l[0] = h[0];
        miu[0] = 0;
    }
    for (int i = 1; i <= n - 1; i++)
    {
        alpha[i] = (3 / h[i]) * (a[i + 1] - a[i]) - (3 / h[i - 1]) * (a[i] - a[i - 1]);
    }   
    z[0] = alpha[0] / l[0];
    for (int i = 1; i <= n-1; i++)
    {
        l[i] = 2 * (x[i + 1] - x[i - 1]) - h[i - 1] * miu[i - 1];
        miu[i] = h[i] / l[i];
        z[i] = (alpha[i] - h[i - 1] * z[i - 1]) / l[i];
    }
    if (Type == 1)
    {
        l[n] = h[n - 1] * (2 - miu[n - 1]);
        z[n] = (alpha[n] - h[n - 1] * z[n - 1]) / l[n];
    }
    else
    {
        l[n] = 1;
        z[n] = alpha[n];
    }
    c[n] = z[n];
    for (int j = n-1; j >= 0; j--)
    {
        c[j] = z[j] - miu[j] * c[j + 1];
        b[j] = (a[j + 1] - a[j]) / h[j] - h[j] * (c[j + 1] + 2 * c[j]) / 3;
        d[j] = (c[j + 1] - c[j]) / (3 * h[j]);
    }
    for (int i = n-1; i >= 0; i--)
    {
        a[i + 1] = a[i];
        b[i + 1] = b[i];
        c[i + 1] = c[i];
        d[i + 1] = d[i];
    }
}

double S(double t, double Fmax, int n, double x[], double a[], double b[], double c[], double d[])
{
    int j = 0;
    double temp;

    if (t < x[0] || t > x[n])
        return Fmax;
    for (int i = 0; i <= n-1 ; i++)
    {
        if (x[i] <= t && t <= x[i+1]) {//限定条件必须准确
            j = i;
            break;
        }
    }
    temp = t - x[j];

    return (temp * (temp * (d[j + 1] * temp + c[j + 1]) + b[j + 1]) + a[j + 1]);
}