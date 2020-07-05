#!/bin/bash

#$1 filename
#$2 size bytes

./ImagePartitionCreator.sh -f "zero-$1-ud-size" $2 0
./ImagePartitionCreator.sh -f "one-$1-ud-size" $2 1
./ImagePartitionCreator.sh -f "rand-$1-ud-size" $2 2

