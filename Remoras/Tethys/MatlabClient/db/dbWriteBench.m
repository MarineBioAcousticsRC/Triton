function dbWriteBench(output, q_elapsed, p_elapsed, query, count)
% dbWriteBench(dir, q_elapsed, p_elapsed, query, count)
% output - directory to write benchmarks, must exist & accessible
%  if empty, writes to stdout
% q_elapsed - time to prepare and run query
% p_elapsed - time parse query result
% count - Number of items processed

to_file = ~ isempty(output); %if no dir specified, send to stdout

timestamp = datetime();
t_elapsed = q_elapsed + p_elapsed;
t_per_count = t_elapsed / (count/1000);
bench_str = sprintf('%s: Query\n%s\nTotal / Query / Parse / Rate_per_1K_Items\n%s, %s, %s, %s\n', ...
    timestamp, query, t_elapsed, q_elapsed, p_elapsed, t_per_count);


if isempty(to_file)
    bench_file = fullfile(bench_path,...
        sprintf('%s_detections_w.txt',datestr(now(),'yyyy-mm-dd')));
    bench_fid=fopen(bench_file,'at');
    summary_file=(fullfile(bench_path,'1detection_summary_w.txt'));
    summ_fid = fopen(summary_file,'at');

    fprintf(bench_fid,bench_str);
    fprintf(summ_fid,summ_str);
    fclose(bench_fid);
    fclose(summ_fid);
else
   fprintf(bench_str);
end
    