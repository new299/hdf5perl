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
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Hdf5 - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Hdf5;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Hdf5, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

U-user-PC\user, E<lt>user@x-ray.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by U-user-PC\user

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
