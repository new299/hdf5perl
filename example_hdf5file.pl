use Hdf5File;
use v5.14;


my $file = Hdf5File->new();
$file->open('./random.hdf5');

dump_groups("/");


sub dump_datasets {
  my (@args) = @_;

  my $path = $args[0];

  my @datasets = $file->get_datasets($path);

  for(my $n=0;$n<=$#datasets;$n++) {
    say "dataset: " , $path , $datasets[$n];
  }
}

sub dump_groups {
  my (@args) = @_;

  my $path = $args[0];
  say "group  : " , $path;
  dump_datasets($path);

  my @groups = $file->get_groups($path);

  for(my $n=0;$n<=$#groups;$n++) {
    if($groups[$n] ne "") {
      dump_groups($path . $groups[$n] . "/");
    }
  }
}

