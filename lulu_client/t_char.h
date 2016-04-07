#ifndef _T_CHAR_H_
#define _T_CHAR_H_

#include <string.h>
#include <string>

#define GetLLByte(i)			((i) & 0xFF)
#define GetLByte(i)			(((i) >> 8) & 0xFF)
#define GetHByte(i)			(((i) >> 16) & 0xFF)
#define GetHHByte(i)			(((i) >> 24) & 0xFF)

// 位数i 从右侧计数即低位,从最地位为1，不是0
#define GetBitFrom8(v,index)		(((v) >> ((index) - 1)) & 0x1)

// 87654321
#define SetBitOf8(v,index,val)		((v) = ((v) &(~(1 << ((index) - 1)))) | (((val) & 0x1) << ((index) - 1)))
#define GetBits(Value,Base,Bits)	(((Value) >> ((Base) - (Bits))) & ((~(0xFF << (Bits))) & 0xFF))

#define char_len(str)		((str) ? strlen(str) : 0)

// 向_pcDst最多_iMaxLen个字节，不判断_pcSrc的结尾
int char_copy(char *_pcDst, const char *_pcSrc, int _iMaxLen);

// 向_pcDst最多拷贝_iMaxLen - 1个字节，若_pcSrc不足_iMaxLen - 1个字节，则复制_pcSrc的长度，_pcDst结尾赋值为0
int char_ncopy(char *_pcDst, const char *_pcSrc, int _iMaxLen);

// 把_pcSrc的指定位置_iOffset的_iCount个字节，合成为一个int,低前高后
int char_GetBytes(const char *_pcSrc, int _iOffset, int _iCount);

// 把_pcDst的指定位置_iOffset的_iCount个字节设置为_iValue
int char_SetBytes(char *_pcDst, int _iOffset, int _iCount, int _iValue);

// 获取要截取的字符串，仅仅得到位置和长度，不拷贝
char* char_GetStringBetweenString(char *_pcData, char *_pcHead, char *_pcEnd, int *_piDstLen);

// 返回两个字符中间的字符串指针以及长度
char *char_GetStringBetweenChar(char *_pcData, char _cHead, char _cEnd, int *_piDstLen);

// 复制两个字符串中间的字符串到指定位置
char* char_CopyStringBetweenString(char *_pcData, char *_pcHead, char *_pcEnd, int _iDstMaxLen, 
										char *_pcDst, int *_piDstLen);

// 复制两个字符中间的字符串到指定位置
char* char_CopyStringBetweenChar(char *_pcData, char _cHead, char _cEnd, int _iDstMaxLen, 
												char *_pcDst, int *_piDstLen);

// 从两个字符串中间提取一个int
int char_GetIntBetweenString(char *_pcData, char *_pcHead, char *_pcEnd);

// 从两个字符之间提取一个int
int char_GetIntBetweenChar(char *_pcData, char _cHead, char _cEnd);

// 把_pcSrc中_SrcSub替换为_pcDstSub，并保存至_pcDst
int char_Replace(char *_pcDst, char *_pcSrc, char *_pcDstSub, char *_SrcSub, int _iDstMaxLen);

/** @brief    16进制字符串转正常字符串
  * @param[in]  szIn    16进制字符串
  * @return  成功返回正常字符串，需要手动free , 失败返回null
  */
char* HexToStr(char* szIn);
std::string Hex2Str(char* szIn);
/** @brief    正常字符串转16进制字符串
  * @param[in]  szIn    正常字符串
  * @return  成功返回16进制字符串，需要手动free , 失败返回null
  */
char* StrToHex(char* szIn);

int char_ToUpper(char* szInOut);

int char_ToLower(char* szInOut);


#endif
