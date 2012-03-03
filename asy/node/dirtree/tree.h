

#ifndef __TREE_H__
#define __TREE_H__


typedef enum{
	NODE_TYPE_DIR,
	NODE_TYPE_FILE,
	NODE_TYPE_LAST
}node_type_t;

/* tree node */
typedef struct _TNODE{
	struct _TNODE*   dad;   /* parent; null if root */
	struct _TNODE*   sib;   /* right sibling; null if last child */
	struct _TNODE*   kid;   /* first child; null if leaf */
	
	node_type_t      type;
	char*            txt;   /* null terminated string */
}TNODE;


#ifdef __cplusplus
extern "C"{
#endif


TNODE* tnode_new(node_type_t type);
void tnode_free(TNODE* node);
TNODE* tnode_last_sib(TNODE* node);
TNODE* tnode_last_kid(TNODE* node);
TNODE* tnode_left_sib(TNODE* node);
int tnode_attach(TNODE* dad, TNODE* node);
void tnode_detach(TNODE* node);
void tnode_delete(TNODE* node);


#ifdef __cplusplus
}
#endif



#endif /* __TREE_H__ */
