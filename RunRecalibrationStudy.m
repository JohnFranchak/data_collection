clear all
tic
out_dir = uigetdir('','Specify a directory to save output files');
id = inputdlg('Enter participant id')';
cond = inputdlg('Enter condition (f or b)');

stim_levels_dec = 15:.5:60;
stim_levels_aff = 15:.5:60;
stim_levels_nopack = 10:.5:55;

[mu_est_pre, sigma_est_pre, trial_unit_pre, trial_resp_pre, time_pre] = DataCollection(out_dir, id{1}, strcat('pre_',cond{1}), stim_levels_dec, 0, 30, 30);
save(strcat(out_dir,'/',id{1}));
[mu_est_aff, sigma_est_aff, trial_unit_aff, trial_resp_aff, time_aff] = DataCollection(out_dir, id{1}, strcat('aff_',cond{1}), stim_levels_aff, 4, 32, 20);
save(strcat(out_dir,'/',id{1}));
[mu_est_pst, sigma_est_pst, trial_unit_pst, trial_resp_pst, time_pst] = DataCollection(out_dir, id{1}, strcat('pst_',cond{1}), stim_levels_dec, 0, 30, 30);
save(strcat(out_dir,'/',id{1}));
[mu_est_npk, sigma_est_npk, trial_unit_npk, trial_resp_npk, time_npk] = DataCollection(out_dir, id{1}, strcat('npk_',cond{1}), stim_levels_dec, 4, mu_est_aff - 10, 15);
save(strcat(out_dir,'/',id{1}));

measurement_offset = inputdlg('Enter measurement camera reading with doorway fully closed')';

save(strcat(out_dir,'/',id{1}));

disp('Experiment successfully completed. Please check that all of the files have been saved to the participant directory, and then close Matlab.');
toc