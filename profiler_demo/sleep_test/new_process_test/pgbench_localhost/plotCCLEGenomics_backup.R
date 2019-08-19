library(readr)
library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)
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

all_times <- read.csv(args[1], sep="\t")

all_times <- read.csv("./Data/cpu.tsv", sep="\t")

all_times$Time <- strtrim(all_times$Time,19)
#This line cause all Time to overwritten with "NA"
#all_times$Time <- parse_datetime(all_times$Time)
samples <- levels(all_times$Sample)
start <- subset(all_times,Task == 'start')$Time
trimming <- subset(all_times,Task == 'trimming')$Time
sorting <- subset(all_times,Task == 'sorting')$Time
fastq <- subset(all_times,Task == 'fastq')$Time
kallisto <- subset(all_times,Task == 'kallisto')$Time

all_times <- data.frame(samples,start,trimming,sorting,fastq,kallisto)
all_times <- all_times[order(start),]

beginning <- all_times$start[1]

time_since_global_beginning = function(x) (as.double(x) - as.double(beginning)) / 60.0
time_since_sample_beginning = function(x) as.double(x['kallisto']) - as.double(x['start'])
time_per_task = function(x,column1, column2) (as.double(x[column1]) - as.double(x[column2])) / as.double(x['run_length'])
percent_time = function(x,column) as.double(x[column]) / as.double(x['run_length'])




all_times$start <- sapply(all_times$start,FUN=time_since_global_beginning)

all_times$trimming <- sapply(all_times$trimming,FUN=time_since_global_beginning)
all_times$sorting <- sapply(all_times$sorting,FUN=time_since_global_beginning)
all_times$fastq <- sapply(all_times$fastq,FUN=time_since_global_beginning)
all_times$kallisto <- sapply(all_times$kallisto,FUN=time_since_global_beginning)
all_times$run_length <- apply(all_times, FUN=time_since_sample_beginning, MARGIN = 1)

waterfall = data.frame(sample = all_times$sample, start = all_times$start, end = all_times$kallisto)
waterfall$real = waterfall$start
waterfall$length = all_times$run_length
waterfall <- melt(waterfall, id.vars=c("sample", "real","length"), value.name="value", variable.name="Time")
mid <- mean(waterfall$length)


sorting <- apply(all_times, FUN=time_per_task, MARGIN = 1, column1 = "sorting", column2 = "start")
fastq <- apply(all_times, FUN=time_per_task, MARGIN = 1, column1 = "fastq", column2 = "sorting")
trimming <- apply(all_times, FUN=time_per_task, MARGIN = 1, column1 = "trimming", column2 = "fastq")
kallisto <- apply(all_times, FUN=time_per_task, MARGIN = 1, column1 = "kallisto", column2 = "trimming")

percents <- data.frame(samples, trimming, sorting,fastq,kallisto)

percents <- data.frame(task = c('Sorting','Fastq','Trimming','Kallisto'),
                       value = c(mean(percents$sorting) * 100, mean(percents$fastq) * 100,
                                 mean(percents$trimming) * 100, mean(percents$kallisto) * 100))


total = 0
totals = c()
bars = c()
for (value in percents$value) {
  total = total + value
  totals = c(totals, total - (value / 2))
  bars = c(bars, total)
}
percents$position = totals
percents$bars = bars
percents$task <- factor(percents$task,levels(percents$task)[c(2,5,3,4,1)])


outlierReplace(waterfall, "value", which(waterfall$real > 300), NA)
outlierReplace(waterfall, "length", which(waterfall$real > 300), NA)
outlierReplace(waterfall, "real", which(waterfall$real > 300), NA)

print("Finished progress file")


cpu <- read_tsv(paste(args[2], "cpu.tsv",sep = ""))
mem <- read_tsv(paste(args[2], "mem.tsv",sep = ""))
net <- read_tsv(paste(args[2], "net.tsv",sep = ""))
disk <- read_tsv(paste(args[2], "disk.tsv",sep = ""))









