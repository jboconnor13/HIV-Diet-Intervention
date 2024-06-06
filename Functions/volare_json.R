###This function generates a json file
volare_json <- function(data, data_results, outcome) {
  test_colors <- c("#A1DAB4","#41B6C4","#2C7FB8","#253494", "#E7298A")
  data <- all_data_delta
  data_results <- nt_mb_lm
  outcome <- "Diet"
  data_results_filt <- data_results[which(data_results$Outcome==outcome),]
  for (j in 2:5) {
    data_results_filt[,j] <- as.character(data_results_filt[,j])
  } 
  for (k in 6:8) {
    data_results_filt[,k] <- as.numeric(data_results_filt[,k])
  }
  data_results_filt <- data_results_filt[,c(1,2,3,4,6,8)]
  colnames(data_results_filt) <- c("key", "Assays", "Analyte1", "Analyte2", "F", 'pAdj')
  data_results_filt <- data_results_filt[which(data_results_filt$pAdj<0.2),]
  outcome_vals <- unique(data[,which(colnames(data)==outcome)])
  #detail_data <- data[,which(colnames(data) %in% c("StudyID",outcome,as.character(data_results_filt$Analyte1),as.character(data_results_filt$Analyte2)))]
  assays_tog <- unique(data_results$Assays)
  assays_split <- unlist(strsplit(assays_tog, "\\.(?=[^.]*$)", perl = TRUE))
  assays_data <- as.data.frame(t(test_colors[1:length(assays_split)]))
  colnames(assays_data) <- paste0(assays_split,"_")
  #colnames(detail_data)[1:2] <- c("PID", "Cohort")
  summary_test <- as.list(data_results_filt)
  setwd("/Users/johnoconnor/HIVStudy/R_Analysis/Volare")
  json_test <- fromJSON("bloodforVolaremanualedit.json")
  summary_test[["mPlot"]]<-json_test[["summary"]][["mPlot"]]
  #detail_test <- detail_data
  for (j in data_results_filt$Key) {
    detail_test[paste0("infl_",j)] <- "NA"
  }
  json_out <- list(
    configuration=list(assayAware="true",
                       assays=as.list(assays_data),
                       influenceAware="true",
                       cohort=outcome_vals,
                       colors=c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"),
                       statement=paste0("Analysis of data with ", outcome, " outcome")
                       ),
    statement=paste0("Analysis of data with ", outcome, " outcome"),
    config=outcome_vals,
    colors=c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"),
    summary=summary_test#,
  #  detail=as.list(detail_test)
  )
} 
