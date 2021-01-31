%% Solution to Tabu Search Problem from IJNME Paper
% Runs in 2.949 seconds

clear all
close all
%% Plot the original function
syms x
f = 5+sin(x)+sin((10*x)/3)+log(x)-0.84*(x); %Function
fplot(f, [2.7,7.5]); title('Function to Minimize and Points Evaluated')
hold on

%% Initialization
a = 2.7; %Lower bound
b = 7.5; %Upper bound

lengthH = 10; %Number of steps that will be taken
stepsH = zeros(1, lengthH); %Allocate space for steps 
stepsH(1,1) = b-a; %Size of first step

for i=2:1:lengthH %Fill in remaining steps
    stepsH(1,i) = stepsH(1, i-1)./10; %Each step size is 1/10 of the previous step size
end

lengthT = 10; %Size of tabu list
tabuListT = zeros(1, lengthT); %Allocate space for tabu list
maxTabuSize = 10;

overallBest=a; %Initialize S (the initial solution)
overallBestFitness=fitness_func(overallBest); %Evaluate S

%% Loop: create neighbours, evaluate fitness, update best solution and tabu list
for m=1:5 %Evaluate 5 different "neighborhoods"
    test(m)=0.96*(m-1); %Starting Point of each neighborhood
    bestSolution = a+test(m); %Initial best solution (for each neighborhood)
    bestSolutionFitness = fitness_func(bestSolution); %Initial best solution fitness (for each neighborhood)

    k = 1; %Tabu List Increments
    while (k < 14) %Stopping condition is 14 iterations
        neighbors = zeros(1, 2*length(stepsH)); %Allocate space for neighbors
        j = 1; %Fitness Increments
        % Neighbors above current solution
        for i = 1:1:length(stepsH)
            neighbors(1,i) = bestSolution+stepsH(1,i);
        end
        % Neighbors below current solution
        for i = 1:1:length(stepsH) %Subtract steps
            neighbors(1,i+length(stepsH)) = bestSolution - stepsH(1,i);
        end
        % Evaluate each neighbor with fitness function
        for i = 1:1:length(neighbors)
            % Check if neighbor is within bounds and not on Tabu List
            if ((neighbors(1,i) >= a) && (neighbors(1,i) <= b) && ~ismember(neighbors(1,i),tabuListT))
                feasibleMoves(1,j) = neighbors(1,i); %Reduce neighbors into feasbile x values
                fitness(1,j) = fitness_func(feasibleMoves(j)); %Calculate fitness
                plot(feasibleMoves(j), fitness(j), '.r') %Show all the points checked
                % Update best solution and tabu list
                if (fitness(j) < bestSolutionFitness)
                    bestSolution = feasibleMoves(j);
                    bestSolutionFitness = fitness(j);
                    tabuListT(1,k) = bestSolution;
                    if (length(tabuListT) > maxTabuSize)
                        tabuListT = tabuListT(2:end);
                    end
                    k = k +1;
                end
                j = j+1;
            end
        end
        if(bestSolutionFitness<overallBestFitness)
            overallBest=bestSolution;
            overallBestFitness=fitness_func(overallBest);
        end
    end
end

%% Display Results
display(overallBest) %Final Solution
display(overallBestFitness) %Final Solution Fitness
plot(overallBest, overallBestFitness, 'Xg') %Show the best solution on the plot

%% Fitness Function
function fitness = fitness_func(x)
functionEval = 5+sin(x)+sin((10*x)/3)+log(x)-0.84*(x);
fitness = functionEval;
end