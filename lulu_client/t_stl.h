#ifndef _T_STL_H_
#define _T_STL_H_

#define LIST_TWO_WAY_LINKED	1

// 使用list,pool，第一个元素必须为TStlHead
// 使用listex,poolex，则不需要包含TStlHead
typedef struct StlHead
{
#if LIST_TWO_WAY_LINKED
	struct StlHead *m_Previous;
#endif
	struct StlHead *m_Next;
	
}TStlHead;

#endif
