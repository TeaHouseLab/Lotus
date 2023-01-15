#!/bin/bash
wget https://github.com/TeaHouseLab/Lotus/releases/download/latest/lotus.tar.gz
tar xf lotus.tar.gz
mv lotus /opt
ln -s /opt/lotus/lotus /usr/bin/lotus
