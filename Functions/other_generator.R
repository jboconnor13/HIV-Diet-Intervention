###This function generates a list of variables with "Other" for those that are either infrequent or low in abundance 
other_generator <- function(data, name_field, type, threshold, abundance_field="Abundance", id_var="Sample") {
library(dplyr)
#data=SEQ010_met
#name_field="Genus"
#type="Top Average"
#threshold=50
#abundance_field="Abundance"
#id_var="SampleID"
nm_col <- which(colnames(data)==name_field)
ab_col <- which(colnames(data)==abundance_field)
id_col <- which(colnames(data)==id_var)
data_temp <- data[,c(id_col,nm_col,ab_col)]

  if (type=="Max Abundance") {
    max_data_temp <- data_temp %>%
      group_by(get(name_field)) %>%
      summarize(max = max(as.numeric(get(abundance_field))))
    names_inc <- max_data_temp$`get(name_field)`[which(as.numeric(max_data_temp$max)>threshold)]
  }
  if (type=="Top Average") {
    max_data_temp <- data_temp %>%
      group_by(get(name_field)) %>%
      summarize(avg = mean(as.numeric(get(abundance_field)))) %>%
      arrange(desc(avg))
    names_inc <- max_data_temp$`get(name_field)`[1:threshold]
  }
  if (type=="Top Max") {
    max_data_temp <- data_temp %>%
      group_by(get(name_field)) %>%
      summarize(max = max(as.numeric(get(abundance_field)))) %>%
      arrange(desc(max))
    names_inc <- max_data_temp$`get(name_field)`[1:threshold]
  }
  if (type=="Max Percent Abundance") {
    colnames(data_temp) <- c("id","nm","ab")
    max_data_temp <- data_temp
    max_data_temp["perc"] <- NA
    for (l in 1:nrow(max_data_temp)) {
      stud_l <- max_data_temp[l,1]
      sum_l <- sum(as.numeric(max_data_temp[which(as.vector(max_data_temp$id)==stud_l),3]))
      max_data_temp$perc <- as.numeric(max_data_temp$ab)/as.numeric(sum_l)
    }
    names_inc <- max_data_temp$nm[which(as.numeric(max_data_temp$perc)>threshold)]
  }
  if (type=="Frequency") {
    freq_data_temp_1 <-as.data.frame(table(data[which(colnames(data) %in% c(name_field, id_var))]))
    freq_data_temp_2 <- freq_data_temp_1[which(freq_data_temp_1$Freq>0),]
    freq_data_temp<- as.data.frame(table(freq_data_temp_2[,which(colnames(freq_data_temp_2) %in% c(name_field))]))
    names_inc <- freq_data_temp[which(as.numeric(freq_data_temp$Freq)>threshold),1]
  }
  if (type=="Percentage") {
    id_num <- length(unique(data[,which(colnames(data)==id_var)]))
    freq_data_temp_1 <-as.data.frame(table(data[which(colnames(data) %in% c(name_field, id_var))]))
    freq_data_temp_2 <- freq_data_temp_1[which(freq_data_temp_1$Freq>0),]
    freq_data_temp<- as.data.frame(table(freq_data_temp_2[,which(colnames(freq_data_temp_2) %in% c(name_field))]))
    names_inc <- freq_data_temp[which(as.numeric(freq_data_temp$Freq/id_num)>threshold),1]
  }
#  new_varnames <- c()
#  for (k in 1:nrow(data)) {
#    start_time <- Sys.time() 
#    old_varname_k <- data[k,which(colnames(data)==name_field)]
#    if (old_varname_k %in% names_inc) {
#      new_varnames <- rbind(new_varnames,as.character(old_varname_k))
#    } else {
#      new_varnames <- rbind(new_varnames,"Other")
#    }
#    end_time <- Sys.time()
#    left <- nrow(data)-k
#    time_left <- left*(as.numeric(end_time)-as.numeric(start_time))
#    print(paste0("Completed ",k, '/',nrow(data)))
#    print(paste0("Estimated Time Remaining ", round(time_left/60,0), " minutes and ",(time_left%%60)," seconds"))
#  }
  new_varnames <- as.data.frame(matrix("Other",nrow(data),1))
  data_var <- data
  colnames(data_var)[which(colnames(data_var)==name_field)] <- "Test_Group_Other"
  non_other_ind <- which(data_var$Test_Group_Other %in% names_inc)
  other_ind <- setdiff(1:nrow(data), non_other_ind)
  new_varnames$V1[non_other_ind] <- data_var$Test_Group_Other[non_other_ind]

  return(new_varnames)
} 
