calculate_font_sizes <- function(font_size_base_dict, figure_width, figure_height, base_size = 10) {
    #' Calculate Font Sizes Proportionally
    #'
    #' This function calculates font sizes proportionally based on a dictionary of font size bases
    #' and figure dimensions (width and height). It can be used to adjust font sizes in plots
    #' to maintain proportionality with varying figure sizes.
    #'
    #' @param font_size_base_dict A named list specifying font size base values for different elements.
    #'                            The names in the list correspond to elements in the plot, and the
    #'                            values represent the base font sizes.
    #' @param figure_width The width of the figure in which the font sizes need to be adjusted.
    #' @param figure_height The height of the figure in which the font sizes need to be adjusted.
    #'
    #' @return A list of calculated font sizes, with names corresponding to the elements in the
    #'         font_size_base_dict.
    #'
    #' @examples
    #' # Define your font size base dictionary
    #' font_size_base_dict <- list(
    #'   AXIS_FONTSIZE_BASE = 10,
    #'   COMMONAXIS_FONTSIZE_BASE = 15,
    #'   TITLE_FONTSIZE_BASE = 20
    #' )
    #'
    #' # Define your figure dimensions (width and height)
    #' figure_width <- 12
    #' figure_height <- 8
    #'
    #' # Calculate the font sizes using the function
    #' font_sizes <- calculate_font_sizes(font_size_base_dict, figure_width, figure_height)
    #'
    #' # Access the font sizes as needed
    #' AXIS_FONTSIZE <- font_sizes$AXIS_FONTSIZE_BASE
    #' COMMONAXIS_FONTSIZE <- font_sizes$COMMONAXIS_FONTSIZE_BASE
    #' TITLE_FONTSIZE <- font_sizes$TITLE_FONTSIZE_BASE
    #'
    #' # Apply the font sizes to your plot elements
    #' plot +
    #'   theme(
    #'     axis.text.x = element_text(size = AXIS_FONTSIZE),
    #'     axis.text.y = element_text(size = AXIS_FONTSIZE),
    #'     axis.title.x = element_text(size = AXIS_FONTSIZE),
    #'     axis.title.y = element_text(size = AXIS_FONTSIZE),
    #'     plot.title = element_text(size = TITLE_FONTSIZE),
    #'     plot.subtitle = element_text(size = TITLE_FONTSIZE),
    #'     plot.caption = element_text(size = COMMONAXIS_FONTSIZE),
    #'     legend.text = element_text(size = COMMONAXIS_FONTSIZE)
    #'   )
    #'
    #' @export
#     scaling_factor <- base_size / max(figure_width, figure_height) 

#     font_sizes <- lapply(font_size_base_dict, function(base_size) {
#         new_size <- base_size * scaling_factor
#         return(new_size)
#     })

#     return(font_sizes)
# }


  base_scaling_factor <- 10 / max(figure_width, figure_height)
  
  scaled_font_sizes <- sapply(font_size_base_dict, function(base_size) {
    scaled_size <- base_size * base_scaling_factor
    return(scaled_size)
  })
  
  return(scaled_font_sizes)
}

# font_size_base_dict <- list(
#   AXIS_FONTSIZE_BASE = 10,
#   COMMONAXIS_FONTSIZE_BASE = 15,
#   TITLE_FONTSIZE_BASE = 20
# )
