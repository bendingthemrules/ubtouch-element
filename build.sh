#!/bin/bash
qtdeploy build
mkdir -p build

cp manifest.json build
cp element.apparmor build
cp element.desktop build

cp deploy/linux/element-client build
mv build/element-client build/element

cp -R assets build

cd build && click build .
