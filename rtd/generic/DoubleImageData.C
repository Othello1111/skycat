/*
 * E.S.O. - VLT project
 *
 * "@(#) $Id$"
 *
 * DoubleImageData.C - member functions for class DoubleImageData
 *
 * See the man page RTI(3) for a complete description of this class
 * library.
 *
 * who             when      what
 * --------------  --------  ----------------------------------------
 * Peter W. Draper 30/05/01  Created.
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream.h>
#include <assert.h>
#include <math.h>
#include "DoubleImageData.h"

/* 
 * Convert the given double to short by adding the bias, scaling,
 * rounding if necessary and checking the range.
 */
short DoubleImageData::scaleToShort( double d )
{
    if ( isnan(d) ) {
	return LOOKUP_BLANK;
    }

    //  Blank pixel value is is special lookup table position. Note
    //  Starlink uses a special value for floating point too (not a NaN).
    if ( haveBlank_ ) {
        if ( blank_ == d ) {
            return LOOKUP_BLANK;
        }
    }

    short s;
    d = (d + bias_) * scale_;
    if (d < 0.0 ) {
	if( ( d -= 0.5 ) < LOOKUP_MIN ) {
	    s = LOOKUP_MIN;
	} else {
	    s = (short)d;
        }
    } else {
	if( ( d += 0.5 ) > LOOKUP_MAX) {
	    s = LOOKUP_MAX;
        } else {
	    s = (short)d;
        }
    }
    return s;
}

/*
 * Initialize conversion from base type float to short
 * and scale the low and high cut levels to short range.
 *
 * Method: 2 member variables, bias_ and scale_, are set here and
 * used later to convert the float raw image data to short, which is
 * then used as an index in the lookup table:
 */
void DoubleImageData::initShortConversion()
{
    bias_ = -((lowCut_ + highCut_) * 0.5);
    if( (highCut_ - lowCut_) > 0.0 ) {
	scale_ = LOOKUP_WIDTH / (highCut_ - lowCut_);
    } else {
	scale_ = 1.0;
    }

    scaledLowCut_ = scaleToShort(lowCut_);
    scaledHighCut_ = scaleToShort(highCut_);
    if (haveBlank_)
	scaledBlankPixelValue_ = LOOKUP_BLANK;
}


/*
 * Include some standard methods as (cpp macro) templates:
 * These are methods that are the same for all derived classes of ImageData,
 * except that they work on a different raw data type
 */
#define CLASS_NAME DoubleImageData
#define DATA_TYPE double

// return true is the value x is a NAN (define to 0 for non-float types)
#define ISNAN(x) isnan(x)

#include "ImageTemplates.C"