package Hdf5;


require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
@EXPORT = qw(H5Fcreate);

bootstrap Hdf5;
1;
