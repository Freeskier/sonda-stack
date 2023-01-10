#!/bin/sh

echo "Generated HTML report at: $(date)" >> /html-report.log
/usr/local/bin/rita import --rolling --delete --numchunks 1 /logs dataset >> /html-report.log
/usr/local/bin/rita html-report dataset >> /html-report.log

if [ -d "/root/dataset1" ]; then
  echo "Copying files from dataset1..."
  yes | cp -R /root/dataset1/* /root/dataset
  rm -R -d /root/dataset1
fi

