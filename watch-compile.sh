#!/usr/bin/env bash

COLOR_OFF="\e[0m";
DIM="\e[2m";

function compile {
  find src -type f -name '*.elm' | xargs elm make --output=/dev/null
}

function run {
  clear;
  tput reset;
  echo -en "\033c\033[3J";

  echo -en "${DIM}";
  date -R;
  echo -en "${COLOR_OFF}";

  compile;
}

run;

find src -type f -name '*.elm' | xargs chokidar | while read WHATEVER; do
  run;
done;
