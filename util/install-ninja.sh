#!/bin/bash -xeu

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

# ./ninja ninja_test
# ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots


install -vm755 ninja $LFS/usr/bin/
install -vDm644 misc/bash-completion $LFS/usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  $LFS/usr/share/zsh/site-functions/_ninja
