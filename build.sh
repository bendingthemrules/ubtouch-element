#!/bin/bash
set -e

qtdeploy build
mkdir -p build

cp manifest.json build
cp element.apparmor build
cp element.desktop build
cp element.url-dispatcher.json build

cp deploy/linux/element-client build
mv build/element-client build/element

cd push/executable/ && qtdeploy build
cd ../..
cp push/executable/deploy/linux/executable build
mv build/executable build/elementHelper
cp push/pushHelper.apparmor.json build
cp push/pushHelper.json build

cp -R assets build

cd build && click build .
