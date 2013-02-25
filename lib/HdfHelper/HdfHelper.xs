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
