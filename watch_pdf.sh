#!/bin/sh

cleanup() {
	kill -- -$$
}

trap cleanup EXIT INT TERM

ls bin/generate_pdf.rb lib/bible.rb lib/pdf.rb | entr -r ruby bin/generate_pdf.rb &
ls cache/bible.pdf | entr zathura cache/bible.pdf &

wait
