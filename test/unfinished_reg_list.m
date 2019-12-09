%treatsbx(load_parameters('DL159', '190612', 8, 0));
%treatsbx(load_parameters('DL170', '190613', 6, 0));
%treatsbx(load_parameters('DL171', '190614', 8, 0));
%treatsbx(load_parameters('DL172', '190617', 9, 0));  % has slight move during CSD raising period. 
% Done with ref_idx to seperate stages and only correct ref in trunk, set
% threshold at 5.
%treatsbx(load_parameters('DL173', '190620', 6, 0));   % several fames are
%very bad, need interpulation.
% Done with ref_idx only [0,13500]. do interpulation with threshold = 3
%treatsbx(load_parameters('DL174', '190622', 4, 0));

%treatsbx(load_parameters('RAS001', '190913', 3, 0));
%treatsbx(load_parameters('RAS002', '190916', 3, 0));
%treatsbx(load_parameters('RAS003', '190917', 3, 0));
%treatsbx(load_parameters('RAS004', '190920', 3, 0)); % has some shaky at
%A2 period. Done with ref_idx to seperate stages and only correct ref in
%trunk, set threshold at 5.



%csd_single_trial_analysis(load_parameters('DL159', '190612', 8, 0));
%csd_single_trial_analysis(load_parameters('DL170', '190613', 6, 0));
%csd_single_trial_analysis(load_parameters('DL171', '190614', 8, 0));
%csd_single_trial_analysis(load_parameters('DL172', '190617', 9, 0));
csd_single_trial_analysis(load_parameters('DL173', '190620', 6, 0));
csd_single_trial_analysis(load_parameters('DL174', '190622', 4, 0));
csd_single_trial_analysis(load_parameters('RAS001', '190913', 3, 0));
csd_single_trial_analysis(load_parameters('RAS002', '190916', 3, 0));
csd_single_trial_analysis(load_parameters('RAS003', '190917', 3, 0));
csd_single_trial_analysis(load_parameters('RAS004', '190920', 3, 0));