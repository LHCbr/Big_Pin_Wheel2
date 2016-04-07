#ifndef _RECV_POOL_H_
#define _RECV_POOL_H_

#include "t_list.h"

typedef struct
{
	TStlHead m_Head;// 因为会直接写入EpoolConnection的m_ptList,所以也需要这个字段
	int m_iSize;
	int m_iStart;		// 数据起点，m_pcData有可能包含多帧数据，通过移动m_iStart，删掉之前数据
	int m_iSum;
	char m_pcData[0];
}TRecvNode;


int recv_pool_Init();

TRecvNode* recv_pool_New();

int recv_pool_Delete(TRecvNode* _ptNode);

#endif
