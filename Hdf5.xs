#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include </home/user/hdf5/include/hdf5.h>

#include "const-c.inc"

#include <stdint.h>

MODULE = Hdf5		PACKAGE = Hdf5		

INCLUDE: const-xs.inc

hid_t
get_H5T_STD_I16LE()
CODE:
	RETVAL = H5T_STD_I16LE_g;
OUTPUT:
	RETVAL

hid_t
get_H5T_STD_I32LE()
CODE:
	RETVAL = H5T_STD_I32LE_g;
OUTPUT:
	RETVAL

H5T_class_t
get_H5T_COMPOUND()
CODE:
	RETVAL = H5T_COMPOUND;
OUTPUT:
	RETVAL

hid_t
get_H5S_SELECT_SET()
CODE:
	RETVAL = H5S_SELECT_SET;
OUTPUT:
	RETVAL

hid_t
get_H5T_IEEE_F64LE()
CODE:
	RETVAL = H5T_IEEE_F64LE;
OUTPUT:
	RETVAL

hid_t
get_H5T_NATIVE_INT()
CODE:
	RETVAL = H5T_NATIVE_INT_g;
OUTPUT:
	RETVAL

hid_t
get_H5T_NATIVE_FLOAT()
CODE:
	RETVAL = H5T_NATIVE_FLOAT_g;
OUTPUT:
	RETVAL

hid_t
get_H5T_NATIVE_DOUBLE()
CODE:
	RETVAL = H5T_NATIVE_DOUBLE_g;
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
	AV * dims
	AV * maxdims
CODE:
	hsize_t *cdims    = malloc((av_len(dims)+1)   *sizeof(hsize_t));
	hsize_t *cmaxdims = malloc((av_len(maxdims)+1)*sizeof(hsize_t));
	RETVAL = H5Sget_simple_extent_dims(space_id,cdims,cmaxdims);
	int i=0;
	for(i=0;i<=av_len(dims);i++) { 
		av_store(dims,i,newSVnv(cdims[i]));
		av_store(maxdims,i,newSVnv(cmaxdims[i]));
	}
	free(cdims);
	free(cmaxdims);
OUTPUT:
	RETVAL

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
	RETVAL = H5Screate_simple(rank,d,NULL);
OUTPUT:
	RETVAL

hid_t
H5Tcreate(class,size)
	H5T_class_t class
	size_t size

herr_t
H5Tinsert(dtype_id,name,offset,field_id)
	hid_t dtype_id
	const char * name
	size_t offset
	hid_t field_id


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

herr_t
H5Aclose(attr)
	hid_t attr

herr_t
H5Gclose(group)
	hid_t group

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
	for(i=0;i<=av_len(buf);i++) {
		SV** e = av_fetch(buf,i,0);
		buffer[i] = SvNV(*e);
	}
	RETVAL = H5Dwrite(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buffer);
OUTPUT:
	RETVAL

herr_t 
H5Dread32(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buf)
	hid_t dataset_id
	hid_t mem_type_id
	hid_t mem_space_id
	hid_t file_space_id
	hid_t xfer_plist_id
	AV * buf
CODE:
	int32_t *data = malloc(av_len(buf)*sizeof(int32_t));
	RETVAL = H5Dread(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,data);
	int i=0;
	for(i=0;i<=av_len(buf);i++) { 
		av_store(buf,i,newSVnv(data[i]));
	}
	free(data);
OUTPUT:
	RETVAL

herr_t 
H5Dread16(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buf)
	hid_t dataset_id
	hid_t mem_type_id
	hid_t mem_space_id
	hid_t file_space_id
	hid_t xfer_plist_id
	AV * buf
CODE:
	int16_t *data = malloc(av_len(buf)*sizeof(int16_t));
	RETVAL = H5Dread(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,data);
	int i=0;
	for(i=0;i<=av_len(buf);i++) { 
		av_store(buf,i,newSVnv(data[i]));
	}
	free(data);
OUTPUT:
	RETVAL

herr_t 
H5DreadRaw(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,buf)
	hid_t dataset_id
	hid_t mem_type_id
	hid_t mem_space_id
	hid_t file_space_id
	hid_t xfer_plist_id
	SV * buf
CODE:
	// testing by reading 100bytes
	int read_size=100;
	int8_t *data = malloc(100);
	RETVAL = H5Dread(dataset_id,mem_type_id,mem_space_id,file_space_id,xfer_plist_id,data);

        sv_setpvn(buf,data,read_size);
	free(data);
OUTPUT:
	RETVAL
	
herr_t
H5Sselect_hyperslab(space_id,op,start,stride,count,block)
	hid_t space_id
	H5S_seloper_t	op
	AV * start
	AV * stride
	AV * count
	AV * block
CODE:
	hsize_t *hstart  = malloc(sizeof(hsize_t)*av_len(start)); 
	hsize_t *hstride = malloc(sizeof(hsize_t)*av_len(stride));
	hsize_t *hcount  = malloc(sizeof(hsize_t)*av_len(count));
	hsize_t *hblock  = malloc(sizeof(hsize_t)*av_len(block));

	int n;
	for(n=0;n<=av_len(start);n++) {
		SV** a = av_fetch(start,n,0);
		hstart[n] = SvNV(*a);
	}

	for(n=0;n<=av_len(stride);n++) {
		SV** b = av_fetch(stride,n,0);
		hstride[n] = SvNV(*b);
	}

	for(n=0;n<=av_len(count);n++) {
		SV** c = av_fetch(count,n,0);
		hcount[n] = SvNV(*c);
	}

	for(n=0;n<=av_len(block);n++) {
		SV** d = av_fetch(block,n,0);
		hblock[n] = SvNV(*d);
	}

	RETVAL = H5Sselect_hyperslab(space_id,op,hstart,hstride,hcount,hblock);
	free(hstart);
	free(hstride);
	free(hcount);
	free(hblock);
OUTPUT:
	RETVAL

hid_t
H5Aopen_name(loc_id,name)
	hid_t	loc_id
	const char * name

herr_t
H5Aread64f(attr_id,mem_type_id,buf)
	hid_t attr_id
	hid_t mem_type_id
	AV * buf
CODE:
	double *data = malloc((av_len(buf)+1)*sizeof(double));
	RETVAL = H5Aread(attr_id,mem_type_id,data);
	int i=0;
	for(i=0;i<=av_len(buf);i++) { 
		av_store(buf,i,newSVnv(data[i]));
	}
	free(data);
OUTPUT:
	RETVAL

hid_t
H5Gopen1(loc_id,name)
	hid_t loc_id
	const char *name

herr_t
H5Gget_num_objs(loc_id,num_obj)
	hid_t loc_id
	AV * num_obj
CODE:
	hsize_t cnum_obj;
	RETVAL = H5Gget_num_objs(loc_id,&cnum_obj);
	av_store(num_obj,0,newSVnv(cnum_obj));
	
