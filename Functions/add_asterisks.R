###This function just adds asterisks of significance based on p-value 
add_asterisks <- function(p_values) {
  asterisks <- character(length(p_values))  # Initialize an empty character vector
  
  for (i in seq_along(p_values)) {
    if (p_values[i] < 0.001) {
      asterisks[i] <- "***"
    } else if (p_values[i] < 0.01) {
      asterisks[i] <- "**"
    } else if (p_values[i] < 0.05) {
      asterisks[i] <- "*"
    } else {
      asterisks[i] <- "ns"
    }
  }
  
  return(asterisks)
} 
