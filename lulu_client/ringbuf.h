#ifndef _RING_BUF_H_
#define _RING_BUF_H_

typedef struct
{
	void *m_ptSelftData;	//应用层数据
} TRingBuf;

enum
{
	RINGBUF_WRITE_BLOCK = 0,	//空间不够时写等待
	RINGBUF_WRITE_COVER = 1,	//空间不够时写覆盖
};

// 创建一个环形buf
TRingBuf *ringbuf_Create(int _iBufSize, int _iType);

// 销毁一个环形buf
void *ringbuf_Destroy(TRingBuf *_ptBuf);

// 环形buf中现存可读数据
int ringbuf_DataSize(TRingBuf *_ptBuf);

// 环形buf现可写数据
int ringbuf_Capacity(TRingBuf *_ptBuf);

// 写数据到环形buf
int ringbuf_Write(int _iSize, const void *_ptSrc, TRingBuf *_ptBuf);

// 从环形buf读取数据
int ringbuf_Read(int _iSize, void *_ptDst, TRingBuf *_ptBuf);

int ringbuf_Clear(TRingBuf *_ptBuf);

// zty 20120220
//复制环形buf数据,不删除
int ringbuf_Copy(int _iSize, void *_ptDst, TRingBuf *_ptBuf);

//删除环形buf数据
int ringbuf_Remove(int _iSize, TRingBuf *_ptBuf);
// zty add end

#endif

