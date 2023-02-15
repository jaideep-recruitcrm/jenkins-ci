#!/bin/bash
res=$(curl -s -w "%{http_code}" http://3.108.160.3/public/sum/4/2)
body=${res::-3}
if [ $body != "6" ]; then
  echo "Error"
fi