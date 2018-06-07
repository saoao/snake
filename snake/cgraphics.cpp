#include <windows.h>  
#include <stdio.h>  
#include "graphics.h"
#include "globals.h"

int framerate=60;
int fullscreen=0;
int use_sai=0;

//重建转换表Palette, 将Genesis的色彩字bbb0ggg0rrr0转换为PC16位色
//(PC16位色可能是555: 0rrr rrgg gggb bbbb 或是565: rrrr rggg gggb bbbb, 后者常见)
void Recalculate_Palettes(){
	int r, g, b;
	int rf, gf, bf;

	for(r = 0; r < 0x10; r++){			//模拟rrr0 (r的B0被忽略, 0,2,4,6,8,A,C,E)
		for(g = 0; g < 0x10; g++){		//模拟ggg0
			for(b = 0; b < 0x10; b++){	//模拟bbb0
				//各分量都化为6位 (注意r,g,b的B0被忽略, 因Genesis是固定0)
				//转PC格式时, r分量b分量会右移1位, 成5位, g分量不变 (565时)
				rf = (r & 0xE) << 2;	//rrr000
				gf = (g & 0xE) << 2;	//ggg000
				bf = (b & 0xE) << 2;	//bbb000

				rf =(int) ((double) (rf) * ((double) (255) / 224.0));
				gf =(int) ((double) (gf) * ((double) (255) / 224.0));
				bf =(int) ((double) (bf) * ((double) (255) / 224.0));

				//各分量嵌位, 不得超过6位能表示的范围
				if (rf < 0) rf = 0;
				else if (rf > 0x3F) rf = 0x3F;
				if (gf < 0) gf = 0;
				else if (gf > 0x3F) gf = 0x3F;
				if (bf < 0) bf = 0;
				else if (bf > 0x3F) bf = 0x3F;

				//合成16位色
				//r分量b分量右移1位, 成5位, g分量不变 (565时)或右移1位(555时)
				//各分量移位至各自的位置
				rf = (rf >> 1) << 11;
				gf = (gf >> 0) << 5;
				bf = (bf >> 1) << 0;

				//存入转换好的PC16位色,PC32位色
				//(注意下标, 是Genesis色彩格式: bbb0ggg0rrr0)
				//(注意由于计算各分量时r,g,b的B0被忽略, 
				// 所以[bbb0ggg0rrr0]与[bbb0ggg0rrr1]对应的值相同, 其余类推)
				Palette[(b << 8) | (g << 4) | r] = rf | gf | bf;
				
				//32 bit version
				rf = (r & 0xE) << 4;	//rrr00000
				gf = (g & 0xE) << 4;	//ggg00000
				bf = (b & 0xE) << 4;	//bbb00000
				rf =(int) ((double) (rf) * ((double) (255) / 224.0));
				gf =(int) ((double) (gf) * ((double) (255) / 224.0));
				bf =(int) ((double) (bf) * ((double) (255) / 224.0));
				if (rf < 0) rf = 0;
				else if (rf > 0xFF) rf = 0xFF;
				if (gf < 0) gf = 0;
				else if (gf > 0xFF) gf = 0xFF;
				if (bf < 0) bf = 0;
				else if (bf > 0xFF) bf = 0xFF;
				rf <<=16;
				gf <<=8;
				Palette32[(b << 8) | (g << 4) | r] = rf | gf | bf;
			}
		}
	}
}

void Set_disp_width(int mode){
	CRam_Flag=1;
	VRam_Flag=1;
	if (!mode){
		H_Cell=32;
		H_Win_Mul=5;
		H_Pix=256;
		H_Pix_Begin=32;
		if (Win_X_Pos>32)
			Win_X_Pos=32;
	}else{
		H_Cell=40;
		H_Win_Mul=6;
		H_Pix=320;
		H_Pix_Begin=0;
		if (Win_X_Pos>40)
			Win_X_Pos=40;
	}
}

void Set_scroll_mode(int hmode, int vmode){
//hmode		0=all	2=tile	3=line
//vmode		0=all	1=2t
	static hmasks[]={0x0000, 0x0000, 0x01F8, 0x01FF};
	static vmasks[]={0x0000, 0x007e};

	if (hmode>=0){
		H_Scroll_Mask =hmasks[hmode&3];
	}
	if (vmode>=0){
		V_Scroll_MMask =vmasks[vmode&1];
	}
}

void Set_scroll_size(int mode){
//mode
//	0	V32*H32
//	1	V32*H64
//	2	V32*H128
//	3	V64*H32
//	4	V64*H64
//	5	V128*H32
	static int settbl[]={
		5,31,31,
		6,31,63,
		7,31,127,
		5,63,31,
		6,63,63,
		5,127,31
	};
	int *ptbl;

	ptbl=&settbl[(mode<<1)+mode];
	H_Scroll_CMul=*ptbl++;
	V_Scroll_CMask=*ptbl++;
	H_Scroll_CMask=*ptbl++;
}

void Set_window_pos(int x, int y){
	if (x>=0){
		Win_lr=x;
		x =(x&0x1f)<<1;
		Win_X_Pos =(x>H_Cell)? H_Cell:x;
	}
	if (y>=0){
		Win_ud=y;
		Win_Y_Pos =y & 0x1f;
	}
}

void Init_graphics(){
	Recalculate_Palettes();
	Set_disp_width(0);
	Set_scroll_mode(0,0);
	Set_scroll_size(0);
	Set_window_pos(0x94,0x9e);
	Disp_state=1;
	VDP_Current_Line=0;
	CRam_Flag=1;
	VRam_Flag=0;
	Auto_Inc=2;

	SP_colide=0;

	Vbl_state=1;
	Hbl_state=DMA_state=STE_state=interlace_state=0;
}

int initVideo(){
	DEVMODE dmode;
	unsigned int freq;

	EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, &dmode);
	freq =dmode.dmDisplayFrequency;
	if (freq<57){
		if (fherr)
			fprintf(fherr, "屏幕刷新率过低\n");
		return 0;
	}
	else if (freq<60){
		framerate=freq;
	}else{
		framerate=60;
	}
	Crt_BPP =dmode.dmBitsPerPel;
	if (Crt_BPP!=16 && Crt_BPP!=32){
		if (fherr)
			fprintf(fherr, "只支持16位色或32位色, 请切换到桌面16位色或32位色\n");
		return 0;
	}

	Flag_Clr_Scr = 1;


	End_DDraw();

	if (!fullscreen){
		if (Init_DDraw(g_hwnd)==0){
			if (fherr)
				fprintf(fherr, "DDRAW初始化失败\n");
			return 0;
		}
	}else{
		if (Init_DDraw_FS(g_hwnd)==0){
			if (fherr)
				fprintf(fherr, "DDRAW初始化失败\n");
			return 0;
		}
		Crt_BPP =16;
	}

	Init_graphics();

	return 1;
}

extern short vscolls_lines[224];
extern int weffect_on;

void DrawBG(){
	for (VDP_Current_Line=0; VDP_Current_Line<SCREEN_H; VDP_Current_Line++){
		Render_Line();
	}
}
