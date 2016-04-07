
#include "Rc4Encrypt.h"
#include <stdio.h>
#include <string.h>

CRc4Encrypt::CRc4Encrypt(void)
{

    m_KeySize = 0;
    m_DefaultRc4Key = NULL;

    this->SetKey(NULL,0);

    return;
}

CRc4Encrypt::CRc4Encrypt( unsigned char *Rc4Key )
{
    m_KeySize = 0;
    m_DefaultRc4Key = NULL;

    this->SetKey(Rc4Key,RC4_DEFAULT_KEY_SIZE);
    return;
}

CRc4Encrypt::~CRc4Encrypt(void)
{
    if (m_DefaultRc4Key != m_Rc4KeyBuffer)
    {
        if (NULL != m_DefaultRc4Key)
        {
            delete [] m_DefaultRc4Key;
            m_DefaultRc4Key = NULL;
        }
    }
}

void CRc4Encrypt::SetKey( unsigned char *Rc4Key,int Rc4KeySize )
{
    unsigned char DefaultKey [RC4_DEFAULT_KEY_SIZE] = {
        0x48, 0xB8, 0x90, 0x78, 0x56, 0x34, 0x12, 0x00,
        0x00, 0x00, 0xFF, 0xE0, 0x00, 0x00, 0x00, 0x00
    };

    int  KeySize;

    if (Rc4KeySize <= 0 || !Rc4Key)
    {
        KeySize = RC4_DEFAULT_KEY_SIZE;
    }
    else
    {
        KeySize = Rc4KeySize;
    }

    if (m_DefaultRc4Key)
    {
        delete []m_DefaultRc4Key;
        m_DefaultRc4Key = NULL;
    }

    m_DefaultRc4Key = new unsigned char[KeySize];
    if (m_DefaultRc4Key)
    {
		memcpy(m_DefaultRc4Key,Rc4Key?Rc4Key:DefaultKey,KeySize);        
        m_KeySize = KeySize;
    }
    
    return;
}

void CRc4Encrypt::RC4Init()
{
    unsigned char KeyMap[0x100] = {0}; 
    int  i = 0;
    unsigned char cbTmp = 0;
    unsigned char cbIdx = 0;


    for (i = 0;i < 0x100; i++)
    {  
        m_Rc4KeyBuffer[i] = (unsigned char)i;
        KeyMap[i] = m_DefaultRc4Key[i % m_KeySize];            
    }

    for (i = 0; i < 0x100; i++)
    {
        cbIdx = m_Rc4KeyBuffer[i] + cbIdx + KeyMap[i];
        cbTmp = m_Rc4KeyBuffer[i];
        m_Rc4KeyBuffer[i] = m_Rc4KeyBuffer[cbIdx];
        m_Rc4KeyBuffer[cbIdx] = cbTmp; 
    }
}

void CRc4Encrypt::EncryptBuffer( unsigned char *DataBuffer,int DataSize )
{
    unsigned char *TempBuffer;

    if (DataSize <= 0)
    {
        return;
    }
    
    TempBuffer = new unsigned char [DataSize];
    
    if (!TempBuffer)
    {
        return;
    }

    RC4Init();
    RC4Encrypt(DataBuffer,DataSize,TempBuffer);
	memcpy(DataBuffer,TempBuffer,DataSize);
   
    delete [] TempBuffer;
    
    return;

}

void CRc4Encrypt::RC4Encrypt( unsigned char *lpEncryptBuffer, int BufferSize, unsigned char *lpNewBuffer )
{
    unsigned char     cnIdx = 0; 
    unsigned char     n = 0; 
    unsigned char     m = 0; 
    unsigned char     nTmp = 0;
    int               i  = 0;


    for (i = 0 ; i< BufferSize; i++)
    {

        cnIdx = (unsigned char)(i + 1);   
        n = m_Rc4KeyBuffer[cnIdx];
        m += n;

        m_Rc4KeyBuffer[cnIdx] = m_Rc4KeyBuffer[m];
        m_Rc4KeyBuffer[m] = n;
        nTmp = n + m_Rc4KeyBuffer[cnIdx];
        lpNewBuffer[i] = m_Rc4KeyBuffer[nTmp] ^ lpEncryptBuffer[i];

    }

    return;
}
