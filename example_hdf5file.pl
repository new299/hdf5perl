use Hdf5File;
use v5.14;

use Data::Dumper;

my $file = Hdf5File->new();
$file->open('./random.hdf5');

dump_groups("/");


sub dump_attributes_group {

  my (@args) = @_;
  my $path = $args[0];

  my @attributes = $file->get_group_attributes($path);

  for(my $n=0;$n<=$#attributes;$n++) {
    if($attributes[$n] ne "") {
      say "attribute: " , $path , $attributes[$n];
      print Dumper($file->read_attribute($path,$attributes[$n]));
    }
  }
}

sub dump_attributes_dataset {
  my (@args) = @_;
  my $path = $args[0];

  my @attributes = $file->get_dataset_attributes($path);

  for(my $n=0;$n<=$#attributes;$n++) {
    if($attributes[$n] ne "") {
      say "attribute: " , $path , $attributes[$n];
      print Dumper($file->read_attribute($path . $attributes[$n]));
    }
  }
}

sub dump_datasets {
  my (@args) = @_;

  my $path = $args[0];

  my @datasets = $file->get_datasets($path);

  for(my $n=0;$n<=$#datasets;$n++) {
    say "dataset  : " , $path , $datasets[$n];
    dump_attributes_dataset($path .$datasets[$n]);
    print Dumper($file->read_dataset($path . $datasets[$n],-1,-1));
  }
}

sub dump_groups {
  my (@args) = @_;

  my $path = $args[0];
  say "group    : " , $path;
  dump_attributes_group($path);
  dump_datasets($path);

  my @groups = $file->get_groups($path);

  for(my $n=0;$n<=$#groups;$n++) {
    if($groups[$n] ne "") {
      dump_groups($path . $groups[$n] . "/");
    }
  }
}

