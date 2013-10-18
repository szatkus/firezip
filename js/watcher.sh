#!/bin/sh

function watch {
	last='X'
	while true; do
		new=`stat -c %Z $1`
		if [ "$last" != "$new" ]; then
			coffee -c $1
			echo  "Compile $1"
		fi
		last=$new
		sleep 0.5
	done
}

for i in *.coffee; do
	watch $i &
done

pid=$!
read
kill $pid
