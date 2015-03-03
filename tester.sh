#!/bin/bash

# VUT FIT
# IPP Projekt - JMP (php5) 2014/2015
# Autor: Lucie Sedláčková
# Spuštění: 1) chmod +x tester.sh 
#           2) ./tester.sh

INTERPRET='php -d open_basedir=""'
SCRIPT=jmp.php

if [ ! -e $SCRIPT ]
then
  echo "$SCRIPT NOT FOUND!"
  exit
else
  head -3 $SCRIPT > tests/third_line
  tail -1l tests/third_line > tests/third_line.log
  rm -f tests/third_line
  thr=`cat tests/third_line.log`
  if [ ${#thr} -lt 13 ]
  then 
    echo "Treti radek skriptu: FAIL"
  else
    if [ ${thr:0:5} = '#JMP:' ]
    then
      echo "Treti radek skriptu: "
      echo "${thr:0:5} OK"
      echo "Zadany LOGIN: ${thr:5:8}"
      echo 'Zbytek radku: "'${thr:13}'"'
    else
      echo "Treti radek skriptu: FAIL"
    fi
  fi
fi

rm -f tests/*.log
FILES=`ls tests/test*.tst`
declare -a soubor
possition=0
index=0

while [ $possition -le ${#FILES} ]
do
  soubor[$index]=${FILES:$possition:20}
  possition=`expr $possition + 21`
  index=`expr $index + 1`
done

##### TESTY NA PARAMETRY MAKROPROCESORU:
echo "------- PARAMETRY (err_code/ref) ------"

$INTERPRET $SCRIPT --help > tests/help.log
if [[ $? -eq 0 ]]
then
  echo "TEST --help               (0)     OK"
  echo "--------------- NAPOVEDA --------------"
  cat tests/help.log
else
  echo "TEST --help               (0)     FAIL"
fi

echo "Hello, world! " | $INTERPRET $SCRIPT >> /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "TEST zadny param          (0)     OK"
else
  echo "TEST zadny param          (0)     FAIL"
fi

$INTERPRET $SCRIPT -r --input=filename -r >> /dev/null 2>&1
if [[ $? -eq 1 ]]
then
  echo "TEST opakujici se         (1)     OK"
else
  echo "TEST opakujici se         (1)     FAIL"
fi
  
$INTERPRET $SCRIPT --help --input=filename >> /dev/null 2>&1
if [[ $? -eq 1 ]]
then
  echo "TEST help + jiny          (1)     OK"
else
  echo "TEST help + jiny          (1)     FAIL"
fi

$INTERPRET $SCRIPT --input=filename -m >> /dev/null 2>&1
if [[ $? -eq 1 ]]
then
  echo "TEST jiny                 (1)     OK"
else
  echo "TEST jiny                 (1)     FAIL"
fi

$INTERPRET $SCRIPT --input=tests/test000 >> /dev/null 2>&1
if [[ $? -eq 2 ]]
then
  echo "TEST input neex           (2)     OK"
else
  echo "TEST input neex           (2)     FAIL"
fi

$INTERPRET $SCRIPT --input=tests/test001-00.tst --output=tests/test001-00.log --cmd='' >> /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "TEST cmd=\"\"               (0)     OK"
  diff -a tests/test001-00.log tests/test001-00.ref >> /dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    echo "                          (ref)   OK"
  else
    echo "                          (ref)   FAIL"
  fi
else
  echo "TEST cmd=\"\"               (0)     FAIL"
fi

$INTERPRET $SCRIPT --input=tests/test001-00.tst --output=tests/test001-00.log --cmd='Ahoj, ' >> /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "TEST cmd=\"Ahoj, \"         (0)     OK"
  diff -a tests/test001-00.log tests/cmd2.ref >> /dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    echo "                          (ref)   OK"
  else
    echo "                          (ref)   FAIL"
  fi
else
  echo "TEST cmd=\"Ahoj, \"         (0)     FAIL"
fi

$INTERPRET $SCRIPT --input=tests/test001-00.tst --output=tests/test001-00.log --cmd='$' >> /dev/null 2>&1
if [[ $? -eq 55 ]]
then
  echo "TEST cmd=\"$\"              (55)    OK"
else
  echo "TEST cmd=\"$\"              (55)    FAIL"
fi

$INTERPRET $SCRIPT --input=tests/test002-55.tst --output=tests/test002-55.log --cmd='{abc' >> /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "TEST cmd=\"{abc\"           (0)     OK"
  diff -a tests/test002-55.log tests/cmd4.ref >> /dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    echo "                          (ref)   OK"
  else
    echo "                          (ref)   FAIL"
  fi
else
  echo "TEST cmd=\"{abc\"           (0)     FAIL"
fi

##### TESTY SYNTAX
echo "--------------- SYNTAXE ---------------"
echo "     c_testu   err_code/ref       stav"
 
i=0
while [ $i -lt 15 ]
do
  numb=${soubor[$i]:10:3}
  $INTERPRET $SCRIPT --input=${soubor[$i]} --output=${soubor[$i]:0:16}.log >> /dev/null 2>&1
  if [[ $? -eq ${soubor[$i]:14:2} ]]
  then
    echo "TEST $numb       ${soubor[$i]:14:2}                 OK"
    if [[ ${soubor[$i]:14:2} -eq 0 ]]
    then
      diff -a ${soubor[$i]:0:16}.log ${soubor[$i]:0:16}.ref #>> /dev/null 2>&1
      if [[ $? -eq 0 ]]
      then
        echo "               ref                OK"
      else
        echo "               ref                FAIL"
      fi
    fi
  else
    echo "TEST $numb       ${soubor[$i]:14:2}                 FAIL"
  fi
  
  i=`expr $i + 1`
done

##### TESTY SEMANTIKA
echo "-------------- SEMANTIKA --------------"
echo "     c_testu   err_code/ref       stav"

while [ $i -lt 44 ]
do
  numb=${soubor[$i]:10:3}
  $INTERPRET $SCRIPT --input=${soubor[$i]} --output=${soubor[$i]:0:16}.log >> /dev/null 2>&1
  if [[ $? -eq ${soubor[$i]:14:2} ]]
  then
    echo "TEST $numb       ${soubor[$i]:14:2}                 OK"
    if [[ ${soubor[$i]:14:2} -eq 0 ]]
    then
      diff -a ${soubor[$i]:0:16}.log ${soubor[$i]:0:16}.ref >> /dev/null 2>&1
      if [[ $? -eq 0 ]]
      then
        echo "               ref                OK"
      else
        echo "               ref                FAIL"
      fi
    fi
  else
    echo "TEST $numb       ${soubor[$i]:14:2}                 FAIL"
  fi
  i=`expr $i + 1`
done

$INTERPRET $SCRIPT --input=${soubor[$i]} -r --output=${soubor[$i]:0:16}.log >> /dev/null 2>&1
if [[ $? -eq ${soubor[$i]:14:2} ]]
then
  echo "TEST 045 (-r)  ${soubor[$i]:14:2}                 OK"
else
  echo "TEST 045 (-r)  ${soubor[$i]:14:2}                 FAIL"
fi

i=`expr $i + 1`

$INTERPRET $SCRIPT --input=${soubor[$i]} --output=${soubor[$i]:0:16}.log >> /dev/null 2>&1
if [[ $? -eq ${soubor[$i]:14:2} ]]
then
  echo "TEST 046 (set) ${soubor[$i]:14:2}                 OK"
  if [[ ${soubor[$i]:14:2} -eq 0 ]]
  then
    diff -a ${soubor[$i]:0:16}.log ${soubor[$i]:0:16}.ref >> /dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
      echo "               ref                OK"
    else
      echo "               ref                FAIL"
    fi
  fi
else
  echo "TEST 046 (set) ${soubor[$i]:14:2}                 FAIL"
fi
