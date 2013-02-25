package Hdf5File;
use Data::Dumper;

use lib './lib';
use lib './blib/arch/auto/Hdf5';
use lib './blib/lib/HdfHelper/blib/lib';
use lib './blib/lib/HdfHelper/blib/arch/auto/HdfHelper';


use Hdf5;
use HdfHelper;

sub new {
  my ($class) = @_;
  my $self    = {
                 created => 1,
                };
  bless $self, $class;
  return $self;
}


# Open the Hdf5 file
sub open {
 
  my ($self, @args) = @_;

  $self->{_filename}   = $args[0];

  $self->{_filehandle} = $file = Hdf5::H5Fopen($self->{_filename},$Hdf5::H5F_ACC_RDONLY,$Hdf5::H5P_DEFAULT);

  if($self->{_filehandle} < 0) { return 0; }
  return 1;
}

sub is_open {
  my ($self, @args) = @_;

  if($self->{_filehandle} < 0) { return 0; }

  return 1;
}


# Get all group names under the provided path
sub get_groups {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return (); }

  my $group_path = $args[0];

  $group = Hdf5::H5Gopen1($self->{_filehandle},$group_path);

  Hdf5::H5Gget_num_objs($group,\@num_obj);

  my @object_names;
  for($n=0;$n<$num_obj[0];$n++) {
    my $str;
    Hdf5::H5Gget_objname_by_idx($group,$n,$str,1000);
    Hdf5::H5Gget_objtype($file,$group_path . $str,$type);
    if($type eq "GROUP") {
      $object_names[$n] = $str;
    }
  }
  return @object_names;
}

# Get all dataset names under the provided path
sub get_datasets {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return (); }

  my $group_path = $args[0];

  $group = Hdf5::H5Gopen1($self->{_filehandle},$group_path);

  Hdf5::H5Gget_num_objs($group,\@num_obj);

  my @object_names;
  for($n=0;$n<$num_obj[0];$n++) {
    my $str;
    Hdf5::H5Gget_objname_by_idx($group,$n,$str,1000);
    Hdf5::H5Gget_objtype($file,$group_path . $str,$type);
    if($type eq "DATASET") {
      $object_names[$n] = $str;
    }
  }
  return @object_names;
}

# Get all attribute names under the provided path
sub get_group_attributes {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return (); }

  my $group_path = $args[0];
  $group = Hdf5::H5Gopen1($self->{_filehandle},$group_path);
  $attr_count = Hdf5::H5Aget_num_attrs($group);

  my @attribute_names;
  for($n=0;$n<$attr_count;$n++) {
    $attr_id = Hdf5::H5Aopen_idx($group,$n);
    Hdf5::H5Aget_name($attr_id,1000,$name);
    $attribute_names[$n] = $name;
  }

  return @attribute_names;
}

# Get all attribute names under the provided path
sub get_dataset_attributes {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return (); }

  my $dataset_path = $args[0];
  $dataset = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $attr_count = Hdf5::H5Aget_num_attrs($dataset);

  my @attribute_names;
  for($n=0;$n<$attr_count;$n++) {
    $attr_id = Hdf5::H5Aopen_idx($dataset,$n);
    Hdf5::H5Aget_name($attr_id,1000,$name);
    $attribute_names[$n] = $name;
  }

  return @attribute_names;
}

# return the size of a dataset (given the path)
sub get_dataset_size {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return 0; }

  my $dataset_path = $args[0];
  
  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  my $file_dataspace = Hdf5::H5Dget_space($dataset);
  $dataset_size = Hdf5::H5Sget_simple_extent_npoints($file_dataspace);

  return $dataset_size;
}

