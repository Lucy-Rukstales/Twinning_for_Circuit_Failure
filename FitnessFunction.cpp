/* 
 * Copyright (c) 2021 rukstalg@miamioh.edu
 * 
 * Date:        5/5/2021
 * 
 * Contributor: Lucy Rukstales
 * 
 * Description: Modeled after FinalFitnessFunctionTest.m. This code reads two
 *              files: SimData.csv and a .txt file. SimData.csv contains model
 *              ripple data for several capacitors; each row is a different 
 *              capacitor. The .txt file is experimental data for a singe trial 
 *              of of a single capacitor. The code calculated the RMS error of
 *              the .txt file to each of the models and returns the capacitor 
 *              value corresponding to the smallest error
 * 
 * Note:        The xcorr() method isn't currently being used because the data 
 *              set is so small. This should be reincorporated with larger data 
 *              sets, especially when the high frequency adc is used. xcorr() 
 *              will shift the experimental data to line up with the model data,   
 *              when comparing data. See line 267.
 */

#include <cstdlib>
#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string.hpp>
#include <unordered_map>
#include <float.h>
#include <math.h>

using namespace std;

using StrVec = vector<string>;
using IntVec = vector<int>;
using DblVec = vector<double>;
using DblDblVec = vector<DblVec>;

/**
 * Creates a matrix to store the model data. Each row is the model data of a 
 * capacitor.
 * 
 * @param simulated The matrix of model data.
 * 
 * @param path The path to the file containing model data, SimData.csv.
 */
void create2DVector(StrVec& capNames, DblDblVec& simulated, 
        const string& path) {
    // Open file stream
    ifstream input(path);
    
    // Necessary loop variables
    string line;
    
    // Loop through the file, row by row
    while (getline(input, line)) {
        // Split each row on the ','
        StrVec strVec;
        DblVec dblVec;
        boost::split(strVec, line, boost::is_any_of(","));
        
        // The first term is the capacitor name
        capNames.push_back(strVec.at(0));
        strVec.erase(strVec.begin());
        
        // Convert the matrix from string values to doubles
        for (auto& val : strVec) {
            dblVec.push_back(stod(val));
        }
        
        // Append the vector for this current capacitor to the model data matrix
        simulated.push_back(dblVec);
    }
}

/**
 * Create a vector of the measured data.
 * 
 * @param measured The vector of measured data.
 * 
 * @param input The file path to a .txt data file.
 */
void createVector(DblVec& measured, ifstream& input) {
    // Open file stream
    string line;
    while (getline(input, line)) {
        measured.push_back(stod(line));
    }
}

/**
 * Sum all of the elements in a vector.
 * 
 * @param vec The vector to be summed.
 * 
 * @return A double.
 */
double sum(DblVec& vec) {
    double sum = 0.0;
    for (size_t i = 0; i < vec.size(); i++) {
        sum += vec.at(i);
    }
    return sum;
}

/**
 * Cross Correlation method. Calculates the cross-correlation between two 
 * vectors.
 * 
 * @param lags The vector of lags associated with the correlation coefficients.
 * 
 * @param xc The vector of correlation coefficients.
 * 
 * @param measured Vector of measured data.
 * 
 * @param simulated Single row of the model data matrix.
 */
void xcorr(IntVec& lags, DblVec& xc, DblVec& measured, DblVec& simulated) { 
    int N = 34;
    
    //  Calculate the correlation series
    double sxy, syx, maxdelay = N;

    for (int delay = -maxdelay + 1; delay < maxdelay; delay++) {
        sxy = 0, syx = 0;
        if (delay >= 0) {
            for (int i = 0; i < N - delay; i++) {
                sxy += (measured.at(i + delay)) * (simulated.at(i));
            }
        } else {
            for (int i = 0; i < N + delay; i++) {
                sxy += (measured.at(i)) * (simulated.at(i - delay));
            }
        }

        xc.push_back(sxy);
        lags.push_back(delay);
    }
}

/**
 * Find the index of the largest value in a vector.
 * 
 * @param vec The vector to parse.
 * 
 * @return The integer index of the largest value.
 */
int maxIndex(DblVec& vec) {
    double max = -DBL_MAX;
    int index;
    for (size_t i = 0; i < vec.size(); i++) {
        if (vec.at(i) > max) {
            index = i;
            max = vec.at(i);
        }
    }
    return index;
}

