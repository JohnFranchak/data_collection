out_dir = uigetdir('','Specify a directory to save output files');
id = inputdlg('Enter participant id')';

stim_levels_dec = 15:.5:60;
stim_levels_aff = 20:.5:45;
stim_levels_nopack = 12:.5:30;

[mu_est_pre, sigma_est_pre, trial_unit_pre, trial_resp_pre] = DataCollection(out_dir, id{1}, 'pre', stim_levels_dec);
[mu_est_aff, sigma_est_aff, trial_unit_aff, trial_resp_aff] = DataCollection(out_dir, id{1}, 'aff', stim_levels_aff);
[mu_est_pst, sigma_est_pst, trial_unit_pst, trial_resp_pst] = DataCollection(out_dir, id{1}, 'pst', stim_levels_dec);
[mu_est_npk, sigma_est_npk, trial_unit_npk, trial_resp_npk] = DataCollection(out_dir, id{1}, 'npk', stim_levels_dec);

offset = inputdlg('Type measurement camera reading with doorway fully closed')';

save(strcat(out_dir,'/',id{1}));