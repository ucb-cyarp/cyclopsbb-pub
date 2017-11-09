function [assign, wire] = export_fixed_point_ver( value, name, wire_format, assign_format, signed, word_len, frac_len)
%export_fixed_point_ver prints parameter declarations in verilog syntax

fixed_pt = fi(value, signed, word_len, frac_len);

wire = sprintf(wire_format, word_len-1, 0, name);
assign = sprintf(assign_format, name, word_len, fixed_pt.bin);

end

