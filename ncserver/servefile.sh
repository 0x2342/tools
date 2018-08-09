#!/bin/sh

PORT=9999
echo "Serving at $PORT"
{ _FILE=$1; echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c $_FILE)\r\nConnection: close\r\n\r\n"; cat $_FILE; } | nc -l $PORT
