#include "im_pub.h"

#include "t_char.h"
#include "t_base.h"


//0x68
#define PROTOCOL_KEY 0x69

int im_pub_GetLen(const char *_pcData)
{
	if(NULL == _pcData)
	{
		dbg();
		return 0;
	}

	if(PROTOCOL_KEY != _pcData[0] 
		|| _pcData[0] != _pcData[5])
	{
		dbg();
		return 0;
	}

	return char_GetBytes(_pcData, 1, 4);
}

int im_pub_GetVersion(const char *_pcData)
{
	if(NULL == _pcData)
	{
		dbg();
		return 0;
	}

	return _pcData[6] & 0xFF;
}

int im_pub_GetFun(const char *_pcData)
{
	if(NULL == _pcData)
	{
		dbg();
		return 0;
	}
	PPackInfo packInfo = (PPackInfo)_pcData;
	return packInfo->msgHead.iFun;
}

int im_pub_GetSendSerial(const char *_pcData)
{
	if(NULL == _pcData)
	{
		dbg();
		return 0;
	}

	return _pcData[8] & 0xFF;
}

#if 0
int im_pub_DataStartLen
{
	return 9;
}
#endif

int im_pub_SetFrameHead(char *_pcSend, int _iDataLen, int _iFun, int _iSerial)
{
	if(NULL == _pcSend)
	{
		dbg();
		return ERR;
	}

	_pcSend[0] = PROTOCOL_KEY;
	_pcSend[1] = GetLLByte(_iDataLen);
	_pcSend[2] = GetLByte(_iDataLen);
	_pcSend[3] = GetHByte(_iDataLen);
	_pcSend[4] = GetHHByte(_iDataLen);
	_pcSend[5] = PROTOCOL_KEY;
	_pcSend[6] = 0x6; //协议版本号，兼容相关
	_pcSend[7] = _iFun;
	_pcSend[8] = _iSerial;

	return OK;
}

int im_pub_SetFrameEnd(char *_pcSend, int _iCount)
{
	if(NULL == _pcSend)
	{
		dbg();
		return ERR;
	}

	_pcSend[_iCount] = 0x0;
	_pcSend[_iCount + 1] = 0x16;

	return OK;	
}

int im_pub_SetSendSerial(char *_pcSend, int _iSerial)
{
	if(NULL == _pcSend)
	{
		dbg();
		return ERR;
	}

	_pcSend[8] = _iSerial;

	return OK;
}