# read the dataset and return it as an array, optionally give a start and end position within the dataset.
sub read_dataset {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return 0; }


  # first we need to determine what datatype is contained in the dataset...
  my $dataset_path = $args[0];
  my $start        = $args[1];
  my $end          = $args[2];

  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  Hdf5::H5Tget_class($datatype,$class);
  $size      = Hdf5::H5Tget_size($datatype);
   
  Hdf5::H5Dclose($dataset);
  Hdf5::H5Tclose($datatype);
  
  # Processing for compound datatypes is different than everything else.
  if( $class eq "COMPOUND") { return $self->read_dataset_compound($dataset_path,$start,$end);}

  # Processing simple datatypes
  return $self->read_dataset_simple($dataset_path,$start,$end);

}

sub read_dataset_simple {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return 0; }

  my $dataset_path = $args[0];
  my $start        = $args[1];
  my $end          = $args[2];

  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  Hdf5::H5Tget_class($datatype,$class);
  $size      = Hdf5::H5Tget_size($datatype);

  # change this so, a) they are read as arguments, and b) they can be set to -1 to read everything.

  my @file_hcount   = ( $end - $start );
  my @file_hnstart  = ( $start );
  my @file_hnstride = ( 1 );
  my @file_hblock   = ( 1 );

  my @mem_hcount   = ( $end - $start );
  my @mem_hnstart  = ( 0 );
  my @mem_hnstride = ( 1 );
  my @mem_hblock   = ( 1 );

  $memtype = $datatype;

  # Select part of the dataset to read
  if($start != -1) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($file_dataspace, $Hdf5::H5S_SELECT_SET, \@file_hnstart, \@file_hnstride, \@file_hcount, \@file_hblock);
  
    my $memory_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($memory_dataspace, $Hdf5::H5S_SELECT_SET, \@mem_hnstart, \@mem_hnstride, \@mem_hcount, \@mem_hblock);

    my $status = Hdf5::H5DreadRaw($dataset, $memtype, $memory_dataspace, $file_dataspace, $Hdf5::H5P_DEFAULT, $dataout, ($end - $start)*$size);
  }

  # Read complete dataset
  if($start == -1) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    $dataset_size = Hdf5::H5Sget_simple_extent_npoints($file_dataspace)*$size;
    my $status = Hdf5::H5DreadRaw($dataset, $memtype, $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $dataout, $dataset_size);
  }

  my $is_string = 0;

  my $unpack_string = "(";
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_C_S1      ())) { $unpack_string .= "Z"; $is_string = 1; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= "i"; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= "I"; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= "s"; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= "S"; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= "f"; }
  if(Hdf5::H5Tequal($datatype,Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= "d"; }
  $unpack_string .= ")*";
 
  my @as_array = unpack $unpack_string, $dataout;

  if($is_string == 1) { return $string = join('',@as_array); }

  return @as_array;
}

