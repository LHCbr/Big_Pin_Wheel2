#include "ImMsg.h"

#include <string.h>

#include "Rc4Encrypt.h"
#include "zipbuf.h"
#include "zconf.h"
#include "crc32.h"


CImMsg::CImMsg(uint32_t _BodyLen):body_length_(_BodyLen),data_(PackHeadLen + _BodyLen)
{
	
}


CImMsg::~CImMsg(void)
{
}

bool CImMsg::decode_header()
{
	PPackHead pBasePack = (PPackHead)head();
	//非常包，断开
	if (pBasePack->proKey1 != PROTOCOL_KEY1 || pBasePack->proKey2 != PROTOCOL_KEY2)  return false;
	if (pBasePack->dataLen < MsgHeadLen) return false;

	set_body_length(pBasePack->dataLen);
	return true;
}

void CImMsg::set_body_length(size_t length)
{
	body_length_ = length;
	if (body_length_ + PackHeadLen > data_.size()) data_.resize(body_length_ + PackHeadLen);
}

void CImMsg::set_data_length(size_t length)
{
	set_body_length(length + MsgHeadLen);
}

bool CImMsg::set_full_data(const char* _szData, size_t _dataLen, bool _bDecodePacket /*= true*/)
{
	set_body_length(_dataLen - PackHeadLen);
	memcpy(head(), _szData, _dataLen);
	if (_bDecodePacket) 
	{
		return decode_packet();
	}
	return true;
}



void CImMsg::set_data(const char* _szBuf, size_t _bufLen, uint32_t _iFun, uint8_t _iSerial, uint8_t nCmpType)
{
	set_data_length(_bufLen);
	if(_szBuf) memcpy(data(), _szBuf, _bufLen);
	PMsgHead msgHead = (PMsgHead)body();
	msgHead->iFun = _iFun;
	msgHead->iSerial = _iSerial;

	encode_packet(nCmpType);
}

void CImMsg::encode_packet(uint8_t nCmpType)
{
	PPackHead pBasePack = (PPackHead)head();
	pBasePack->proKey1 = PROTOCOL_KEY1;
	pBasePack->proKey2 = PROTOCOL_KEY2;
	pBasePack->Compressed = nCmpType;
	pBasePack->Version = ImMsgVer;
	pBasePack->dataLen = body_length_;
	pBasePack->unzipLen = body_length_;
	Compressed(nCmpType);

	pBasePack = (PPackHead)head();
	pBasePack->crc32 = crc32( (unsigned char *)body(),body_length_);// 包头校验
//	pBasePack->iRatio = 1 + pBasePack->dataLen / body_length_;
	pBasePack->dataLen = body_length_;
}

bool CImMsg::Compressed(uint8_t nCmpType)
{
	switch (nCmpType)
	{
	case cmpr_zip:
		{
			//unsigned long dst_len = 130 + body_length() + sizeof(PackHead);
			unsigned long dst_len = 13 + body_length()*1.5 + sizeof(PackHead);
			if (dst_len < 13 + TotalHeadLen) dst_len = 13 + TotalHeadLen;
			std::vector<char> dstBuf(dst_len);
			long ret = ZipBuffer((const char*)head(),length(),PackHeadLen, (char*)&*dstBuf.begin(), dst_len);
			if ( !ret ) return false;

			dstBuf.resize(dst_len);
		//	data_.assign(dstBuf.begin(),dstBuf.begin() + dst_len);
			body_length_ = dst_len - PackHeadLen;
			data_.swap(dstBuf);
		}
		break;
	case cmpr_rc4:
		{
			CRc4Encrypt rc4;
			rc4.EncryptBuffer((unsigned char *)body(),body_length_);
		}
		break;
	case cmpr_zip_rc4:
		{
			//加密和解密顺序相反
			CRc4Encrypt rc4;
			rc4.EncryptBuffer((unsigned char *)body(),body_length_);

			//unsigned long dst_len = 130 + body_length() + sizeof(PackHead);
			unsigned long dst_len = 13 + body_length()*1.5 + sizeof(PackHead);
			if (dst_len < 13 + TotalHeadLen) dst_len = 13 + TotalHeadLen;
			std::vector<char> dstBuf(dst_len);
			long ret = ZipBuffer((const char*)head(),length(),PackHeadLen, (char*)&*dstBuf.begin(), dst_len);
			if ( !ret ) return false;

			dstBuf.resize(dst_len);
		//	data_.assign(dstBuf.begin(),dstBuf.begin() + dst_len);
			body_length_ = dst_len - PackHeadLen;
			data_.swap(dstBuf);
		}
		break;
	default:
		break;
	}
	return true;
}

bool CImMsg::decode_packet()
{
	PPackHead pBasePack = (PPackHead)head();
	if (pBasePack->proKey1 != PROTOCOL_KEY1 || pBasePack->proKey2 != PROTOCOL_KEY2)  return false;
	if (pBasePack->dataLen < MsgHeadLen) return false;

	unsigned int desCrc32 = crc32((unsigned char*)body(),body_length_);
	if (desCrc32 != pBasePack->crc32) return false;

	if(!UnCompressed()) return false;

	pBasePack = (PPackHead)head();
	pBasePack->dataLen = body_length_;
	return true;
}

bool CImMsg::UnCompressed()
{
	PPackHead pBasePack = (PPackHead)head();
	switch (pBasePack->Compressed)
	{
	case cmpr_zip:
		{
			//unsigned long dst_len = pBasePack->iRatio * pBasePack->dataLen + sizeof(PackHead);
			unsigned long dst_len = pBasePack->unzipLen + sizeof(PackHead);
			std::vector<char> dstBuf(dst_len);
		//	memcpy((void*)&*dstBuf.begin(),data(),header_length);

			long ret = UnZipBuffer((const char*)head(),length(),PackHeadLen, (char*)&*dstBuf.begin(), dst_len);
			if ( !ret ) return false;

		//	data_.resize(dst_len);
		//	data_.assign(dstBuf.begin(),dstBuf.begin() + dst_len);
			body_length_ = dst_len - PackHeadLen;
			data_.swap(dstBuf);
		}
		break;
	case cmpr_rc4:
		{
			CRc4Encrypt rc4;
			rc4.EncryptBuffer((unsigned char *)body(),body_length_);
		}
		break;
	case cmpr_zip_rc4:
		{
			//unsigned long dst_len = pBasePack->iRatio * pBasePack->dataLen + sizeof(PackHead);
			unsigned long dst_len = pBasePack->unzipLen + sizeof(PackHead);
			std::vector<char> dstBuf(dst_len);
		//	memcpy((void*)&*dstBuf.begin(),data(),header_length);

			long ret = UnZipBuffer((const char*)head(),length(),PackHeadLen, (char*)&*dstBuf.begin(), dst_len);
			if ( !ret ) return false;

		//	data_.resize(dst_len);
		//	data_.assign(dstBuf.begin(),dstBuf.begin() + dst_len);
			body_length_ = dst_len - PackHeadLen;
			data_.swap(dstBuf);

			CRc4Encrypt rc4;
			rc4.EncryptBuffer((unsigned char *)body(),body_length_);
		}
		break;
	default:
		break;
	}
	return true;
}