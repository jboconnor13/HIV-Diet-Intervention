#This function generates a micrshades function
cat_color_generator <- function(data, cat_var, sub_cat_var, grp_var) {
#  data <- DM_genefamilies_fun_long_met_filt
#  cat_var <- "Top_CategoryName1"
#  sub_cat_var <- "Top_CategoryName2"
#  grp_var <- "group"
  library(microshades)
  library(colorspace)
  #All colors are generated and split by gray and non_gray colors
  all_colors <- c(microshades_palettes, microshades_cvd_palettes)
  all_names <- names(all_colors)
  g_names <- grep("gray$", names(all_colors), value = TRUE)
  ng_names <- setdiff(all_names, g_names)
  g_colors <- all_colors[g_names]
  ng_colors <- all_colors[ng_names]

  data_temp <- unique(data[,which(colnames(data) %in% c(cat_var, sub_cat_var, grp_var))])
  data_temp <- as.data.frame(data_temp)  
  data_temp["hex"] <- ""
  cats <- unique(data_temp[,which(colnames(data_temp) %in% c(cat_var))])
  data_final <- c()
  for (c in cats) {
  #  c <- "Oxidoreductases"
    data_c <- data_temp[which(as.vector(data_temp[,which(colnames(data_temp) %in% c(cat_var))])==c),] 
    if (c == "Other") {
      colors_c <- g_colors[g_names[1]]
      g_names <- g_names[-1]
      g_colors <- g_colors[g_names]
    } else {
      colors_c <- ng_colors[ng_names[1]]
      ng_names <- ng_names[-1]
      ng_colors <- ng_colors[ng_names]
    }
    data_c_other <- data_c[which(as.vector(data_c[,which(colnames(data_c) == c(sub_cat_var))])=="Other"),] 
    data_c_nother <- data_c[which(as.vector(data_c[,which(colnames(data_c) == c(sub_cat_var))])!="Other"),] 
    if (nrow(data_c_other)==1) {
      data_c_other$hex <- colors_c[[1]][1]
      data_c_nother$hex <- colorRampPalette(c(colors_c[[1]][2], colors_c[[1]][5]))(nrow(data_c_nother))
    } else {
      data_c_nother$hex <- colorRampPalette(c(colors_c[[1]][1], colors_c[[1]][5]))(nrow(data_c_nother))
    }
    data_c_add <- rbind(data_c_nother,data_c_other)
    data_final <- rbind(data_final, data_c_add)
  }
return(data_final)
}