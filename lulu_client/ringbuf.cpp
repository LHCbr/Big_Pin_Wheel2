#include "ringbuf.h"
#include "t_base.h"
#include "t_num.h"

#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>

typedef struct
{
	TRingBuf m_tNoUse;
	pthread_mutex_t m_Mutex;
	int m_iType;
	int m_iBufSize;
	unsigned int m_iReadPos;
	unsigned int m_iWritePos;
	unsigned char m_cBuf[0];
} TRingBuffer;

static inline void RingBufClear(TRingBuffer *_ptBuf)
{
	_ptBuf->m_iReadPos = 0;
	_ptBuf->m_iWritePos = 0;	
}
// 创建一个环形buf
TRingBuf *ringbuf_Create(int _iBufSize, int _iType)
{
	if(_iBufSize <= 0)
	{
		return NULL;
	}
	
	TRingBuffer *ptBuf = (TRingBuffer*)malloc(sizeof(TRingBuffer) + _iBufSize);
	
	if(NULL == ptBuf)
	{
		return NULL;
	}

	memset(ptBuf, 0, sizeof(TRingBuffer));
	ptBuf->m_iBufSize = _iBufSize;
	ptBuf->m_iType    = _iType;
	RingBufClear(ptBuf);
	
	if(0 != pthread_mutex_init(&ptBuf->m_Mutex, NULL))
	{
		free(ptBuf);
		return NULL;
	}

	// for test
	#if 0
	ptBuf->m_iReadPos = 2147466720;
	ptBuf->m_iWritePos = 2147466720;
	#endif
	
	return (TRingBuf *)ptBuf;
}

// 销毁一个环形buf
void *ringbuf_Destroy(TRingBuf *_ptBuf)
{	
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;

	if(ptBuf)
	{
		pthread_mutex_destroy(&ptBuf->m_Mutex);
		free(ptBuf);
	}
	
	return NULL;
}

static inline int Pos(int _iPos, int _iBufSize)
{
	return _iPos % _iBufSize;
}

// 环形buf中现存可读数据
int ringbuf_DataSize(TRingBuf *_ptBuf)
{
	int nBytes = 0;
	
	if (_ptBuf)
	{
		TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;	
		
		pthread_mutex_lock(&ptBuf->m_Mutex);

		nBytes = ptBuf->m_iWritePos - ptBuf->m_iReadPos;
		
		pthread_mutex_unlock(&ptBuf->m_Mutex);
	}

	return nBytes;
}

// 环形buf现可写数据
int ringbuf_Capacity(TRingBuf *_ptBuf)
{
	int nBytes = 0;
	
	if (_ptBuf)
	{
		TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
		int iSize = ptBuf->m_iBufSize;
		
		pthread_mutex_lock(&ptBuf->m_Mutex);
		nBytes = iSize - (ptBuf->m_iWritePos - ptBuf->m_iReadPos);
		pthread_mutex_unlock(&ptBuf->m_Mutex);
	}
	return nBytes;
}

// 写数据到环形buf
static void ringbuf_WriteData(int _iSize, const char *_ptSrc, TRingBuffer *_ptBuf)
{
	#if 1
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	int iSize = ptBuf->m_iBufSize;
	int iWpos = Pos(ptBuf->m_iWritePos, iSize);

	
	if (iWpos + _iSize <= iSize)
	{
		memcpy(ptBuf->m_cBuf + iWpos, _ptSrc, _iSize);
	}
	else
	{
		int nBytes = iSize - iWpos;
	
		memcpy(ptBuf->m_cBuf + iWpos, _ptSrc, nBytes);
		memcpy(ptBuf->m_cBuf, _ptSrc + nBytes, _iSize - nBytes);
	}

	ptBuf->m_iWritePos += _iSize;
	#else
	_ptBuf->m_iWritePos += _iSize;
	#endif
}

