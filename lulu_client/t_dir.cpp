#include "t_dir.h"

#include "t_num.h"
#include "t_base.h"

#include <string.h>

int dir_Create(char* _pcDirName)
{
	struct stat stStat;
	if (_pcDirName == NULL || _pcDirName[0] == '\0')
	{
		return -1;
	}
	//以下是对几种情况的判断，存在但不是目录，存在且是目录，不存在且创建成功，不存在且创建失败
	if(stat((char *)_pcDirName, &stStat) == 0)
    {
        if(!S_ISDIR(stStat.st_mode))
        {
            if(mkdir((char *)_pcDirName, S_IRWXU|S_IRWXG|S_IRWXO) == 0)
            {
                //printf("%s existed,but it's not a direct.Create %s direct successed \n", _pcDirName, _pcDirName);
				chmod((char *)_pcDirName, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
				return 0;
            }
            else
            {
                //printf("%s existed,but it's not a direct.Create %s direct failed\n", _pcDirName, _pcDirName);
				return -1;
            }
        }
		else
		{
			//目录已存在则直接更改权限
			//printf("%s existed, and it's a direct.Now will chage its mode!\n", _pcDirName);
			chmod((char *)_pcDirName, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
			return 0;
		}
    }
    else
    {
        if(mkdir((char *)_pcDirName, S_IRWXU|S_IRWXG|S_IRWXO) == 0)
        {
            //printf("%s not existed.Create %s direct successed \n", _pcDirName, _pcDirName);
			chmod((char *)_pcDirName, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
			return 0;
        }
        else
        {
            //printf("%s not existed.Create %s direct failed \n", _pcDirName, _pcDirName);
			return -1;
        }
    }
	return 0;
}

int dir_IsExist(char *_pcDir)
{
	struct stat file_info;

	#if 0
	文件状态存储结构：struct stat file_info;
	获取文件状态：stat(filename, &file_info);
	文件类型和权限：mode_t mode = file_info.st_mode;
	mode_t其实就是一个整型，例如0777,第一个数即为文件类型
	使用系统相关宏来判断更方便
	if ( S_ISDIR(mode) ) /* 目录 */
	if ( S_ISREG(mode) ) /* 文件 */
	if ( S_ISLNK(mode) ) /* 链接 */
	#endif

	return !stat(_pcDir, &file_info);
}


int dir_IsDir(char *_pcDir)
{
	struct stat file_info;

	if(!stat(_pcDir, &file_info))
	{
		return S_ISDIR(file_info.st_mode);
	}
	else
	{
		return 0;
	}
}

int dir_IsSpecialDir(char *_pcDir)
{
	return 0 == strcmp(_pcDir, ".") || 0 == strcmp(_pcDir, "..");
}

int dir_IsFile(char *_pcDir)
{
	struct stat file_info;

	if(!stat(_pcDir, &file_info))
	{
		return S_ISREG(file_info.st_mode);
	}
	else
	{
		return 0;
	}
}

int dir_IsLink(char *_pcDir)
{
	struct stat file_info;

	if(!stat(_pcDir, &file_info))
	{
		return S_ISLNK(file_info.st_mode);
	}
	else
	{
		return 0;
	}
}


char* dir_DirName(char *_pcInDir, char *_pOutDir, int _iOutLen)
{
	if(NULL == _pcInDir || NULL == _pOutDir)
	{
		dbg();
		return NULL;
	}

	dbgprintf(0, "DirName:%s", _pcInDir);

	int i = 0;
	int Len = strlen(_pcInDir);

	for(i = Len - 1; i >= 0; i--)
	{
		if('/' == _pcInDir[i])
		{
			break;
		}
	}

	if(i > 0)
	{
		Len = TMIN(i, _iOutLen - 1);
		strncpy(_pOutDir, _pcInDir, Len);

		_pOutDir[Len] = 0;
	}
	else
	{
		_pOutDir[0] = 0;
	}
	

	return _pOutDir;
}

void dir_CreateTree(char *_pcDir)
{  
 	dbgprintf(0, "createTree:%s", _pcDir);
	
	if(dir_IsExist(_pcDir))
	{  
	    return;  
	}

	char pcNewDir[64];

	dir_DirName(_pcDir, pcNewDir, 64);

	dbgprintf(0, "pcNewDir:%s", pcNewDir);

	if(0 == pcNewDir[0])
	{
		return;
	}

	if(!dir_IsExist(pcNewDir))
	{  
		dir_CreateTree(pcNewDir);  

		dbgprintf(0, "mkdir:%s", pcNewDir);
		
		mkdir(pcNewDir, 0777);
	}
  
	return;  
} 

void dir_Delete(char *_pcDir)
{
	remove(_pcDir);
}


