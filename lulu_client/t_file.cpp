#include "t_file.h"
#include "t_dir.h"
#include "t_rand.h"
#include "t_time.h"
#include "t_base.h"

#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <pthread.h>

char* file_GetNotRepeat(char *_pcHomeDir, char* _pcSuffix, char *_pcOutFilePath, int _iMaxLen)
{
	if(NULL == _pcHomeDir || NULL == _pcOutFilePath)
	{
		if(_pcOutFilePath)
		{
			_pcOutFilePath[0] = 0;
		}
		
		dbg();
		return NULL;
	}
	
	int iFileCount = 1000;
	static int iFileIndex = 1000;
	static char pcDirName[64] = {0};
    static pthread_mutex_t _Mux = PTHREAD_MUTEX_INITIALIZER;
	pthread_mutex_lock(&_Mux);
	if(iFileIndex++ >= iFileCount)
	{
		iFileIndex = 0;
	}
	pthread_mutex_unlock(&_Mux);
	
	// 每iFileCount个文件，创建一个新的文件夹，以当前时刻命名
	if(iFileIndex == 0)
	{
		snprintf(pcDirName, 64, "%s%u/", _pcHomeDir, time_GetSecSince1970());

		dir_CreateTree(pcDirName);
	}

	snprintf(_pcOutFilePath, _iMaxLen, "%s%u%03d.%s", 
 				pcDirName, time_GetSecSince1970(), iFileIndex, _pcSuffix);

	return _pcOutFilePath;
}

void* file_OpenForWrite(char *_pcFileName)
{
	if(NULL == _pcFileName)
	{
		dbg();
		return NULL;
	}

	return fopen(_pcFileName, "w");
}

int file_Write(void *_ptFp, char *_pcData, int _iLen)
{
	if(NULL == _ptFp || NULL == _pcData || _iLen < 1)
	{
		dbg();
		return ERR;
	}

	//dbgprintf(0, "file_Write:%d", _iLen);

	fwrite(_pcData, 1, _iLen, (FILE *)_ptFp);

	return OK;
}

int file_Close(void *_ptFp)
{
	dbgprintf(0, "file_Close %x", _ptFp);
	//log2_WriteEx("file_Close %x", _ptFp);
	
	if(_ptFp)
	{
		fclose((FILE *)_ptFp);

		//log2_WriteEx("file_Close finish");
		
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int file_Save(char *_pcData, int _iLen, char *_pcDir, char *_pcSuffix, 
			char* _pcOutFileName, int _iFileNameMaxLen)
{
	int iFileCount = 1000;
	static int iFileIndex = 1000;
	static char pcDirName[64];

	// 每iFileCount个文件，创建一个新的文件夹，以当前时刻命名
	if(iFileIndex++ >= iFileCount)
	{
		iFileIndex = 0;
		snprintf(pcDirName, 64, "%s%u/", _pcDir, time_GetSecSince1970());

		dir_CreateTree(pcDirName);
	}

	snprintf(_pcOutFileName, _iFileNameMaxLen, "%s%u_%03d.%s", 
			pcDirName, time_GetSecSince1970(), 
			//rand_GetInt(0, 99), 
			iFileCount,
			_pcSuffix);

	dbgprintf(0, "file_Save SaveFile To %s", _pcOutFileName);

	FILE *fp = fopen(_pcOutFileName, "w");

	if(NULL == fp)
	{
		dbg();
		return ERR;
	}

	fwrite(_pcData, 1, _iLen, fp);

	fclose(fp);

	return OK;
}

int file_Flush(void *_ptFile)
{
	if(_ptFile)
	{
		fflush((FILE *)_ptFile);
		return OK;
	}
	else
	{
		dbg();
		return ERR;
	}
}

int file_ReadAll(char *_pcFileName, char *_pcData, int _iMaxLen)
{
	if(NULL == _pcFileName || NULL == _pcData || _iMaxLen < 1)
	{
		dbg();
		return ERR;
	}

	FILE *fp = fopen(_pcFileName, "r");

	if(NULL == fp)
	{
		dbg();
		return ERR;
	}

	fread(_pcData, 1, _iMaxLen, fp);

	fclose(fp);

	return OK;
}

void* file_OpenForRead(char *_pcFileName)
{
	return fopen(_pcFileName, "r");
}

int file_Read(void *_ptFile, char *_pcData, int _iMaxLen)
{
	FILE *fp = (FILE *)_ptFile;

	int iRet = -1;

	//dbgprintf(0, "file_Read %x,%x", _ptFile, fp);
	//log2_WriteEx("file_Read %x,%x", _ptFile, fp);
	
	if(fp)
	{
		iRet = fread(_pcData, 1, _iMaxLen, fp);

	//	dbgprintf(0, "file_Read %x %d", fp, iRet);
	//	log2_WriteEx("file_Read %x %d", fp, iRet);
	}

	return iRet;
}

int file_Seek(void *_ptFile, long int _lOffset, int _iWhence)
{
	FILE *fp = (FILE *)_ptFile;
	int iRet = -1;
	if(fp)
	{
		iRet = fseek(fp, _lOffset, _iWhence);
	}
	return iRet;
}

int file_GetSize(char *_pcFile)
{  
    int iSize = -1;     
	
    struct stat statbuff;  
	
    if(stat(_pcFile, &statbuff) >= 0)
	{ 
        iSize = statbuff.st_size;  
    }
	
    return iSize;  
}  


int file_Remove(char *_pcFileName)
{
	DIR *dir;
	struct dirent *dir_info;
	char pcFilePath[256];
	
	if(dir_IsFile(_pcFileName))
	{
		dir_Delete(_pcFileName);
		return OK;
	}
	else if(dir_IsDir(_pcFileName))
	{
		if((dir = opendir(_pcFileName)) == NULL)
		{
			dbg();
			return ERR;
		}
		
		while((dir_info = readdir(dir)) != NULL)
		{
			if(dir_IsSpecialDir(dir_info->d_name))
			{
				continue;
			}
			
			snprintf(pcFilePath, 256, "%s/%s", _pcFileName, dir_info->d_name);
			
			file_Remove(pcFilePath);
		}
	}

	return OK;
}




