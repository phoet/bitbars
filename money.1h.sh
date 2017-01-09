#!/bin/bash

# documentation for the yahoo quotes http://www.jarloo.com/yahoo_finance/
/usr/local/bin/wget --content-disposition "http://download.finance.yahoo.com/d/quotes.csv?s=GCZ16.CMX&f=ac" -O /tmp/gold.csv -o /tmp/log
/usr/local/bin/wget --content-disposition "http://download.finance.yahoo.com/d/quotes.csv?s=SHOP&f=ac" -O /tmp/shop.csv -o /tmp/log
/usr/local/bin/wget --content-disposition "http://download.finance.yahoo.com/d/quotes.csv?s=CADEUR=X&f=ac" -O /tmp/cadeur.csv -o /tmp/log

echo "💰"
echo "---"
echo -n "GOLD: " | cat - /tmp/gold.csv
echo -n "SHOP: " | cat - /tmp/shop.csv
echo -n "CADEUR: " | cat - /tmp/cadeur.csv

