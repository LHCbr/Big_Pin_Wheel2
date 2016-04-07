#include <stdio.h>
#include <zlib.h>
#include <string.h>
#include "zipbuf.h"

long ZipBuffer(const char * src,long srcl , long loffset,char * dst ,unsigned long & dstl)
{
	if ( dstl < srcl*1.1 ) return 0;
	dstl -= loffset;
	memcpy(dst,src,loffset);
	if ( Z_OK != compress((Bytef*)(dst+loffset),&dstl,(Bytef*)(src + loffset),srcl-loffset) ) return 0;
	dstl += loffset;
	return dstl;
}

long UnZipBuffer(const char * src,long srcl , long loffset,char * dst ,unsigned long & dstl)
{
	memcpy(dst,src,loffset);
	dstl -= loffset;
	if ( Z_OK != uncompress((Bytef*)(dst+loffset),&dstl,(Bytef*)(src+loffset),srcl-loffset) ) return 0;
	dstl += loffset;
	return dstl;
}
