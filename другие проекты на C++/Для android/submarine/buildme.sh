cp opt/bootlocal.sh /opt
echo "making submarine app..."
tce-load -i cmake
tce-load -i make
tce-load -i compiletc
tce-load -i isl-dev
dep_dir="/home/tc/submarine/dependencies"
cd ${dep_dir}
tar -xvf libjpeg.tar
cd ${dep_dir}/libjpeg
cmake .
sudo make install
cd ${dep_dir}
sudo rm -r libjpeg
tar -xvf raspicam.tar
cd ${dep_dir}/raspicam
mkdir build
cd build
cmake ..
sudo make install
cd ${dep_dir}
sudo rm -r raspicam

#sudo ldconfig
#while true; do
#    read -p "Do you wish to continue?" yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
cd /home/tc/submarine
make clean
make
echo "done"
