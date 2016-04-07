#ifndef _SCHOOL_MINES_SERVICE_H_
#define _SCHOOL_MINES_SERVICE_H_

#include "im_pub.h"
#include "t_binary_tree.h"
#include "t_pub.h"

typedef struct
{
	TBinaryTreeNodeHead m_Head;
	int m_iSerial;				// 文件发送序列号
	int m_iLastSendTime;		// 文件最后一次发送的时间
}TFileWaitingConfirm;

// 初始化,一般服务器端用
int file_waiting_confirm_init();
// 一般客户端用
int file_waiting_confirm_create(int _iMaxSerial);

// 插入
int file_waiting_confirm_insert(int _iSerial,int _iLastSendTime);

// 查找学校
TFileWaitingConfirm* file_waiting_confirm_get(int _iSerial);

// 删除学校
int file_waiting_confirm_remove(TFileWaitingConfirm *_pTSchoolMines);

// 遍历
int file_waiting_confirm_traversal(FTraversalNode _pfTraversalNode);

// 清空
int file_waiting_confirm_clear();

/** @brief    判断是否为空，如果为空就没有待收包了
  * @return  空返回OK
  */
int file_waitng_confirm_is_empty();
#endif

