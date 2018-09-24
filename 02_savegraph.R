source("libraries.R")
source("functions.R")
library(igraph)

# parameters --------------------------------------------------------------

node_name = 'MDQ'
data_day = '2018-09-11' # day txs were read
timezone = 'America/Buenos_Aires'
datetime_start = '2018-08-01 10:00'
datetime_end = '2018-09-10 22:00'
# ids to be omitted from analysis (gobierno-par, propuesta-par, pamelaps)
omit_accounts = c('1.2.150830','1.2.151476','1.2.667678')
tk_id = '1.3.1236' # id of token to be tracked (MONEDAPAR)


# read names and txs ------------------------------------------------------

# read user names
unames = readLines('data/raw/names_'%+% node_name %+%'.txt', warn=F)
# read tx data (read with 01_read.py)
data_raw = read.csv("data/working/txs_"%+% node_name%+%"_"%+%data_day%+%".csv", header=T,
                    stringsAsFactors=F, row.names=1)
  # datetime already is -03 (done in 01_read.py)

# filter txs --------------------------------------------------------------

# set time interval
time_interval = interval(start=ymd_hm(datetime_start, tz=timezone), 
                         end=ymd_hm(datetime_end, tz=timezone))

# apply filters
data = data_raw %>% 
  # datetime in datetime format and right TZ 
  mutate(datetime = as_datetime(datetime) %>% force_tz("America/Buenos_Aires")) %>% 
  dplyr::filter(
    # txs with right asset ID
    asset_id %in% tk_id,
    # time interval
    datetime %within% time_interval,
    # listed user names
    sender_name %in% unames & recipient_name %in% unames)


# graph data --------------------------------------------------------------

# edge data for graph (tx=edge)
edges = data %>% transmute(from=sender_id, to=recipient_id, weight=amount)

# type of balance of each vertex (positive o negative)
buy_data = edges %>% group_by(from) %>% summarise(buy_value=sum(weight))
sell_data = edges %>% group_by(to) %>% summarise(sell_value=sum(weight))

# vertex data for graph (vertex=user=node)
vertices = data %>% select(sender_id, sender_name) %>% 
  setNames(c("recipient_id","recipient_name")) %>% 
  rbind(data[c("recipient_id","recipient_name")]) %>% setNames(c("id","name")) %>% 
  distinct() %>% 
  left_join(buy_data, by=c("id"="from")) %>% 
  left_join(sell_data, by=c("id"="to")) %>% replace(is.na(.),0) %>% 
  mutate(balance=sell_value-buy_value,
         type=case_when(balance>=0 ~ "positive",
                        TRUE ~ "negative"))

# directed base graph
net = graph_from_data_frame(d=edges, vertices=vertices, directed=T)
# save graph
saveRDS(net, file="data/working/graph_"%+% node_name %+% "_" %+% 
          substr(datetime_start,1,10) %+% "_" %+% substr(datetime_end,1,10) %+% ".RDS")
