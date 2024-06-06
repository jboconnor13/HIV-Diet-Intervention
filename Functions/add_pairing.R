###This function specifies a pairing field 
add_pairing <- function(study_ids) {
  pairing <- character(length(study_ids))  # Initialize an empty character vector
  un_ids <- unique(study_ids)
  for (i in seq_along(study_ids)) {
    pairing[i] <- as.numeric(which(un_ids==study_ids[i]))
  }
  return(as.numeric(pairing))
} 