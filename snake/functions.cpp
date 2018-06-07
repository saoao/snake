#include <windows.h>
#include <stdio.h>
#include <memory.h>
#include "assert.h"
#include "graphics.h"
#include "globals.h"
#include "player.h"
#include "enemy.h"

unsigned short *get_sc_bktbl(int tx, int ty);
void set_sc_ti(unsigned short *sc_bktbl, int tx, int ty);

/*
void clear_crambuf(){
	memset(cram_buf, 0, sizeof(cram_buf));
	cram_dirty=1;
}

*/

void init_VDP(){
	int i;

	Disp_state=0;
	BG_Color=0x10;

	for (i=0; i<0x1000; i++){
		ScreenA[i]=ScreenB[i]=0;
	}
	memset(Sprite, 0, 80*8);
	memset(HSRam, 0, 240*4);
	memset(VSRam, 0, 64*4);

	Disp_state=1;
}

void write_hvscroll(){
	HSRam[0] =-h_scroll_pa;
	HSRam[1] =-h_scroll_pb;
	VSRam[0] =v_scroll_pa;
	VSRam[1] =v_scroll_pb;
}

void set_crambuf_by_no(){
	unsigned short *pbuf=cram_buf;
	unsigned short *psrc =&color_tbl[color_no<<7];
	int i;

	for (i=0; i<64; i++){
		*pbuf++=*psrc++;
	}
	for (i=64; i<128; i++){
		*pbuf++=Palette[*psrc++];
	}
	memcpy(cram_buf_org, cram_buf, sizeof(cram_buf));
	cram_dirty=1;
}

void color_op(){
	int mode =color_change_mode-2, step, step2, i;
	unsigned short *pclrs =cram_buf_org, temp;
	unsigned short *pbuf =cram_buf, cword, c16;

	if (mode<0)
		return;
	if ((step =color_step--)==0)
		color_change_mode=0;
	switch (mode){
	case 2:
		step =0xf-step;
	case 0:
		for (i=0; i<64; i++){
			temp =cword =*pclrs++;
			temp &=0xf;
			c16 =(temp>=step)?(temp-step):0;
			temp =cword;
			cword =(cword>>4) &0xf;
			c16 |=((cword>=step)?(cword-step):0)<<4;
			temp =(temp>>8) &0xf;
			c16 |=((temp>=step)?(temp-step):0)<<8;
			*pbuf++ =c16;
		}
		step<<=1;	step2 =step<<1;
		for (i=64; i<128; i++){
			temp =cword =*pclrs++;
			temp &=0x1f;
			c16 =(temp>=step)?(temp-step):0;
			temp =cword;
			cword =(cword>>5)&0x3f;
			c16 |=((cword>=step2)?(cword-step2):0)<<5;
			temp =(temp>>11)&0x1f;
			c16 |=((temp>=step)?(temp-step):0)<<11;
			*pbuf++ =c16;
		}
		break;
	case 3:
		step =0xf-step;
	case 1:
		/*
		for (i=0; i<64; i++){
			cbyte =((*pclrs++)&0xf)+step;
			c16 =((cbyte<=0xe)?cbyte:0xe)<<8;
			temp =cbyte =*pclrs++;
			cbyte =(cbyte>>4)+step;
			c16 |=((cbyte<=0xe)?cbyte:0xe)<<4;
			temp =(temp&0xf)+step;
			c16 |=(temp<=0xe)?temp:0xe;
			*pbuf++ =c16;
		}
		*/
		break;
	}
	cram_dirty =1;
}

void gfx_setting(int no, int addr){
	unsigned char *psrc=&snake_gfx[gfx_offset[no]], *pdest=&VRam[addr];
	unsigned int len =gfx_offset[no+1]-gfx_offset[no];
	memcpy (pdest, psrc, len);
}

void cats_setting(int cat_no, int addr){
	unsigned char *psrc=&snake_gfx[gfx_offset[4]], *pdest=&VRam[addr];
	unsigned int len =0x4e20;

	psrc +=cat_no*0x4e20;
	memcpy (pdest, psrc, len);
}

void draw_sc_by_pos(int tx, int ty){
	int row,col;
	int tx_v =tx;
	unsigned short *sc_bktbl;

	for (row =0; row<29; row++){
		tx =tx_v;
		sc_bktbl =get_sc_bktbl(tx, ty);
		for (col =0; col<33; col++){
			set_sc_ti(sc_bktbl, tx, ty);
			if ((++tx & 0x1f)==0)
				sc_bktbl =get_sc_bktbl(tx, ty);
		}
		ty++;
	}
}

