df_filtered <- data %>% 
group_by(KEY) %>%
filter(n() > NTRIALS) %>%
ungroup() 