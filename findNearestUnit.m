function [unit] = findNearestUnit(stim_levels, val)
s = abs(stim_levels-val);
unit = stim_levels(s == min(s));