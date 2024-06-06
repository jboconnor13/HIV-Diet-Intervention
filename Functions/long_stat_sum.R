###This function provides comprehensive longitudinal mxed effects modelling on subsets of a dataset 
long_stat_sum <- function(data, subs_vars, tm_var, dep_vars, rand_var, normality) {
  library(lme4)
  library(lmerTest)
  library(afex)
  #long_stat_sum(clr_meta, c("MSMHIVGroup","Diet"),"Timepoint",mb_vars,"StudyID", TRUE)
#  data <- clr_meta
#  subs_vars <- c("MSMHIVGroup","Diet")
#  tm_var <- "Timepoint"
#  dep_vars <- mb_vars
#  rand_var <- "StudyID"
#  normality <- TRUE
  subs_var_num <- length(subs_vars)
  dep_var_num <- length(dep_vars)
  subs_var_list <- list()
  for (j in 1:subs_var_num) {
    subs_name_j <- subs_vars[j]
    subs_vals_j <- as.vector(unique(data[,which(colnames(data)==subs_name_j)]))
    subs_var_list[[subs_name_j]] <- subs_vals_j
  }
  tm_vals <- unlist(as.vector(unique(data[,which(colnames(data)==tm_var)])))
  tm_combs <- combn(tm_vals, 2, simplify = FALSE)
  tm_strings <- sapply(tm_combs, function(x) paste(x, collapse = "-"))
  subs_var_list[["combo"]] <- tm_strings
  
  stats_sum_table_base <- c() 
  for (k in 1:dep_var_num){
    dep_unit <- expand.grid(subs_var_list)
    stats_sum_table_base_k <- cbind(rep(dep_vars[k], nrow(dep_unit)),dep_unit)
    colnames(stats_sum_table_base_k)[1] <- "Measure"
    stats_sum_table_base <- rbind(stats_sum_table_base,stats_sum_table_base_k)
  }
  stats_sum_table <- cbind(stats_sum_table_base, matrix(NA,nrow(stats_sum_table_base),4))
  colnames(stats_sum_table)[(ncol(stats_sum_table_base)+1):ncol(stats_sum_table)] <- c("group1", "group2","p-value", "p.signif")
  for (r in 1:nrow(stats_sum_table)) {
    time_combs <- strsplit(as.character(stats_sum_table$combo[r]),split="-")
    stats_sum_table$group1[r] <- time_combs[[1]][1]
    stats_sum_table$group2[r] <- time_combs[[1]][2]
    #Edit on 11-09-23 to work around NA values 
    if (!is.na(stats_sum_table$Measure[r])) {
      meas_col <- which(colnames(data)==stats_sum_table$Measure[r])  
    } else {
      meas_col <- which(is.na(colnames(data)))  
    }
    time_col <- which(colnames(data)==tm_var)
    rand_col <- which(colnames(data)==rand_var)
    data_time <- unlist(data[,time_col])
    for (l in 1:length(data_time)) {
      data_time[l] <- as.character(unlist(data_time[l]))
    }
    which_rows <- which(as.vector(data_time) %in% c(time_combs[[1]][1], time_combs[[1]][2]) & !is.na(as.numeric(unlist(data[,meas_col]))))
    for (p in 2:(ncol(stats_sum_table_base)-1)) {
      data_p <- as.data.frame(data[,which(colnames(data)==colnames(stats_sum_table)[p])])
      which_rows_p <- which(data_p==as.character(stats_sum_table[r,p]))
      which_rows <- intersect(which_rows,which_rows_p)
    }
    ##Edit on 10-31-22 to only perform longitudinal statistics on samples with two values (both timepoints)
    data_r_pre <- as.data.frame(data[which_rows,c(meas_col, time_col, rand_col)])
    colnames(data_r_pre) <- c("Amount", "Time", "ID")
    data_r <- data_r_pre %>%
      group_by(ID) %>%
      filter(n() > 1) %>%
      ungroup()
    colnames(data_r) <- c("Amount", "Time", "ID")
    data_r$Amount <- as.numeric(data_r$Amount)
    if (nrow(data_r)>4) {
      if (normality==TRUE) {
        stat_test_r <- lmer(Amount ~ Time + (1 | ID), data = data_r)
        stat_mixed_r <- mixed(stat_test_r, data=data_r)
        stat_sum_r <- summary(stat_mixed_r)
        stats_sum_table$`p-value`[r] <- stat_sum_r$coefficients[2,5]
      } else {
        data_wide <- dcast(data_r, ID ~ Time, value.var = "Amount")
        data_wide_filt <- data_wide[which(!is.na(data_wide[,2]) & !is.na(data_wide[,3])),]
        data_r_filt <- data_r[which(data_r$ID %in% data_wide_filt$ID),]
        stat_test_r <- friedman.test(Amount ~ Time | ID, data = data_r_filt)
        stats_sum_table$`p-value`[r] <- stat_test_r$p.value
      }
      stats_sum_table$`p-value`[r] <- as.numeric(stats_sum_table$`p-value`[r])
      if (stats_sum_table$`p-value`[r] < 0.001) {
        stats_sum_table$p.signif[r] <- "***"
      } else if (stats_sum_table$`p-value`[r] < 0.01) {
        stats_sum_table$p.signif[r] <- "**"
      } else if (stats_sum_table$`p-value`[r] < 0.05) {
        stats_sum_table$p.signif[r] <- "*"
      } else {
        stats_sum_table$p.signif[r] <- "ns"
      }  
    } else {
      stats_sum_table$`p-value`[r] <- NA
      stats_sum_table$p.signif[r] <- "ns"
    }
  }
  #remove combo 
  stats_sum_table_final <- stats_sum_table[,which(colnames(stats_sum_table)!="combo")]
  return(stats_sum_table_final)
} 