#ifndef GRAPHICS_H
#define GRAPHICS_H

#ifdef __cplusplus
extern "C" {
#endif

extern int framerate;
extern int fullscreen;
extern int Have_MMX;
extern int use_sai;

//struct Reg_VDP_Type {
	//unsigned int Set1;			-->Hbl_state
	//unsigned int Set2;			-->Vbl_state, Disp_state, DMA_state
	//unsigned int Pat_ScrA_Adr;	-->ScreenA
	//unsigned int Pat_Win_Adr;		-->Window
	//unsigned int Pat_ScrB_Adr;	-->ScreenB
	//unsigned int Spr_Att_Adr;		-->Sprite
	//unsigned int Reg6;
	//unsigned int BG_Color;		-->BG_Color
	//unsigned int Reg8;
	//unsigned int Reg9;
	//unsigned int H_Int;			-->HInt_Counter
	//unsigned int Set3;			-->void Set_scroll_mode(int hmode, int vmode)
	//unsigned int Set4;			-->STE_state, interlace_state
	//unsigned int H_Scr_Adr;		-->HSRam
	//unsigned int Reg14;
	//unsigned int Auto_Inc;		-->Auto_Inc
	//unsigned int Scr_Size;		-->void Set_scroll_size(int mode)
	//unsigned int Win_H_Pos;		-->Win_X_Pos, Win_lr -->Set_window_pos(int x, int y)
	//unsigned int Win_V_Pos;		-->Win_Y_Pos, Win_ud
	//unsigned int DMA_Lenght_L;
	//unsigned int DMA_Lenght_H;
	//unsigned int DMA_Src_Adr_L;
	//unsigned int DMA_Src_Adr_M;
	//unsigned int DMA_Src_Adr_H;
	//unsigned int DMA_Lenght;
	//unsigned int DMA_Address;
//};

//set directly
extern int	Hbl_state, Vbl_state, Disp_state, DMA_state;
extern int	STE_state;
extern int	interlace_state;

extern int	CRam_Flag;
extern int	VRam_Flag;

extern int	BG_Color;					//0  0  CPT1  CPT0  COL3  COL2  COL1  COL0

extern int	HInt_Counter;

extern int	Auto_Inc;

extern int VDP_Current_Line;


//by Set_disp_width(int mode)
extern int	H_Cell;
extern int	H_Win_Mul;
extern int	H_Pix;
extern int	H_Pix_Begin;

//Set_scroll_mode(int hmode, int vmode)
extern int	H_Scroll_Mask;
extern int	V_Scroll_MMask;

//by Set_scroll_size(int mode)
extern int	H_Scroll_CMul;
extern int	H_Scroll_CMask;
extern int	V_Scroll_CMask;

//by Set_window_pos(int x, int y)
extern int	Win_X_Pos, Win_Y_Pos;
extern int	Win_lr, Win_ud;

//clear directly, set by graphics routine
extern int	SP_colide;					//B5：1=有任何2个sprite的非透明点碰撞

extern unsigned char VRam[0x115580];
extern unsigned short CRam[128];
extern unsigned int ScreenA[64*64];
extern unsigned int ScreenB[64*64];
extern unsigned int Window[64*32];
extern unsigned short Sprite[80*4];
extern unsigned short HSRam[240*2];
extern unsigned short VSRam[64*2];

extern unsigned short MD_Screen[336 * 240];
extern unsigned int MD_Screen32[336 * 240];
extern unsigned short MD_Palette[256];
extern unsigned short Palette[0x1000];
extern unsigned int Palette32[0x1000];
extern int Crt_BPP;
extern unsigned long TAB336[336];

extern struct
{
	int Pos_X;
	int Pos_Y;
	unsigned int Size_X;
	unsigned int Size_Y;
	int Pos_X_Max;
	int Pos_Y_Max;
	unsigned int Num_Tile;
	int dirt;
} Sprite_Struct[256];

void Render_Line();
void Check_MMX();
void Blit_2xSAI_MMX(unsigned char *Dest, int pitch, int x, int y, int offset);

#ifdef __cplusplus
};
#endif

void Set_disp_width(int mode);
void Set_scroll_mode(int hmode, int vmode);
void Set_scroll_size(int mode);
void Set_window_pos(int x, int y);
void Init_graphics();


#define SCREEN_W 320
#define SCREEN_H 224
#define RENDER_W 336

int initVideo();
void DrawBG();

#endif