% !! This is super slow and should only be used for experiments !!

cost(C) :- C = #sum { W,Q,F,CH: violation_weight(F,W), violation(CH,F,Q) }.

#show cost/1.
