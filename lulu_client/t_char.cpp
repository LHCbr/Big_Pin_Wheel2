#include "t_char.h"

#include "t_num.h"
#include "t_base.h"

#include <ctype.h>
#include <stdlib.h>


int char_copy(char *_pcDst, const char *_pcSrc, int _iMaxLen)
{
	if(NULL == _pcDst || NULL == _pcSrc || _iMaxLen < 1)
	{
		//dbg();
		return 0;
	}

	int i = 0; 
	for(i = 0; i < _iMaxLen; i++)
	{
		if(_pcSrc[i])
		{
			_pcDst[i] = _pcSrc[i];
		}
		else
		{
			break;
		}
	}

	return i;
}

int char_ncopy(char *_pcDst, const char *_pcSrc, int _iMaxLen)
{
	if(NULL == _pcDst)
	{
		dbg();
		return ERR;
	}
	
	if(NULL == _pcSrc || _iMaxLen < 1)
	{
		_pcDst[0] = 0;

		return 0;
	}

	int i = 0; 
	for(i = 0; i < _iMaxLen - 1; i++)
	{
		if(_pcSrc[i])
		{
			_pcDst[i] = _pcSrc[i];
		}
		else
		{
			break;
		}
	}

	_pcDst[i] = 0;

	return i;
}

int char_GetBytes(const char *_pcSrc, int _iOffset, int _iCount)
{
	if(NULL == _pcSrc)
	{
		dbg();
		return 0;
	}

	int i = 0;
	int iRet = 0;

	for(i = 0; i < _iCount; i++)
	{
		iRet = iRet | ((_pcSrc[_iOffset + i] & 0xFF) << (i * 8));
	}

	return iRet;
}

int char_SetBytes(char *_pcDst, int _iOffset, int _iCount, int _iValue)
{
	if(NULL == _pcDst)
	{
		dbg();
		return ERR;
	}

	int i = 0;
	
	for(i = 0; i < _iCount; i++)
	{
		_pcDst[_iOffset + i] = (_iValue >> (i * 8)) & 0xFF; 
	}

	return OK;
}

// ???????????????????????λ?ú???????????
char* char_GetStringBetweenString(char *_pcData, char *_pcHead, char *_pcEnd, int *_piDstLen)
{
	if(NULL == _pcData || NULL == _pcHead 
		|| NULL == _pcEnd || NULL == _piDstLen)
	{
		dbg();
		return NULL;
	}

	dbgprintf(0, "GetBetweenString:head:%s,end:%s", _pcHead, _pcEnd);

	char *pcFindHead = strstr(_pcData, _pcHead);

	if(NULL == pcFindHead)
	{
		dbg();
		return NULL;
	}

	char *pcFindEnd = strstr(pcFindHead, _pcEnd);

	if(NULL == pcFindEnd)
	{
		dbg();
		return NULL;
	}

	int HeadLen = strlen(_pcHead);
	int Len = pcFindEnd - pcFindHead - HeadLen;

	if(Len < 0)
	{
		Len = 0;
	}

	*_piDstLen = Len;

	return pcFindHead + HeadLen;
}


char *char_GetStringBetweenChar(char *_pcData, char _cHead, char _cEnd, int *_piDstLen)
{
	if(NULL == _pcData || NULL == _piDstLen)
	{
		dbg();
		return NULL;
	}

	char *pcFindHead = strchr(_pcData, _cHead);

	if(NULL == pcFindHead)
	{
		dbg();
		return NULL;
	}

	char *pcFindEnd = strchr(pcFindHead, _cEnd);

	if(NULL == pcFindEnd)
	{
		dbg();
		return NULL;
	}

	int Len = pcFindEnd - pcFindHead - 1;

	if(Len < 0)
	{
		Len = 0;
	}

	*_piDstLen = Len;

	return pcFindHead + 1;
}

/*
	_pcData	????????
	_pcHead	????????
	_pcEnd	???????β
	_iDstMaxLen	?????
	_pcDst	?????????
	_piDstLen	????????????

	Return	_pcDst
*/
char* char_CopyStringBetweenString(char *_pcData, char *_pcHead, char *_pcEnd, int _iDstMaxLen, 
										char *_pcDst, int *_piDstLen)
{
	int iDstLen = 0;

	char * pcPointDst = char_GetStringBetweenString(_pcData, _pcHead, _pcEnd, &iDstLen);
	
	if(NULL == pcPointDst)
	{
		dbg();
		return NULL;
	}

	if(iDstLen > _iDstMaxLen)
	{
		iDstLen = _iDstMaxLen - 1;
	}

	strncpy(_pcDst, pcPointDst, iDstLen);

	_pcDst[iDstLen] = 0;

	if(_piDstLen)
	{
		*_piDstLen = iDstLen;
	}

	return pcPointDst;
}

