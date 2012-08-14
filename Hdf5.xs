#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include </home/user/hdf5/include/hdf5.h>

#include "const-c.inc"

MODULE = Hdf5		PACKAGE = Hdf5		

INCLUDE: const-xs.inc

hid_t
H5Fcreate(name,flags,create_id,access_id)
	const char *name
	unsigned int flags
	hid_t create_id
	hid_t access_id
