% MIT Software licence
% Copyright 2025 Rychtar and Taylor
%
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the “Software”),
% to deal in the Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute, sublicense,
% and/or sell copies of the Software, and to permit persons to whom
% the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
% IN THE SOFTWARE.
%
%


function main
% This file is for the paper Stephenson et al. ivestigating Nash equilibria 
% for an experimental vaccination game.
% The work was supported by the  National Science Foundation grant number 
% DMS 2327790.
% 
% The code was written by Jan Rychtar and Dewey Taylor
% This version is from January 16, 2025



% Close all previous figures
close all
clear all


% Set the number of agents in the game
N = 10; 
all_agents = (1:N);

% Set the diseaset epidemiology (reproduction number)
R01 = 4; % for treatment 1
R02 = 4; % for treatment 2
R03 = 1.5; % for treatment 3
R04 = 1.5; % for treatment 4


% Set the vaccination and disease costs
cV1 =  ones(1,N); % cost of vaccine for an individual i ; it will be the same in all threatments
cD1 = [7*ones(1,N/2) 3*ones(1,N/2) ]; % Cost of disease, treatment 1
cD3 = [7*ones(1,N/2) 3*ones(1,N/2) ]; % Cost of disease, treatment 3
cD2 = 5*ones(1,N); % cost of disease for an individual i, treatment 2
cD4 = 5*ones(1,N); % cost of disease for an individual i, treatment 4



% In case the relative costs cV/cD are not monotonically increasing,
% order them
[cV1,cD1] = order_costs(cV1, cD1); % treatment 1
[cV2,cD2] = order_costs(cV1, cD2); % treatment 2
[cV3,cD3] = order_costs(cV1, cD3); % treatment 3
[cV4,cD4] = order_costs(cV1, cD4); % treatment 4


% Just test the formulas to make sure we ae getting what we expected
% getNE(cV, cD, R0)
getNE(cV1, cD1, R01) % should return 7
getNE(cV2, cD2, R02) % should return 7
getNE(cV3, cD3, R03) % should return 3
getNE(cV4, cD4, R04) % should return 2


% % Plot the figures for theoretical predictions
% plotExampleTreatment(mycV, mycD, myR0, ytoplimit, treatment_number)
plotExampleTreatment(cV1, cD1, R01, 1, 1) % Treatment 1
plotExampleTreatment(cV2, cD2, R02, 1, 2) % Treatment 2
plotExampleTreatment(cV3, cD3, R03, 0.5, 3) % Treatment 3
plotExampleTreatment(cV4, cD4, R04, 0.5, 4) % Treatment 4



% Plot the dependence of NE on R0
%plotDependenceOnR0(mycV, mycD, R0range, filename)
plotDependenceOnR0(cV1, cD1, linspace(1,5, 501), 'NEonR0heterogeneous')
plotDependenceOnR0(cV1, cD2, linspace(1,5, 501), 'NEonR0homogeneous')




return

%% Codes of the functions to plot the figures

    function plotExampleTreatment(mycV, mycD, myR0, ytoplimit, treatment_number)
        % plots the figures showing the treatment options and how agents
        % decide in them


        % Start the 
        figure
        % Place multiple plots in the figure
        hold on
        % Start with axis on the left
        yyaxis left
        % Plot the relative vaccination costs
        plot(all_agents, mycV./mycD, '+')
        % Setup x ticks for all n
        xticks(all_agents)
        % Set limits on the y axis
        ylim([0 ytoplimit])
        % Set the x and y labels and the title
        xlabel('Agent number, $n$')
        ylabel('Relative vaccination cost, $\frac{c_n^V}{c_n^D}$')
        title(['Treatment $' num2str(treatment_number) '$'])
        % Start the axis on the right
        yyaxis right
        % plot the disease risk
        plot(all_agents, f(all_agents-1, myR0), 'o')
        % set labels and limits
        ylabel('Disease risk, $f(n-1)$')
        ylim([0 ytoplimit])
        % Format the figure and save it
        FormatFigure
        SaveFigure(['Treatment' num2str(treatment_number)])

    end

    function plotDependenceOnR0(mycV, mycD, R0range, filename)
        % Plots the dependence of nash equilibrium on R0

        % Get the population size
        N = length(mycV);

        % Get relative costs of vaccinations
        rel_costs = mycV./mycD;
        
        % for every R0 in the range
        for auxR0 = 1:length(R0range)  % auxiliary counter to go through all the values
            % Set the value of R0
            myR0 = R0range(auxR0);

            % Get the NE
            NE(auxR0) = getNE(mycV, mycD, myR0);
        end

        
        % Start the figure 
        figure
        % Plot the NE as a function of R0
        plot(R0range, NE/N, 'k.')
        if any(diff(rel_costs)>0)
            % if there is a difference in relative costs, i.e.,
            % heterogeneous population

            % Determine how many of the vulenrable will vaccinate
            NE_vulnerable = min(NE,5); % all up to 5 which is their max
            
            % Determine how many of the less vulnerable will vaccinate
            NE_less_vulnerable = NE - NE_vulnerable;

            hold on
            plot(R0range, NE_vulnerable/(N/2), 'g.')
            plot(R0range, NE_less_vulnerable/(N/2), 'b.')
        end

        % Set labels
        xlabel('Reproduction number, $R_0$')
        ylabel('NE vaccination coverage')
        ylim([0 1])
        % Format and save
        FormatFigure
        SaveFigure(filename)
    end


