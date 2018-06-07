#include <windows.h>  
#include <stdio.h>  
#include "graphics.h"
#include "globals.h"

int framerate=60;
int fullscreen=0;
int use_sai=0;

//�ؽ�ת����Palette, ��Genesis��ɫ����bbb0ggg0rrr0ת��ΪPC16λɫ
//(PC16λɫ������555: 0rrr rrgg gggb bbbb ����565: rrrr rggg gggb bbbb, ���߳���)
void Recalculate_Palettes(){
	int r, g, b;
	int rf, gf, bf;

	for(r = 0; r < 0x10; r++){			//ģ��rrr0 (r��B0������, 0,2,4,6,8,A,C,E)
		for(g = 0; g < 0x10; g++){		//ģ��ggg0
			for(b = 0; b < 0x10; b++){	//ģ��bbb0
				//����������Ϊ6λ (ע��r,g,b��B0������, ��Genesis�ǹ̶�0)
				//תPC��ʽʱ, r����b����������1λ, ��5λ, g�������� (565ʱ)
				rf = (r & 0xE) << 2;	//rrr000
				gf = (g & 0xE) << 2;	//ggg000
				bf = (b & 0xE) << 2;	//bbb000

				rf =(int) ((double) (rf) * ((double) (255) / 224.0));
				gf =(int) ((double) (gf) * ((double) (255) / 224.0));
				bf =(int) ((double) (bf) * ((double) (255) / 224.0));

				//������Ƕλ, ���ó���6λ�ܱ�ʾ�ķ�Χ
				if (rf < 0) rf = 0;
				else if (rf > 0x3F) rf = 0x3F;
				if (gf < 0) gf = 0;
				else if (gf > 0x3F) gf = 0x3F;
				if (bf < 0) bf = 0;
				else if (bf > 0x3F) bf = 0x3F;

				//�ϳ�16λɫ
				//r����b��������1λ, ��5λ, g�������� (565ʱ)������1λ(555ʱ)
				//��������λ�����Ե�λ��
				rf = (rf >> 1) << 11;
				gf = (gf >> 0) << 5;
				bf = (bf >> 1) << 0;

				//����ת���õ�PC16λɫ,PC32λɫ
				//(ע���±�, ��Genesisɫ�ʸ�ʽ: bbb0ggg0rrr0)
				//(ע�����ڼ��������ʱr,g,b��B0������, 
				// ����[bbb0ggg0rrr0]��[bbb0ggg0rrr1]��Ӧ��ֵ��ͬ, ��������)
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
			fprintf(fherr, "��Ļˢ���ʹ���\n");
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
			fprintf(fherr, "ֻ֧��16λɫ��32λɫ, ���л�������16λɫ��32λɫ\n");
		return 0;
	}

	Flag_Clr_Scr = 1;


	End_DDraw();

	if (!fullscreen){
		if (Init_DDraw(g_hwnd)==0){
			if (fherr)
				fprintf(fherr, "DDRAW��ʼ��ʧ��\n");
			return 0;
		}
	}else{
		if (Init_DDraw_FS(g_hwnd)==0){
			if (fherr)
				fprintf(fherr, "DDRAW��ʼ��ʧ��\n");
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