char* char_CopyStringBetweenChar(char *_pcData, char _cHead, char _cEnd, int _iDstMaxLen, 
												char *_pcDst, int *_piDstLen)
{
	int iDstLen = 0;

	char * pcPointDst = char_GetStringBetweenChar(_pcData, _cHead, _cEnd, &iDstLen);
	
	if(NULL == pcPointDst)
	{
		dbg();
		return NULL;
	}

	if(iDstLen > _iDstMaxLen)
	{
		iDstLen = _iDstMaxLen - 1;
	}

	strncpy(_pcDst, pcPointDst, iDstLen);

	_pcDst[iDstLen] = 0;

	if(_piDstLen)
	{
		*_piDstLen = iDstLen;
	}

	return pcPointDst;
}

int char_GetIntBetweenString(char *_pcData, char *_pcHead, char *_pcEnd)
{
	char pcData[16];

	if(char_CopyStringBetweenString(_pcData, _pcHead, _pcEnd, 16, pcData, NULL))
	{
		return num_atoi(pcData);
	}
	else
	{
		return -1;
	}
}

int char_GetIntBetweenChar(char *_pcData, char _cHead, char _cEnd)
{
	char pcData[16];

	if(char_CopyStringBetweenChar(_pcData, _cHead, _cEnd, 16, pcData, NULL))
	{
		return num_atoi(pcData);
	}
	else
	{
		return -1;
	}
}

int char_Replace(char *_pcDst, char *_pcSrc, char *_pcDstSub, char *_SrcSub, int _iDstMaxLen)
{
	if(NULL == _pcDst || NULL == _pcSrc 
		|| NULL == _pcDstSub || NULL == _SrcSub)
	{
		dbg();
		return ERR;
	}

	char *pcLast = _pcSrc;
	char *pcFind = NULL;

	*_pcDst = 0;
	
	while(1)
	{
		pcFind = strstr(pcLast, _SrcSub);

		if(NULL == pcFind)
		{
			strncat(_pcDst, pcLast, _iDstMaxLen - strlen(_pcDst));
			break;
		}
		else
		{
			strncat(_pcDst, pcLast, pcFind - pcLast);
			pcLast = pcFind + strlen(_SrcSub);

			strncat(_pcDst, _pcDstSub, _iDstMaxLen - strlen(_pcDst));
		}
	}

	return OK;
}

////////////IOS推送时需要把16进制转成正常文本////////////

int Char2Hex(char ch)  
{  
    if('0' <= ch && ch <= '9') return (ch - '0');
	if('A' <= ch && ch <= 'F') return (ch - 'A' + 10);
	if('a' <= ch && ch <= 'f') return (ch - 'a' + 10);
	return -1; 
}  

char* HexToStr(char* szIn)
{
	int nLen = char_len(szIn);
	if(nLen < 1)
	{
	    return NULL;
	}
	int nNewLen = nLen / 2 + 1;//(nLen < 2 || nLen % 2 != 0) ? (nLen + 1) : (nLen / 2 + 1);
	char* szOut = (char *)malloc(nNewLen * sizeof(char));
	if(NULL == szOut)
	{
		dbg();
		return NULL;
	}
	memset(szOut,0,nNewLen * sizeof(char));

/*	if(nLen < 2 || nLen % 2 != 0)
	{
		if(szIn) strcpy(szOut,szIn);
		return szOut;
	}*/
	
	int i = 0;
	for (; i < nLen - 1; i += 2) 
	{
		unsigned int anInt = Char2Hex(szIn[i]) * 16 + Char2Hex(szIn[i+1]);
		szOut[i / 2] = anInt;
	}
	return szOut;
}

std::string Hex2Str(char* szIn)
{
	std::string strRet;
	char* szRet = HexToStr(szIn);
	if (NULL != szRet)
	{
		strRet.assign(szRet,strlen(szRet));
		free(szRet);
	}
	return strRet;
}

char* StrToHex(char* szIn)
{
    int nLen = char_len(szIn);
	if(nLen < 1)
	{
	    return NULL;
	}
	int nNewLen = nLen * 2 + 1;
	char* szOut = (char *)malloc(nNewLen * sizeof(char));
	if(NULL == szOut)
	{
		dbg();
		return NULL;
	}
	memset(szOut,0,nNewLen * sizeof(char));

	char strTmp[3] = {0};
	int i = 0;
    for(; i < nLen; i++)  
    {
        snprintf(strTmp,3,"%02X", szIn[i]&0xff);
        strcat(szOut,strTmp);
    }
    
	return szOut;
}

////////////END IOS推送时需要把16进制转成正常文本////////////


int char_ToUpper(char* szInOut)
{
    if(NULL == szInOut)
    {
        dbg();
        return ERR;
    }

    int iLen = strlen(szInOut);
    int i;
    for(i=0;i < iLen; i++)
    {
        szInOut[i]=toupper(szInOut[i]);
    }
    return OK;
}

int char_ToLower(char* szInOut)
{
    if(NULL == szInOut)
    {
        dbg();
        return ERR;
    }

    int iLen = strlen(szInOut);
    int i;
    for(i=0;i < iLen; i++)
    {
        szInOut[i]=tolower(szInOut[i]);
    }
    return OK;
}


