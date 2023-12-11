# Themes 

th1 <- theme_classic() +
  theme(
    legend.position = "none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8),
    plot.background = element_rect(fill = "#000033"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white", size = 9),
    strip.text = element_text(color = "white"),
    panel.background = element_rect(fill = "transparent"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    plot.margin = unit(c(0,0,0,0), "lines")
  )

###

th2 <-  theme_classic() +
  theme(
    legend.position = "none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8),
    plot.background = element_rect(fill = "#000033"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white", size = 9),
    strip.text = element_text(color = "white"),
    panel.background = element_rect(fill = "transparent"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.line.y = element_blank(),
    axis.text.y = element_blank())# no y axis

###

th3 <-  theme_classic() +
  theme(
    legend.position = "right",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8),
    plot.background = element_rect(fill = "#000033"),
    axis.text = element_text(color = "white"),
    axis.title = element_text(color = "white"),
    plot.title = element_text(color = "white"),
    strip.text = element_text(color = "white"),
    panel.background = element_rect(fill = "transparent"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.line.y = element_blank(),
    axis.text.y = element_blank())