#include <stdio.h>
#include <math.h>

#define ZERO 1e-13 /* X is considered to be 0 if |X|<ZERO */
#define MAXN 11    /* Max Polynomial Degree + 1 */

double Polynomial_Root(int n, double c[], double a, double b, double EPS);

int main()
{
    int n;
    double c[MAXN], a, b;
    double EPS = 0.00005;
    int i;

    scanf("%d", &n);
    for (i = n; i >= 0; i--)
        scanf("%lf", &c[i]);
    scanf("%lf %lf", &a, &b);
    printf("%.4f\n", Polynomial_Root(n, c, a, b, EPS));

    return 0;
}

/* Your function will be put here */
double Polynomial_Root(int n, double c[], double a, double b, double EPS)
{
    if (a > b) {
        int t = a;       
        a = b;
        b = t;
    }
    double div = 5;
    double interval = (b - a) / div;
    double p, p0, root;
    double N = 1000;
    double FP = 0,  FP0 = 0, FPP0 = 0, FPPP0 = 0;
    double denominator = 0;
    double accur = 999;
    int flag = 0;
    for (int i = 0; i <= div; ++i)
    {
        p0 = a + interval * i;
        flag = 0;
        for (int j = 0; j < N; ++j)
        {
            FP0 = 0;
            for (int k = 0; k <= n; ++k)
            {
                FP0 += c[k] * pow(p0, k);
            }
            if (fabs(FP0) < ZERO)//收敛
            {
                flag = 1;
                break;
            }
            FPP0 = 0;
            for (int k = 1; k <= n; ++k)
            {
                FPP0 += k * c[k] * pow(p0, k - 1);
            }
            FPPP0 = 0;
            for (int k = 2; k <= n; ++k)
            {
                FPPP0 += (k) * (k - 1) * c[k] * pow(p0, k - 2);
            }
            denominator = FPP0 * FPP0 - FP0 * FPPP0;
            if (fabs(denominator) < ZERO)//分母等于0
            {
                flag = 0;
                break;
            }
            p = p0 - (FP0 * FPP0) / denominator;
            if (p < a || p > b)
            {
                flag = 0;
                break;
            }
            if (fabs(p - p0) < EPS)//根不在区间内，舍去
            {
                flag = 1;
                break;
            }
            p0 = p;
        }
        FP = 0;
        for (int k = 0; k <= n; ++k)
        {
            FP += c[k] * pow(p, k);
        }
        if (flag && fabs(FP) < accur)
        {
            accur = fabs(FP);
            root = p;
        }
    }

    return root;
}