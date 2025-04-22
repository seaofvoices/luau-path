#!/bin/sh

set -e

scripts/build-single-file.sh .darklua-bundle.json build/luau-path.luau
scripts/build-single-file.sh .darklua-bundle-dev.json build/debug/luau-path.luau
scripts/build-roblox-model.sh .darklua.json build/luau-path.rbxm
scripts/build-roblox-model.sh .darklua-dev.json build/debug/luau-path.rbxm
