#ifndef _T_BINARY_TREE_H_
#define _T_BINARY_TREE_H_

typedef void TBinaryTree;

// 二叉树节点的头
typedef struct BinaryTreeNodeHead
{
	struct BinaryTreeNodeHead *m_ptLeft;	// 左节点
	struct BinaryTreeNodeHead *m_ptRight;	// 右节点
	struct BinaryTreeNodeHead *m_ptNext;	// 当插入节点的值相同，维护一个列表

}TBinaryTreeNodeHead;

// 遍历模式
enum
{
	BINARY_TREE_DISPLAY_BEFORE,	// 前序
	BINARY_TREE_DISPLAY_MIDDLE,	// 中序
	BINARY_TREE_DISPLAY_AFTER	// 后序
};

// 节点比较结果
enum
{
	BINARY_TREE_COMPARE_UNKNOWN = -1,	// 未知错误
	BINARY_TREE_COMPARE_DO = 0,			// 找到了节点
	BINARY_TREE_COMPARE_PASS,			// 找到了节点，不做处理，继续搜索
	BINARY_TREE_COMPARE_LEFT,			// 搜索左树
	BINARY_TREE_COMPARE_RIGHT,			// 搜索右树
};

// 节点比较函数
// _ptNode1 节点1
// _ptNode2 节点2
// 返回值0 _ptNode1=_ptNode2；1 _ptNode1>_ptNode2；2 _ptNode1<_ptNode2
typedef int(*FBinaryTreeCompareFun)(int _iType, void *_ptNode1, void *_ptNode2);

// 查找比较函数
// _ptNode 节点
// _ptKey 值
// 返回值0 _ptNode1=_ptKey；1 _ptNode1>_ptKey；2 _ptNode1<_ptKey
//typedef int(*FBinaryTreeFindFun)(int _iType, void *_ptNode, void *_ptKey);

// 处理函数
typedef int(*FTraversalNode)(void *_ptNode);
// 处理函数
typedef int(*FTraversalNode2)(void *_ptNode, void *_ptParam);

// 拷贝函数
// _ptDstNode 目标节点
// _ptSrcNode 源节点
typedef int(*FBinaryTreeCopyFun)(void *_ptDstNode, void *_ptSrcNode);

// 析构函数
// _ptNode 目标节点
typedef int(*FBinaryTreeDestroyFun)(void *_ptNode);


// 创建树
// _iNodeSize 树节点的大小
TBinaryTree* binary_tree_Create(int _iNodeSize,
										FBinaryTreeCompareFun _pfBinaryTreeCompare, 
										//FBinaryTreeFindFun _pfBinaryTreeFind,
										FBinaryTreeCopyFun _pfBinaryTreeCopy,
										FBinaryTreeDestroyFun _pfBinaryTreeDestroy);

// 插入节点
int binary_tree_Insert(TBinaryTree *_ptBinaryTree, void *_ptNode);

// 查找节点,将查找到的节点复制到_ptNodeArray
// _ptKey 参考
// _ptNodeArray 存储查找到的节点
// _iMaxCount 查找的最多节点数
int binary_tree_Find(TBinaryTree *_ptBinaryTree, int _iType, void *_ptKey, void *_ptNodeArray, int _iMaxCount);

// 获取节点,将查找到的节点指针，保存到_pptNodeArray
// 因为Remove等操作 会造成节点的改变，因此这个方法不严谨
// _ptKey 参考
// _pptNodeArray 存储查找到的节点指针
// _iMaxCount 查找的最多节点数
int binary_tree_Get(TBinaryTree *_ptBinaryTree, int _iType, void *_ptKey, void **_pptNodeArray, int _iMaxCount);

// 移除一个节点,通过回调函数，比较节点是否相同
int binary_tree_RemoveByValue(TBinaryTree *_ptBinaryTree, void *_ptNode);

// 移除一个节点,比较节点指针判断是否相同
int binary_tree_Remove(TBinaryTree *_ptBinaryTree, void *_ptNode);

// 遍历,对每个节点调用_pfTraversalNode函数
int binary_tree_Traversal(TBinaryTree *_ptBinaryTree, FTraversalNode _pfTraversalNode);

// 遍历,对每个节点调用_pfTraversalNode2函数
int binary_tree_Traversal2(TBinaryTree *_ptBinaryTree, FTraversalNode2 _pfTraversalNode2, void* _ptParam);


/** @brief 复制所有节点到内存
 *@param[in] _ptBinaryTree  二叉树
 *@param[in] _iStructSize  二叉树存储的结构体的大小
 *@param[in] _szBuf  要复制到的目标内存
 *@param[in] _szBuf  要复制到的目标内存
 *@param[in] _iMaxLen  内存最大值
 *@param[out] _piCopyPos  内存开始复制的位置
 *@param[out] _piCount  复制的个数
*/
int binary_tree_CopyAllNode(TBinaryTree *_ptBinaryTree, int _iStructSize, 
	char* _szBuf, int _iMaxLen, int *_piCopyPos, int *_piCount);

/** @brief    得到根节点
  * @param[in]  _ptBinaryTree	树实例
  * @return  返回根节点
  */
TBinaryTreeNodeHead *binary_tree_GetHead(TBinaryTree *_ptBinaryTree);


// 打印
int binary_tree_Display(TBinaryTree *_ptBinaryTree, int _iType);

// 清空
int binary_tree_Clear(TBinaryTree *_ptBinaryTree);

// 析构
int binary_tree_Destroy(TBinaryTree *_ptBinaryTree);

#endif
