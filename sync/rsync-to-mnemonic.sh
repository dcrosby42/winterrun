#!/bin/bash
pushd `dirname ${BASH_SOURCE[0]}` > /dev/null; HERE=`pwd`; popd > /dev/null
cd $HERE

rsync -azv ./ mnemonic:/home/dcrosby/game/winterrun/