# CPU Graph
ggplot(data=cpu, aes(x=Time, y=Value, group=Metric, color=Metric)) +
  annotate("rect", xmin=0, xmax=percents$bars[1], ymin=0, ymax=100, fill="red", alpha=0.1) +
  annotate("rect", xmin=percents$bars[1], xmax=percents$bars[2], ymin=0, ymax=100, fill="blue", alpha=0.08) +
  annotate("rect", xmin=percents$bars[2], xmax=percents$bars[3], ymin=0, ymax=100, fill="green", alpha=0.08) +
  annotate("rect", xmin=percents$bars[3], xmax=percents$bars[4], ymin=0, ymax=100, fill="yellow", alpha=0.08) +
  geom_line(size=1.2) + sar_theme() +
  labs(color = "") +
  scale_x_continuous(name = "Progress",limits = c(0,102), expand = c(0,0), breaks = seq(from = 0, to = 100, by = 10), labels = sapply(seq(from = 0, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  scale_y_continuous(name = "Utilization", limits = c(-1,100), expand = c(0,0), breaks = seq(from = 10, to = 100, by = 10), labels = sapply(seq(from = 10, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  guides(color = guide_legend(label.position = "bottom"))


ggsave(paste(args[3],"CPU.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")

# Memory Graph
ggplot(data=mem, aes(x=Time, y=Value, group=Metric, color=Metric)) +
  annotate("rect", xmin=0, xmax=percents$bars[1], ymin=0, ymax=100, fill="red", alpha=0.1) +
  annotate("rect", xmin=percents$bars[1], xmax=percents$bars[2], ymin=0, ymax=100, fill="blue", alpha=0.08) +
  annotate("rect", xmin=percents$bars[2], xmax=percents$bars[3], ymin=0, ymax=100, fill="green", alpha=0.08) +
  annotate("rect", xmin=percents$bars[3], xmax=percents$bars[4], ymin=0, ymax=100, fill="yellow", alpha=0.08) +
  geom_line(size=1.2) + sar_theme() +
  labs(color = "") +
  scale_colour_brewer(type = "qual", palette = "Dark2", direction = 1) +
  scale_x_continuous(name = "Progress",limits = c(0,102), expand = c(0,0), breaks = seq(from = 0, to = 100, by = 10), labels = sapply(seq(from = 0, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  scale_y_continuous(name = "Utilization", limits = c(-1,100), expand = c(0,0), breaks = seq(from = 10, to = 100, by = 10), labels = sapply(seq(from = 10, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  guides(color=FALSE)

ggsave(paste(args[3],"Memory.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")

#Network Graph
ggplot(data=net, aes(x=Time, y=Value, group=Metric, color=Metric, linetype = Metric)) +
  annotate("rect", xmin=0, xmax=percents$bars[1], ymin=0, ymax=70, fill="red", alpha=0.1) +
  annotate("rect", xmin=percents$bars[1], xmax=percents$bars[2], ymin=0, ymax=70, fill="blue", alpha=0.08) +
  annotate("rect", xmin=percents$bars[2], xmax=percents$bars[3], ymin=0, ymax=70, fill="green", alpha=0.08) +
  geom_line(size=1.2) + sar_theme(width = unit(15,"line")) +
  labs(color = "") +
  scale_colour_brewer(type = "qual", palette = "Dark2", direction = -1) +
  scale_x_continuous(name = "Progress",limits = c(0,102), expand = c(0,0), breaks = seq(from = 0, to = 100, by = 10), labels = sapply(seq(from = 0, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  scale_y_continuous(name = "Transfer Speed (MB/s)", limits = c(-0.5,70), expand = c(0,0), breaks = seq(from = 10, to = 70, by = 10)) +
  scale_linetype_manual(values = c(1,5)) +
  guides(linetype=FALSE, color = guide_legend(label.position = "bottom"))

ggsave(paste(args[3],"Network.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")

# Disk Graph
ggplot(data=disk, aes(x=Time, y=Value, group=Metric, color=Metric, linetype = Metric)) +
  annotate("rect", xmin=0, xmax=percents$bars[1], ymin=0, ymax=450, fill="red", alpha=0.1) +
  annotate("rect", xmin=percents$bars[1], xmax=percents$bars[2], ymin=0, ymax=450, fill="blue", alpha=0.08) +
  annotate("rect", xmin=percents$bars[2], xmax=percents$bars[3], ymin=0, ymax=450, fill="green", alpha=0.08) +
  annotate("rect", xmin=percents$bars[3], xmax=percents$bars[4], ymin=0, ymax=450, fill="yellow", alpha=0.08) +
  geom_line(size=1.2) + sar_theme(width = unit(20, "lines")) +
  labs(color = "") +
  scale_colour_brewer(type = "qual", palette = "Dark2", direction = -1) +
  scale_x_continuous(name = "Progress",limits = c(0,102), expand = c(0,0), breaks = seq(from = 0, to = 100, by = 10), labels = sapply(seq(from = 0, to = 100, by = 10), function(x) paste(x,'%', sep = ""))) +
  scale_y_continuous(name = "Transfer Speed (MB/s)",limits = c(-0.5,450), expand = c(0,0), breaks = seq(from = 50, to = 450, by = 50)) +
  scale_linetype_manual(values = c(5,1,5,1)) +
  guides(linetype=FALSE, color = guide_legend(label.position = "bottom"))

ggsave(paste(args[3],"Disk.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")





vmlogs = read_tsv(args[4])
vmlogs$Time <- parse_datetime(vmlogs$Time)
vmlogs <- filter(vmlogs, Event %in% c("creation","finished","preempted"))
beginning <- min(vmlogs$Time)
vmlogs$Time <- sapply(vmlogs$Time,FUN=time_since_global_beginning)
newdf <- as.data.frame(matrix(NA,nrow=length(levels(as.factor(vmlogs$`Google ID`))),ncol=6))
colnames(newdf) <- c("Sample","Google ID","Start","End","Length", "EndType")
i <- 1
for (id in as.factor(vmlogs$`Google ID`)) {
  tmp <- filter(vmlogs, `Google ID` %in% id)
  startTime <- filter(tmp, Event %in% "creation")$Time
  endTime <- subset(tmp, Event %in% c("finished", "preempted"))$Time
  endType <- subset(tmp, Event %in% c("finished", "preempted"))$Event
  length <- as.numeric(endTime - startTime)
  sample <- tmp$Sample[1]
  newdf[i,] <- c(sample, id, startTime, endTime, length, endType)
  i <- i + 1
}
newdf$Length <- as.numeric(newdf$Length)
newdf$Start <- as.numeric(newdf$Start)
newdf$End <- as.numeric(newdf$End)
newdf <- unique(newdf[duplicated(newdf),])

outlierReplace(newdf, "Start", which(newdf$End > 1000), NA)
outlierReplace(newdf, "Length", which(newdf$End > 1000), NA)
outlierReplace(newdf, "End", which(newdf$End > 1000), NA)

newdf$Real <- newdf$Start

test <- melt(newdf, id.vars=c("Sample","Google ID", "Real","Length","EndType"), value.name="value", variable.name="Time", na.rm=TRUE)


#option 1 (lines showing when preemptions restarted)
ggplot(data=test, aes(x=value, y=reorder(`Google ID`,-Real), group = Sample, colour = Length)) +
  geom_line(na.rm = TRUE) + waterfall_theme() +
  labs(x = "Time Since Start (Minutes)", y = "Sample", colour = "Running Time", title = "") +
  scale_x_continuous(breaks = seq(from = 0, to = max(as.numeric(test$value), na.rm = TRUE) + 75, by = 50)) +
  scale_color_gradient(low="#65A621", high="black", space ="Lab" )

ggsave(paste(args[3],"Samples.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")

# #option 2 (with or without points, simple waterfall)
# ggplot(data=test, aes(x=value, y=reorder(`Google ID`,-Real), colour = Length)) + geom_point() +
#   geom_line(na.rm = TRUE) + waterfall_theme() +
#   labs(x = "Time Since Start (Minutes)", y = "Sample", colour = "Running Time", title = "") +
#   scale_x_continuous(breaks = seq(from = 0, to = max(as.numeric(test$value), na.rm = TRUE) + 75, by = 50)) +
#   scale_color_gradient(low="#65A621", high="black", space ="Lab" )
#
# get_size <- function(x) {
#   if (x == "finished") {
#     return(0.1)
#   }
#   else {
#     return(2)
#   }
# }
#
# get_color <- function(x) {
#   if (x == "finished") {
#     return("green")
#   }
#   else {
#     return("#E6564F")
#   }
# }
#
# #option 3
# ggplot(data=test, aes(x=value, y=reorder(`Google ID`,-Real), colour = Length)) + geom_line(na.rm = TRUE) + waterfall_theme() +
#   geom_point(data = filter(test, Time %in% "End"), aes(x=value, y=reorder(`Google ID`,-Real), shape=as.factor(EndType), size=unlist(lapply(EndType, get_size)), fill=unlist(lapply(EndType, get_color))), show.legend = FALSE) +
#   scale_shape_manual(values=c(1, 23)) +
#   labs(x = "Time Since Start (Minutes)", y = "Sample", colour = "Running Time", title = "") +
#   scale_x_continuous(breaks = seq(from = 0, to = max(as.numeric(test$value), na.rm = TRUE) + 75, by = 50)) +
#   scale_color_gradient(low="#65A621", high="black", space ="Lab" )
#

vmlogs = read_tsv(args[4])
vmlogs$Time <- parse_datetime(vmlogs$Time)


genomics_timeline = data.frame(filter(vmlogs, Event %in% "finished")$`Google ID`)
colnames(genomics_timeline) <- "Google ID"

events <- matrix(c(c("creation","spun_up","image_pulled","files_localized","docker_finished","files_delocalized"),c("creation","start","localizing-files","running-docker","delocalizing-files","ok")), ncol=2)


for (i in 1:6) {
  column <- filter(vmlogs, Event %in% events[i,2])
  column <- column[,c("Google ID", "Time")]
  colnames(column) <- c("Google ID",events[i,1])
  genomics_timeline <- inner_join(genomics_timeline, column)
  genomics_timeline[events[i,1]] <- as.double(unlist(genomics_timeline[events[i,1]]))
}
time_per_task = function(x,column1) as.double(x[column1]) / as.double(x['run_length'])

genomics_timeline$run_length = genomics_timeline$files_delocalized - genomics_timeline$creation
genomics_timeline_tmp <- genomics_timeline
genomics_timeline$creation <- 0
for (i in 2:6) {
  genomics_timeline[events[i,1]] <- as.double(unlist(genomics_timeline_tmp[events[i,1]])) - as.double(unlist(genomics_timeline_tmp[events[i-1,1]]))
  genomics_timeline[events[i,1]]  <- apply(genomics_timeline, 1, time_per_task, column1=events[i,1])
}

time.spin_up = mean(genomics_timeline$spun_up) * 100
time.pull_image = mean(genomics_timeline$image_pulled) * 100
time.localize_files = mean(genomics_timeline$files_localized) * 100
time.run_docker = mean(genomics_timeline$docker_finished) * 100
time.delocalize_files = mean(genomics_timeline$files_delocalized) * 100

time.sorting = ((time.run_docker / 100) * (percents[1,2] / 100)) * 100
time.fastq = ((time.run_docker / 100) * (percents[2,2] / 100)) * 100
time.trimming = ((time.run_docker / 100) * (percents[3,2] / 100)) * 100
time.kallisto = ((time.run_docker / 100) * (percents[4,2] / 100)) * 100

timeline <- data.frame(
  task=as.factor(c("Spin Up","Pull Image","Localize Files","Sorting","FASTQ","Trimming","Kallisto","Delocalize Files")),
  value=c(time.spin_up, time.pull_image, time.localize_files, time.sorting, time.fastq, time.trimming, time.kallisto, time.delocalize_files))

timeline$task <- factor(timeline$task,levels(timeline$task))

factors <- c("Spin Up","FASTQ","Pull Image","Trimming","Localize Files","Kallisto","Sorting", "Delocalize Files")

for (i in 8:1) {
  timeline$task <- relevel(timeline$task, factors[i])
  print (factors[i])
}


progress = c()
position = c()
for (i in 1:8) {
  total = 0
  for (j in 1:i) {
    total = total + timeline$value[j]
  }
  progress = c(progress, total)
  position = c(position, (total - (timeline$value[i] / 2)))
}
timeline$progess = progress
position[2] = 14.5
position[3] = 19
timeline$position = position

ggplot(timeline, aes(x=0,y=value,fill=task, width=10)) +
  annotate("text", x=-6, y=timeline$position, label=paste(round(timeline$value,digits = 1),'%',sep = ""), size=10) +
  geom_bar(stat="identity") +
  coord_flip() +
  labs(x = "", y = "", fill = "Tasks\n", title = "") +
  bar_theme() +
  guides(fill = guide_legend(label.position = "bottom", title.position = "top", title.hjust = 0.5)) +
  scale_fill_brewer(type = "qual", palette = "Dark2", direction = 1) +
  scale_x_continuous(limits = c(-6.75,25), expand = c(0,0))

ggsave(paste(args[3],"Time.jpeg",sep = ""), height = 285.75, width = 508, units = "mm")
