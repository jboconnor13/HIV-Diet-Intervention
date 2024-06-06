###This function generates a list of variables with "Other" for those that are either infrequent or low in abundance 
other_generater <- function(data, name_field, type, threshold, abundance_field="Abundance", id_var="Sample") {
library(dplyr)
data_temp <- data[,which(colnames(data) %in% c(name_field, abundance_field))]
  if (type=="Max Abundance") {
    max_data_temp <- data_temp %>%
      group_by(get(name_field)) %>%
      summarize(max = max(get(abundance_field)))
    names_inc <- max_data_temp$`get(name_field)`[which(max_data_temp$max>threshold)]
  }
  if (type=="Frequency") {
    freq_data_temp <-as.data.frame(table(data_temp[which(colnames(data_temp)==name_field)]))
    names_inc <- freq_data_temp[which(freq_data_temp$Freq>threshold),1]
  }
  if (type=="Percentage") {
    id_num <- length(unique(data[,which(colnames(data)==id_var)]))
    freq_data_temp <-as.data.frame(table(data_temp[which(colnames(data_temp)==name_field)]))
    names_inc <- freq_data_temp[which((freq_data_temp$Freq/id_num)>threshold),1]
  }
  new_varnames <- c()
  for (k in 1:nrow(data)) {
    old_varname_k <- data[k,which(colnames(data)==name_field)]
    if (old_varname_k %in% names_inc) {
      new_varnames <- rbind(new_varnames,old_varname_k)
    } else {
      new_varnames <- rbind(new_varnames,"Other")
    }
  }
  return(new_varnames)
} 