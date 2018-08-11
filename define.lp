% ====== Define ======

% Types of marks to encode data.
marktype(point;bar;line;area;text;tick;rect).
% High level data types: quantitative, ordinal, nominal, temporal.
type(quantitative;ordinal;nominal;temporal).
% Basic types of the data.
primitive_type(string;number;boolean;datetime).
% Supported aggregation functions.
aggregate_op(count;mean;median;min;max;stdev;sum).
summative_aggregate_op(count;sum).
% Numbers of bins that can be recommended; any natural number is allowed.
binning(10;25;200).

% Encoding channels.
single_channel(x;y;color;size;shape;text;row;column).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;size;shape;text;detail).

% Possible tasks.
tasks(value;summary).

% Possible stackings.
stacking(zero;normalize).



basic_channel(x;y;color;size;shape).

% Tableau palettes.
tableau10(blue;orange;red;teal;green;yellow;purple;pink;brown;gray).
tableau20(blue;lightblue;orange;lightorange;green;lightgreen;tea;yellow;
  teal;lightteal;red;salmon;gray;lightgray;violet;lightpink;purple;lightpurple;brown;lightbrown).

% Vega color schemes.
scheme(viridis;inferno;magma;plasma;blues;greens;greys;purples;reds;oranges).

% palettes for encoding high-cardinality nominal fields.
hpalette(tableau10;tableau20;accent;category10;category20;category20b;category20c;
  dark2;paired;pastel1;pastel2;set1;set2;set3).





% ====== Helpers ======

discrete(CH,E) :- type(CH,E,(nominal;ordinal)).
discrete(CH,E) :- bin(CH,E,_).
continuous(CH,E) :- encoding(CH,E), not discrete(CH,E).

channel_discrete(CH,C) :- discrete(CH,E), channel(CH,E,C).
channel_continuous(CH,C) :- continuous(CH,E), channel(CH,E,C).

ordered(CH,E) :- type(CH,E,(ordinal;quantitative)).

% Fields
field(F) :- fieldtype(F,_).

% Stacking is applied to the continuous x or y.
stack(CH,EC,S) :- channel(CH,EC,(x;y)), channel(CH,ED,(x;y)), continuous(CH,EC), discrete(CH,ED), stack(CH,S).
% X and y are continuous.
stack(CH,E,S) :- channel_continuous(CH,x), channel(CH,E,y), continuous(CH,E), stack(CH,S).

stack(CH,S) :- stack(CH,_,S).

% Data properties
enc_cardinality(CH,E,C) :- field(CH,E,F), cardinality(CH,F,C), chart(CH).
enc_entropy(CH,E,EN) :- field(CH,E,F), entropy(CH,F,EN), chart(CH).
enc_interesting(CH,E) :- field(CH,E,F), interesting(CH,F), chart(CH).
enc_extent(CH,E,MIN,MAX) :- field(CH,E,F), extent(CH,F,MIN,MAX).

% Cardinality of discrete field. A binned field has the cadinality of its field.
discrete_cardinality(CH,E,CE) :- discrete(CH,E), enc_cardinality(CH,E,CE), channel(CH,E,C), not bin(CH,E,_).
discrete_cardinality(CH,E,CB) :- channel(CH,E,C), bin(CH,E,CB).

% Define a fake violation/3 for all violation/2.
violation(CH,F,_placeholder) :- violation(CH,F).

% == Chart Types ==

% Continuous by continuous.
is_c_c(CH) :- channel_continuous(CH,x), channel_continuous(CH,y), chart(CH).

% Continuous by discrete (or continuous only).
is_c_d(CH) :- channel_continuous(CH,x), not channel_continuous(CH,y).
is_c_d(CH) :- channel_continuous(CH,y), not channel_continuous(CH,x).

% Discrete by discrete.
is_d_d(CH) :- channel_discrete(CH,x), channel_discrete(CH,y).

% == Overlap ==

% The continuous variable is a measure (it is aggregated) and all other channels are .aggregated, or we use stack -> no overlap
non_pos_unaggregated(CH) :- chart(CH), channel(CH,E,C), non_positional(C), not aggregate(CH,E,_).
no_overlap(CH) :- is_c_d(CH), continuous(CH,E), channel(CH,E,(x;y)), aggregate(CH,E,_), not non_pos_unaggregated(CH).
no_overlap(CH) :- is_c_d(CH), stack(CH,_).

% the size of the discrete positional encoding
discrete_size(CH,S) :- is_c_d(CH), x_y_cardinality(CH,_,S).
discrete_size(CH,1) :- is_c_d(CH), channel_continuous(CH,x), not channel(CH,_,y).
discrete_size(CH,1) :- is_c_d(CH), channel_continuous(CH,y), not channel(CH,_,x).

% Data size is as small as discrete dimension -> no overlap.
no_overlap(CH) :- is_c_d(CH), num_rows(S), discrete_size(CH,S).

% We definitely overlap if the data size > discrete size.
overlap(CH) :- is_c_d(CH), not no_overlap(CH), num_rows(S1), discrete_size(CH,S2), S1 > S2.

% helpers to go from quadratic to linear number of grounding
x_y_cardinality(CH,x,S) :- channel(CH,E,x), discrete_cardinality(CH,E,S).
x_y_cardinality(CH,y,S) :- channel(CH,E,y), discrete_cardinality(CH,E,S).

% No overlap if all other dimensions are aggregated.
discrete_size(CH,S) :- is_d_d(CH), x_y_cardinality(CH,x,SX), x_y_cardinality(CH,y,SY), S = SX*SY.
no_overlap(CH) :- is_d_d(CH), not non_pos_unaggregated(CH).
no_overlap(CH) :- is_d_d(CH), num_rows(S1), discrete_size(CH,S2), S1 <= S2.  % This cannot guarantee no overlap.

% We can guarantee overlap using this rule unless we are using row / column.
row_col(CH) :- channel(CH,_,(row;column)).
overlap(CH) :- is_d_d(CH), channel(CH,E,C), not row_col(CH), not no_overlap(CH), num_rows(S1), discrete_size(CH,S2), S1 > S2.

% == Orientation ==

% Orientation tells us which one is the dependent and independent variable.

orientation(CH,vertical) :- mark(CH,(bar;tick;area;line)), channel_discrete(CH,x).
orientation(CH,vertical) :- mark(CH,(area;line)), channel_continuous(CH,x), channel_continuous(CH,y).

orientation(CH,horizontal) :- mark(CH,(bar;tick;area;line)), channel_discrete(CH,y).




% Palettes
palette(C) :- tableau10(C).
palette(C) :- tableau20(C).

highcardinality(CH,E) :- field(CH,E,F), cardinality(CH,F,C), C > 10.

% Silence warnings about properties never appearing in head.
type(0,0,0) :- #false.
bin(0,0,0) :- #false.
entropy(0,0,0) :- #false.
interesting(0,0) :- #false.
extent(0,0,0,0) :- #false.
fieldtype(0,0) :- #false.
aggregate(0,0,0) :- #false.
num_rows(0) :- #false.
mark(0,0) :- #false.
log(0,0) :- #false.
zero(0,0) :- #false.
task(0,0) :- #false.
ndomain(0,0,0) :- #false.
qdomain(0,0,0,0) :- #false.
cardinality(0,0,0) :- #false.
violation(0,0) :- #false.
ccolor(0,0) :- #false.
hcolor(0,0,0) :- #false.
ncolor(0,0,0) :- #false.
qcolor(0,0,0) :- #false.
