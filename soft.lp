% After adding a soft constraint to this file, make sure to update weights.lp and run process_violations.py..

% ====== Preferences ======

% Prefer to use raw (no aggregate).
violation(CH,aggregate,E) :- chart(CH), aggregate(CH,E,_).

% Prefer to not bin.
violation(CH,bin,E) :- chart(CH), bin(CH,E,_).

% Prefer binning with at most 12 buckets.
violation(CH,bin_high,E) :- chart(CH), bin(CH,E,B), B > 12.

% Prefer binning with more than 7 buckets.
violation(CH,bin_low,E) :- chart(CH), bin(CH,E,B), B <= 7.

% Prefer to use fewer encodings.
violation(CH,encoding,E) :- chart(CH), encoding(CH,E).

% Prefer to use fewer encodings with fields (count does not have a field).
violation(CH,encoding_field,E) :- chart(CH), encoding(CH,E), field(CH,E,_).

% Prefer not to use the same field multiple times.
violation(CH,same_field_2,F) :- chart(CH), field(F), { field(CH,_,F) } = 2.
violation(CH,same_field_gte3,F) :- chart(CH), field(F), { field(CH,_,F) } >= 3.

% Prefer not to use count more than once.
violation(CH,count_twice) :- chart(CH), { aggregate(CH,_,count) } = 2.

% Shape channel should not have too high cardinality.
violation(CH,shape_cardinality,E) :- chart(CH), channel(CH,E,shape), discrete_cardinality(CH,E,C), C > 5.

% Numbers should not be nominal.
violation(CH,number_nominal,E) :- chart(CH), type(CH,E,nominal), field(CH,E,F), fieldtype(F,number).

% Binned quantitative field should not have too low cardinality.
violation(CH,bin_cardinality,E) :- chart(CH), type(CH,E,quantitative), bin(CH,E,_), enc_cardinality(CH,E,C), C < 15.

% Prefer quantitative for bin.
violation(CH,quant_bin,E) :- chart(CH), bin(CH,E,_), not type(CH,E,quantitative).

% Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
violation(CH,only_discrete) :- chart(CH), not continuous(CH,_).

% Prefer not to use multiple non-positional encoding channels.
violation(CH,multiple_non_pos) :- chart(CH), {channel(CH,_,C): non_positional(C)} > 1.

% Prefer not to use non-positional channels until all positional channels are used.
violation(CH,non_positional_pref) :- chart(CH), channel(CH,_,C), non_positional(C), not channel(CH,_,(x;y)).

% Aggregate plots should not use raw continuous as group by.
violation(CH,aggregate_group_by_raw,E) :- chart(CH), aggregate(CH,_,_), continuous(CH,E), not aggregate(CH,E,_).

% Aggregate should also have a discrete encoding to group by.
violation(CH,agg_dim) :- chart(CH), aggregate(CH,_,_), not discrete(CH,_).

% Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
violation(CH,x_y_raw,E) :- chart(CH), channel(CH,EX,x), discrete(CH,EX), channel(CH,EY,y), discrete(CH,EY), not aggregate(CH,E,_), continuous(CH,E).

% Prefer not to use log scale.
violation(CH,log,E) :- chart(CH), log(CH,E).