static void sc_add_row(int tx, int ty){
	int col;
	unsigned short *sc_bktbl;

	sc_bktbl =get_sc_bktbl(tx, ty);
	for (col =0; col<33; col++){
		set_sc_ti(sc_bktbl, tx, ty);
		if ((++tx & 0x1f)==0)
			sc_bktbl =get_sc_bktbl(tx, ty);
	}
}

static void sc_add_col(int tx, int ty){
	int row;
	unsigned short *sc_bktbl;

	sc_bktbl =get_sc_bktbl(tx, ty);
	for (row =0; row<29; row++){
		set_sc_ti(sc_bktbl, tx, ty);
		if ((++ty & 0x1f)==0)
			sc_bktbl =get_sc_bktbl(tx, ty);
	}
}

static unsigned short *get_sc_bktbl(int tx, int ty){
	int xpages;
	unsigned short *ptbl =stage_data[stage].bk_pages;
	int pageidx;

	xpages =stage_data[stage].xpages;
	pageidx =(ty>>5)*xpages+(tx>>5);
	return &ptbl[pageidx<<10];
}

static void set_sc_ti(unsigned short *sc_bktbl, int tx, int ty){
	int scidx = ((ty&0x1f)<<6)+(tx&0x3f);
	int o_idx = ((ty&0x1f)<<5)+(tx&0x1f);

	assert(scidx<0x1000);

	int ti =sc_bktbl[o_idx], t;
	unsigned int ti32;

	t =ti&0x7ff;
	ti32 =((ti&0x8000)<<16) | ((ti &0x6000)<<15) | ((ti & 0x1800)<<15) | t;
	ScreenB[scidx]= ti32;
}

void sc_scroll_addrowcol(){
	int tx, ty;

	if (pb_to_scroll){
		if (pb_scroll_flag &1){
			if ((v_scroll_pb -=pb_scroll_step)<0)
				v_scroll_pb=0;
			tx =h_scroll_pb>>3;
			ty =v_scroll_pb>>3;
			sc_add_row(tx, ty);
		}
		if(pb_scroll_flag &2){
			v_scroll_pb +=pb_scroll_step;
			if (v_scroll_pb>stage_data[stage].v_scroll_max_pb)
				v_scroll_pb =stage_data[stage].v_scroll_max_pb;
			tx =h_scroll_pb>>3;
			ty =(v_scroll_pb>>3)+0x1c;
			sc_add_row(tx, ty);
		}
		if (pb_scroll_flag &4){
			if ((h_scroll_pb -=pb_scroll_step)<0)
				h_scroll_pb=0;
			tx =h_scroll_pb>>3;
			ty =v_scroll_pb>>3;
			sc_add_col(tx, ty);
		}
		if(pb_scroll_flag &8){
			h_scroll_pb +=pb_scroll_step;
			if (h_scroll_pb>stage_data[stage].h_scroll_max_pb)
				h_scroll_pb =stage_data[stage].h_scroll_max_pb;
			tx =(h_scroll_pb>>3)+0x20;
			ty =v_scroll_pb>>3;
			sc_add_col(tx, ty);
		}
		if ((pb_to_scroll -=pb_scroll_step)<0)
			pb_to_scroll =0;
	}
}

static int check_bg_sub(int x, int y){
	int pageidx, xpages;
	unsigned short *ptbl;
	int tx, ty, taddr;

	if (y<0)
		return 0;

	tx =x>>3;
	ty =y>>3;
	xpages =stage_data[stage].xpages;
	pageidx =(ty>>5)*xpages+(tx>>5);
	ptbl =&stage_data[stage].bk_pages[pageidx<<10];
	tx &=0x1f;
	ty &=0x1f;
	taddr =(ty<<5)+tx;

	if (pageidx==0 && taddr==0x4f && game_state!=3)
		return 1;

	if (ptbl[taddr] & 0x7ff)
		return 1;
	else
		return 0;
}

//dir_keys=RLDU, ÇÒ±ØÐë·Ç0
int check_bg(int x, int y, int *dir_keys, int oflag){
	int tmp1, tmp2;

	tmp1 =tmp2 =*dir_keys;
	tmp1 &=3;
	tmp2 =(tmp2>>2) & 3;
	tmp1 =(tmp1&1)|(tmp1>>1);
	tmp2 =(tmp2&1)|(tmp2>>1);

	if ((tmp1+tmp2)==2){
		if (*dir_keys & oflag)
			*dir_keys ^=oflag;
		else
			return 1;
	}

	x +=X_MARGIN;
	if (*dir_keys & 1){
		y-=5;
		tmp1=x-4;	tmp2=x+3;
		if (check_bg_sub(tmp1,y) ||check_bg_sub(tmp2,y))
			return 1;
		else
			return 0;
	}else if (*dir_keys & 2){
		y+=4;
		tmp1=x-4;	tmp2=x+3;
		if (check_bg_sub(tmp1,y) ||check_bg_sub(tmp2,y))
			return 1;
		else
			return 0;
	}else if (*dir_keys & 4){
		x-=5;
		tmp1=y-4;	tmp2=y+3;
		if (check_bg_sub(x,tmp1) ||check_bg_sub(x,tmp2))
			return 1;
		else
			return 0;
	}else{
		x+=4;
		tmp1=y-4;	tmp2=y+3;
		if (check_bg_sub(x,tmp1) ||check_bg_sub(x,tmp2))
			return 1;
		else
			return 0;
	}

}

