% Print Fixed Point Parameters

format_str = '#define %-30s 0b%s';

disp('#ifndef RADIO_PARAMS_SIM_H');
disp('#define RADIO_PARAMS_SIM_H');
disp(' ');

disp(export_fixed_point_c(tx_gain, 'TX_GAIN', format_str, true, 8, 4));
disp(export_fixed_point_c(rx_gain, 'RX_GAIN', format_str, true, 8, 4));
disp(export_fixed_point_c(rx_gain_i, 'RX_I_GAIN', format_str, true, 8, 4));
disp(export_fixed_point_c(rx_gain_q, 'RX_Q_GAIN', format_str, true, 8, 4));
disp(export_fixed_point_c(rx_offset_correction_i, 'RX_I_OFFSET', format_str, true, 14, 11));
disp(export_fixed_point_c(rx_offset_correction_q, 'RX_Q_OFFSET', format_str, true, 14, 11));
disp(export_fixed_point_c(agcDesired, 'RX_AGC_DESIRED', format_str, true, 32, 18));
disp(export_fixed_point_c(agcStep, 'RX_AGC_STEP_SIZE', format_str, true, 32, 18));
disp(export_fixed_point_c(timing_pre_scale, 'RX_TIMING_PRE_SCALE', format_str, true, 32, 22));
disp(export_fixed_point_c(timing_p, 'RX_TIMING_P', format_str, true, 32, 22));
disp(export_fixed_point_c(timing_i, 'RX_TIMING_I', format_str, true, 32, 22));
disp(export_fixed_point_c(timing_integrator1_decay, 'RX_TIMING_INTEGRATOR1_DECAY', format_str, true, 32, 22));
%disp(export_fixed_point_c(timing_pre_stage2_scale, 'RX_TIMING_PRE_STAGE2_SCALE', format_str, true, 32, 22));
%disp(export_fixed_point_c(timing_integrator2_decay, 'RX_TIMING_INTEGRATOR2_DECAY', format_str, true, 32, 22));
%disp(export_fixed_point_c(timing_post_scale, 'RX_TIMING_POST_SCALE', format_str, true, 32, 22));

disp(export_fixed_point_c(post_cr_i_offset, 'RX_CR_I_OFFSET', format_str, true, 14, 11));
disp(export_fixed_point_c(post_cr_q_offset, 'RX_CR_Q_OFFSET', format_str, true, 14, 11));
%disp(export_fixed_point_c(cr_pre_scale, 'RX_CR_PRE_SCALE', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_i_preamp, 'RX_CR_I_PREAMP', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_p, 'RX_CR_P', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_i, 'RX_CR_I', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_integrator1_decay, 'RX_CR_INTEGRATOR1_DECAY', format_str, true, 25, 17));
%disp(export_fixed_point_c(cr_pre_stage2_scale, 'RX_CR_PRE_STAGE2_SCALE', format_str, true, 25, 17));
%disp(export_fixed_point_c(cr_integrator2_decay, 'RX_CR_INTEGRATOR2_DECAY', format_str, true, 25, 17));
%disp(export_fixed_point_c(cr_post_scale, 'RX_CR_POST_SCALE', format_str, true, 25, 17));

%Extensions
disp(export_fixed_point_c(agc_on, 'AGC_ON', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_agc, 'AGC_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(agc_sat_up, 'AGC_SATURATE_UP', format_str, true, 32, 18));
disp(export_fixed_point_c(agc_sat_low, 'AGC_SATURATE_LOW', format_str, true, 32, 18));
disp(export_fixed_point_c(freeze_en_tr_int1, 'TR_INT1_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_tr_int2, 'TR_INT2_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_tr_phase, 'TR_PHASE_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(tr_int1_sat_up, 'TR_INT1_SATURATE_UP', format_str, true, 32, 22));
disp(export_fixed_point_c(tr_int1_sat_low, 'TR_INT1_SATURATE_LOW', format_str, true, 32, 22));
disp(export_fixed_point_c(tr_sat2_up, 'TR_SATURATE2_UP', format_str, true, 32, 22));
disp(export_fixed_point_c(tr_sat2_low, 'TR_SATURATE2_LOW', format_str, true, 32, 22));
disp(export_fixed_point_c(freeze_on_stf_done, 'FREEZE_ON_STF_DONE', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_on_cef_done, 'FREEZE_ON_CEF_DONE', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_on_valid, 'FREEZE_ON_VALID', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_cr_int1, 'CR_INT1_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_cr_int2, 'CR_INT2_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(freeze_en_cr_phase, 'CR_PHASE_FREEZE_EN', format_str, true, 2, 0));
disp(export_fixed_point_c(cr_int1_sat_up, 'CR_INT1_SATURATE_UP', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_int1_sat_low, 'CR_INT1_SATURATE_LOW', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_sat2_up, 'CR_SATURATE2_UP', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_sat2_low, 'CR_SATURATE2_LOW', format_str, true, 25, 17));
disp(export_fixed_point_c(cal_sig_i_mult, 'CAL_I_MULT', format_str, true, 16, 14));
disp(export_fixed_point_c(cal_sig_q_mult, 'CAL_Q_MULT', format_str, true, 16, 14));
disp(export_fixed_point_c(cal_sig_i_offset, 'CAL_I_OFFSET', format_str, true, 16, 14));
disp(export_fixed_point_c(cal_sig_q_offset, 'CAL_Q_OFFSET', format_str, true, 16, 14));

disp(' ');
disp('#endif');
