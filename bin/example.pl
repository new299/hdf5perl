#!/usr/bin/env perl
# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        new
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
use strict;
use warnings;
use Hdf5;
use English qw(-no_match_vars);
use Carp;
use Readonly;

our $VERSION = '0.01';

#Create a file
{
  my $file   = Hdf5::H5Fcreate(q[/tmp/test.hdf5], $Hdf5::H5F_ACC_TRUNC, $Hdf5::H5P_DEFAULT, $Hdf5::H5P_DEFAULT);
  Readonly::Scalar my $DIMSF  => [ 5 , 6 ];
  Readonly::Scalar my $DATAIN => [ 0 , 1 , 2 , 3 , 4 , 5 ,
                                   1 , 2 , 3 , 4 , 5 , 6 ,
                                   2 , 3 , 4 , 5 , 6 , 7 ,
                                   3 , 4 , 5 , 6 , 7 , 8 ,
                                   4 , 5 , 6 , 7 , 8 , 9 ,
                                   5 , 6 , 7 , 8 , 9 , 10 ];

  # create an array called data filled with data.
  my $dataspace = Hdf5::H5Screate_simpleNULL(2, $DIMSF);
  my $datatype  = Hdf5::H5Tcopy(Hdf5::get_H5T_NATIVE_INT());

  Hdf5::H5Tset_order($datatype, $Hdf5::H5T_ORDER_LE);

  my $dataset   = Hdf5::H5Dcreate2($file, 'IntArray', $datatype, $dataspace, $Hdf5::H5P_DEFAULT, $Hdf5::H5P_DEFAULT, $Hdf5::H5P_DEFAULT);

  Hdf5::H5Dwrite($dataset, Hdf5::get_H5T_NATIVE_INT(), $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $DATAIN);

  Hdf5::H5Sclose($dataspace);
  Hdf5::H5Tclose($datatype);
  Hdf5::H5Dclose($dataset);
  Hdf5::H5Fclose($file);
}

{
  my $dataout = [ 0 , 0 , 0 , 0 , 0 , 0 ,
                  0 , 0 , 0 , 0 , 0 , 0 ,
                  0 , 0 , 0 , 0 , 0 , 0 ,
                  0 , 0 , 0 , 0 , 0 , 0 ,
                  0 , 0 , 0 , 0 , 0 , 0 ,
                  0 , 0 , 0 , 0 , 0 , 0 ];
  #Read the created file
  my $file      = Hdf5::H5Fopen(q[/tmp/test.hdf5], $Hdf5::H5F_ACC_RDONLY, $Hdf5::H5P_DEFAULT);
  my $dataset   = Hdf5::H5Dopen2($file, 'IntArray', $Hdf5::H5P_DEFAULT);

  Hdf5::H5Dread32($dataset, Hdf5::get_H5T_NATIVE_INT(), $Hdf5::H5S_ALL, $Hdf5::H5S_ALL, $Hdf5::H5P_DEFAULT, $dataout);

  my $num_obj = [ 0 ];

  Hdf5::H5Gget_num_objs($file, $num_obj);
  printf "obj count: %d\n", $num_obj->[0] or croak qq[Error printing: $ERRNO];

  Readonly::Scalar my $SIZE => 40;
  my $str;
  Hdf5::H5Gget_objname_by_idx($file, 0, $str, $SIZE);

  printf "name: %s END\n", $str or croak qq[Error printing: $ERRNO];
  print join q[ ], @{$dataout} or croak qq[Error printing: $ERRNO];
  print "\n" or croak qq[Error printing: $ERRNO];
}

unlink '/tmp/test.hdf5';
