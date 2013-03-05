package Hdf5;

use 5.014002;
use strict;
use warnings;
use Carp;

require Exporter;
#use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Hdf5 ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Hdf5::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Hdf5', $VERSION);

$Hdf5::H5F_ACC_RDONLY = 0;
$Hdf5::H5F_ACC_RDWR   = 1;
$Hdf5::H5F_ACC_TRUNC  = 2;
$Hdf5::H5F_ACC_EXCL   = 4;
$Hdf5::H5F_ACC_DEBUG  = 8;
$Hdf5::H5F_ACC_CREAT  = 16;
$Hdf5::H5P_DEFAULT    = 0;

$Hdf5::H5T_NATIVE_INT = 50331660;
$Hdf5::H5T_ORDER_LE   = 0;
$Hdf5::H5S_ALL        = 0;

$Hdf5::H5S_SELECT_SET = 0;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

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

=head2 AUTOLOAD

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item 5.014002

=item strict

=item warnings

=item Carp

=item Exporter

=item XSLoader

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