int ringbuf_Write(int _iSize, const void *_ptSrc, TRingBuf *_ptBuf)
{
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	const char *ptSrc = (const char *)_ptSrc;
	int iSize = 0;
	int iDataSize = 0;
	int iCap = 0;

	if (NULL == _ptSrc || NULL == _ptBuf)
	{
		return -1;
	}

	if (_iSize < 1)
	{
		return _iSize;
	}

	// do safe check 20110715 
	if (ptBuf->m_iBufSize < 1 || ptBuf->m_iReadPos < 0 || ptBuf->m_iWritePos < 0)
	{
		return -1;
	}
	
	pthread_mutex_lock(&ptBuf->m_Mutex);

	//td_printf(0, "ring buf %p write pos = %d, read pos = %d\n", _ptBuf, ptBuf->m_iWritePos, ptBuf->m_iReadPos);

	if(ptBuf->m_iWritePos <= ptBuf->m_iReadPos /*&& ptBuf->m_iWritePos != 2147466720*/)
	{
		RingBufClear(ptBuf);
	}
	else if (ptBuf->m_iWritePos > 0x1FFFFFFF) //解决读写指针无限制递增溢出变负 20110713 dxl
	{
		int iIndx1 = ptBuf->m_iWritePos / ptBuf->m_iBufSize;
		int iIndx2 = ptBuf->m_iReadPos / ptBuf->m_iBufSize;
		int iIndx = iIndx1 < iIndx2 ? iIndx1 : iIndx2;
		int iDec = iIndx * ptBuf->m_iBufSize;

		ptBuf->m_iWritePos -= iDec;
		ptBuf->m_iReadPos -= iDec;
	}

	iSize = ptBuf->m_iBufSize;
	iDataSize = ptBuf->m_iWritePos - ptBuf->m_iReadPos;
	iCap = iSize - iDataSize;

	if (_iSize <= iCap)
	{
		ringbuf_WriteData(_iSize, ptSrc, ptBuf);
	}
	else if (RINGBUF_WRITE_BLOCK == ptBuf->m_iType)
	{
		int iLeft = _iSize;
		while (iLeft > 0)
		{
			iCap = iSize - (ptBuf->m_iWritePos - ptBuf->m_iReadPos);

			if (iCap > 0)
			{
				// zty 20120331
				iCap = TMIN(iLeft, iCap);
				
				ringbuf_WriteData(iCap, ptSrc, ptBuf);
				
				// zty 20120308
				//ptBuf += iCap;
				ptSrc += iCap;
				iLeft -= iCap;
			}
			else
			{
				pthread_mutex_unlock(&ptBuf->m_Mutex); //解锁让对方去处理
				usleep(1000);
				pthread_mutex_lock(&ptBuf->m_Mutex);
			}
		}
	}
	else
	{
		if (_iSize < iSize)
		{
			ringbuf_WriteData(_iSize, ptSrc, ptBuf);
		}
		else
		{
			RingBufClear(ptBuf);
			ringbuf_WriteData(iSize, ptSrc + (_iSize - iSize), ptBuf);
		}

		ptBuf->m_iReadPos = ptBuf->m_iWritePos - iSize;
	}
	
	pthread_mutex_unlock(&ptBuf->m_Mutex);

	return iSize;
}

// 从环形buf读取数据
static void ringbuf_ReadData(int _iSize, char *_ptDst, TRingBuffer *_ptBuf)
{
	#if 1
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	int iSize = ptBuf->m_iBufSize;
	int iRpos = Pos(ptBuf->m_iReadPos, iSize);

	
	if (iRpos + _iSize <= iSize)
	{
		memcpy(_ptDst, ptBuf->m_cBuf + iRpos, _iSize);
	}
	else
	{
		int nBytes = iSize - iRpos;
	
		memcpy(_ptDst, ptBuf->m_cBuf + iRpos, nBytes);
		memcpy(_ptDst + nBytes, ptBuf->m_cBuf, _iSize - nBytes);
	}

	ptBuf->m_iReadPos += _iSize;
	#else
	_ptBuf->m_iReadPos += _iSize;
	#endif
}

int ringbuf_Read(int _iSize, void *_ptDst, TRingBuf *_ptBuf)
{
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	int nBytes = _iSize;
	int iDataSize = 0;

	if (NULL == _ptDst || NULL == _ptBuf)
	{
		return -1;
	}

	if (_iSize < 1)
	{
		return _iSize;
	}

	// do safe check 20110715 
	if (ptBuf->m_iBufSize < 1 || ptBuf->m_iReadPos < 0 || ptBuf->m_iWritePos < 0)
	{
		return -1;
	}	
	
	pthread_mutex_lock(&ptBuf->m_Mutex);
	
	if(ptBuf->m_iReadPos >= ptBuf->m_iWritePos)
	{
		nBytes = 0;
		//td_printf(0, "ringbuf_Read clear %d %d##########", ptBuf->m_iWritePos, ptBuf->m_iReadPos);
		RingBufClear(ptBuf);
		goto EXIT;
	}

	iDataSize = ptBuf->m_iWritePos - ptBuf->m_iReadPos;
	if (iDataSize < nBytes)
	{
		nBytes = iDataSize;
	}
	ringbuf_ReadData(nBytes, (char *)_ptDst, ptBuf);
	
	
EXIT:
	pthread_mutex_unlock(&ptBuf->m_Mutex);
	return nBytes;
}

