function [mu_est, sigma_est, trial_unit, trial_resp, elapsed_time] = DataCollection(out_dir, id, condition, stim_levels, mode, mu_est, num_trials)
tic
addpath('Palamedes/')

%Parameters for simulating
mu_actual = 50;
sig_actual = 2;

if nargin < 1
    id = 'test';
    condition = 'test';
    out_dir = pwd;
    mode = 0; %search mode (0 = binary, 1 = coarse, 2 = fine, 3 = randomized)
    num_trials = 1000;
    mu_est = 30;
end

trial_unit = []; %array to keep track of presented trials
trial_resp = []; %array to keep track of trial responses (0 no/fail, 1 yes/succeed)
trial_num = 1;

%Set initial loop conditions

exit = false;

close all;
clf;
h = figure(1);
set(h,'Position',[0,0,450,800]);

outfile = strcat(out_dir,'/',id, '_', condition,'.csv');
graphfile = strcat(out_dir,'/',id, '_', condition,'.eps');


%Loop through trials until user chooses to exit
while(~exit)
    %Select next trial
    if mode == 0 %Start with largest and smallest, then binary search
        if trial_num == 1
            trial_unit(trial_num) = max(stim_levels); %#ok<*AGROW,*SAGROW>
            min_pos = length(stim_levels);
        elseif trial_num == 2
            trial_unit(trial_num) = min(stim_levels);
            max_neg = 1;
        else 
            trial_unit(trial_num) = stim_levels(round(mean([min_pos max_neg])));
        end
    elseif mode == 1
        trial_unit(trial_num) = coarse_block(block_i); %Choose predefined trials from coarse block
    elseif mode == 2
        trial_unit(trial_num) = fine_block(block_i); %Choose predefined trials from fine block
    elseif mode == 3 %Randomize units based on sigma
        if sigma_est >= 1.5 
            rand_unit = mu_est + randn(1,1).* sigma_est;
        else
            rand_unit = mu_est + randn(1,1).* 1.5;
        end
        trial_unit(trial_num) = findNearestUnit(stim_levels, rand_unit);
    end
    
    setUnitView(trial_unit(trial_num),trial_num);
    
    %Ask for user input (trial result, exit)
    while(1)
        if trial_num == num_trials + 1
            disp('Completed specified number of trials. Type exit and hit enter to end block.');
        end
        reply = input(sprintf('Trial #%d at %2.1f>> ',trial_num,trial_unit(trial_num)),'s');
        if strcmp(reply, 'exit')
            exit = true;
            break;
        elseif strcmp(reply, 'y')
            trial_resp(trial_num) = 1;
            break;
        elseif strcmp(reply, 'n')
            trial_resp(trial_num) = 0;
            break;
        elseif strcmp(reply, 's')
            trial_resp(trial_num) = rand(1,1) >= 1 - normcdf(trial_unit(trial_num),mu_actual, sig_actual);
            break;
        elseif ~isempty(str2double(reply))
            val = str2double(reply);
            level = find(stim_levels == val);
            if ~isempty(level)
                trial_unit(trial_num) = stim_levels(level);
                setUnitView(trial_unit(trial_num),trial_num);
            end 
        end  
    end
    
    if exit == true %Skip next section and exit 
        break;
    end
    
    %Update binary search based on response, change mode if needed
    if mode == 0 && trial_num > 2
        if trial_resp(trial_num) == 1
            min_pos = find(stim_levels == trial_unit(trial_num));
        elseif trial_resp(trial_num) == 0
            max_neg = find(stim_levels == trial_unit(trial_num));
        end
        if max_neg >= min_pos || abs(max_neg - min_pos) < 5 %Condition for moving to mode 1
            mode = 1;
            %Run a fit on the current data       
            initial_guess = (max_neg + min_pos)/2;
            paramsValues = fitPsych(trial_unit, trial_resp, initial_guess);
            mu_est = findNearestUnit(stim_levels, paramsValues(1));
         
            
            %Create a random block of trials around threshold
            coarse_block = zeros(1,14) + mu_est;
            coarse_block = coarse_block + [0 0 -3 -3 3 3 -4 -4 4 4 -5 -5 5 5];
            coarse_block = coarse_block(randperm(length(coarse_block)));
            block_i = 1;
        end
    elseif mode == 1
        block_i = block_i + 1;
        if block_i > numel(coarse_block) 
            mode = 2;
            paramsValues = fitPsych(trial_unit, trial_resp, mu_est);
            mu_est = findNearestUnit(stim_levels, paramsValues(1));
            %Create fine block around new threshold
            fine_block = zeros(1,11) + mu_est;
            fine_block  = fine_block  + [0 0 0 -1 -1 1 1 -2 -2 2 2];
            fine_block  = fine_block (randperm(length(fine_block)));
            block_i = 1;
        end
    elseif mode == 2
        block_i = block_i + 1;
        if block_i > numel(fine_block) 
            mode = 3;
            paramsValues = fitPsych(trial_unit, trial_resp, mu_est);
            mu_est = paramsValues(1);
            sigma_est = 1./paramsValues(2);
        end
    end
    
    %Update graphview & parameter estimates
    [mu_est sigma_est] = setGraphview(10,trial_resp, trial_unit, trial_num, mu_est,'ro','b',id, condition);
        
    trial_num = trial_num + 1;
    csvwrite(outfile, [trial_unit' trial_resp']);
