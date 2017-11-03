#!/bin/bash

rm -rf Hasil_Compile/simple.tr Hasil_Compile/simwrls.nam TCL_file/fungsidipanggil.txt TCL_file/rtable.txt Hasil_Compile/normal.tr Hasil_Compile/normal.nam
cd ns-allinone-2.35/ns-2.35 
sudo make && sudo make install
cd ../../TCL_file
ns $1
