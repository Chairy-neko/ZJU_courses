#include <stdio.h>

#define Max_size 10000 /* max number of dishes */

void Price(int n, double p[]);

double p[Max_size];
double l1[Max_size][2], u1[Max_size], l2[Max_size][2], u2[Max_size];
double z1[Max_size], z2[Max_size], x1[Max_size], x2[Max_size];

int main()
{
    int n, i;
    

    scanf("%d", &n);
    for (i = 0; i < n; i++)
        scanf("%lf", &p[i]);
    Price(n, p);
    for (i = 0; i < n; i++)
        printf("%.2f ", p[i]);
    printf("\n");

    return 0;
}

/* Your function will be put here */
//注意最后一位的值
void Price(int n, double p[])
{
    
    double pk;
    
    //caculate x1
    l1[0][1] = 2;
    u1[0] = 0.5 / l1[0][1];
    z1[0] = p[0] / l1[0][1];

    for (int i = 1; i < n - 2; ++i)
    {
        l1[i][0] = 0.5;
        l1[i][1] = 2 - l1[i][0] * u1[i-1];
        u1[i] = 0.5 / l1[i][1];
        z1[i] = (p[i] - l1[i][0] * z1[i - 1]) / l1[i][1];
    }

    l1[n - 2][0] = 0.5;
    l1[n - 2][1] = 2 - l1[n - 2][0] * u1[n - 3];
    z1[n - 2] = (p[n-2] - l1[n - 2][0] * z1[n - 3]) / l1[n - 2][1];

    x1[n - 2] = z1[n - 2];
    for (int i = n - 3; i >= 0; --i)
    {
        x1[i] = z1[i] - u1[i] * x1[i + 1];
    }

    //caculate x2
    l2[0][1] = 2;
    u2[0] = 0.5 / l2[0][1];
    z2[0] = -0.5 / l2[0][1];

    for (int i = 1; i < n - 2; ++i)
    {
        l2[i][0] = 0.5;
        l2[i][1] = 2 - l2[i][0] * u2[i - 1];
        u2[i] = 0.5 / l2[i][1];
        z2[i] = (0 - l2[i][0] * z2[i - 1]) / l2[i][1];
    }

    l2[n - 2][0] = 0.5;
    l2[n - 2][1] = 2 - l2[n - 2][0] * u2[n - 3];
    z2[n - 2] = (-0.5 - l2[n - 2][0] * z2[n - 3]) / l2[n - 2][1];

    x2[n - 2] = z2[n - 2];
    for (int i = n - 3; i >= 0; --i)
    {
        x2[i] = z2[i] - u2[i] * x2[i + 1];
    }
    
    //caculate x
    pk = (p[n - 1] - 0.5 * x1[0] - 0.5 * x1[n - 2]) / (0.5 * x2[0] + 0.5 * x2[n - 2] + 2);

    for (int i = 0; i < n - 1; ++i)
    {
        p[i] = x2[i] * pk + x1[i];
    }

    p[n - 1] = pk;
}

//reference:https://blog.csdn.net/hggshiwo/article/details/109011459