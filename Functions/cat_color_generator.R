#This function generates a micrshades function
cat_color_generator <- function(data, cat_var, sub_cat_var, grp_var) {
#  data <- euk_met
#  cat_var <- "Top_Phylum"
#  sub_cat_var <- "Top_Genus"
#  grp_var <- "group"
  library(microshades)
  library(colorspace)
  library(RColorBrewer)
  #All colors are generated and split by gray and non_gray colors
  all_colors_base <- c(microshades_palettes, microshades_cvd_palettes)
  
  brewer_pallets <- as.data.frame(brewer.pal.info)
  cont_pallets <- rownames(brewer_pallets)[which(brewer_pallets$category=="seq")]
  all_colors <- all_colors_base
  
  for (cp in cont_pallets) {
    cp_base <- c()
    brewer_cp <-brewer.pal(5, cp)
    for (nc in 1:5) {
      col_nc <- brewer_cp[[nc]][1]
      for (jc in 1:length(all_colors)) {
        if (tolower(col_nc) %in% tolower(all_colors[[jc]])) {
          cp_base <- append(cp_base,col_nc)
        }
      }
    }
    if (length(cp_base)<1) {
      all_colors[[cp]] <- brewer.pal(5, cp) 
    }
  }
   
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
  c_g_num <- 1
  c_ng_num <- 1
  for (c in cats) {
    data_c <- data_temp[which(as.vector(data_temp[,which(colnames(data_temp) %in% c(cat_var))])==c),] 
    if (c == "Other") {
      colors_c <- g_colors[g_names[c_g_num]]
      #g_names <- g_names[-1]
      #g_colors <- g_colors[g_names]
      c_g_num <- c_g_num+1
      #c_g_num <- (c_g_num_pre %% length(g_colors)) + 1
    } else {
      colors_c <- ng_colors[ng_names[c_ng_num]]
      #ng_names <- ng_names[-1]
      #ng_colors <- ng_colors[ng_names]
      c_ng_num <- c_ng_num+1
      #c_ng_num <- (c_ng_num_pre %% length(ng_colors)) + 1
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