
#ifndef ___ZIP_BUF_HPP__
#define ___ZIP_BUF_HPP__

long ZipBuffer(const char * src,long srcl , long loffset,char * dst ,unsigned long & dstl);
long UnZipBuffer(const char * src,long srcl , long loffset,char * dst ,unsigned long & dstl);

#endif