% Prefer to include zero for continuous (binned doesn't need zero).
violation(CH,zero,E) :- chart(CH), continuous(CH,E), not zero(CH,E).

% Prefer zero size (even when binned).
violation(CH,zero_size) :- chart(CH), channel(CH,E,size), not zero(CH,E).

% Prefer zero positional.
violation(CH,zero_positional) :- chart(CH), continuous(CH,E), channel(CH,E,(x;y)), not zero(CH,E).

% Prefer not to use zero when the difference between min and max is larger than distance to 0.
violation(CH,zero_skew) :- chart(CH), enc_extent(CH,E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(CH,E).

% Do not include zero when the range of data includes zero.
violation(CH,includes_zero) :- chart(CH), zero(CH,E), extent(CH,E,MIN,MAX), MIN < 0, MAX > 0.

% Prefer to use only x instead of only y.
violation(CH,only_x) :- chart(CH), channel(CH,_,y), not channel(CH,_,x).

% Chart orientation for bar and tick (with and without bin).
% Binned fields have short labels if they are quantitative while otherwise labels can be long.
violation(CH,orientation_binned) :- chart(CH), bin(CH,E,_), type(CH,E,quantitative), not channel(CH,E,x).

% Prefer not to use ordinal for fields with high cardinality.
violation(CH,high_cardinality_ordinal,E) :- chart(CH), type(CH,E,ordinal), discrete_cardinality(CH,E,C), C > 30.

% Prefer not to use nominal for fields with high cardinality.
violation(CH,high_cardinality_nominal,E) :- chart(CH), type(CH,E,nominal), enc_cardinality(CH,E,C), C > 12.

% Prefer not to use high cardinality nominal for color.
violation(CH,high_cardinality_nominal_color,E) :- chart(CH), type(CH,E,nominal), channel(CH,E,color), enc_cardinality(CH,E,C), C > 10.

% Avoid high cardinality on x or column as it causes horizontal scrolling.
violation(CH,horizontal_scrolling,E) :- chart(CH), channel(CH,E,x), discrete_cardinality(CH,E,C), C > 50.
violation(CH,horizontal_scrolling,E) :- chart(CH), channel(CH,E,columm), discrete_cardinality(CH,E,C), C > 5.

% Prefer to use temporal type with dates.
violation(CH,temporal_date,E) :- chart(CH), field(CH,E,F), fieldtype(F,datetime), not type(CH,E,temporal).

% Prefer quantitative for numbers with high cardinality.
violation(CH,quantitative_numbers) :- chart(CH), field(CH,E,F), fieldtype(F,number), cardinality(CH,F,C), C > 20, not bin(CH,E,_), not type(CH,E,quantitative).

% Overplotting.

% Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
violation(CH,position_entropy,E) :- chart(CH), channel(CH,E,(x;y)), continuous(CH,E), enc_cardinality(CH,E,C), C > 100, enc_entropy(CH,E,EN), EN <= 12, not aggregate(CH,E,_).

% Prefer not to use size when the cardinality is large on x or y.
violation(CH,high_cardinality_size,E) :- chart(CH), continuous(CH,E), channel(CH,_,size), enc_cardinality(CH,E,C), C > 100, channel(CH,E,(x;y)).

% Prefer not to aggregate for value tasks.
violation(CH,value_agg) :- chart(CH), task(CH,value), aggregate(CH,_,_).

% Prefer not to use row and column for summary tasks as it makes it difficult to compare.
violation(CH,facet_summary,E) :- chart(CH), task(CH,summary), channel(CH,E,row).

% Positional interactions as suggested by Kim et al.
violation(CH,x_row) :- chart(CH), channel(CH,_,x), channel(CH,_,row).
violation(CH,y_row) :- chart(CH), channel(CH,_,y), channel(CH,_,row).
violation(CH,x_column) :- chart(CH), channel(CH,_,x), channel(CH,_,column).
violation(CH,y_column) :- chart(CH), channel(CH,_,y), channel(CH,_,column).

% Entropy, primary quantitaty interactions as suggested by Kim et al.
violation(CH,color_entropy_high, E) :- chart(CH), channel(CH,E,color), enc_entropy(CH,E,EN), EN > 12, type(CH,E,quantitative), enc_interesting(CH,E).
violation(CH,color_entropy_low, E) :- chart(CH), channel(CH,E,color), enc_entropy(CH,E,EN), EN <= 12, type(CH,E,quantitative), enc_interesting(CH,E).
violation(CH,size_entropy_high, E) :- chart(CH), channel(CH,E,size), enc_entropy(CH,E,EN), EN > 12, type(CH,E,quantitative), enc_interesting(CH,E).
violation(CH,size_entropy_low, E) :- chart(CH), channel(CH,E,size), enc_entropy(CH,E,EN), EN <= 12, type(CH,E,quantitative), enc_interesting(CH,E).

% Prefer not to use continuous on x, discrete on y, and column.
violation(CH,c_d_column) :- chart(CH), channel_continuous(CH,x), channel_discrete(CH,y), channel(CH,_,column).

% Prefer time on x.
violation(CH,temporal_y) :- chart(CH), type(CH,E,temporal), not channel(CH,E,x).

% Prefer not to overlap with DxD.
violation(CH,d_d_overlap) :- chart(CH), is_d_d(CH), overlap.

% ====== Rankings ======

% === Data Types ===

% Prefer quantitative > ordinal > nominal.
violation(CH,type_q,E) :- chart(CH), type(CH,E,quantitative).
violation(CH,type_o,E) :- chart(CH), type(CH,E,ordinal).
violation(CH,type_n,E) :- chart(CH), type(CH,E,nominal).


% === Mark types ===

violation(CH,c_c_point) :- chart(CH), is_c_c(CH), mark(CH,point).
violation(CH,c_c_line) :- chart(CH), is_c_c(CH), mark(CH,line).
violation(CH,c_c_area) :- chart(CH), is_c_c(CH), mark(CH,area).
violation(CH,c_c_text) :- chart(CH), is_c_c(CH), mark(CH,text).
violation(CH,c_c_tick) :- chart(CH), is_c_c(CH), mark(CH,tick).


violation(CH,c_d_point) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,point).
violation(CH,c_d_bar) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,bar).
violation(CH,c_d_line) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,line).
violation(CH,c_d_area) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,area).
violation(CH,c_d_text) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,text).
violation(CH,c_d_tick) :- chart(CH), is_c_d(CH), not no_overlap, mark(CH,tick).

