//Copyright

/*
 * Lucy Rukstales
 * ECE 448
 * Tabu Search Example
 * Compiled with: g++ -g -Wall -std=c++17 -o tabu TabuSearch.cpp
 */

#include <vector>
#include <iostream>
#include <cmath>

double fitness_func(double x) {
  return 5 + sin(x) + sin((10*x)/3) + log(x) - 0.84*x;
}

bool contains(std::vector<double> list, double value) {
  for (long unsigned int i = 0; i < list.size(); i++) {
    if (list[i] == value) {
      return true;
    }
  }
  return false;
}

int main() {
  //* Define the function interval, [a,b]
  const double a = 2.7;
  const double b = 7.5;

  std::vector<double> stepsH;
  stepsH.push_back(b-a);
  for (int i = 1; i < 10; i++) {
    stepsH.push_back(stepsH[i-1]/10);
  }

  //* Initialize and create tabu list
  std::vector<double> tabuListT;
  const int maxTabuSize = 10;

  double overallBest = a;
  double overallBestFitness = fitness_func(overallBest);
  std::vector<double> neighbors;
  std::vector<double> fitness;
  std::vector<double> feasibleMoves;

  for (int m = 0; m < 5; m++) {
    double test = 0.96*m;
    double bestSolution = a + test;
    double bestSolutionFitness = fitness_func(bestSolution); 

    //* Loop: create neighbors, evaluate fitness, update best solution and tabu list
    int k = 0;
    while (k < 10) {
      int j = 0;
      neighbors.clear();
      feasibleMoves.clear();
      fitness.clear();

      //* Add steps
      for (int i = 0; i < (int) stepsH.size(); i++) {
        neighbors.push_back(bestSolution + stepsH[i]);
      }

      //* Subtract steps
      for (int i = 0; i < (int) stepsH.size(); i++) {
        neighbors.push_back(bestSolution - stepsH[i]);
      }

      for (int i = 0; i <  (int) neighbors.size(); i++) {
        if ((neighbors[i] >= a) && (neighbors[i] <= b) && (contains(tabuListT, neighbors[i]) == false)) { //* ??
          feasibleMoves.push_back(neighbors[i]);
          fitness.push_back(fitness_func(feasibleMoves[j]));
          if (fitness[j] < bestSolutionFitness) {
            bestSolution = feasibleMoves[j];
            bestSolutionFitness = fitness[j];
            tabuListT.push_back(bestSolution);
            if (tabuListT.size() > maxTabuSize) { 
              tabuListT.erase(tabuListT.begin());
            }
            k++;
          }
          j++;
        }
      }
      if (bestSolutionFitness < overallBestFitness) {
        overallBest = bestSolution;
        overallBestFitness = fitness_func(overallBest);
      }
    }
  }

  std::cout << "Minimum Position: (" << overallBest << ", " << overallBestFitness << ")\n";

  return 0;
}