end

%Calculate final fit parameters, save data to file
paramsValues = fitPsych(trial_unit, trial_resp, mu_est);
mu_est = paramsValues(1);
sigma_est = 1./paramsValues(2);
    
csvwrite(outfile, [trial_unit(1:length(trial_resp))' trial_resp(1:length(trial_resp))']);

reply = input('Save graph of curve fit [y] [n]? ','s');
if strcmp(reply, 'y')
    clf;
    close all;
    [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
    succtrials = HIT;
    totaltrials = N;
    w = 10;
    minx = mu_est - w;
    maxx = mu_est + w;
    
    x = minx:.01:maxx;
    affmu = mu_est;
    affsig = sigma_est;
    affrate = succtrials ./ totaltrials;
    afftrials = totaltrials;
    afx = normcdf(x,affmu, affsig);

    plot(x, afx,'b','LineWidth',2);
    axis([minx maxx -.01 1.01])
    xlabel('Trial Unit');
    ylabel('Prop. Yes Responses');
    hold on
    for i = 1:length(STIM)
        if not(isnan(affrate(i)))
            markersize = (afftrials(i) * 2) + 5;
            plot(STIM(i),affrate(i),'ro','LineWidth',2,'MarkerSize',markersize);
            title(sprintf('%s %s, mu: %3.1f, sig: %3.1f', id, condition, mu_est, sigma_est));
        end
    end
    hold off
    saveas(1, graphfile, 'epsc');
end

elapsed_time = toc;

end

%%%SUPPORT FUNCTIONS

function [paramsValues] = fitPsych(trial_unit, trial_resp, initial_guess)
    [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
    [paramsValues] = PAL_PFML_Fit(STIM, HIT, N, [initial_guess 2 0 0], [1 1 0 0 ], @PAL_CumulativeNormal);
end

function setUnitView(unit, trial_num)
    subplot(3,1,1); 
    cla;
    set(1, 'Toolbar', 'none');
    set(1, 'MenuBar', 'none');
    t = text(0.1,0.3,sprintf('%04.1f', unit));
    set(t, 'FontSize', 80);
    set(t, 'Color', [0 1 0]);
    tt = text(0.01,0.8,sprintf('Trial # %03d', trial_num));
    set(tt, 'FontSize', 60);
    set(tt, 'Color', [0 0 1]);
    a = get(1, 'CurrentAxes');
    set(a, 'XTickLabel', '');
    set(a, 'YTickLabel', '');
    set(a, 'XTick', []);
    set(a, 'YTick', []);
    set(a, 'XColor', [1 1 1]);
    set(a, 'YColor', [1 1 1]);
end

function [mu_est sigma_est] = setGraphview(w, trial_resp, trial_unit, trial_num, initial_guess, symbol,color,id, condition)
    [STIM, HIT, N] = PAL_PFML_GroupTrialsbyX(trial_unit, trial_resp, ones(size(trial_resp)));
    [paramsValues] = PAL_PFML_Fit(STIM, HIT, N, [initial_guess 2 0 0], [1 1 0 0 ], @PAL_CumulativeNormal);
    mu_est = paramsValues(1);
    sigma_est = 1./paramsValues(2);
    succtrials = HIT;
    totaltrials = N;
    min = mu_est - w;
    max = mu_est + w;
    
    set(1, 'Toolbar', 'none');
    set(1, 'MenuBar', 'none');
    x = min:.01:max;
    affmu = mu_est;
    affsig = sigma_est;
    affrate = succtrials ./ totaltrials;
    afftrials = totaltrials;

    afx = normcdf(x,affmu, affsig);

    subplot(3,1,2); 
    plot(x, afx,color,'LineWidth',2);
    axis([min max -.01 1.01])
    xlabel('Trial Unit');
    ylabel('Prop. Yes Responses');
    hold on
    for i = 1:length(STIM)
        if not(isnan(affrate(i)))
            markersize = (afftrials(i) * 2) + 5;
            plot(STIM(i),affrate(i),symbol,'LineWidth',2,'MarkerSize',markersize);
            title(sprintf('%s %s, mu: %3.1f, sig: %3.1f', id, condition, mu_est, sigma_est));
        end
    end
    hold off

    subplot(3,1,3);
    plot(1:length(trial_unit), trial_unit, '--ko');
    xlabel('Trial Number');
    ylabel('Trial Unit');
    hold on
    for i = 1:length(trial_unit)
        if trial_resp(i) == 0
            plot(i, trial_unit(i), 'ko', 'MarkerFaceColor','r')
        end
    end
    if length(trial_unit) < 20
        axis([1 20 mu_est-8 mu_est+8]);
    else
        axis([length(trial_unit)-20 length(trial_unit) mu_est-8 mu_est+8]);
    end

    
end