
### DO NOT USE


# deg <- igraph::degree(net, mode="all")
# igraph::V(net)$size <- deg*3/30
# # Set edge width based on weight:
# igraph::E(net)$width <- igraph::E(net)$weight/600
# #change arrow size and edge color:
# igraph::E(net)$arrow.size <- .2
# igraph::E(net)$edge.color <- "gray80"
# # igraph::E(net)$width <- 1+igraph::E(net)$weight/120

# nodos_aislados <- V(net)[degree(net)<1] #detecto los nodos sin conexion con nadie
# net <- delete.vertices(net, c(nodos_aislados)) #elimino los nodos sin deteccions
V(net)$size <- degree(net)/5 #defino el tamano del nodo segun el grado (numero de conexion)
# ancho de flechas segun valor de transaccion (weight)
E(net)$width <- E(net)$weight/500
# Disegnare il grafo:
V(net)$label.cex <- 0.7 #tamano de letra
E(net)$curved <- 0.2 #flechas curvas
E(net)$size <- 0.25

# version simple que combina flechas repetidas de un nodo a otro (las suma)
net_s = igraph::simplify(net, remove.multiple=T, remove.loops=T,  
                         edge.attr.comb="sum")
# aca saca edges por debajo de umbral
net_s <- delete_edges(net_s, E(net_s)[weight<100])


par(mai=c(0,0,0,0)) #tamano de los bordes 0 (sin borde)
plot(net, edge.arrow.size=0.15, layout=layout.fruchterman.reingold,
     vertex.label.dist=0.50)

l = layout_with_lgl(net_s, root="leonelmachado")
plot(net_s, edge.arrow.size=0.15, layout=l,
     vertex.label.dist=0.50)
plot(net_s, edge.arrow.size=0.15, layout=layout.kamada.kawai,
     vertex.label.dist=0.50)


netm <- get.adjacency(net_s, attr="weight", sparse=F)
palf <- colorRampPalette(c("gold", "dark orange")) 
heatmap(netm, Rowv = NA, Colv = NA, col = palf(100), 
        scale="none", margins=c(10,10))



# matriz "IO" -- ventas por fila, compras por columna
as.matrix(net[])




data_graph %>% dplyr::filter(from=="pamelasierra") %>% 
  group_by(to) %>% summarise(sell=sum(weight))

data_graph %>% dplyr::filter(to=="pamelasierra") %>% 
  group_by(from) %>% summarise(buy=sum(weight))




tkplot(net, edge.arrow.size=0.25, layout=layout.kamada.kawai, vertex.label.dist=0.50)
# rglplot(net, edge.arrow.size=0.25, layout=layout.kamada.kawai, vertex.label.dist=0.50)




plot(net, edge.curved=.1, label=NA)

plot(net2, edge.arrow.size=.4, edge.curved=.1, label.cex=0.5)


net_sub = igraph::induced_subgraph(net, 1:20)
plot(net_sub)
E(net_sub)$width

