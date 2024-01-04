library(rmarkdown)

# Set the directory containing Rmd files
rmd_dir <- "scripts/step02_R_bookdown"
setwd(rmd_dir)

# List all Rmd files
rmd_files <- list.files(pattern = "\\.Rmd$", full.names = TRUE)

# Function to render a single file
render_rmd <- function(file) {
  tryCatch({
    render(file)
    cat("Successfully rendered:", file, "\n")
  }, error = function(e) {
    cat("Error rendering", file, ":", e$message, "\n")
  })
}

# Loop over Rmd files and render each
for (file in rmd_files) {
  render_rmd(file)
}
