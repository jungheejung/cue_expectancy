#' Apply a large text theme to a ggplot object
#'
#' This function takes a ggplot object and applies a theme that sets the text size and the subtitle size
#' with default values that can be customized.
#'
#' @param ggplot_obj A ggplot object to which the theme should be applied.
#' @param text_size Size of the main text elements in the plot; default is 15.
#' @param subtitle_size Size of the subtitle text elements in the plot; default is 11.
#' @return A ggplot object with the updated theme.
#' @examples
#' # Apply the custom theme with default sizes
#' my_ggplot <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
#' my_ggplot <- plot_largetext(my_ggplot)
#'
#' # Apply the custom theme with specified text and subtitle sizes
#' my_ggplot <- plot_largetext(my_ggplot, text_size = 12, subtitle_size = 9)
#' @export
#' @importFrom ggplot2 theme element_text element_blank
#' @importFrom ggtext element_textbox_simple
plot_largetext <- function(ggplot_obj, text_size = 15, subtitle_size = 11) {
  ggplot_obj <- ggplot_obj +
    theme(
      text = element_text(size = text_size),
      aspect.ratio = 1,
      axis.line = element_line(colour = "black"),
      panel.background = element_blank(),
      plot.subtitle = ggtext::element_textbox_simple(size = subtitle_size)
    )
  return(ggplot_obj)
}
