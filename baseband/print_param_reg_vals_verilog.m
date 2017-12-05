% Print Fixed Point Parameters

wire_str = 'wire [%d:%d] %s;';
assign_str = 'assign %-30s = %d''b%s;';

assigns = {};
wires = {};

[assign, wire] = export_fixed_point_ver(tx_gain, 'TX_GAIN', wire_str, assign_str, true, 8, 4); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(rx_gain, 'RX_GAIN', wire_str, assign_str, true, 8, 4); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(rx_gain_i, 'RX_I_GAIN', wire_str, assign_str, true, 8, 4); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(rx_gain_q, 'RX_Q_GAIN', wire_str, assign_str, true, 8, 4); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(rx_offset_correction_i, 'RX_I_OFFSET', wire_str, assign_str, true, 14, 11); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(rx_offset_correction_q, 'RX_Q_OFFSET', wire_str, assign_str, true, 14, 11); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(agcDesired, 'RX_AGC_DESIRED', wire_str, assign_str, true, 38, 18); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(agcStep, 'RX_AGC_STEP_SIZE', wire_str, assign_str, true, 38, 18); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(timing_pre_scale, 'RX_TIMING_PRE_SCALE', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(timing_p, 'RX_TIMING_P', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(timing_i, 'RX_TIMING_I', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(timing_integrator1_decay, 'RX_TIMING_INTEGRATOR1_DECAY', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(timing_pre_stage2_scale, 'RX_TIMING_PRE_STAGE2_SCALE', wire_str, assign_str, true, 32, 22)); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(timing_integrator2_decay, 'RX_TIMING_INTEGRATOR2_DECAY', wire_str, assign_str, true, 32, 22)); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(timing_post_scale, 'RX_TIMING_POST_SCALE', wire_str, assign_str, true, 32, 22)); assigns{end+1} = assign; wires{end+1} = wire;

[assign, wire] = export_fixed_point_ver(post_cr_i_offset, 'RX_CR_I_OFFSET', wire_str, assign_str, true, 14, 11); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(post_cr_q_offset, 'RX_CR_Q_OFFSET', wire_str, assign_str, true, 14, 11); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(cr_pre_scale, 'RX_CR_PRE_SCALE', wire_str, assign_str, true, 25, 17)); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_i_preamp, 'RX_CR_I_PREAMP', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_p, 'RX_CR_P', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_i, 'RX_CR_I', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_integrator1_decay, 'RX_CR_INTEGRATOR1_DECAY', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(cr_pre_stage2_scale, 'RX_CR_PRE_STAGE2_SCALE', wire_str, assign_str, true, 25, 17)); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(cr_integrator2_decay, 'RX_CR_INTEGRATOR2_DECAY', wire_str, assign_str, true, 25, 17)); assigns{end+1} = assign; wires{end+1} = wire;
%[assign, wire] = export_fixed_point_ver(cr_post_scale, 'RX_CR_POST_SCALE', wire_str, assign_str, true, 25, 17)); assigns{end+1} = assign; wires{end+1} = wire;

%Extensions
[assign, wire] = export_fixed_point_ver(agc_on, 'AGC_ON', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_agc, 'AGC_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(agc_sat_up, 'AGC_SATURATE_UP', wire_str, assign_str, true, 38, 18); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(agc_sat_low, 'AGC_SATURATE_LOW', wire_str, assign_str, true, 38, 18); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_tr_int1, 'TR_INT1_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_tr_int2, 'TR_INT2_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_tr_phase, 'TR_PHASE_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(tr_int1_sat_up, 'TR_INT1_SATURATE_UP', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(tr_int1_sat_low, 'TR_INT1_SATURATE_LOW', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(tr_sat2_up, 'TR_SATURATE2_UP', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(tr_sat2_low, 'TR_SATURATE2_LOW', wire_str, assign_str, true, 32, 22); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_on_stf_done, 'FREEZE_ON_STF_DONE', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_on_cef_done, 'FREEZE_ON_CEF_DONE', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_on_valid, 'FREEZE_ON_VALID', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_cr_int1, 'CR_INT1_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_cr_int2, 'CR_INT2_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(freeze_en_cr_phase, 'CR_PHASE_FREEZE_EN', wire_str, assign_str, true, 2, 0); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_int1_sat_up, 'CR_INT1_SATURATE_UP', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_int1_sat_low, 'CR_INT1_SATURATE_LOW', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_sat2_up, 'CR_SATURATE2_UP', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cr_sat2_low, 'CR_SATURATE2_LOW', wire_str, assign_str, true, 25, 17); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cal_sig_i_mult, 'CAL_I_MULT', wire_str, assign_str, true, 16, 14); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cal_sig_q_mult, 'CAL_Q_MULT', wire_str, assign_str, true, 16, 14); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cal_sig_i_offset, 'CAL_I_OFFSET', wire_str, assign_str, true, 16, 14); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(cal_sig_q_offset, 'CAL_Q_OFFSET', wire_str, assign_str, true, 16, 14); assigns{end+1} = assign; wires{end+1} = wire;

%eq
[assign, wire] = export_fixed_point_ver(lmsStep_init, 'EQ_STEP', wire_str, assign_str, true, 36, 24); assigns{end+1} = assign; wires{end+1} = wire;
[assign, wire] = export_fixed_point_ver(lmsStep_meta, 'EQ_STEP_META', wire_str, assign_str, true, 36, 24); assigns{end+1} = assign; wires{end+1} = wire;

for i = 1:length(wires)
    disp(wires{i});
end
disp(' ');
for i = 1:length(assigns)
    disp(assigns{i});
end