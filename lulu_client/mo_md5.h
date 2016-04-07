#ifndef __MO_MD5_H__
#define __MO_MD5_H__

#include <string>

namespace MoMd5
{

/* Any 32-bit or wider unsigned integer data type will do */
typedef unsigned int MD5_u32plus;

typedef struct {
	MD5_u32plus lo, hi;
	MD5_u32plus a, b, c, d;
	unsigned char buffer[64];
	MD5_u32plus block[16];
} MD5_CTX;

extern void MD5_Init(MD5_CTX *ctx);
extern void MD5_Update(MD5_CTX *ctx, const void *data, unsigned long size);
extern void MD5_Final(unsigned char *result, MD5_CTX *ctx);


extern void GetMd5HashCode(const unsigned char * key,const unsigned int nLen,unsigned char *& md5);
extern std::string Md5ToString(const unsigned char* szMd5, const unsigned int nLen);
extern std::string GetMd5Str(const unsigned char * key,const unsigned int nLen);


}

#endif
