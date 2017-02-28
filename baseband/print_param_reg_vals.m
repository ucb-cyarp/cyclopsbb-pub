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
disp(export_fixed_point_c(timing_pre_stage2_scale, 'RX_TIMING_PRE_STAGE2_SCALE', format_str, true, 32, 22));
disp(export_fixed_point_c(timing_integrator2_decay, 'RX_TIMING_INTEGRATOR2_DECAY', format_str, true, 32, 22));
disp(export_fixed_point_c(timing_post_scale, 'RX_TIMING_POST_SCALE', format_str, true, 32, 22));

disp(export_fixed_point_c(post_cr_i_offset, 'RX_CR_I_OFFSET', format_str, true, 14, 11));
disp(export_fixed_point_c(post_cr_q_offset, 'RX_CR_Q_OFFSET', format_str, true, 14, 11));
disp(export_fixed_point_c(cr_pre_scale, 'RX_CR_PRE_SCALE', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_i_preamp, 'RX_CR_I_PREAMP', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_p, 'RX_CR_P', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_i, 'RX_CR_I', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_integrator1_decay, 'RX_CR_INTEGRATOR1_DECAY', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_pre_stage2_scale, 'RX_CR_PRE_STAGE2_SCALE', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_integrator2_decay, 'RX_CR_INTEGRATOR2_DECAY', format_str, true, 25, 17));
disp(export_fixed_point_c(cr_post_scale, 'RX_CR_POST_SCALE', format_str, true, 25, 17));

disp(' ');
disp('#endif');
