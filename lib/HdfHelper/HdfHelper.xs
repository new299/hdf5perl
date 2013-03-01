#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


MODULE = HdfHelper		PACKAGE = HdfHelper		


AV *
get_every_nth(aref, stride, offset)
    SV * aref;
	int stride;
	int offset;
INIT:
    AV * results;
    I32 numvalues = 0;
    int i;
    
    /* Check that aref is a reference, then check that it is an
    array reference, then check that it is non-empty. */
    if ((! SvROK(aref))
    || (SvTYPE(SvRV(aref)) != SVt_PVAV)
    || ((numvalues = av_len((AV *)SvRV(aref))) < 0))
    {
        XSRETURN_UNDEF;
    }

    /* Create the array which holds the return values. */
    results = (AV *) sv_2mortal ((SV *) newAV ());
CODE:
	AV* array;
	array = (AV*)SvRV(aref);
    for (i=offset; i<=numvalues; i+=stride) {
		av_push(results, newSVsv( *av_fetch(array, i, 0) ) );
    }
    RETVAL = results;
OUTPUT:
    RETVAL

void
rescale_array(aref, A, B)
    SV * aref;
    SV * A;
    SV * B;
INIT:
    I32 numvalues = 0;
    int i;
    
    /* Check that aref is a reference, then check that it is an
    array reference, then check that it is non-empty. */
    if ((! SvROK(aref))
    || (SvTYPE(SvRV(aref)) != SVt_PVAV)
    || ((numvalues = av_len((AV *)SvRV(aref))) < 0))
    {
        XSRETURN_UNDEF;
    }
CODE:
    /* Performs the transformation V_i -> (V_i + A) * B  */
    for (i=0; i<=numvalues; i++) {
       SV** elem = av_fetch( (AV*)SvRV(aref), i, 1);
       SV* new_elem = newSVnv( (SvNV(*elem) + SvNV(A)) * SvNV(B) );
       av_store( (AV*)SvRV(aref), i, new_elem );
    }