void set_sp_end(){
	if (sprite_cnt)
		sprite_buf[sprite_cnt-1].size_link &=0xff00;
	else{
		sprite_buf[0].size_link =0;
		sprite_buf[0].spy =0x170;
	}
}

static void set_sprite(short spx, short spy, short spsize, short spti){
	int sps=sprite_cnt;

	if (sprite_cnt<80){
		sprite_buf[sps].spx =spx;
		sprite_buf[sps].spy =spy;
		sprite_buf[sps].size_link =spsize | ++sprite_cnt;
		sprite_buf[sps].spti =spti;
	}
}

static void draw_sp_obj(SP_DATA *pobj){
	short spx, spy;
	unsigned int *ptbl;
	int *pstbl;
	int xoff, yoff, size, ti;

	spy =pobj->y +0x80;
	spx =pobj->x +0x80 +X_MARGIN;
	spx -=h_scroll_pb;
	spy -=v_scroll_pb;

	if (spx>=0x60 && spx<0x180 && spy>=0x60 && spy<0x160){
		ptbl =sp_form_data[pobj->form];
		pstbl =(int*)ptbl[((pobj->form_idx)<<1)+1];
		if (pobj->hidden_cnt==0 || (pobj->hidden_cnt & 1)){
			while ((xoff=*pstbl++)){
				yoff =*pstbl++;
				size =*pstbl++;
				ti =*pstbl++;
				if (pobj->injury_cnt>(ENEMY_INJURY_CNT>>1) || pobj->injury_cnt & 0x8){
					ti =(ti & 0x9fff) | 0x2000;
				}
				set_sprite(spx+xoff, spy+yoff, size, ti);
			}
		}
	}
}

void draw_sp_objs(){
	int i;
	SP_DATA *node;

	node =g_player;
	while (node){
		draw_sp_obj(node);
		node =node->next;
	}
	for (i=0; i<MAX_ENEMIES; i++){
		if (g_enemys[i]){
			node =g_enemys[i];
			while (node){
				draw_sp_obj(node);
				node =node->next;
			}
		}
	}
}

int col_detect(SP_DATA *pobj1, SP_DATA *pobj2){
	static unsigned int col_dist[]={9, 6, 6, 5};

	int type1=0, type2=0, xd, yd;
	unsigned int dist, distx2;

	if (pobj1->food_cnt || pobj1->form==4 || pobj1->form==9)
		type1 =1;
	if (pobj2->food_cnt || pobj2->form==4 || pobj2->form==9)
		type2 =1;

	dist =col_dist[(type1<<1)+type2];
	distx2 =dist<<1;

	xd =pobj2->x -dist; yd =pobj2->y -dist;
	
	if (((unsigned)(pobj1->x -xd))<distx2 && ((unsigned)(pobj1->y -yd))<distx2)
		return 1;
	else
		return 0;
}

void init_for_explosion (SP_DATA *node){
	node->state =6;
	node->speed =0;
	node->form =0xa;
	node->form_cnt =0;
	node->form_idx =0;
}

unsigned char* write_msg(int tx, int ty, unsigned int tibase, unsigned int *buf, unsigned char *msg){
	int rows =0, widx;
	int qh, wh, hz, hzcnt;
	unsigned int ti;

	widx =((ty&0x1f)<<6)+(tx & 0x3f);
	hzcnt=0;
	while(hzcnt<14){
		qh =*msg++;
		if (qh==0)
			return msg;
		wh =*msg++;
		qh -=0xa1;
		wh -=0xa1;
		hz =qh*94 +wh;
		ti =tibase +0x800 +(hz<<2);
		buf[widx] =ti;
		buf[(widx+0x40)&0x7ff] =ti+2;
		widx =(widx & 0x7c0) | ((widx+1)&0x3f);
		buf[widx] =ti+1;
		buf[(widx+0x40)&0x7ff] =ti+3;
		widx =(widx & 0x7c0) | ((widx+1)&0x3f);
		hzcnt++;
	}//while(1)
	return msg;
}
