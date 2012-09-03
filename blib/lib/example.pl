use lib './lib';
use lib './blib/arch/auto/Hdf5';

use Hdf5;

#Create a file
$file = Hdf5::H5Fcreate("./test.hdf5",$Hdf5::H5F_ACC_TRUNC,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT);

@dimsf = ( 5 , 6 );

@datain = ( 0 , 1 , 2 , 3 , 4 ,5 ,
            1 , 2 , 3 , 4 , 5 ,6 ,
            2 , 3 , 4 , 5 , 6 ,7 ,
            3 , 4 , 5 , 6 , 7 ,8 ,
            4 , 5 , 6 , 7 , 8 ,9 ,
            5 , 6 , 7 , 8 , 9 ,10 );

# create an array called data filled with data.
$dataspace = Hdf5::H5Screate_simpleNULL(2,\@dimsf);
$datatype  = Hdf5::H5Tcopy(Hdf5::get_H5T_NATIVE_INT());
$status    = Hdf5::H5Tset_order($datatype, H5T_ORDER_LE);
$dataset   = Hdf5::H5Dcreate2($file,"IntArray",$datatype,$dataspace,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT,$Hdf5::H5P_DEFAULT);
$status	= Hdf5::H5Dwrite($dataset,Hdf5::get_H5T_NATIVE_INT(),$Hdf5::H5S_ALL,$Hdf5::H5S_ALL,$Hdf5::H5P_DEFAULT,\@datain);

Hdf5::H5Sclose($dataspace);
Hdf5::H5Tclose($datatype);
Hdf5::H5Dclose($dataset);
Hdf5::H5Fclose($file);


@dataout = ( 0 , 0 , 0 , 0 , 0 ,0 ,
             0 , 0 , 0 , 0 , 0 ,0 ,
             0 , 0 , 0 , 0 , 0 ,0 ,
             0 , 0 , 0 , 0 , 0 ,0 ,
             0 , 0 , 0 , 0 , 0 ,0 ,
             0 , 0 , 0 , 0 , 0 ,0 );
#Read the created file
$file      = Hdf5::H5Fopen("./test.hdf5",$Hdf5::H5F_ACC_RDONLY,$Hdf5::H5P_DEFAULT);
$dataset   = Hdf5::H5Dopen2($file,"IntArray",$Hdf5::H5P_DEFAULT);
$status    = Hdf5::H5Dread32($dataset,Hdf5::get_H5T_NATIVE_INT(),$Hdf5::H5S_ALL,$Hdf5::H5S_ALL,$Hdf5::H5P_DEFAULT,\@dataout);

@num_obj = ( 0 );

Hdf5::H5Gget_num_objs($file,\@num_obj);
print "obj count: ", $num_obj[0], "\n";

$str = "                               0"; 

Hdf5::H5Gget_objname_by_idx($file,0,\$str,40);
print "name: ", $str, "\n";

for($c=0;$c<30;$c++) {
	print $dataout[$c];
	print " ";
}
