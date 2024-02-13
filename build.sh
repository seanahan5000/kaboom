#!/bin/bash
set -x

if ! [[ -d obj ]]; then
  mkdir obj
fi

cd "src"
ca65 kaboom.s -l../obj/kaboom.lst -o../obj/kaboom.o
ld65 --obj ../obj/kaboom.o -C apple2-asm.cfg --start-addr $6000 -o../obj/kaboom.bin
cd ".."

#---------------------------------------
# Copy all project files
# (needed for RPW65 debugger)
#---------------------------------------

ROOT=`pwd`
PROJECTS="$ROOT/../dbug/projects"

if ! [[ -d "$PROJECTS" ]]; then
  mkdir $PROJECTS
fi

PROJ="$PROJECTS/kaboom"

if ! [[ -d "$PROJ" ]]; then
  mkdir $PROJ
fi

cp obj/kaboom.bin $PROJ
cp obj/kaboom.lst $PROJ
cp project-kaboom.json $PROJ

#---------------------------------------
