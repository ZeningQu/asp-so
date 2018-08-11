% ====== Generate ======
% generate channel for each encoding.
{ channel(CH,E,C): basic_channel(C) } = 1 :- chart(CH), encoding(CH,E).

% ====== Hard ======
% ------------- Single-View Constraints --------------
% (from draco) Cannot use single channels twice.
:- single_channel(C), chart(CH), 2 { channel(CH,_,C) }.

% ------------- Multi-View Consistency Constraints --------------
% CHANNEL_FIELD_SWAP: No swap in channel-field mappings
:- chart(CH1), field(CH1,E1,F1), field(CH1,E2,F2), channel(CH1,E1,C1), channel(CH1,E2,C2),
chart(CH2), field(CH2,E3,F1), field(CH2,E4,F2), channel(CH2,E3,C2), channel(CH2,E4,C1),
CH1 != CH2, E1 != E2, E3 != E4, F1 != F2, C1 != C2.

% CHANNEL_FIELD_SHIFT: No shift in channel-field mappings
% Note: we don't recommend redundant encoding
:- chart(CH1), field(CH1,E1,F), channel(CH1,E1,C1),
chart(CH2), field(CH2,E2,F), channel(CH2,E2,C2),
CH1 != CH2, C1 != C2.
