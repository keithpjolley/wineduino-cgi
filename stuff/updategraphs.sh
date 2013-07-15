#!/bin/sh

bin=`basename "${0}"`
cd /Library/WebServer/Documents/wineduino/stuff || exit 1

h=""
d=""
w=""
m=""
y=""
a=""
doall=""

while getopts hdwmya o
do case "$o" in
  h)  h="TRUE";;
  d)  d="TRUE";;
  w)  w="TRUE";;
  m)  m="TRUE";;
  y)  y="TRUE";;
  a)  a="TRUE";;
  [?])
      print >&2 "Usage: $bin [-h -d -w -m -y -a]"
      exit 1;;
  esac
done
shift `echo "${OPTIND}-1" | bc`

# run all the plots if no args are given
[ -z "$h" -a -z "$d" -a -z "$w" -a -z "$m" -a -z "$y" -a -z "$a" ] && doall="TRUE"

[ -n "$h" -o -n "$doall" ] && R --slave -f "hour.R"    2>/dev/null
[ -n "$d" -o -n "$doall" ] && R --slave -f "day.R"     2>/dev/null
[ -n "$w" -o -n "$doall" ] && R --slave -f "week.R"    2>/dev/null
[ -n "$m" -o -n "$doall" ] && R --slave -f "month.R"   2>/dev/null
[ -n "$y" -o -n "$doall" ] && R --slave -f "year.R"    2>/dev/null
[ -n "$a" -o -n "$doall" ] && R --slave -f "alldata.R" 2>/dev/null

true
