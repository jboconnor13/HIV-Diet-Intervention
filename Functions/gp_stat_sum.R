###This function provides comprehensive group statistics on subsets of a dataset at different timepoints
gp_stat_sum <- function(data, tm_var, dep_vars, gp_var, normality) {
  tm_vals <- as.vector(unique(data[,which(colnames(data)==tm_var)]))
  gp_vals <- as.vector(unique(data[,which(colnames(data)==gp_var)]))
  stats_sum_table_base <- expand.grid(dep_vars,tm_vals)
  stats_sum_table <- cbind(stats_sum_table_base, matrix(NA,nrow(stats_sum_table_base),4))
  colnames(stats_sum_table) <- c("Measure",tm_var,"group1", "group2","p-value", "p.signif")
  gp_col <- which(colnames(data)==gp_var) 
  tm_col <- which(colnames(data)==tm_var)
  for (r in 1:nrow(stats_sum_table)) {
    stats_sum_table$group1[r] <- gp_vals[1]
    stats_sum_table$group2[r] <- gp_vals[2]
    dep_col <- which(colnames(data)==stats_sum_table$Measure[r])
    which_rows <- which(as.character(data[,tm_col])==as.character(stats_sum_table[r,2]) & !is.na(as.numeric(data[,dep_col])))
    data_r <- data[which_rows,c(gp_col,tm_col,dep_col)]
    colnames(data_r) <- c("Group","Time","Amount")
    data_r$Amount <- as.numeric(data_r$Amount)
    if (nrow(data_r)>4) {
      if (normality==TRUE) {
        stat_test_r <- lm(Amount~Group, data=data_r)
        anova_r <- anova(stat_test_r)
        stats_sum_table$`p-value`[r] <- anova_r$`Pr(>F)`[1]
      } else {
        stat_test_r <- wilcox.test(Amount~Group, data=data_r)
        stats_sum_table$`p-value`[r] <- stat_test_r$p.value
      }
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
  return(stats_sum_table)
} 