violation(CH,c_d_no_overlap_point) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,point).
violation(CH,c_d_no_overlap_bar) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,bar).
violation(CH,c_d_no_overlap_line) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,line).
violation(CH,c_d_no_overlap_area) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,area).
violation(CH,c_d_no_overlap_text) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,text).
violation(CH,c_d_no_overlap_tick) :- chart(CH), is_c_d(CH), no_overlap, mark(CH,tick).


violation(CH,d_d_point) :- chart(CH), is_d_d(CH), mark(CH,point).
violation(CH,d_d_text) :- chart(CH), is_d_d(CH), mark(CH,text).
violation(CH,d_d_rect) :- chart(CH), is_d_d(CH), mark(CH,rect).


% === Channel rankings à la APT ===

violation(CH,continuous_x,E) :- chart(CH), channel(CH,E,x), continuous(CH,E).
violation(CH,continuous_y,E) :- chart(CH), channel(CH,E,y), continuous(CH,E).
violation(CH,continuous_color,E) :- chart(CH), channel(CH,E,color), continuous(CH,E).
violation(CH,continuous_size,E) :- chart(CH), channel(CH,E,size), continuous(CH,E).
violation(CH,continuous_text,E) :- chart(CH), channel(CH,E,text), continuous(CH,E).

violation(CH,ordered_x,E) :- chart(CH), channel(CH,E,x), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_y,E) :- chart(CH), channel(CH,E,y), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_color,E) :- chart(CH), channel(CH,E,color), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_size,E) :- chart(CH), channel(CH,E,size), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_text,E) :- chart(CH), channel(CH,E,text), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_row,E) :- chart(CH), channel(CH,E,row), discrete(CH,E), not type(CH,E,nominal).
violation(CH,ordered_column,E) :- chart(CH), channel(CH,E,column), discrete(CH,E), not type(CH,E,nominal).

violation(CH,nominal_x,E) :- chart(CH), channel(CH,E,x), type(CH,E,nominal).
violation(CH,nominal_y,E) :- chart(CH), channel(CH,E,y), type(CH,E,nominal).
violation(CH,nominal_color,E) :- chart(CH), channel(CH,E,color), type(CH,E,nominal).
violation(CH,nominal_shape,E) :- chart(CH), channel(CH,E,shape), type(CH,E,nominal).
violation(CH,nominal_text,E) :- chart(CH), channel(CH,E,text), type(CH,E,nominal).
violation(CH,nominal_row,E) :- chart(CH), channel(CH,E,row), type(CH,E,nominal).
violation(CH,nominal_column,E) :- chart(CH), channel(CH,E,column), type(CH,E,nominal).
violation(CH,nominal_detail,E) :- chart(CH), channel(CH,E,detail), type(CH,E,nominal).

violation(CH,interesting_x,E) :- chart(CH), channel(CH,E,x), enc_interesting(CH,E).
violation(CH,interesting_y,E) :- chart(CH), channel(CH,E,y), enc_interesting(CH,E).
violation(CH,interesting_color,E) :- chart(CH), channel(CH,E,color), enc_interesting(CH,E).
violation(CH,interesting_size,E) :- chart(CH), channel(CH,E,size), enc_interesting(CH,E).
violation(CH,interesting_shape,E) :- chart(CH), channel(CH,E,shape), enc_interesting(CH,E).
violation(CH,interesting_text,E) :- chart(CH), channel(CH,E,text), enc_interesting(CH,E).
violation(CH,interesting_row,E) :- chart(CH), channel(CH,E,row), enc_interesting(CH,E).
violation(CH,interesting_column,E) :- chart(CH), channel(CH,E,column), enc_interesting(CH,E).
violation(CH,interesting_detail,E) :- chart(CH), channel(CH,E,detail), enc_interesting(CH,E).

% === Aggregations ===

violation(CH,aggregate_count,E) :- chart(CH), aggregate(CH,E,count).
violation(CH,aggregate_sum,E) :- chart(CH), aggregate(CH,E,sum).
violation(CH,aggregate_mean,E) :- chart(CH), aggregate(CH,E,mean).
violation(CH,aggregate_median,E) :- chart(CH), aggregate(CH,E,median).
violation(CH,aggregate_min,E) :- chart(CH), aggregate(CH,E,min).
violation(CH,aggregate_max,E) :- chart(CH), aggregate(CH,E,max).
violation(CH,aggregate_stdev,E) :- chart(CH), aggregate(CH,E,stdev).


