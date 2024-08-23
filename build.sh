#!/bin/bash
set -x

if ! [[ -d obj ]]; then
  mkdir obj
fi

cd "src"
ca65 kaboom.s -l../obj/kaboom.lst -o../obj/kaboom.o
ld65 --obj ../obj/kaboom.o -C apple2-asm.cfg -o../obj/kaboom!
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

cp obj/kaboom! $PROJ
cp obj/kaboom.lst $PROJ
cp kaboom.rpw-project $PROJ

#---------------------------------------
