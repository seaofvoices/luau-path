#!/bin/sh

set -e

DARKLUA_CONFIG=".darklua-tests.json"

if [ ! -d node_modules ]; then
    rm -rf temp
    yarn install
fi
if [ ! -d node_modules/.luau-aliases ]; then
    yarn prepare
fi

if [ -d "temp" ]; then
    ls -d temp/* | grep -v node_modules | xargs rm -rf
fi

rojo sourcemap test-place.project.json -o sourcemap.json

run_tests () {
    SYS_PATH_SEPARATOR="$1" darklua process --config $DARKLUA_CONFIG jest.config.lua temp/jest.config.lua
    SYS_PATH_SEPARATOR="$1" darklua process --config $DARKLUA_CONFIG scripts/roblox-test.server.lua temp/scripts/roblox-test.server.lua
    SYS_PATH_SEPARATOR="$1" darklua process --config $DARKLUA_CONFIG node_modules temp/node_modules
    SYS_PATH_SEPARATOR="$1" darklua process --config $DARKLUA_CONFIG src temp/src

    # cat temp/src/sys/path/init.lua
    cp test-place.project.json temp/

    rojo build temp/test-place.project.json -o temp/test-place.rbxl

    run-in-roblox --place temp/test-place.rbxl --script temp/scripts/roblox-test.server.lua
}

run_tests ''
run_tests '\'
