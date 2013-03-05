package HdfHelper;

use 5.014002;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use HdfHelper ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('HdfHelper', $VERSION);

# Preloaded methods go here.

1;
__END__

=head1 NAME

HdfHelper - Just some functions to make hdf5perl a bit faster

=head1 SYNOPSIS

  use HdfHelper;

=head1 DESCRIPTION

Provides get_every_nth to get every nth element of a perl array,
and rescale_array to perform the transformation A_i -> (A_i + a) * b
to a perl array.

=head2 EXPORT

None by default.

=head1 SEE ALSO

=head1 AUTHOR

C. J. Wright, E<lt>chris.wright@nanoporetech.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by C. J. Wright

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
