out_dir = uigetdir('','Specify a directory to save output files');
id = inputdlg('Enter participant id')';

stim_levels = 15:.5:60;

[mu_est_pre, sigma_est_pre, trial_unit_pre, trial_resp_pre] = DataCollection(out_dir, id{1}, 'pre', stim_levels);
[mu_est_aff, sigma_est_aff, trial_unit_aff, trial_resp_aff] = DataCollection(out_dir, id{1}, 'aff', stim_levels);
[mu_est_pst, sigma_est_pst, trial_unit_pst, trial_resp_pst] = DataCollection(out_dir, id{1}, 'pst', stim_levels);

save(strcat(out_dir,'/',id{1}));