#!/usr/bin/env zsh
#
# WARNING
# This is ran viac VSCode's "default test task", meaning it's ran from 
# the root directory. that's why all the references to test scripts
# call "bin/test-X.zsh" and not "./test-X.zsh"
#
# for testing, you also need jq

# backup my actual user.sqlite3
mv user.sqlite3 user.sqlite3.bkp

echo -n "top9 returns 1 element… "
capture=`zsh bin/test-top9.zsh | jq '.items | length'`
[[ $capture == '1'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "that element is correct… "
capture=`zsh bin/test-top9.zsh | jq -r '.items[0].title'`
[[ $capture == 'UTF Search: no usage yet'  ]] && echo ' YES' || echo " NO ($capture)"
echo

# matching the json - \u0027
echo -n "u0027 returns one element… "
capture=`zsh bin/test-main.zsh 'u0027' | jq '.items | length'`
[[ $capture == '1'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "that element is apostrophe… "
capture=`zsh bin/test-main.zsh 'u0027' | jq -r '.items[0].title'`
[[ $capture == "'"  ]] && echo ' YES' || echo " NO ($capture)"
echo

# matching characters BEFORE
echo -n "'l arrow' = '⇆' "
capture=`zsh bin/test-main.zsh 'l arrow' | jq -r '.items[0].title'`
[[ $capture == '⇆'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "'left arrow' = '←' "
capture=`zsh bin/test-main.zsh 'left arrow' | jq -r '.items[0].title'`
[[ $capture == '←'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "'r arrow' = '⇄'"
capture=`zsh bin/test-main.zsh 'r arrow' | jq -r '.items[0].title'`
[[ $capture == '⇄'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "'sign' = '¶'"
capture=`zsh bin/test-main.zsh 'sign' | jq -r '.items[0].title'`
[[ $capture == '¶'  ]] && echo ' YES' || echo " NO ($capture)"
echo

# matching exact characters
echo -n "!! returns one element… "
capture=`zsh bin/test-main.zsh '!!' | jq '.items | length'`
[[ $capture == '1'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "that element is apostrophe… "
capture=`zsh bin/test-main.zsh '!!' | jq -r '.items[0].title'`
[[ $capture == "!"  ]] && echo ' YES' || echo " NO ($capture)"
echo

# spawn usage of three characters: 5× '😊', 3× '→', 1× '×'
echo -n "Generating fake user.usage… "
hex='1f60a' zsh bin/test-write.zsh
hex='1f60a' zsh bin/test-write.zsh
hex='1f60a' zsh bin/test-write.zsh
hex='1f60a' zsh bin/test-write.zsh
hex='1f60a' zsh bin/test-write.zsh
hex='2192' zsh bin/test-write.zsh
hex='2192' zsh bin/test-write.zsh
hex='2192' zsh bin/test-write.zsh
hex='d7' zsh bin/test-write.zsh
echo " YES"

echo -n "top9 now returns 3 elements… "
capture=`zsh bin/test-top9.zsh | jq '.items | length'`
[[ $capture == '3'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "that elements are correct (\"😊   (5×),→   (3×),×   (1×)\")… "
capture=`zsh bin/test-top9.zsh | jq '.items | map (.title) | join(",")'`
[[ $capture == '"😊   (5×),→   (3×),×   (1×)"'  ]] && echo ' YES' || echo " NO ($capture)"
echo

# test some queries again, now with top9 having preference
# matching characters BEFORE
echo -n "preference: 'arrow' = '→' "
capture=`zsh bin/test-main.zsh 'arrow' | jq -r '.items[0].title'`
[[ $capture == '→'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "!preference: 'larr' = '←' "
capture=`zsh bin/test-main.zsh 'larr' | jq -r '.items[0].title'`
[[ $capture == '←'  ]] && echo ' YES' || echo " NO ($capture)"
echo -n "preference: 'sign' = '×'"
capture=`zsh bin/test-main.zsh 'sign' | jq -r '.items[0].title'`
[[ $capture == '×'  ]] && echo ' YES' || echo " NO ($capture)"
echo

# And finally, ridiculuous raw query
echo -n "my favourite raw query: ':sea* OR ch* work* flow*' ⌘6 is seal or seat"
capture=`zsh bin/test-main.zsh ':sea* OR ch* work* flow*' | jq -r '.items[5].title'`
[[ $capture == '🦭' || $capture == '💺'  ]] && echo ' YES' || echo " NO ($capture)"

# put my actual user.sqlite3 back
rm user.sqlite3
mv user.sqlite3.bkp user.sqlite3

# space
echo
