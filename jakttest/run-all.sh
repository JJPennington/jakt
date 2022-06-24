#!/bin/bash

if [ ! -x ./build/jakttest ]; then
    echo "jakttest binary does not exist. Building it now."
    cargo run jakttest/jakttest.jakt
fi

cargo run selfhost/main.jakt

pass=0
fail=0
skipped=0

count=0

for f in samples/**/*.jakt tests/**/*.jakt; do
    count=$((count + 1))
done

i=0

set +m

for f in samples/**/*.jakt tests/**/*.jakt; do
    i=$((i + 1))
    $(./build/jakttest $f >/dev/null 2>/dev/null) >/dev/null 2>/dev/null
    
    exitcode=$?

    echo -n "($i/$count: $pass+$fail+$skipped) "

    if [ $exitcode == 0 ]; then
        pass=$((pass + 1))
        echo -ne "[ \033[32;1mPASS\033[0m ] "
    elif [ $exitcode == 2 ]; then
        skipped=$((skipped + 1))
        echo -ne "[ \033[33;1mSKIPPED\033[0m ] "
    else
        fail=$((fail + 1))
        echo -ne "[ \033[31;1mFAIL\033[0m ] "
    fi
    echo "$f"

done

rm compiler.err compiler.out output.jakt runtest.err runtest.out

echo ==============================
echo "$pass" passed
echo "$fail" failed
echo "$skipped" skipped
echo ==============================
