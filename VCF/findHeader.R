findHeader <- function(inputFile){
	con  <- file(inputFile, open = "r")
	cnt = 0
	while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
	    if (substr(oneLine,1,1)=='#'){
			cnt = cnt + 1
		}else{
			break
		}
	}
	close(con)
	return(cnt)
}

