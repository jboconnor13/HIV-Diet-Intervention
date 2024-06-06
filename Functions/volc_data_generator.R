####Volcano plot data generator 

volc_data_generator <- function(data, var_names, sep_field, paired, normality, id_var="StudyID", upfield="XXXXX") {
#  data=bd_all_proc_imp_msm_1
#  var_names=origcol
#  sep_field="HIV"
#  paired=FALSE
#  normality=TRUE
#  id_var="StudyID"
#  upfield="HIV-Positive"
  volc_data <- as.data.frame(var_names)
  volc_data["p-value"] <- NA
#  volc_data["significance"] <- ""
#  volc_data["significance_label"] <- ""
  volc_data["padj"] <- NA
  volc_data["mean_diff"] <- NA
  volc_data["mean_fc"] <- NA
  volc_data["mean_log2_fc"] <- NA
  
  id_col <- which(colnames(data)==id_var)
  sep_col <- which(colnames(data)==sep_field)
  sep_vals <- unique(data[which(!is.na(data[,sep_col])),sep_col])
  data_temp_ids <- unique(data[,id_col])
  for (j in 1:nrow(volc_data)) {
    var_j <- volc_data[j,1]
    var_col_j <- which(colnames(data)==var_j)
    data_all_j <- data[,c(id_col, sep_col, var_col_j)]
    colnames(data_all_j) <- c("id", "sep", "var")
    data_temp_j <- cbind(data_temp_ids, rep(NA, length(data_temp_ids)),  rep(NA, length(data_temp_ids)))
    colnames(data_temp_j)[1] <- id_var
    if (is.list(sep_vals)) {
      colnames(data_temp_j)[2] <- sep_vals[[1]][1]
      colnames(data_temp_j)[3] <- sep_vals[[1]][2]  
    } else {
      colnames(data_temp_j)[2] <- sep_vals[1]
      colnames(data_temp_j)[3] <- sep_vals[2]  
    }
    
    for (r in 1:nrow(data_temp_j)) {
      study_j_r <- data_temp_j[r,1]
      data_j_r_1 <- as.numeric(data_all_j$var[which(data_all_j$id==study_j_r & data_all_j$sep==colnames(data_temp_j)[2])])
      if(length(data_j_r_1)==1) {
        data_temp_j[r,2] <- data_j_r_1
      }      
      data_j_r_2 <- as.numeric(data_all_j$var[which(data_all_j$id==study_j_r & data_all_j$sep==colnames(data_temp_j)[3])]) 
      if(length(data_j_r_2)==1) {
        data_temp_j[r,3] <- data_j_r_2
      }
    }
    data_temp_j <- as.data.frame(data_temp_j)
    data_temp_j[,2] <- as.numeric(data_temp_j[,2])
    data_temp_j[,3] <- as.numeric(data_temp_j[,3])
    if (upfield!="XXXXX") {
      upcol_j <- which(colnames(data_temp_j)==upfield)
      dncol_j <- which(colnames(data_temp_j)!=upfield & colnames(data_temp_j)!=id_var)
      data_temp_j <- data_temp_j[,c(1,dncol_j, upcol_j)] 
    }
    if(paired==TRUE) {
      if (length(which(!is.na(data_temp_j[,2]) & !is.na(data_temp_j[,3])))>3 & max(abs(as.numeric(data_temp_j[,2])-as.numeric(data_temp_j[,3])), na.rm=TRUE)>0) {
        data_temp_j["diff"] <- as.numeric(data_temp_j[,3])-as.numeric(data_temp_j[,2])
        data_temp_j["fc"] <- as.numeric(data_temp_j[,3])/as.numeric(data_temp_j[,2])
        mean_diff_j <- mean(as.numeric(data_temp_j$diff), na.rm=TRUE)
        mean_fc_j <- mean(as.numeric(data_temp_j$fc), na.rm=TRUE)
        mean_log_fc_j <- log2(as.numeric(mean_fc_j))
        if (normality==TRUE) {
          test_j <- t.test(as.numeric(data_temp_j[,2]),as.numeric(data_temp_j[,3]), paired=TRUE)
        } else {
          test_j <- wilcox.test(as.numeric(data_temp_j[,2]),as.numeric(data_temp_j[,3]), paired=TRUE)
        }
        volc_data$`p-value`[j] <- as.numeric(test_j$p.value)
        volc_data$mean_diff[j] <- as.numeric(mean_diff_j)
        volc_data$mean_fc[j] <- as.numeric(mean_fc_j)
        volc_data$mean_log2_fc[j] <- as.numeric(mean_log_fc_j)   
      }
    } else {
      if (length(which(!is.na(data_temp_j[,2])))>1 & length(which(!is.na(data_temp_j[,3])))>1 & (mean(data_temp_j[,3], na.rm=TRUE)!=mean(data_temp_j[,2], na.rm=TRUE))) {
        mean_diff_j <- mean(as.numeric(data_temp_j[,3]), na.rm=TRUE)-mean(as.numeric(data_temp_j[,2]),na.rm=TRUE)
        mean_fc_j <- mean(as.numeric(data_temp_j[,3]),na.rm=TRUE) /mean(as.numeric(data_temp_j[,2]),na.rm=TRUE)
        mean_log_fc_j <- log2(as.numeric(mean_fc_j))
        if (normality==TRUE) {
          test_j <- t.test(as.numeric(data_temp_j[,2]),as.numeric(data_temp_j[,3]), paired=FALSE, na.rm=TRUE)
        } else {
          test_j <- wilcox.test(as.numeric(data_temp_j[,2]),as.numeric(data_temp_j[,3]), paired=FALSE, na.rm=TRUE)
        }
        volc_data$`p-value`[j] <- as.numeric(test_j$p.value)
        volc_data$mean_diff[j] <- as.numeric(mean_diff_j)
        volc_data$mean_fc[j] <- as.numeric(mean_fc_j)
        volc_data$mean_log2_fc[j] <- as.numeric(mean_log_fc_j) 
      }
    }
  }
  volc_data$padj <- p.adjust(volc_data$`p-value`, method="fdr")
  return(volc_data)
}

