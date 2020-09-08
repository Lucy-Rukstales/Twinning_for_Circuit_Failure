#include <cmath>
#include <iostream>

int main(int argc, char *argv[]) {

  /* Define Interval [a, b] */
  const double a = 2.7;
  const double b = 7.5;
  
  /* Define H steps */
  const int r = 20;
  double H[r];
  H[0] = b - a;
  int i;
  for (i = 1; i < r; i++) {
    H[i] = H[i-1]/10.0;
  }
  
  /* Initialize Tabu List Parameters */
  double x = 5.0;
  double y = x;
  double T[r][2];
  int K = 0;
  
  /* Neighbors stuff */
  double N[r];
  double fx;
  double fy;
  int count = 0;
  int i;
  for (j = 0; j < r; j++) {
    fx = 5 + sin(x) + sin(10*x/3) + log(x) - 0.84*x;
    fy = 5 + sin(y) + sin(10*y/3) + log(y) - 0.84*y;
    while (fx >= fy && K < r) {
      y = y + H[K];
      fy = 5 + sin(y) + sin(10*y/3) + log(y) - 0.84*y;
      if (fy < fx) {
        T[j][0] = x;
        T[j][1] = H[K];
        K = 0;
        x = y;
      } 
      else {
        K++;
      }
    }
  }
  
  return 0;
}
