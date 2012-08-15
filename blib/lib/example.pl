
use lib './lib';
use lib './blib/arch/auto/Hdf5';

use Hdf5;

#Create a file
$file = Hdf5::H5Fcreate("./test.hdf5",$Hdf5::H5F_ACC_TRUNC,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT);

@dimsf = ( 5 , 6 );

@data = ( 0 , 0 , 0 , 0 , 0 ,0 ,
          0 , 0 , 0 , 0 , 0 ,0 ,
          0 , 0 , 0 , 0 , 0 ,0 ,
          0 , 0 , 0 , 0 , 0 ,0 ,
          0 , 0 , 0 , 0 , 0 ,0 ,
          0 , 0 , 0 , 0 , 0 ,0 );

# create an array called data filled with data.
$dataspace = Hdf5::H5Screate_simpleNULL(2,\@dimsf);
$datatype  = Hdf5::H5Tcopy(Hdf5::get_H5T_NATIVE_INT());
$status    = Hdf5::H5Tset_order($datatype, H5T_ORDER_LE);
$dataset   = Hdf5::H5Dcreate2($file,"IntArray",$datatype,$dataspace,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT);
$status	= Hdf5::H5Dwrite($dataset,$Hdf5::H5T_NATIVE_INT,$Hdf5::H5S_ALL,$Hdf5::H5S_ALL,$Hdf5::H5P_DEFAULT,\@data);

Hdf5::H5Sclose($dataspace);
Hdf5::H5Tclose($datatype);
Hdf5::H5Dclose($dataset);
Hdf5::H5Fclose($file);


#Read the created file
#$file = Hdf5::H5Fopen("./abit.fast5",$Hdf5::H5F_ACC_RDONLY,$Hdf5::H5P_DEFAULT);
#$dataset = Hdf5::H5Dopen2($file,"IntArray",$Hdf5::H5P_DEFAULT);
#$datatype = H5Dget_type($dataset);
#$t_class = H5Tget_class($datatype);
#$size = H5Tget_size($datatype);

