date_now=`date +%Y-%m-%d`
file_name=$date_now-$1
title=${file_name%.*}
mv $1 $file_name
sed -i "1i\---\ntitle: $title\ndate: $date_now\ntags:\n- Linux\n---\n" $file_name
