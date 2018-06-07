#ifndef GLOBALS_H
#define GLOBALS_H
#include "sdl/include/SDL_mixer.h"

#define X_MARGIN 16
#define MAX_PLAYER_NODES 8
#define HIDDEN_CNT 180
#define MAX_ENEMIES_NODES 48
#define MAX_ENEMIES 12
#define MAX_ENEMY_NODES 8
#define ENEMY_MOVE_CNT 360
#define ENEMY_INJURY_CNT 400
#define ENEMY_FOOD_CNT 1000

typedef void (*SUB) ();

struct SP_DATA{
	int							state;		//0=空闲	1=复活准备	2=自动进入
	int							len;		//仅用于头节点, 为身节点的数量(主角初值0)
	short						x;
	short						y;
	int							speed;
	int							hidden_cnt;	//仅用于主角的初始隐身
	int							is_auto;
	int							move_cnt;
	int							move_flag, last_move_flag;	//RLDU
	int							form;
	int							form_cnt;
	int							form_idx;
	int							injury_cnt, food_cnt;		//仅用于敌方蛇
	SP_DATA						*master_sp;
	unsigned short				master_mflags_array_idx;
	unsigned short				master_mflags_array[10];
	SP_DATA						*next;
};

struct SPRITE{
	short						spy;
	unsigned short				size_link;
	unsigned short				spti;
	short						spx;
};

struct STAGE_DATA{
	int							gfx_no;
	unsigned short				*bk_pages;
	int							xpages;
	int							ypages;
	short						h_scroll_max_pb;
	short						v_scroll_max_pb;
	int							color_no;
	int							snakes;
	char						*bgm_name;
};

extern unsigned char *snake_gfx;
extern Mix_Chunk* g_sound[];

extern int frame_count;

extern short h_scroll_pa, v_scroll_pa;
extern short h_scroll_pb, v_scroll_pb;

extern int pb_to_scroll;
extern int pb_scroll_flag;
extern int	pb_scroll_step;

extern SPRITE sprite_buf[80];
extern int sprite_cnt;

extern int color_no;
extern int color_change_mode;
extern int color_step;
extern unsigned short cram_buf[0x80];
extern unsigned short cram_buf_org[0x80];
extern int cram_dirty;


void init_VDP();
void write_hvscroll();
void sc_scroll_addrowcol();
int check_bg(int x, int y, int *dir_keys, int oflag);
void set_sp_end();
void draw_sp_objs();
void color_op();
void clear_crambuf();
void gfx_setting(int no, int addr);
void cats_setting(int cat_no, int addr);
void set_crambuf_by_no();
void draw_sc_by_pos(int tx, int ty);
int col_detect(SP_DATA *pobj1, SP_DATA *pobj2);
void init_for_explosion (SP_DATA *node);
unsigned char* write_msg(int tx, int ty, unsigned int tibase, unsigned int *buf, unsigned char *msg);

//data.cpp
extern unsigned int gfx_offset[];
extern unsigned short color_tbl[];
extern STAGE_DATA stage_data[];
extern unsigned int *sp_form_data[];
extern unsigned int title_tiles[];
extern unsigned short dingcm_colors[];
extern int dot_idx_shuffle[];
extern unsigned short cats_colors[];
extern unsigned char *end_msg[];

//winmain.cpp
extern HINSTANCE g_instance;
extern HWND g_hwnd;
extern FILE* fherr;
extern int stage;
extern int game_state;

//loadmus.cpp
int loadzipfile(char* zipfile,
					 char* filename,
					 char** destbuf,
					 int* filesize);

int loadfile(char* filename, char** destbuf, int* filesize);

//ddraw.cpp
extern int Flag_Clr_Scr;

void End_DDraw();
int Init_DDraw(HWND hWnd);
int Init_DDraw_FS(HWND hWnd);
int Clear_Primary_Screen(HWND hWnd);
int Flip(HWND hWnd);

//dinput.cpp
struct K_Def {
	unsigned int Start, Mode;
	unsigned int A, B, C;
	unsigned int X, Y, Z;
	unsigned int Up, Down, Left, Right;
	};

extern int P1_Keys;
extern int P1_Triggers;
extern unsigned char Keys[256];

int Init_Input(HINSTANCE hInst, HWND hWnd);
void Update_Controllers();
void End_Input();

//cgraphics.cpp

#define SND_TITLE		0
#define SND_START		1
#define SND_S_START		2
#define SND_CLEAR		3
#define SND_GAMEOVER	4
#define SND_RATING		5
#define SND_BLOW		6
#define SND_LAY_EGG		7
#define SND_P_EAT_EGG	8
#define SND_E_EAT_EGG	9
#define SND_REBORN		10
#define SND_P_INJURY	11
#define SND_E_INJURY	12

#endif