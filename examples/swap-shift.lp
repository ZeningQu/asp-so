% swap & shift revision prototype

% test with `clingo --opt-mode=OptN examples/swap-shift.lp`

#include "define.lp".
#include "channel-field.lp".
#include "soft.lp".
#include "weights.lp".
#include "assign_weights.lp".
#include "optimize.lp".
% #include "cost.lp".
#include "output.lp".

% ====== Input ======
chart(c0).
encoding(c0,e0).
field(c0,e0,origin).
type(c0,e0,nominal).
encoding(c0,e1).
field(c0,e1,name).
type(c0,e1,nominal).

chart(c1).
encoding(c1,e0).
field(c1,e0,origin).
type(c1,e0,nominal).
encoding(c1,e1).
field(c1,e1,name).
type(c1,e1,nominal).
