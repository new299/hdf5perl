
use lib './lib';
use lib './blib/arch/auto/Hdf5';

use Hdf5;

#$res = Hdf5::H5Fcreate("./test.hdf5",0,0,0);
print $Hdf5::H5F_ACC_RDWR;
#$res = Hdf5::H5Fopen("./abit.fast5",0,0);
$res = Hdf5::H5Fopen("./abit.fast5",$Hdf5::H5F_ACC_RDONLY,$Hdf5::H5P_DEFAULT);
