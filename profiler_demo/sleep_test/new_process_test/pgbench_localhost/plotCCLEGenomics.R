library(readr)
library(dplyr)
library(ggplot2)
library(scales)
#library(reshape2)
library(extrafont)
library(magrittr)
library(data.table)

outlierReplace = function(dataframe, cols, rows, newValue = NA) {
  if (any(rows)) {
    set(dataframe, rows, cols, newValue)
  }
}
args = commandArgs(trailingOnly=TRUE)

waterfall_theme <- function(base_size = 20, base_family = "Roboto") {
  theme(
    line =               element_line(colour = "black", size = 0.5, linetype = 1,
                                      lineend = "round"),
    rect =               element_rect(fill = "white", colour = "black", size = 0.5, linetype = 1),
    text =               element_text(family = base_family, face = "plain",
                                      colour = "black", size = base_size,
                                      hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9, margin = margin(1,1,1,1), debug = FALSE),
    axis.text =          element_text(size = rel(1.2), colour = "black"),
    strip.text =         element_text(size = rel(1.2), colour = "black"),

    axis.line =          element_blank(),
    axis.text.x =        element_text(vjust = 1),
    axis.text.y =        element_blank(),
    axis.ticks.x =       element_line(size = 0.2),
    axis.ticks.y =       element_blank(),
    axis.title =         element_text(colour = "black", size = rel(1.4)),
    axis.title.x =       element_text(vjust = 1, margin = margin(t=20,b=15)),
    axis.title.y =       element_text(angle = 90, margin = margin(r=10)),
    axis.ticks.length =  unit(0.3, "lines"),

    legend.background =  element_rect(colour = NA),
    legend.margin =      unit(0.2, "cm"),
    legend.key =         element_rect(fill = "black"),
    legend.key.size =    unit(1.2, "lines"),
    legend.key.height =  NULL,
    legend.key.width =   NULL,
    legend.text =        element_text(size = rel(0.8), colour = "black"),
    legend.text.align =  NULL,
    legend.title =       element_text(size = rel(1.2), hjust = 0.5, colour = "black"),
    legend.title.align = NULL,
    legend.position =    "right",
    legend.direction =   "vertical",
    legend.justification = "right",
    legend.box =         NULL,

    panel.background =   element_rect(fill = "white", colour = NA),
    panel.border =       element_rect(fill = NA, colour = "black"),
    panel.grid.major.x = element_line(colour = "grey20", size = 0.2),
    panel.grid.major.y = element_line(colour = "grey20", size = 0.005),
    panel.grid.minor =   element_blank(),
    panel.margin =       unit(0.25, "lines"),

    strip.background =   element_rect(fill = "grey30", colour = "grey10"),
    strip.text.x =       element_text(),
    strip.text.y =       element_text(angle = -90),

    plot.background =    element_rect(),
    plot.title =         element_text(size = rel(1.8)),
    plot.margin =        unit(c(1, 1, 0.5, 0.5), "lines"),

    complete = TRUE
  )
}

bar_theme <- function(base_size = 20, base_family = "Roboto") {
  theme(
    line =               element_line(colour = "white", size = 0.25, linetype = 1,
                                      lineend = "round"),
    rect =               element_rect(fill = "white", colour = "white", size = 0.25, linetype = 0),
    text =               element_text(family = base_family, face = "plain",
                                      colour = "black", size = base_size,
                                      hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9, margin = margin(1,1,1,1), debug = FALSE),
    axis.text =          element_text(size = rel(1.2), colour = "black"),
    strip.text =         element_text(size = rel(1.2), colour = "black"),

    axis.line =          element_blank(),
    axis.text.x =        element_blank(),
    axis.text.y =        element_blank(),
    axis.ticks =         element_blank(),
    axis.title =         element_text(colour = "black", size = rel(1.4)),
    axis.title.x =       element_text(vjust = 1, margin = margin(t=20,b=15)),
    axis.title.y =       element_text(angle = 90, margin = margin(r=10)),
    axis.ticks.length =  unit(0.3, "lines"),

    legend.background =  element_rect(colour = NA),
    legend.margin =      unit(0.2, "cm"),
    legend.key =         element_blank(),
    legend.key.size =    unit(1.2, "lines"),
    legend.key.height =  NULL,
    legend.key.width =   unit(12, "lines"),
    legend.text =        element_text(size = rel(1.2), colour = "black", margin = margin(r=20,l=20)),
    legend.text.align =  0.5,
    legend.title =       element_text(size = rel(1.4), colour = "black"),
    legend.title.align = NULL,
    legend.position =    "bottom",
    legend.direction =   "horizontal",
    legend.justification = "bottom",
    legend.box =         NULL,

    panel.background =   element_rect(fill = "white", colour = NA),
    panel.border =       element_blank(),
    panel.grid.major =   element_blank(),
    panel.grid.minor =   element_blank(),
    panel.margin =       unit(0.25, "lines"),

    strip.background =   element_rect(fill = "grey30", colour = "grey10"),
    strip.text.x =       element_text(),
    strip.text.y =       element_text(angle = -90),

    plot.background =    element_rect(),
    plot.title =         element_text(size = rel(1.8), margin = margin(b=10)),
    plot.margin =        unit(c(1, 1, 0.5, 0.5), "lines"),

    complete = TRUE
  )
}

