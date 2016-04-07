#ifndef _T_RAND_H_
#define _T_RAND_H_

#define RAND_MODE_NUM		0x1		// 只有数字
#define RAND_MODE_L_CHAR	0x2		// 只有小写字母
#define RAND_MODE_U_CHAR	0x4		// 只有大写字母

// 包含所有数字和字母
#define RAND_MODE_ALL		(RAND_MODE_NUM | RAND_MODE_L_CHAR | RAND_MODE_U_CHAR)

/** @brief    随机int , 范围_iMin <= 返回值 < _iMax
  * @param[in]  _iMin	范围，最小值
  * @param[in]  _iMax	范围，最大值
  * @return  返回随机int值
  */
int rand_GetInt(int _iMin, int _iMax);

/** @brief    获取随机字符串
  * @param[in]  _iMode	生成字符串的类型
  * @param[out]  _pcOut	接收字符数组
  * @param[in]  _iMaxLen	生成字符个数
  * @return  返回随机字符串
  */
char* rand_GetString(int _iMode, char *_pcOut, int _iMaxLen);

#endif
