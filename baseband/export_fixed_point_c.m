function str = export_fixed_point_c( value, name, format, signed, word_len, frac_len)
%export_fixed_point_c prints an export thing

fixed_pt = fi(value, signed, word_len, frac_len);

str = sprintf(format, name, fixed_pt.bin);

end

