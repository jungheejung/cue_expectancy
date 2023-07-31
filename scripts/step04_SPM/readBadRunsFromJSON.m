function bad_runs_table = readBadRunsFromJSON(badruns_file)
    % Read the badruns_file and construct a table with sub_num, ses_num, and run_num
    bad_runs_table = table();

    try
        fid = fopen(badruns_file);
        json_str = fread(fid, '*char').';
        fclose(fid);
        bad_runs = jsondecode(json_str);
        
        subjects = fieldnames(bad_runs);
        num_subjects = numel(subjects);

        % Loop through each subject and their corresponding bad runs
        for i = 1:num_subjects
            sub = subjects{i};
            bad_run_list = bad_runs.(sub);
            num_bad_runs = numel(bad_run_list);
            sub_num = str2double(regexp(sub, '\d+', 'match'));
            % Extract the sub_num, ses_num, and run_num from each bad run
            for j = 1:num_bad_runs
                ses_num = str2double(extractBetween(bad_run_list{j}, 'ses-', '_run-'));
                run_num = str2double(regexp(bad_run_list{j}, 'run-(\d+)', 'tokens', 'once'));%extractBetween(bad_run_list{j}, 'ses-', '_run-');
%                 ses_num = str2double(run_info{1});
%                 run_num = str2double(run_info{2});

                % Append the data to the table
                new_row = table(sub_num, ses_num, run_num, 'VariableNames', {'sub_num', 'ses_num', 'run_num'});
                bad_runs_table = [bad_runs_table; new_row];
            end
        end

    catch
        disp('Error reading badruns JSON file.');
    end
end
