# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        cwright
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Hdf5.t'

use strict;
use warnings;
use Hdf5;
use Test::More tests => 1;

BEGIN { use_ok('Hdf5') };

