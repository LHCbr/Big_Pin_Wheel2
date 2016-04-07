
#ifndef _IM_CLIENT_MSG_FILTER_H_
#define _IM_CLIENT_MSG_FILTER_H_

#include <stdint.h>
#include <list>
#include <auto_lock.h>

#if 0
int InitMsgFilter();
int AddMsgToFilter(int64_t _iSendIndex,uint32_t nMsgLen);
int MsgFilterDestroy();
#endif

class CClientMsgFilter
{
public:
	struct TMsgFilterData
	{
		int64_t m_iSendIndex;
		uint32_t m_iMsgLen;
	};
	typedef std::list<TMsgFilterData> MsgFilterLst;
	typedef std::list<TMsgFilterData>::iterator MsgFilterLstIt;
	CClientMsgFilter()
	{
	}

	~CClientMsgFilter()
	{
		AutoMLock aml(_mutex);
		_msg_lst.clear();
	}
	int AddMsgToFilter(int64_t _iSendIndex,uint32_t nMsgLen);
	static CClientMsgFilter& Instance();
private:
	bool FndMsgFrmFilter(int64_t _iSendIndex, uint32_t _iMsgLen);
	typedef MoMo::Mutex Mutex;
	typedef MoMo::AutoMLock AutoMLock;
	Mutex _mutex;
	MsgFilterLst _msg_lst;
};

#define MsgFilterInstance() CClientMsgFilter::Instance() 

#endif

