
use lib './lib';
use lib './blib/arch/auto/Hdf5';

use Hdf5;

#$res = Hdf5::H5Fcreate("./test.hdf5",0,0,0);

$res = Hdf5::H5Fopen("./abit.fast5",0,0);
#$res = H5Fopen("./abit.hdf5",H5F_ACC_RDONLY,H5P_DEFAULT);