% === Stack ===

violation(CH,stack_zero) :- chart(CH), stack(CH,zero).
violation(CH,stack_normalize) :- chart(CH), stack(CH,normalize).


% === Task - marktype correlations ===

violation(CH,value_point) :- chart(CH), task(CH,value), mark(CH,point).
violation(CH,value_bar) :- chart(CH), task(CH,value), mark(CH,bar).
violation(CH,value_line) :- chart(CH), task(CH,value), mark(CH,line).
violation(CH,value_area) :- chart(CH), task(CH,value), mark(CH,area).
violation(CH,value_text) :- chart(CH), task(CH,value), mark(CH,text).
violation(CH,value_tick) :- chart(CH), task(CH,value), mark(CH,tick).
violation(CH,value_rect) :- chart(CH), task(CH,value), mark(CH,rect).

violation(CH,summary_point) :- chart(CH), task(CH,summary), mark(CH,point).
violation(CH,summary_bar) :- chart(CH), task(CH,summary), mark(CH,bar).
violation(CH,summary_line) :- chart(CH), task(CH,summary), mark(CH,line).
violation(CH,summary_area) :- chart(CH), task(CH,summary), mark(CH,area).
violation(CH,summary_text) :- chart(CH), task(CH,summary), mark(CH,text).
violation(CH,summary_tick) :- chart(CH), task(CH,summary), mark(CH,tick).
violation(CH,summary_rect) :- chart(CH), task(CH,summary), mark(CH,rect).


% === Task - channel correlations ===

violation(CH,value_continuous_x,E) :- chart(CH), task(CH,value), channel(CH,E,x), continuous(CH,E), enc_interesting(CH,E).
violation(CH,value_continuous_y,E) :- chart(CH), task(CH,value), channel(CH,E,y), continuous(CH,E), enc_interesting(CH,E).
violation(CH,value_continuous_color,E) :- chart(CH), task(CH,value), channel(CH,E,color), continuous(CH,E), enc_interesting(CH,E).
violation(CH,value_continuous_size,E) :- chart(CH), task(CH,value), channel(CH,E,size), continuous(CH,E), enc_interesting(CH,E).
violation(CH,value_continuous_text,E) :- chart(CH), task(CH,value), channel(CH,E,text), continuous(CH,E), enc_interesting(CH,E).

violation(CH,value_discrete_x,E) :- chart(CH), task(CH,value), channel(CH,E,x), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_y,E) :- chart(CH), task(CH,value), channel(CH,E,y), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_color,E) :- chart(CH), task(CH,value), channel(CH,E,color), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_shape,E) :- chart(CH), task(CH,value), channel(CH,E,shape), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_size,E) :- chart(CH), task(CH,value), channel(CH,E,size), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_text,E) :- chart(CH), task(CH,value), channel(CH,E,text), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_row,E) :- chart(CH), task(CH,value), channel(CH,E,row), discrete(CH,E), enc_interesting(CH,E).
violation(CH,value_discrete_column,E) :- chart(CH), task(CH,value), channel(CH,E,column), discrete(CH,E), enc_interesting(CH,E).

violation(CH,summary_continuous_x,E) :- chart(CH), task(CH,summary), channel(CH,E,x), continuous(CH,E), enc_interesting(CH,E).
violation(CH,summary_continuous_y,E) :- chart(CH), task(CH,summary), channel(CH,E,y), continuous(CH,E), enc_interesting(CH,E).
violation(CH,summary_continuous_color,E) :- chart(CH), task(CH,summary), channel(CH,E,color), continuous(CH,E), enc_interesting(CH,E).
violation(CH,summary_continuous_size,E) :- chart(CH), task(CH,summary), channel(CH,E,size), continuous(CH,E), enc_interesting(CH,E).
violation(CH,summary_continuous_text,E) :- chart(CH), task(CH,summary), channel(CH,E,text), continuous(CH,E), enc_interesting(CH,E).

violation(CH,summary_discrete_x,E) :- chart(CH), task(CH,summary), channel(CH,E,x), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_y,E) :- chart(CH), task(CH,summary), channel(CH,E,y), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_color,E) :- chart(CH), task(CH,summary), channel(CH,E,color), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_shape,E) :- chart(CH), task(CH,summary), channel(CH,E,shape), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_size,E) :- chart(CH), task(CH,summary), channel(CH,E,size), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_text,E) :- chart(CH), task(CH,summary), channel(CH,E,text), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_row,E) :- chart(CH), task(CH,summary), channel(CH,E,row), discrete(CH,E), enc_interesting(CH,E).
violation(CH,summary_discrete_column,E) :- chart(CH), task(CH,summary), channel(CH,E,column), discrete(CH,E), enc_interesting(CH,E).