sar_theme <- function(base_size = 20, base_family = "Roboto", width = unit(10, "lines")) {
  theme(
    line =               element_line(colour = "black", size = 0.5, linetype = 1,
                                      lineend = "round"),
    rect =               element_rect(fill = "white", colour = "black", size = 0.5, linetype = 1),
    text =               element_text(family = base_family, face = "plain",
                                      colour = "black", size = base_size,
                                      hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9, margin = margin(1,1,1,1), debug = FALSE),
    axis.text =          element_text(size = rel(1.2), colour = "black"),
    strip.text =         element_text(size = rel(1.2), colour = "black"),

    axis.line =          element_blank(),
    axis.text.x =        element_text(vjust = 1),
    axis.text.y =        element_text(),
    axis.ticks.x =       element_line(size = 0.2),
    axis.ticks.y =       element_line(size = 0.2),
    axis.title =         element_text(colour = "black", size = rel(1.4)),
    axis.title.x =       element_text(vjust = 1, margin = margin(t=20,b=15)),
    axis.title.y =       element_text(angle = 90, margin = margin(r=10)),
    axis.ticks.length =  unit(0.3, "lines"),

    legend.background =  element_rect(colour = NA),
    legend.margin =      unit(0.2, "cm"),
    legend.key =         element_blank(),
    legend.key.size =    unit(1.2, "lines"),
    legend.key.height =  NULL,
    legend.key.width =   width,
    legend.text =        element_text(size = rel(1.2), colour = "black", margin = margin(r = 15)),
    legend.text.align =  0.5,
    legend.title =       element_text(size = rel(1.2), hjust = 0.5, colour = "black"),
    legend.title.align = NULL,
    legend.position =    "bottom",
    legend.direction =   "horizontal",
    legend.justification = "bottom",
    legend.box =         NULL,

    panel.background =   element_rect(fill = "white", colour = NA),
    panel.border =       element_blank(),
    panel.grid.major.x = element_line(colour = "grey20", size = 0.2),
    panel.grid.major.y = element_line(colour = "grey20", size = 0.2),
    panel.grid.minor =   element_line(colour = "grey20", size = 0.05),
    panel.margin =       unit(0.25, "lines"),

    strip.background =   element_rect(fill = "grey30", colour = "grey10"),
    strip.text.x =       element_text(),
    strip.text.y =       element_text(angle = -90),

    plot.background =    element_rect(),
    plot.title =         element_text(size = rel(1.8)),
    plot.margin =        unit(c(1, 1, 0.5, 0.5), "lines"),

    complete = TRUE
  )
}


#################################################################################################

#all_times <- read.csv(args[1], sep="\t")

cpu <- read.csv("./Data/cpu.tsv", sep="\t")


# CPU Graph
ggplot(data=cpu, aes(x=Time, y=Value, group=Metric, color=Metric)) +
  annotate("rect", xmin=0, xmax=100, ymin=0, ymax=100, fill="red", alpha=0.1) +
  annotate("rect", xmin=0, xmax=100, ymin=0, ymax=100, fill="blue", alpha=0.08) +
  annotate("rect", xmin=0, xmax=100, ymin=0, ymax=100, fill="green", alpha=0.08) +
  annotate("rect", xmin=0, xmax=100, ymin=0, ymax=100, fill="yellow", alpha=0.08) +
  geom_line(size=1.2) + sar_theme() +
  labs(color = "") +
  scale_x_continuous(name = "Progress",limits = c(0,102), expand = c(0,0), breaks = seq(from = 0, to = 100, by = 10), labels = sapply(seq(from = 0, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  scale_y_continuous(name = "Utilization", limits = c(-1,100), expand = c(0,0), breaks = seq(from = 10, to = 100, by = 10), labels = sapply(seq(from = 10, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  guides(color = guide_legend(label.position = "bottom"))


ggsave("CPU.jpeg", height = 285.75 * 4, width = 508 * 4, units = "mm")