sub read_dataset_compound {
  
  my ($self, @args) = @_;
  if(!($self->is_open())) { return 0; }

  my $dataset_path = $args[0];
  my $start        = $args[1];
  my $end          = $args[2];

  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  Hdf5::H5Tget_class($datatype,$class);
  $size      = Hdf5::H5Tget_size($datatype);

  my @names;
  my @classes;
  my @types;
  my @sizes;
  my $total_size;

  $member_count = Hdf5::H5Tget_nmembers($datatype);
  for($n=0;$n<$member_count;$n++) {
    Hdf5::H5Tget_member_name ($datatype,$n,$name );
    Hdf5::H5Tget_member_class($datatype,$n,$class);

    $type = Hdf5::H5Tget_member_type($datatype, $n);
    $size = Hdf5::H5Tget_size($type);

    $names  [$n] = $name;
    $classes[$n] = $class;
    $sizes  [$n] = $size;
    $types  [$n] = $type;
    $total_size += $size;
  }

  my $memtype = Hdf5::H5Tcreate(Hdf5::get_H5T_COMPOUND(), $total_size);

  # Build in memory representation
  my $position=0;
  for($n=0;$n<$member_count;$n++) {
    Hdf5::H5Tinsert($memtype,$names[$n],$position,$types[$n]);
    $position += $sizes[$n];
  }

  # change this so, a) they are read as arguments, and b) they can be set to -1 to read everything.

  my @file_hcount   = ( $end - $start );
  my @file_hnstart  = ( $start );
  my @file_hnstride = ( 1 );
  my @file_hblock   = ( 1 );

  my @mem_hcount   = ( $end - $start );
  my @mem_hnstart  = ( 0 );
  my @mem_hnstride = ( 1 );
  my @mem_hblock   = ( 1 );


  # Select part of the dataset to read
  if($start != -1) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($file_dataspace, $Hdf5::H5S_SELECT_SET, \@file_hnstart, \@file_hnstride, \@file_hcount, \@file_hblock);
  
    my $memory_dataspace = Hdf5::H5Dget_space($dataset);
    Hdf5::H5Sselect_hyperslab($memory_dataspace, $Hdf5::H5S_SELECT_SET, \@mem_hnstart, \@mem_hnstride, \@mem_hcount, \@mem_hblock);

    my $status = Hdf5::H5DreadRaw($dataset, $memtype, $memory_dataspace, $file_dataspace, $Hdf5::H5P_DEFAULT, $dataout, ($end - $start)*$total_size);
  }

  # Read complete dataset
  if($start == -1) {
    my $file_dataspace = Hdf5::H5Dget_space($dataset);
    $dataset_size = Hdf5::H5Sget_simple_extent_npoints($file_dataspace)*$total_size;
    my $status = Hdf5::H5DreadRaw($dataset, $memtype, $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $dataout, $dataset_size);
  }

  my $unpack_string = "(";
  for($n=0;$n<$member_count;$n++) {
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= "i"; }
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= "I"; }
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= "s"; }
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= "S"; }
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= "f"; }
    if(Hdf5::H5Tequal($types[$n],Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= "d"; }
  }
  $unpack_string .= ")*";

  my @as_array = unpack $unpack_string, $dataout;

  my %result_data;
  for($n=0;$n<($#names)+1;$n++) {
    my $slice = HdfHelper::get_every_nth(\@as_array, scalar @names ,$n);
    $result_data{$names[$n]} = $slice;
  }

  return %result_data;
}

# read a whole attribute
sub read_attribute {

  my ($self, @args) = @_;
  if(!($self->is_open())) { return 0; }

  my $group_path     = $args[0];
  my $attribute_name = $args[1];

  my @sample_rate      = ( 0 );

  my $group       = Hdf5::H5Gopen1($self->{_filehandle}, $group_path);
  my $attribute   = Hdf5::H5Aopen_name($group, $attribute_name);
  my $memdatatype = Hdf5::H5Aget_type($attribute);

  Hdf5::H5AreadRaw($attribute, $memdatatype, $dataout);

  my $unpack_string = "(";
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_C_S1      ())) { $unpack_string .= "Z"; $is_string=true; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_I32LE ())) { $unpack_string .= "i"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_U32LE ())) { $unpack_string .= "I"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_I16LE ())) { $unpack_string .= "s"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_U16LE ())) { $unpack_string .= "S"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_U64LE ())) { $unpack_string .= "Q"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_STD_I64LE ())) { $unpack_string .= "q"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_IEEE_F32LE())) { $unpack_string .= "f"; }
  if(Hdf5::H5Tequal($memdatatype,Hdf5::get_H5T_IEEE_F64LE())) { $unpack_string .= "d"; }
  $unpack_string .= ")*";

  my @as_array = unpack $unpack_string, $dataout;


  Hdf5::H5Aclose($attribute);
  Hdf5::H5Gclose($group);

  if($is_string == true) { return $string = join('',@as_array); }

  return @as_array;
}

1;

=head1 NAME

Hdf5File - A HDF5 reader

=head1 SYNOPSIS

See example_hdf5file.pl for an example, this will iterate over an HDF5 and dump the data much like hdf5dump.

=head1 DESCRIPTION

The module provides a low level interface to HDF5 files.

=cut

