# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        new
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package Hdf5;
use strict;
use warnings;
use Carp;
use base qw(Exporter);
use Readonly;

our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION     = '0.02';

sub AUTOLOAD { ## no critic (ProhibitAutoloading)
  # This AUTOLOAD is used to 'autoload' constants from the constant()
  # XS function.

  my $constname;
  our $AUTOLOAD;
  ($constname = $AUTOLOAD) =~ s/.*:://smx;

  if ($constname eq 'constant') {
    croak q[&Hdf5::constant not defined];
  }

  my ($error, $val) = constant($constname);
  if ($error) {
    croak $error;
  }

  {
    no strict 'refs'; ## no critic (Strict);
    *{$AUTOLOAD} = sub { $val };
  }
  goto &{$AUTOLOAD};
}

require XSLoader;
XSLoader::load('Hdf5', $VERSION);

Readonly::Scalar our $H5F_ACC_RDONLY => 0;
Readonly::Scalar our $H5F_ACC_RDWR   => 1;
Readonly::Scalar our $H5F_ACC_TRUNC  => 2;
Readonly::Scalar our $H5F_ACC_EXCL   => 4;
Readonly::Scalar our $H5F_ACC_DEBUG  => 8;
Readonly::Scalar our $H5F_ACC_CREAT  => 16;
Readonly::Scalar our $H5P_DEFAULT    => 0;

Readonly::Scalar our $H5T_NATIVE_INT => 50_331_660;
Readonly::Scalar our $H5T_ORDER_LE   => 0;
Readonly::Scalar our $H5S_ALL        => 0;

Readonly::Scalar our $H5S_SELECT_SET => 0;

1;
__END__

=head1 NAME

Hdf5 - Hdf5 reader perl extension

=head1 VERSION

$LastChangedRevision$

=head1 SYNOPSIS

  use Hdf5;
  blah blah blah

=head1 DESCRIPTION

A read only HDF5 file reader.

=head1 SUBROUTINES/METHODS

=head2 H5Aclose

=head2 H5Aget_name

=head2 H5Aget_num_attrs

=head2 H5Aget_type

=head2 H5Aopen_idx

=head2 H5Aopen_name

=head2 H5Aread64f

=head2 H5AreadRaw

=head2 H5Dclose

=head2 H5Dcreate2

=head2 H5Dget_space

=head2 H5Dget_storage_size

=head2 H5Dget_type

=head2 H5Dopen2

=head2 H5Dread16

=head2 H5Dread32

=head2 H5DreadRaw

=head2 H5Dwrite

=head2 H5Fclose

=head2 H5Fcreate

=head2 H5Fopen

=head2 H5Gclose

=head2 H5Gget_num_objs

=head2 H5Gget_objname_by_idx

=head2 H5Gget_objtype

=head2 H5Gopen1

=head2 H5Sclose

=head2 H5Screate_simple

=head2 H5Screate_simpleNULL

=head2 H5Sget_simple_extent_dims

=head2 H5Sget_simple_extent_ndims

=head2 H5Sget_simple_extent_npoints

=head2 H5Sselect_hyperslab

=head2 H5Tclose

=head2 H5Tcopy

=head2 H5Tcreate

=head2 H5Tequal

=head2 H5Tget_class

=head2 H5Tget_member_class

=head2 H5Tget_member_name

=head2 H5Tget_member_type

=head2 H5Tget_nmembers

=head2 H5Tget_order

=head2 H5Tget_size

=head2 H5Tinsert

=head2 H5Tset_order

=head2 constant

=head2 get_H5S_SELECT_SET

=head2 get_H5T_COMPOUND

=head2 get_H5T_C_S1

=head2 get_H5T_IEEE_F32LE

=head2 get_H5T_IEEE_F64LE

=head2 get_H5T_NATIVE_DOUBLE

=head2 get_H5T_NATIVE_FLOAT

=head2 get_H5T_NATIVE_INT

=head2 get_H5T_STD_I16LE

=head2 get_H5T_STD_I32LE

=head2 get_H5T_STD_I64LE

=head2 get_H5T_STD_I8LE

=head2 get_H5T_STD_U16LE

=head2 get_H5T_STD_U32LE

=head2 get_H5T_STD_U64LE

=head2 get_H5T_STRING

=head2 get_every_nth

=head2 rescale_array

=head2 AUTOLOAD

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Carp

=item Exporter

=item XSLoader

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author: Nava Whiteford$

new@sgenomics.co.uk

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012 by Nava Whiteford

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
