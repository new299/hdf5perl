#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include </home/user/hdf5/include/hdf5.h>

#include "const-c.inc"

MODULE = Hdf5		PACKAGE = Hdf5		

INCLUDE: const-xs.inc

hid_t
get_H5T_STD_I32LE()
CODE:
	RETVAL = H5T_STD_I32LE_g;
OUTPUT:
	RETVAL

hid_t
get_H5T_NATIVE_INT()
CODE:
	RETVAL = H5T_NATIVE_INT_g;
OUTPUT:
	RETVAL

hid_t 
H5Fopen(name,flags,access_id)
	const char *name
	unsigned int flags
	hid_t access_id

hid_t
H5Fcreate(name,flags,create_id,access_id)
	const char *name
	unsigned int flags
	hid_t create_id
	hid_t access_id

hid_t
H5Dopen2(loc_id,name,dapl_id)
	hid_t loc_id
	const char *name
	hid_t dapl_id

hid_t
H5Dget_type(dataset)
	hid_t dataset

H5T_class_t
H5Tget_class(dtype_id)
	hid_t	dtype_id

H5T_order_t
H5Tget_order(dtype_id)
	hid_t	dtype_id

size_t
H5Tget_size(dtype_id)
	hid_t	dtype_id

hid_t
H5Dget_space(dataset_id)
	hid_t	dataset_id

int
H5Sget_simple_extent_ndims(space_id)
	hid_t space_id

int
H5Sget_simple_extent_dims(space_id,dims,maxdims)
	hid_t	space_id
	hsize_t * dims
	hsize_t * maxdims

herr_t
H5Sselect_hyperslab(space_id,op,start,stride,count,block)
	hid_t	space_id
	H5S_seloper_t	op
	hsize_t * start
	hsize_t * stride
	hsize_t * count
	hsize_t * block

hid_t
H5Screate_simple(rank,current_dims,maximum_dims)
	int	rank
	hsize_t * current_dims
	hsize_t * maximum_dims
	
hid_t
H5Screate_simpleNULL(rank,current_dims)
	int	rank
	AV * current_dims
CODE:
	int i=0;
	hsize_t d[100];
	for(i=0;i<rank;i++) {
		SV** e = av_fetch(current_dims,i,0);
		d[i] = SvNV(*e);
	}
	//printf("current_dims[0]: %d",d[0]);
	//printf("current_dims[1]: %d",d[1]);
	RETVAL = H5Screate_simple(rank,d,NULL);
OUTPUT:
	RETVAL

herr_t
H5Dread(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buf)
	hid_t dataset_id
	hid_t mem_type_id
	hid_t mem_space_id
	hid_t file_space_id
	hid_t xfer_plist_id
	void *buf

herr_t
H5Tclose(datatype)
	hid_t datatype

herr_t
H5Dclose(dataset)
	hid_t dataset

herr_t
H5Sclose(dataspace)
	hid_t dataspace

herr_t
H5Fclose(file)
	hid_t file

hid_t
H5Tcopy(type_id)
	hid_t	type_id

herr_t
H5Tset_order(type_id,order)
	hid_t	type_id
	H5T_order_t	order

hid_t
H5Dcreate2(loc_id,name,dtype_id,space_id,lcpl_id,dcpl_id,dapl_id)
	hid_t	loc_id
	char *	name
	hid_t	dtype_id
	hid_t	space_id
	hid_t	lcpl_id
	hid_t	dcpl_id
	hid_t	dapl_id

herr_t
H5Dwrite(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buf)
	hid_t	dataset_id
	hid_t	mem_type_id
	hid_t	mem_space_id
	hid_t	file_space_id
	hid_t	xfer_plist_id
	AV * buf
CODE:
	int i=0;
	unsigned long buffer[100];
	for(i=0;i<av_len(buf);i++) {
		SV** e = av_fetch(buf,i,0);
		buffer[i] = SvNV(*e);
	}
	//printf("buffer[0]: %d",buffer[0]);
	//printf("buffer[1]: %d",buffer[1]);
	RETVAL = H5Dwrite(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buffer);
OUTPUT:
	RETVAL
