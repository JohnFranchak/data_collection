clear all
tic
out_dir = uigetdir('','Specify a directory to save output files');
id = inputdlg('Enter participant id')';

stim_levels_dec = 15:.5:60;
stim_levels_aff = 15:.5:60;
stim_levels_nopack = 10:.5:55;

[mu_est_pre, sigma_est_pre, trial_unit_pre, trial_resp_pre, time_pre] = DataCollection(out_dir, id{1}, 'pre', stim_levels_dec, 0, 30, 30);
save(strcat(out_dir,'/',id{1}));
[mu_est_aff, sigma_est_aff, trial_unit_aff, trial_resp_aff, time_aff] = DataCollection(out_dir, id{1}, 'aff', stim_levels_aff, 4, 30, 20);
save(strcat(out_dir,'/',id{1}));
[mu_est_pst, sigma_est_pst, trial_unit_pst, trial_resp_pst, time_pst] = DataCollection(out_dir, id{1}, 'pst', stim_levels_dec, 0, 30, 30);
save(strcat(out_dir,'/',id{1}));
[mu_est_npk, sigma_est_npk, trial_unit_npk, trial_resp_npk, time_npk] = DataCollection(out_dir, id{1}, 'npk', stim_levels_dec, 4, mu_est_aff - 5, 15);
save(strcat(out_dir,'/',id{1}));

measurement_offset = inputdlg('Enter measurement camera reading with doorway fully closed')';

save(strcat(out_dir,'/',id{1}));

disp('Experiment successfully completed. Please check that all of the files have been saved to the participant directory, and then close Matlab.');
toc