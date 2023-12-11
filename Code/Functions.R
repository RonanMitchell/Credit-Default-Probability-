###

PreGraphs <- function(x, y) {
  
  ggplot(
    data = Data,
    aes(x = {{x}}, fill = {{y}})) +
    geom_bar(position = "fill") +
    th2
  
}

###

PreScatter <- function(x, y, xname, yname) {
  ggplot(Data, aes(x = {{x}}, y = {{y}})) +
    geom_point(shape = 16, color = "pink", alpha = 0.5, size = 2.5) +
    geom_point(shape = 16, color = "maroon", alpha = 0.1, size = 0.5) +
    labs(x = xname, y = yname) +
    geom_smooth(method = "lm", 
                se = FALSE, 
                colour = "white",
                linewidth = 0.5) +
    th2
}

###

Ridge <- function(x, xname){
  
  ggplot({{x}}, aes(x = Amounts, y = Month, fill = Month)) +
    geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
    scale_fill_viridis(name = "Temp. [F]", option = "C", discrete = TRUE) +
    labs(title = xname) +
    xlim(0, 15000) +
    th1
  
}

###

BoxPlot <- function(data, x, y, xname, yname, title ) {
  
  ggplot({{data}}, 
         aes(x = {{x}}, 
             y = {{y}})) +
    geom_boxplot(fill = "pink", 
                 color = "maroon",
                 outlier.shape = 16, 
                 outlier.color = "maroon4") +
    geom_hline(yintercept =  166149.3, 
               linetype = "dotted", 
               color = "white",
               size = 0.6) +
    labs(x = xname, 
         y = yname) +
    ggtitle(title) + 
    th1
  
}

###

Heat <- function(x, xname) {
  
  ggplot(TestScatter, 
         aes(x = {{x}}, 
             y = PredForPlot) ) +
    geom_hex(bins = 30, 
             colour = NA) +
    scale_fill_gradient(low = "#000033", 
                        high = "purple") +
    labs(x = xname, 
         y = "") +
    th1 
  
}