int ringbuf_Clear(TRingBuf *_ptBuf)
{
	if (_ptBuf)
	{
		TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;

		pthread_mutex_lock(&ptBuf->m_Mutex);
		RingBufClear(ptBuf);
		pthread_mutex_unlock(&ptBuf->m_Mutex);
	}

	return 0;
}

// zty 20120220
// 从环形buf复制数据-dlq created at 20111027
static void ringbuf_CopyData(int _iSize, char *_ptDst, TRingBuffer *_ptBuf)
{
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	int iSize = ptBuf->m_iBufSize;
	int iRpos = Pos(ptBuf->m_iReadPos, iSize);

	
	if (iRpos + _iSize <= iSize)
	{
		memcpy(_ptDst, ptBuf->m_cBuf + iRpos, _iSize);
	}
	else
	{
		int nBytes = iSize - iRpos;
	
		memcpy(_ptDst, ptBuf->m_cBuf + iRpos, nBytes);
		memcpy(_ptDst + nBytes, ptBuf->m_cBuf, _iSize - nBytes);
	}

	//ptBuf->m_iReadPos += _iSize;
}

// zty 20120220
int ringbuf_Copy(int _iSize, void *_ptDst, TRingBuf *_ptBuf)
{
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	int nBytes = _iSize;
	int iDataSize = 0;
	
	if (NULL == _ptDst || NULL == _ptBuf)
	{
		return -1;
	}

	if (_iSize < 1)
	{
		return _iSize;
	}

	// do safe check 20110715 
	if (ptBuf->m_iBufSize < 1 || ptBuf->m_iReadPos < 0 || ptBuf->m_iWritePos < 0)
	{
		return -1;
	}	
	
	pthread_mutex_lock(&ptBuf->m_Mutex);

	if(ptBuf->m_iReadPos >= ptBuf->m_iWritePos)
	{
		nBytes = 0;
		//td_printf(0, "ringbuf_Read clear %d %d##########", ptBuf->m_iWritePos, ptBuf->m_iReadPos);
		RingBufClear(ptBuf);
		goto EXIT;
	}

	iDataSize = ptBuf->m_iWritePos - ptBuf->m_iReadPos;
	if (iDataSize < nBytes)
	{
		nBytes = iDataSize;
	}
	
	ringbuf_CopyData(nBytes, (char *)_ptDst, ptBuf);

EXIT:	
	pthread_mutex_unlock(&ptBuf->m_Mutex);
	return nBytes;
}

// zty 20120331
int ringbuf_Remove(int _iSize, TRingBuf *_ptBuf)
{
	TRingBuffer *ptBuf = (TRingBuffer *)_ptBuf;
	//int iSize = ptBuf->m_iBufSize;
	//int iDataSize = 0;
	int nBytes = _iSize;
	int iRet = -1;

	if(NULL == _ptBuf)
	{
		return ERR;
	}

	if(nBytes < 1)
	{
		return nBytes;
	}

	if (ptBuf->m_iBufSize < 1 || ptBuf->m_iReadPos < 0 || ptBuf->m_iWritePos < 0)
	{
		return ERR;
	}

	pthread_mutex_lock(&ptBuf->m_Mutex);

	if(ptBuf->m_iReadPos >= ptBuf->m_iWritePos)
	{
		RingBufClear(ptBuf);
		iRet = ERR;
		
		goto EXIT;
	}

	nBytes = TMIN(nBytes, (ptBuf->m_iWritePos - ptBuf->m_iReadPos));
	
	ptBuf->m_iReadPos += nBytes;
	iRet = OK;
	
EXIT:
	
	pthread_mutex_unlock(&ptBuf->m_Mutex);
	
	return iRet;
}
// zty add end

