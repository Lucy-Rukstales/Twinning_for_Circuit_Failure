%% Draft Solution to Tabu Search Problem from IJNME Paper
% Gets stuck at local minimum

clear all
close all
%% Plot the function
syms x
f = 5+sin(x)+sin((10*x)/3)+log(x)-0.84*(x);
fplot(f, [2.7,7.5]); title('Function to Minimize and Points Evaluated')
hold on

%% Initialization
a = 2.7; %Defined interval for objective function is [0,16]?
b = 7.5;

lengthH = 20; %Initialize and create list of steps
stepsH = zeros(1, lengthH); 
stepsH(1,1) = b-a;
for i=2:1:lengthH
    stepsH(1,i) = stepsH(1, i-1)./10;
end

lengthT = 10; %Initilize and create tabu list
tabuListT = zeros(1, lengthT);
maxTabuSize = 10;

bestSolution = 5; %Create inital solution and calculate inital solution fitness
bestSolutionFitness = fitness_func(bestSolution);

%% Loop: create neighbours, evaluate fitness, update best solution and tabu list
k = 1;
while (k < 14) %Stopping condition is 14 iterations
    neighbours = zeros(1, 2*length(stepsH)); %Create neighbours from intial solution
    j = 1;
    for i = 1:1:length(stepsH) %Add steps
        neighbours(1,i) = bestSolution+stepsH(1,i);
    end
    for i = 1:1:length(stepsH) %Subtract steps
        neighbours(1,i+length(stepsH)) = bestSolution - stepsH(1,i);
    end
    for i = 1:1:length(neighbours)
        if ((neighbours(1,i) >= a) && (neighbours(1,i) <= b) && ~ismember(neighbours(1,i),tabuListT))
            feasibleMoves(1,j) = neighbours(1,i); %Reduce neighbours into feasbile x values
            fitness(1,j) = fitness_func(feasibleMoves(j)); %Calculate fitness
            plot(feasibleMoves(j), fitness(j), '.r') %Show all the points checked
            if (fitness(j) < bestSolutionFitness) %Update best solution and tabu list
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
    display(bestSolution)
    display(bestSolutionFitness)
end

function fitness = fitness_func(x)
functionEval = 5+sin(x)+sin((10*x)/3)+log(x)-0.84*(x);
fitness = functionEval;
end



