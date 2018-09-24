import numpy as np
import pandas as pd
import datetime

import functions as fn

# %% parametros
node_name = 'MDQ'
names_prefix = r'moneda-par' # prefijos de las cuentas de par
hoy = datetime.datetime.today().date()

# %% read names of node accounts
with open('data/raw/names_'+node_name+'.txt','r') as f:
    names = pd.Series(f.read().splitlines())

# %% get ids of accounts
# get all par accounts
accounts = fn.get_accounts(prefix=names_prefix)
# get accounts of node
accounts_node = accounts.loc[accounts.name.isin(names)]

# %% read history of node accounts
# list of accounts' full history
history_full = [fn.get_user_history(user_id=x, max_page_num=9999) for x in list(accounts_node.id_user)]
# list of history (only txs)
history_txs = [fn.get_user_txs_fromhistory(json_account_history=i) for i in history_full]
# dataframe of all txs
txs_df = pd.concat(history_txs).drop_duplicates().sort_values('datetime', ascending=True)

# %% merge with accounts and token data
out = fn.merge_txs_data(txs_df, accounts_df=accounts, tokens_df=fn.token_data())
# regenera index
out.index = range(len(out.index))

# %% write to csv file
out.to_csv('data/working/txs_'+node_name+'_'+hoy+'.csv')
