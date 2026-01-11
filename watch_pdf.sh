#!/bin/sh

cleanup() {
	kill -- -$$
}

trap cleanup EXIT INT TERM

ls bin/biblegen.rb lib/bible.rb lib/pdf.rb | entr -r ruby bin/biblegen --force -f pdf &
ls cache/bible.pdf | entr zathura cache/bible.pdf &

wait
