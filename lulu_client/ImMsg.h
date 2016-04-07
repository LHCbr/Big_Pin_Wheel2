#ifndef ImMsg_h__
#define ImMsg_h__


#include "im_protocol.h"
#include <vector>
#include <cstddef>

//using namespace std;

#define ImMsgVer 0x01

class CImMsg
{
public:
//	typedef std::vector<char> vector_char;

	enum { PackHeadLen = sizeof(PackHead) };
	enum { MsgHeadLen = sizeof(MsgHead) };
	enum { TotalHeadLen = PACK_INFO_LEN };

	CImMsg(uint32_t _BodyLen = 0);
	~CImMsg(void);

	const char* head() const { return &*data_.begin(); }
	char* head() { return &*data_.begin(); }
	const char* body() const { return (&*data_.begin()) + PackHeadLen; }
	char* body() { return (&*data_.begin()) + PackHeadLen; }
	const char* data() const { return (&*data_.begin()) + TotalHeadLen; }
	char* data() { return (&*data_.begin()) + TotalHeadLen; }

	size_t length() const { return PackHeadLen + body_length_; }
	size_t body_length() const { return body_length_; }
	size_t data_length() const { return body_length_ - MsgHeadLen; }
	void set_body_length(size_t length);
	void set_data_length(size_t length);

	//设置所有数据

	bool set_full_data(const char* _szData, size_t _dataLen, bool _bDecodePacket = true);
	//做了简单的判断，并解出包体的长度
	bool decode_header();
	//解包，根据压缩,加密方式来解包
	bool decode_packet();
	void set_data(const char* _szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial = 0, uint8_t nCmpType = cmpr_zip_rc4);
	//压包，压缩和加密
	void encode_packet(uint8_t nCmpType = cmpr_zip_rc4);

private:
	bool Compressed(uint8_t nCmpType = cmpr_zip_rc4);
	bool UnCompressed();

	std::vector<char> data_;
	size_t body_length_;
};


#endif // ImMsg_h__