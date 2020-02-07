#!/bin/bash
 
IP=$1
num_vhosts=1
page=1
touch total-$1

while [ "$num_vhosts" -gt 0 ]; do

 url="http://www.bing.com/search?go=Search&qs=bs&first=$page&FORM=PERE&q=ip%3a$IP"

 out=`mktemp -p . -t .ip2hosts.tmp.XXXXXXX`
 wget -q --header="User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -O "$out" "$url"
 vhosts=`cat "$out" |awk -F'"' 'NR>1&&$0=$1' RS='<h2><a href="' |tr ':' ' ' |tr '/' ' ' |tr '<' ' ' |awk '{print $2}'`
 echo "$vhosts" > partial-$1
 num_vhosts=`grep -v -f total-$1 partial-$1 |wc -l`
 rm -rf partial-$1
 echo "$vhosts" >> total-$1
 rm -f "$out"
 let page=$page+10
done

king=`cat total-$1 |tr '[:upper:]' '[:lower:]' |grep -v 'strong>' |sort -u |grep -v '\<msn\>' |grep -v '^$'`
rm -rf total-$1

for h in `echo "$king"`
do
        echo "$h $IP"
done
