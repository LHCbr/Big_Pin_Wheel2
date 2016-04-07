#ifndef RC4_ENCRYPT_H_
#define RC4_ENCRYPT_H_

#define RC4_DEFAULT_KEY_SIZE  0x10
#define RC4_KEYBUFFER_SIZE  0x100

class CRc4Encrypt
{
private:
    unsigned char *m_DefaultRc4Key;
    int           m_KeySize;

    unsigned char m_Rc4KeyBuffer[RC4_KEYBUFFER_SIZE];

private:
    void RC4Init();
    void RC4Encrypt(
        unsigned char *lpEncryptBuffer,
        int BufferSize,
        unsigned char *lpNewBuffer        
        );

public:
    CRc4Encrypt(void);
    CRc4Encrypt(unsigned char *Rc4Key);
    CRc4Encrypt(unsigned char *Rc4Key,int Rc4KeySize);
    void SetKey( unsigned char *Rc4Key,int Rc4KeySize);
    void EncryptBuffer(unsigned char *DataBuffer,int DataSize);
    ~CRc4Encrypt(void);
};


#endif