%% Functions to get the NE quickly

    function output = getNE(cV, cD, R0)
        % Returns the NE based on the paper

        % Find the number of players 
        N = length(cV);

        % For every player, calculate the incentive function h
        for n = 1:N
            h_function(n) = h(n, cV, cD, R0);
        end

        if h_function(1) < 0
            output = 0;
        else
            % NE is where the max of n for which h(n)>= 0
            output = max(all_agents(h_function>=0));
        end
        
    end


    function output = h(n, cV, cD, R0)
        % Calculates the incentive function
        % given that the agents are numbered so that cV/cD are
        % non-decreasing and players 1, 2, ..., n-1 vaccinate, it evaluate
        % the willingness for the player n to vaccinate

        output = f(n-1, R0) - cV(n)./cD(n);
    end

    function output = f(n,R0)
        % Calculates the risk of infection given n player vaccinate

        % initialize
        output = zeros(1,length(n));

        % Calculate based on the formula
        output = output + (n/N<=1-1./R0).*(1-1./((1-n/N)*R0));
    end


    function [cVout, cDout] = order_costs(cVin, cDin)
        % take the vectors representing cost of vaccination cVin and disease cDin 
        % makes sure they are of the same length, none of cD is 0
        % order them in such a way that cV/cD is nondecreasing
        
        % any(cVin(:))<= 0
        % 
        % any(cDin(:)) <=0
        % 
        % any(size(cVin)~=size(cDin))

        % Checks 
        if any(cVin(:))<= 0 || any(cDin(:) <=0) || length(cVin)~=length(cDin)
            % some costs are negative or 0 or the costs do not have the
            % same length
            disp('Something is wrong with the costs')
            return
        else
            % Calculate the relative costs
            rel_costs = cVin./cDin;
            % Sort the costs
            [~, idx] = sort(rel_costs);
            
            % Reorder the original costs vectors in the above order
            cVout = cVin(idx);
            cDout = cDin(idx);
        end

    end











%% Functions for plotting figures

    function FormatFigure(h)
        % Formats figures so that all figures are uniformly formatted
        % This function has been used in many previous codes by Rychtar and
        % Taylor

        if nargin == 0 % if the function is called without an argument, assume we want to format current figure
            h = gcf;
        end

        % Get axes handle
        haxes=get(h, 'CurrentAxes');

        % Get figure number
        fnbr = get(h,'Number');
        [fig_x,fig_y] = getPosition(fnbr);

        % Set dimensions of the figure
        set(h,'Units','Inches','Position',[fig_x, fig_y, 4, 3]);

        % Set default font size
        set(haxes,'FontSize',10)
        % Set interpreter to LaTeX
        set(0,'defaultTextInterpreter','latex')

        % Set the interpreter for latex
        set(haxes, 'TickLabelInterpreter', 'latex');

        % Find all line objects
        hline= findobj(haxes,'Type','line');
        % Set line properties (relatively fat lines)
        set(hline, 'LineWidth'   , 1);

        % Set axes properties
        set(haxes, ...
            'Box'         , 'on'     , ...  %puts a box around the axis
            'TickDir'     , 'in'     , ...
            'TickLength'  , [.02 .01] , ...
            'XMinorTick'  , 'off'      , ...
            'YMinorTick'  , 'off'     , ...
            'LineWidth'   , 1);

        function [xpos,ypos] = getPosition(n)
            % gets the x y position of the figure to plot
            n = mod(n-1,15)+1;
            ypos = floor((n-1)/5)*5;
            xpos = (mod(n-1,5))*3;
        end

    end

    function SaveFigure(filename)
        % Saves a current graphics file to file named filename.pdf
        % This function has been used in many previous codes by Rychtar and
        % Taylor

        % Get the handle
        h=gcf;
        set(h,'Units','Inches');
        pos = get(h,'Position');

        % Cut all the white margins
        set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

        % Actually save
        print(h,['Figures/' filename, '.pdf'],'-dpdf','-r0')
        %saveas(h, ['Figures/' filename],'epsc')

        % This outputs on the screen what figure was saved into what file
        disp_Diary(['Saved a figure ' num2str(get(gcf,'Number')) ' into a file ' ...
            filename '.eps'])
    end


    function disp_Diary(string)
        % Displays text on the screen and also logs it in the diary
        diary on
        disp(string)
        diary off
    end

end

