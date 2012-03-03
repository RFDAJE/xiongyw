#include   <stdlib.h> 
#include   <stdio.h> 
#include   <dirent.h> 
#include   <sys/stat.h> 
#include   <errno.h> 
#include   <string.h>


#include "tree.h"


const char head[] = 
"import fontsize;\n"
"import \"../node/node.asy\" as node;\n\n"
"settings.tex = \"xelatex\";\n"
"texpreamble(\"\\usepackage{xeCJK}\");\n"
"texpreamble(\"\\setCJKmainfont{SimHei}\");\n"
"texpreamble(\"\\setmonofont[Path=../fonts/]{andalemo.ttf}\");\n\n";


const char usage[] = "Usage: dirtree [-a] root_dir\n"
                     "          -a    output both folders and files. Otherwise, only output folders by default.\n";

TNODE* build_tree(char* dir, int flag);
int get_node_name(TNODE* node, char name[]);
inline int define_a_node(TNODE* node);
int attach_two_nodes(TNODE* dad, TNODE* kid);
void output_nodes(TNODE* root);
char* get_last_part(char* path);
					 
#if (0)
#define DEBUG
#endif


int main(int argc, char *argv[])
{ 

	char rootname[100];
	char rootpath[1024];
	int  flag = 0; /* 0 means default, only output folders. */
                   /* 1 means output all */
	
	if(argc == 2){
		strcpy(rootpath, argv[1]);
	}
	else if(argc == 3){
		if(strcmp(argv[1], "-a") != 0){
			printf("%s", usage);
			exit(0);
		}
		flag = 1;
		strcpy(rootpath, argv[2]);
	}
	else{
		printf("%s", usage);
		exit(0);
	}
	
	/* delete the last '/' */
	if(rootpath[strlen(rootpath)-1] == '/')
		rootpath[strlen(rootpath)-1] = '\0';

	TNODE* root = build_tree(rootpath, flag);



        /********* draw the root tree *******/                             

	printf("%s\n\n", head);

	define_a_node(root);
	output_nodes(root);

	get_node_name(root, rootname);
	printf("\n\n//change the following to draw_call_sequence() to produce call sequence.\n");
	printf("picture root = draw_dir_tree(%s);\n", rootname);
	printf("attach(root.fit(), (0,0), SE);\n");
	
	
	return 0;
}     


/* recursive function: return the root node of the dir */
TNODE* build_tree(char* root, int flag)
{     
	DIR*               dir; 
	struct   dirent*   ptr; 
	struct   stat      st; 
	TNODE*   troot;

#ifdef DEBUG	
	printf("%s\n", root); 
#endif
	
	/* todo: check if "root" is a dir */
	troot = tnode_new(NODE_TYPE_DIR);
	
	if(!troot)
		return NULL;
	
	/* get the last part of the full path */
	troot->txt = strdup(get_last_part(root));

	dir = opendir(root); 

	while((ptr = readdir(dir)) != NULL){
		char full_path[2000];

		/* skip . and .. */
		if(strcmp(ptr->d_name, ".")==0 || strcmp(ptr->d_name, "..")==0){ 
			continue; 
	    } 
		
		strcpy(full_path, root); 
		strcat(full_path, "/");
		strcat(full_path, ptr->d_name);
	    
		stat(full_path, &st); 

		if(S_ISDIR(st.st_mode)){ 
			tnode_attach(troot, build_tree(full_path, flag));
		}
		else if(S_ISREG(st.st_mode)){
#ifdef DEBUG	
			printf("%s\n", ptr->d_name); 
#endif			
			if(flag){
				TNODE* kid = tnode_new(NODE_TYPE_FILE);
				kid->txt=strdup(ptr->d_name);
				tnode_attach(troot, kid);
			}
			else{
				/* do nothing */
			}
		}
		else{
			printf("!!!!!!!!!!!!!not expected!!!!!!!!!!!!!!!!!!!\n"); 
		}
	}	
	 
	closedir(dir); 
	
	return troot;
}       


int get_node_name(TNODE* node, char name[])
{
	sprintf(name, "%s_%08x", node->txt, (unsigned int)node);
	return 0;
}

inline int define_a_node(TNODE* node)
{
	char name[100];
	
	get_node_name(node, name);
	printf("node %-32s = node(\"%s\", \"%s\");\n", name, node->txt, node->type==NODE_TYPE_FILE? "f":"d");
}

int attach_two_nodes(TNODE* dad, TNODE* kid)
{
	char dadname[100], kidname[100];
	get_node_name(dad, dadname);
	get_node_name(kid, kidname);
	printf("%s.attach(%s);\n", dadname, kidname);
	return 0;
}

void output_nodes(TNODE* root)
{
	TNODE* kid;

	/* define all direct kids */
	if(NULL != (kid = root->kid)){
		while(kid){
			define_a_node(kid);
			kid = kid->sib;
		}
	}

	/* attach all direct kids */
	if(NULL != (kid = root->kid)){
		while(kid){
			attach_two_nodes(root, kid);
			kid = kid->sib;
		}
	}
	
	/* traverse on all direct kids */
	if(NULL != (kid = root->kid)){
		while(kid){
			output_nodes(kid);
			kid = kid->sib;
		}
	}
}





char* get_last_part(char* path)
{
	char* p;
	
	int len = strlen(path);
	
	for(p = path + len; p >=path; p --){
		if(*p == '/')
			return p + 1;
	}
	
	return path;
}
