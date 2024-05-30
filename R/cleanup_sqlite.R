cleanup_sqlite <- function(db="grts.sqlite"){
  unlink(db, 
         recursive = TRUE,
         force = TRUE)
  
  file.remove(db)
}