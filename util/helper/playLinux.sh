#!/bin/bash -x

export TARGET_DIR=~/gameLinux
export FILE_BASE=buildLinux

./script/downloadLatest.sh
chmod +x $TARGET_DIR/*
ls $TARGET_DIR/*
for file in "$TARGET_DIR/*"; do
    $file
    break
done