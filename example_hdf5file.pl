use Hdf5File;
use v5.14;


my $file = Hdf5File->new();
$file->open('./random.hdf5');

my @groups = $file->get_groups("/");

for(my $n=0;$n<=$#groups;$n++) {
  say $groups[$n];
}

