read.transfac <- function(file) {
  matrices = list()
  lines = readLines(file)
  count.matrix = numeric()
  read = F
  first = T
  id = NULL
  accession = NULL
  for (line in lines) {
    if (substr(line, 1, 2) == "ID") {
      id = gsub("\\s", "", substr(line, 3, nchar(line)))
    }
    if (substr(line, 1, 2) == "AC") {
      if (!first) {
        attr(count.matrix, "id") = id
        attr(count.matrix, "accession") = accession
        matrices[[length(matrices) + 1]] = count.matrix
      } else {
        first = F
      }
      accession = gsub("\\s", "", substr(line, 3, nchar(line)))
    }
    if (read) {
      if (substr(line, 1, 2) == "XX") {
        read = F
      } else {
        items = strsplit(line, "\\s+")[[1]]
        count.matrix = cbind(count.matrix, as.numeric(items[2:5]))
        rownames(count.matrix) = c("A", "C", "G", "T")
      }      
    }
    if (substr(line, 1, 2) == "P0") {
      read = T
    }
  }
  # append last matrix
  attr(count.matrix, "id") = id
  attr(count.matrix, "accession") = accession
  matrices[[length(matrices) + 1]] = count.matrix
  names(matrices) = sapply(matrices, attr, "id")
  return(matrices)
}
