package Hdf5File;

use lib './lib';
use lib './blib/arch/auto/Hdf5';

use Hdf5;

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
 
  return 1;
}


# Get all group names under the provided path
sub get_groups {

  my ($self, @args) = @_;
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
}

# read the dataset and return it as an array, optionally give a start and end position within the dataset.
sub read_dataset {

  # first we need to determine what datatype is contained in the dataset...
  my ($self, @args) = @_;
  my $dataset_path = $args[0];
  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  Hdf5::H5Tget_class($datatype,$class);
  $size      = Hdf5::H5Tget_size($datatype);
   
  Hdf5::H5Dclose($dataset);
  Hdf5::H5Tclose($datatype);

  if(($class eq "INTEGER") && ($size == 8 ) ) { return read_dataset_int8($dataset_path);  }
  if(($class eq "INTEGER") && ($size == 16) ) { return read_dataset_int16($dataset_path); }
  if(($class eq "INTEGER") && ($size == 32) ) { return read_dataset_int32($dataset_path); }
  if(($class eq "INTEGER") && ($size == 64) ) { return read_dataset_int32($dataset_path); }

  if(($class eq "FLOAT") && ($size == 32) ) { return read_dataset_float32($dataset_path); }
  if(($class eq "FLOAT") && ($size == 64) ) { return read_dataset_float64($dataset_path); }
  if( $class eq "STRING"                  ) { return read_dataset_string($dataset_path);  }
  if( $class eq "BITFIELD"){ }
  if( $class eq "OPAQUE"  ){ }
  if( $class eq "COMPOUND"                ) { return $self->read_dataset_compound($dataset_path);}
  if( $class eq "REFERENCE"){ }
  if( $class eq "ENUM") { }
  if( $class eq "VLEN") { }
  if( $class eq "ARRAY") { }

}

sub read_dataset_int8 {
  print "int8 datatype\n";
}

sub read_dataset_int16 {
  print "int16 datatype\n";
}

sub read_dataset_int32 {
  print "int32 datatype\n";
}

sub read_dataset_int64 {
  print "int64 datatype\n";
}

sub read_dataset_float32 {
  print "float32 datatype\n";
}

sub read_dataset_float64 {
  print "float64 datatype\n";
}

sub read_dataset_string {
  print "string datatype\n";
}

sub read_dataset_compound {
  
  my ($self, @args) = @_;
  my $dataset_path = $args[0];
  $dataset   = Hdf5::H5Dopen2($self->{_filehandle},$dataset_path,$Hdf5::H5P_DEFAULT);
  $datatype  = Hdf5::H5Dget_type($dataset);

  print "compound datatype ", $dataset_path, "\n";

  Hdf5::H5Tget_class($datatype,$class);
  $size      = Hdf5::H5Tget_size($datatype);

  $member_count = Hdf5::H5Tget_nmembers($datatype);
  for($n=0;$n<$member_count;$n++) {
    Hdf5::H5Tget_member_class($datatype,$n,$class);
    Hdf5::H5Tget_member_name ($datatype,$n,$name );

    print "compound: ", $name , " , " , $class , "\n";
  }

  "";
}

# read a whole attribute
sub read_attribute {
}

1;
