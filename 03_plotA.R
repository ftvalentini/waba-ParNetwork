source("libraries.R")
source("functions.R")
library(igraph)


# parameters --------------------------------------------------------------

node_name = 'MDQ'
graph_path = 'data/working/graph_MDQ_2018-08-01_2018-09-10.RDS'

# read graph --------------------------------------------------------------

net = readRDS(file=graph_path)

# vertex parameters -------------------------------------------------------

# Vertex color based on balance type:
V(net)$color <- case_when(V(net)$type=="positive" ~ "lightgreen",
                          TRUE ~ "tomato")
# Vertex color based on balance sign and size:
color_scale = list(neg=colorRampPalette(c("tomato","white")),
                   pos=colorRampPalette(c("white","forestgreen")))
color_order = list(neg=floor(maxmin(vertices$balance[vertices$type=="negative"])*100) %>%
                     replace(.==0,1),
                   pos=floor(maxmin(vertices$balance[vertices$type=="positive"])*100) %>%
                     replace(.==0,1))
V(net)$color[V(net)$type=="negative"] = color_scale$neg(100)[color_order$neg]
V(net)$color[V(net)$type=="positive"] = color_scale$pos(100)[color_order$pos]
# Vertex size based on buy_value + sell_value:
V(net)$size <- maxmin(V(net)$sell_value+V(net)$buy_value)*25


# vertex layout -----------------------------------------------------------

# l = layout_with_lgl(net)
l = layout_in_circle(net)
# l = layout_with_lgl(net, root="nantili")
# l = layout_as_star(net,center="nantili")

# simplified graph --------------------------------------------------------

# graph with repated edges combined (with sum)
net_s <- igraph::simplify(net, remove.multiple = T, 
                          edge.attr.comb=c(weight="sum", type="ignore"))
# graph with small edges deleted
net_s <- delete_edges(net_s, E(net_s)[weight<50])


# edge parameters ---------------------------------------------------------

# edge width based on weight (value of transaction):
# E(net_s)$width <- E(net_s)$weight/500
# color intensity based on weight:
edge_scale = colorRampPalette(c("gray90","gray5"))
edge_order = floor(maxmin(E(net_s)$weight)*100) %>% replace(.==0,1)
E(net_s)$color = edge_scale(100)[edge_order]
# color based on vertex origin
# edge.start <- ends(net_s, es=E(net_s), names=F)[,1]
# edge.col <- V(net_s)$color[edge.start]


# plot --------------------------------------------------------------------

# plot path
file_png = 'output/plots/' %+% node_name %+% '_' %+%
  substr(graph_path, nchar(graph_path)-24, nchar(graph_path)-4) %+% '.png'
# open png device
png(filename=file_png, width=1000, height=1000)
# plot
par(mai=c(0,0,0,0)) # no borders
plot(net_s, layout=l,
     # edge.color=edge.col,
     vertex.label.dist=0.2,
     vertex.label.color="black",
     vertex.label.cex=1.1, 
     edge.arrow.size=.25, 
     edge.curved=0.1)
dev.off()