/**
 * Find the index of the smallest value in a vector.
 * 
 * @param vec The vector to parse.
 * 
 * @return The integer index of the smallest value.
 */
int minIndex(DblVec& vec) {
    double min = DBL_MAX;
    int index;
    for (size_t i = 0; i < vec.size(); i++) {
        if (vec.at(i) < min) {
            index = i;
            min = vec.at(i);
        }
    }
    return index;
}

/**
 * Subtract the elements of vector b from the elements of vector a.
 * 
 * @param a A vector.
 * 
 * @param b A vector.
 * 
 * @return A vector containing the result of a - b.
 */
DblVec sub(DblVec& a, DblVec& b) {
    DblVec sub;
    for (size_t i = 0; i < a.size(); i++) {
        sub.push_back(a.at(i) - b.at(i));
    }
    return sub;
}

/**
 * Multiply the elements of vector a with the corresponding elements in vector b
 * 
 * @param a A vector.
 * 
 * @param b A vector.
 * 
 * @return  A vector containing the result of a.*b.
 */
DblVec mult(DblVec& a, DblVec& b) {
    DblVec mult;
    for (size_t i = 0; i < a.size(); i++) {
        mult.push_back(a.at(i)*b.at(i));
    }
    return mult;
}

/**
 * Calculate the RMS error of two vectors.
 * 
 * @param RMSerror The vector that RMS error values will be placed in.
 * 
 * @param obs The shifted measured data vector.
 * 
 * @param sim A shifted vector from the model data matrix.
 */
void errorCalc(DblVec& RMSerror, DblVec& obs, DblVec& sim) {
    DblVec temp = sub(ref(obs), ref(sim));
    DblVec temp2 = mult(ref(temp), ref(temp));
    double temp3 = sum(ref(temp2));
    double temp4 = temp3/sim.size();
    RMSerror.push_back(sqrt(temp4));
}

/**
 * The fitness function method that shifts vectors depending on the result of 
 * xcorr. The result is a vector of RMS error data.
 * 
 * @param RMSerror A vector of RMS  data.
 * 
 * @param simulated The matrix of model data.
 * 
 * @param measured A vector of measured data.
 */
void fitnessFunc(DblVec& RMSerror, DblDblVec& simulated, DblVec& measured) {
    for (size_t r = 0; r < simulated.size(); r++) {
        DblVec xc, obs, sim;
        IntVec lags;
        xcorr(ref(lags), ref(xc), ref(measured), ref(simulated.at(r)));
        
        int shift = lags.at(maxIndex(ref(xc)));
        if (shift > 0) {
            for (size_t i = shift; i < measured.size() - 1; i++) {
                obs.push_back(measured.at(i));
            }
            for (size_t i = 0; i < obs.size(); i++) {
                sim.push_back(simulated.at(r).at(i));
            }
        } else {
            for (size_t i = abs(shift); i < simulated.size(); i++) {
                sim.push_back(simulated.at(r).at(i));
            }
            for (size_t i = 0; i < sim.size(); i++) {
                obs.push_back(measured.at(i));
            }
        }
        
        // NOTE: To reincorporate the cross correlation meth, change measured to
        // obs and simulated.at(r) to sim in the line below.
        errorCalc(ref(RMSerror), ref(measured), ref(simulated.at(r)));
    }
}

int main(int argc, char** argv) {
    // Read "simulated" data from SimData.csv
    string simulatedPath = "SimData.CSV";
    StrVec capNames;
    DblDblVec simulated;
    create2DVector(ref(capNames), ref(simulated), ref(simulatedPath));
    
    // Read measured data from the ADC
    string measuredPath;
    cout << "Enter a file name (.txt): ";
    while (cin >> measuredPath) {
        DblVec measured;
        ifstream input(measuredPath);
        if (input.good()) {
            createVector(ref(measured), ref(input));

            // Run the function
            DblVec RMSerror;
            fitnessFunc(ref(RMSerror), ref(simulated), ref(measured));
            int solIndex = minIndex(ref(RMSerror));
            string solution = capNames.at(solIndex);
            cout << "Predicted Capacitance is: " << solution << endl;
        } else {
            cout << "Invalid file name.\n";
        }
        cout << "\nEnter a file name (.txt): ";
    }
    
    return 0;
}


