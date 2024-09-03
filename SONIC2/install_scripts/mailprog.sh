#! /bin/bash

MAIL=s-nail
INFO=$2
RECIPIENT=$3

echo "" | s-nail -s "$INFO" -r sonic2-slurm@dcc.ufmg.br $RECIPIENT

