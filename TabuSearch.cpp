// Copyright

/*
 * Lucy Rukstales
 * ECE 448
 * Tabu Search
 * Compiled with: g++ -g -Wall -std=c++17 -o tabu TabuSearch.cpp
 */

#include <vector>
#include <iostream>
#include <cmath>

// Function: fitness_func(double)
// Inputs: a value x for which the function is to be calculated at
// Outputs: the fitness of x (aka the result of the function)
double fitness_func(double x) {
  return 5 + sin(x) + sin((10*x)/3) + log(x) - 0.84*x;
}

// Function: contains(std::vector<double>, double)
// Inputs: vector list and a value
// Outputs: boolean of whether or not the list contains the value
bool contains(std::vector<double> list, double value) {
  // Loop: checks each list spot to see if it matches the specified value
  for (int i = 0; i < static_cast<int>(list.size()); i++) {
    if (list[i] == value) {
      return true;
    }
  }
  return false;
}

// Function: main()
// Inputs: none
// Outputs: coordinates of the function minimum over the specified interval
int main() {
  // Function interval [a,b]
  const double a = 2.7;
  const double b = 7.5;

  // stepsH vector: stores the set of "random" moves
  // Note: stepsH remains constant after initilization
  std::vector<double> stepsH;
  stepsH.push_back(b-a);
  for (int i = 1; i < 10; i++) {
    stepsH.push_back(stepsH[i-1]/10);
  }

  // tabuListT vector: stores the best solution given a set of feasible moves?
  std::vector<double> tabuListT;
  const int maxTabuSize = 10;
  
  // Overall best values are the function minimums
  double overallBest = a;
  double overallBestFitness = fitness_func(overallBest);
  
  // Initialize vectors used in tabu search
  std::vector<double> neighbors;
  std::vector<double> fitness;
  std::vector<double> feasibleMoves;

  for (int m = 0; m < 5; m++) {
    double test = 0.96*m;
    double bestSolution = a + test;
    double bestSolutionFitness = fitness_func(bestSolution); 

    // Loop: create neighbors, evaluate fitness, update best solution and 
    // tabu list
    int k = 0;
    while (k < 14) {
      int j = 0;
      neighbors.clear();
      feasibleMoves.clear();
      fitness.clear();

      // Add/subtract steps
      for (int i = 0; i < static_cast<int>(2*stepsH.size()); i++) {
        if (i < static_cast<int>(stepsH.size())) {
          neighbors.push_back(bestSolution + stepsH[i]);
        } else {
          neighbors.push_back(bestSolution - stepsH[i]);
        }
      }

      for (int i = 0; i < static_cast<int>(neighbors.size()); i++) {
        if ((neighbors[i] >= a) && (neighbors[i] <= b) && 
          (contains(tabuListT, neighbors[i]) == false)) {
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

  // Print the coordinates of the function minimum
  std::cout << "Minimum Position: (" << overallBest << ", " 
    << overallBestFitness << ")\n";

  return 0;
}
