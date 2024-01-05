# Set the directory containing your Rmd files
rmd_dir <- "./"

# Function to extract libraries from a single Rmd file
extract_libraries <- function(file_path) {
    lines <- readLines(file_path, warn = FALSE)
    library_lines <- grep("^(library|require)\\(", lines, value = TRUE)
    package_names <- gsub("^(library|require)\\((.*)\\).*", "\\2", library_lines)
    package_names <- gsub("[[:punct:][:space:]]", "", package_names)
    return(unique(package_names))
}

# List all Rmd files
rmd_files <- list.files(rmd_dir, pattern = "\\.Rmd$", full.names = TRUE)

# Loop over Rmd files and extract libraries
all_libraries <- unlist(lapply(rmd_files, extract_libraries))

# Get unique libraries used across all files
unique_libraries <- unique(all_libraries)

# Print the libraries
print(sort(unique_libraries))
