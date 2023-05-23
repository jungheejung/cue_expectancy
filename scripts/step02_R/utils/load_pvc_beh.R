load_pvc_beh <- function(datadir, subject_varkey, iv, dv, exclude) {
p.df <- load_task_social_df(datadir, taskname = "pain", subject_varkey, iv, dv, exclude)
v.df <- load_task_social_df(datadir, taskname = "vicarious", subject_varkey, iv, dv, exclude)
c.df <- load_task_social_df(datadir, taskname = "cognitive", subject_varkey, iv, dv, exclude)

p.df2= p.df %>%
  arrange(src_subject_id) %>%
  group_by(src_subject_id) %>%
  mutate(trial_index = row_number())
data_p <- p.df2 %>%
  group_by(src_subject_id, session_id, param_run_num) %>%
  mutate(trial_index = row_number(param_run_num))

v.df2 <- v.df %>%
  arrange(src_subject_id ) %>%
  group_by(src_subject_id) %>%
  mutate(trial_index = row_number())
data_v <- v.df2 %>%
  group_by(src_subject_id, session_id, param_run_num) %>%
  mutate(trial_index = row_number(param_run_num))

c.df2 <- c.df %>%
  arrange(src_subject_id) %>%
  group_by(src_subject_id) %>%
  mutate(trial_index = row_number() - 1)
data_c <- c.df2 %>%
  group_by(src_subject_id, session_id, param_run_num) %>%
  mutate(trial_index = row_number(param_run_num))
p.sub <- data_p[,c("src_subject_id", "session_id", "param_run_num", "param_task_name", "event02_expect_angle", "param_cue_type", "param_stimulus_type", "event04_actual_angle", "trial_index")]
v.sub <- data_v[,c("src_subject_id", "session_id", "param_run_num", "param_task_name", "event02_expect_angle", "param_cue_type", "param_stimulus_type", "event04_actual_angle", "trial_index")]
c.sub <- data_c[,c("src_subject_id", "session_id", "param_run_num", "param_task_name", "event02_expect_angle", "param_cue_type", "param_stimulus_type", "event04_actual_angle", "trial_index")]
# sub, ses, run, runtype, event, trial, cuetype, stimintensity
# src_subject_id, session_id, param_run_num, param_task_name, event02_expect_angle, param_cue_type, param_stimulus_type, event04_actual_angle
pvc.sub <- rbind(p.sub, v.sub, c.sub)

pvc.sub$trial_ind <- pvc.sub$trial_index - 1
pvc.sub$sub <- sprintf("sub-%04d", pvc.sub$src_subject_id)
pvc.sub$ses <- sprintf("ses-%02d", pvc.sub$session_id)
pvc.sub$run <- sprintf("run-%02d", pvc.sub$param_run_num)
pvc.sub$runtype <- sprintf("runtype-%s", pvc.sub$param_task_name)
pvc.sub$task <- sprintf("%s", pvc.sub$param_task_name)
pvc.sub$trial <- sprintf("trial-%03d", pvc.sub$trial_ind)
pvc.sub[c('cue', 'DEPc')]  <- str_split_fixed(pvc.sub$param_cue_type, '_', 2)
pvc.sub$cuetype <- sprintf("cuetype-%s", pvc.sub$cue)
pvc.sub[c('stimintensity', 'DEP')]  <- str_split_fixed(pvc.sub$param_stimulus_type, '_', 2)

return(pvc.sub)
}