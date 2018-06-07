#include <windows.h>
#define DIRECTINPUT_VERSION 0x0500
#include <dinput.h>
#include "sdl/include/SDL.h"
#include <time.h>
#include "sound.h"
#include "timing.h"
#include "graphics.h"
#include "globals.h"
#include "player.h"
#include "enemy.h"

static WNDCLASS wndclass;

HINSTANCE g_instance;
HWND g_hwnd;
static int g_running=0;
static int SS_Actived;
FILE* fherr=0;

int power_on=1;
int ending_showed=0;
int stage=0;
int game_state=0x0;

static BOOL init(HINSTANCE hInst, int nCmdShow);
static long PASCAL WinProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);
static void End_All(void);

static void main_sub();
static void game();

void vbl(){
	MSG msg;

	frame_count++;

	while (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE)){
		if (!GetMessage(&msg, NULL, 0, 0)){
			g_running = 0;
			return;
		}

		TranslateMessage(&msg); 
		DispatchMessage(&msg);
	}

	Update_Controllers();
	
	if (fullscreen && (Keys[DIK_ESCAPE] & 0x80)){
		g_running = 0;
		PostQuitMessage (0);
		return;
	}

	memcpy(Sprite, sprite_buf, sizeof(sprite_buf));
	VRam_Flag =1;
	if (cram_dirty){
		cram_dirty =0;
		memcpy (CRam, cram_buf, sizeof(cram_buf));
		CRam_Flag=1;
	}

	write_hvscroll();
	
	if (Disp_state){
		DrawBG();
	}else{
		if (!fullscreen && Crt_BPP==32)
			memset(MD_Screen32,0, 336*240*4);
		else
			memset(MD_Screen,0, 336*240*2);
	}

	Flip(g_hwnd);

	sprite_cnt =0;

	trim_speed();
}

int PASCAL WinMain(HINSTANCE hInst,	HINSTANCE hPrevInst, LPSTR lpCmdLine, int nCmdShow){
	fherr =fopen("error.txt", "w");

	if( !init(hInst, nCmdShow) ){
		return -1;
	}


	Set_scroll_size(1);
	VRam_Flag=0;
	CRam_Flag=1;
	Set_disp_width(0);
	Set_window_pos(0x94,0x9e);

	init_VDP();

	game();

	End_All();

	return 0;
}

BOOL init(HINSTANCE hInst, int nCmdShow){
	int wstyle, fsiz;
	char* inifile=".\\options.ini";
	FILE *f;

	srand( (unsigned)time( NULL ) );

	f=fopen("chgfx.bin","rb");
	if (!f){
		if (fherr)
			fprintf(fherr, "找不到chgfx.bin\n");
		return 0;
	}
	fread(VRam+0x10000,1,0x105580,f);
	fclose (f);

	f=fopen("gfx.dat","rb");
	if (!f){
		if (fherr)
			fprintf(fherr, "找不到gfx.dat\n");
		return 0;
	}
	fseek(f,0,SEEK_END);
	fsiz =ftell(f);
	fseek(f,0,SEEK_SET);
	snake_gfx =(unsigned char*) malloc(fsiz);
	if (!snake_gfx){
		if (fherr)
			fprintf(fherr, "无法读入gfx.dat\n");
		return 0;
	}
	fread(snake_gfx,1,fsiz,f);
	fclose (f);
	
	fullscreen =GetPrivateProfileInt("Snake", "FULLSCREEN",0, inifile);
	use_sai =GetPrivateProfileInt("Snake", "USE_SAI",0, inifile);
	LIVES =GetPrivateProfileInt("Snake", "LIVES",9, inifile);
	Check_MMX();
	if (!Have_MMX)
		use_sai =0;

	if (!initSound(SOUNDFMT, SOUNDCHANS, SOUNDRATE, CHUNKSIZ)){
		if (fherr)
			fprintf(fherr, "SOUND初始化失败\n");
		return FALSE;
	}
	g_sound[SND_TITLE]=Mix_LoadWAV("sfx/title.wav");
	g_sound[SND_CLEAR]=Mix_LoadWAV("sfx/clear.wav");
	g_sound[SND_RATING]=Mix_LoadWAV("sfx/rating.wav");
	g_sound[SND_BLOW]=Mix_LoadWAV("sfx/blow.wav");
	g_sound[SND_START]=Mix_LoadWAV("sfx/start.wav");
	g_sound[SND_S_START]=Mix_LoadWAV("sfx/s_start.wav");
	g_sound[SND_GAMEOVER]=Mix_LoadWAV("sfx/gameover.wav");
	g_sound[SND_LAY_EGG]=Mix_LoadWAV("sfx/lay_egg.wav");
	g_sound[SND_P_EAT_EGG]=Mix_LoadWAV("sfx/p_eat_egg.wav");
	g_sound[SND_E_EAT_EGG]=Mix_LoadWAV("sfx/e_eat_egg.wav");
	g_sound[SND_REBORN]=Mix_LoadWAV("sfx/reborn.wav");
	g_sound[SND_P_INJURY]=Mix_LoadWAV("sfx/p_injury.wav");
	g_sound[SND_E_INJURY]=Mix_LoadWAV("sfx/e_injury.wav");
	//0	BLOW
	//1	LAY_EGG
	//2	E_EAT_EGG
	//3	REBORN
	//4	E_INJURY

	wndclass.style = CS_DBLCLKS;
	wndclass.lpfnWndProc = WinProc;
	wndclass.cbClsExtra = 0;
	wndclass.cbWndExtra = 0;
	wndclass.hInstance = hInst;
	wndclass.hIcon = LoadIcon(hInst, MAKEINTRESOURCE(IDI_APPLICATION));
	wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);
	wndclass.hbrBackground = NULL;
	wndclass.lpszMenuName = NULL;
	wndclass.lpszClassName = "Snake";

	RegisterClass(&wndclass);

	g_instance = hInst;

	wstyle=(fullscreen)? WS_POPUP|WS_EX_TOPMOST:(WS_OVERLAPPED |WS_SYSMENU);
	g_hwnd = CreateWindowEx(
		NULL,
		"Snake",
		"战斗贪吃蛇",
		wstyle,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		320,
		240,
		NULL,
		NULL,
		hInst,
		NULL);

	if (!g_hwnd){
		if (fherr)
			fprintf(fherr, "窗口建立失败\n");
		return FALSE;
	}
	ShowWindow(g_hwnd, nCmdShow);
	if (fullscreen)
		ShowCursor(FALSE);


	if (initVideo()==0){
		return FALSE;
	}

	Clear_Primary_Screen(g_hwnd);
	if (Init_Input(g_instance,g_hwnd)==0){
		if (fherr)
			fprintf(fherr, "DINPUT初始化失败\n");
		return FALSE;
	}

	//初始化定时系统 (使用高精度计数器, 用作确保每秒60帧)
	if(!init_timer(framerate)){
		if (fherr)
			fprintf(fherr, "高精度计数器错误\n");
		return 0;
	}

	//禁止屏幕保护
	SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, &SS_Actived, 0);
	SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, FALSE, NULL, 0);

	g_running = 1;

	return TRUE;
}


long PASCAL WinProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam){
	RECT r;

	switch(message){
		case WM_CREATE:
			//调整模拟窗口大小 (在创建窗口时已将窗口置顶)
			SetRect(&r, 0, 0, 320, 240);
			AdjustWindowRectEx(&r, GetWindowLong(hWnd, GWL_STYLE), 0, GetWindowLong(hWnd, GWL_EXSTYLE));
			if (!fullscreen)
				SetWindowPos(hWnd, HWND_TOPMOST, 700, 60, r.right - r.left, r.bottom - r.top, SWP_SHOWWINDOW);
			else
				SetWindowPos(hWnd, NULL, 700, 60, r.right - r.left, r.bottom - r.top, SWP_NOZORDER | SWP_NOACTIVATE);
			break;
		
		case WM_DESTROY:
		    PostQuitMessage (0);
			break;

		case WM_PAINT:
			Clear_Primary_Screen(hWnd);
			Flip(hWnd);
			break;
	}

	return DefWindowProc(hWnd, message, wParam, lParam);
}

void End_All(void){
	int i=0;

	End_DDraw();
	End_Input();

	//恢复屏幕保护(如原先有)
	SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, SS_Actived, NULL, 0);
	shutdownSound();
	while(g_sound[i])
		Mix_FreeChunk(g_sound[i++]);
	Mix_CloseAudio();

	free(snake_gfx);
}

static void game_sub0();
static void game_sub1();
static void game_sub2();
static void game_sub3();
static void game_sub4();
static void game_sub5();
static void game_sub6();

static SUB game_jtbl[] ={
	game_sub0, game_sub1, game_sub2, game_sub3,
	game_sub4, game_sub5, game_sub6
};

static unsigned char tile145[0x28a0];

static set_145t_data(){
	unsigned char *psrc=&snake_gfx[gfx_offset[3]];
	unsigned int len =gfx_offset[4]-gfx_offset[3];
	memcpy (tile145, psrc, len);
}

static void clear_48t_dot(int dotidx){
	int t, dotmask, byteoff;

	dotmask =(dotidx & 1)? 0x0f:0xf0;
	byteoff =dotidx>>1;
	for (t=0; t<0x48; t++){
		VRam[byteoff] &=dotmask;
		byteoff +=32;
	}
}

static void set_145t_dot(int dotidx){
	int t, byteoff, vbyteoff;
	unsigned char dotmask;

	dotmask =(dotidx & 1)? 0x0f:0xf0;
	byteoff =dotidx>>1;
	vbyteoff =0x2000+(dotidx>>1);
	for (t=0; t<0x145; t++){
		VRam[vbyteoff] &=dotmask;
		VRam[vbyteoff] |=(tile145[byteoff] & (~dotmask));
		byteoff +=32;
		vbyteoff +=32;
	}
}


static void game_sub0(){
	int i, j, done, delay;
	unsigned int *pbuf, *ptiles;
	int dotidx;

	stage =0;
	h_scroll_pa =v_scroll_pa =0;
	h_scroll_pb =v_scroll_pb =0;

	color_no =stage_data[stage].color_no;
	set_crambuf_by_no();
	cram_buf_org[0x10] =0xe00;	//标题背景色=亮蓝色

	gfx_setting(stage_data[stage].gfx_no, 0x0000);	//迷宫TILES点阵
	draw_sc_by_pos(0, 0);
	
	gfx_setting(1, 0x1000);	//主角TILES点阵, T#80起 (这儿用于敌蛇, 只是色彩不同)

	enemy_init();

	done =0;
	while (g_running && !done){
		done =1;
		for (i=0; i<e_snakes; i++){
			if (g_enemys[i]->move_cnt){
				proc_enemy(g_enemys[i]);
				done =0;
				break;
			}
		}
	}
	if (!g_running)	return;

	e_set_states_3();

	cram_buf_org[0x11]=0x0eee;				//标题以及DINGCMHK字样的色彩
	cram_buf_org[0x12]=0x0eee;
	cram_buf_org[0x13]=0x0888;
	cram_buf_org[0x14]=0x0aaa;
	cram_buf_org[0x1f]=0x0;
	for (i=0; i<0x10; i++)				//DINGCMHK头像的色彩
		cram_buf_org[64+i] =dingcm_colors[i];
	cram_dirty=1;


	memset(&VRam[0x2000],0, 0x28a0);	//T#100起的0x145T点阵都为0

	ptiles =title_tiles;				//显示PA, 但因点阵都为0, 实际是全透明
	for (i=0; i<0x20; i++){
		pbuf =&ScreenA[i<<6];
		for (j=0; j<0x20; j++)
			*pbuf++ =0x80000000 | *ptiles++;
	}

	color_change_mode =2;
	color_step=0xf;
	if (power_on){
		power_on =0;
		delay =180;
		while (g_running && --delay){
			proc_enemys();
			draw_sp_objs();
			set_sp_end();
			if (!(frame_count&1))
				color_op();
			vbl();
		}
		if (!g_running)	return;

		PLAYSOUNDFREE(SND_TITLE);

		set_145t_data();
		for (i=0; i<64;){
			if (frame_count & 4){
				dotidx =dot_idx_shuffle[i];
				clear_48t_dot(dotidx);
				set_145t_dot(dotidx);
				i++;
			}

			proc_enemys();
			draw_sp_objs();
			set_sp_end();
			vbl();
			if (!g_running)	return;
		}
	}else{
		gfx_setting(3, 0x2000);
		memset(VRam,0,0x900);
		PLAYSOUNDFREE(SND_TITLE);
	}

	color_op();
	while (g_running){
		proc_enemys();
		draw_sp_objs();
		set_sp_end();
		if (!(frame_count&1))
			color_op();
		vbl();
		if (P1_Triggers & 0x80){
			STOPSOUNDALL;
			PLAYSOUNDFREE(SND_START);
			game_state++;
			break;
		}
	}
}

static void game_sub1(){
	int delay;
	color_change_mode =4;
	color_step=0xf;

	delay =100;
	while (g_running && --delay){
		proc_enemys();
		draw_sp_objs();
		set_sp_end();
		if (!(frame_count&1))
			color_op();
		vbl();
	}

	stage=1;
	your_score =0;
	player_lives =LIVES;
	memset(ScreenA, 0, 64*64*4);
	h_scroll_pb =v_scroll_pb =0;
	gfx_setting(6, 0x8000);
	game_state++;
}

static void show_msg(int tx, int ty, int cg, char *msg, int no_show){
	int vaddr =ty*64 +tx, len =strlen(msg), i,c;
	unsigned int *pout =&ScreenA[vaddr];

	for (i=0; i<len; i++){
		if (no_show)
			*pout++ =0;
		else{
			c =*msg++;
			if (c>='A')
				c =c -'A'+10;
			else
				c =c-'0';
			*pout++ =(0x400 +c) | (cg<<28);
		}
	}
}

static void show_status(){
	int vaddr =2;
	unsigned int *pout =&ScreenA[vaddr];
	char buf[10];

	pout[vaddr] =0x30000080;	pout[vaddr+1] =0x30000082;
	pout[vaddr+64] =0x30000081;	pout[vaddr+65] =0x30000083;

	sprintf (buf,"%02d", player_lives);
	show_msg(6,1,3,buf,0);
}

static void game_sub2(){
	static char *st_msg ="STAGE";
	char buf[10];
	int i, done;
	int delay;

	color_no =stage_data[stage].color_no;
	set_crambuf_by_no();

	gfx_setting(stage_data[stage].gfx_no, 0x0000);
	draw_sc_by_pos(0, 0);

	gfx_setting(1, 0x1000);	//主角TILES点阵, T#80起
	gfx_setting(2, 0x2000);	//爆炸各动画点阵, T#100起

	enemy_init();
	done =0;
	while (g_running && !done){
		done =1;
		for (i=0; i<e_snakes; i++){
			if (g_enemys[i]->move_cnt){
				proc_enemy(g_enemys[i]);
				done =0;
				break;
			}
		}
	}
	if (!g_running)	return;

	show_msg(0xc,0xd,3,st_msg,0);
	sprintf (buf,"%01d", stage);
	show_msg(0x12,0xd,3,buf,0);

	PLAYSOUNDFREE(SND_S_START);

	player_init();
	done =0;
	color_change_mode =2;
	color_step=0xf;
	color_op();

	while (g_running && !done){
		done =1;
		if (g_player->move_cnt){
			proc_player();
			done =0;
		}
		draw_sp_objs();
		set_sp_end();
		show_status();
		if (!(frame_count&1))
			color_op();
		vbl();
	}
	if (!g_running)	return;

	delay=210;
	while(g_running && --delay){
		draw_sp_objs();
		set_sp_end();
		if (!(frame_count&1))
			color_op();
		vbl();
	}
	if (!g_running)	return;

	show_msg(0xc,0xd,3,st_msg,1);
	show_msg(0x12,0xd,3,buf,1);

	e_set_states_3();

	open_bgm(stage_data[stage].bgm_name,0);
	play_bgm(0);
	while (g_running){
		proc_player();
		proc_enemys();
		draw_sp_objs();
		set_sp_end();
		sc_scroll_addrowcol();
		show_status();
		vbl();
		if (no_enemy() || (!player_lives)){
			if (!player_lives)
				stop_bgm();
			game_state++;
			break;
		}
	}
}

static void game_sub3(){
	static int scores[]={30,40,60};
	int delay=180, fcnt=0;

	while(g_running && --delay){
		proc_player();
		proc_enemys();
		draw_sp_objs();
		set_sp_end();
		sc_scroll_addrowcol();
		vbl();
	}
	if (!g_running)	return;

	if (player_lives==0){
		game_state++;
		return;
	}

	your_score += (float)player_lives/LIVES*scores[stage-1];

	stop_bgm();
	p_set_state_8();

	PLAYSOUNDFREE(SND_CLEAR);
	while (g_running){
		proc_player();
		draw_sp_objs();
		if (!sprite_cnt)
			break;
		set_sp_end();
		sc_scroll_addrowcol();
		vbl();
		fcnt++;
	}
	if (!g_running)	return;

	delay =280-fcnt;
	if (delay<0)
		delay =1;
	while(g_running && --delay){
		vbl();
	}
	if (!g_running)	return;

	delay =(stage==3)?120:1;
	while(g_running && --delay){
		vbl();
	}
	if (!g_running)	return;

	color_change_mode =4;
	color_step=0xf;
	color_op();

	delay=60;
	while(g_running && --delay){
		if (!(frame_count&1))
			color_op();
		vbl();
	}
	if (!g_running)	return;

	if (stage!=3){
		stage++;
		game_state--;
	}else{
		game_state =5;
	}
}

static void show_cat(){
	unsigned int *pout =&ScreenA[64*2+3];
	int i,j, idx;

	idx =0;
	for (i=0; i<25; i++){
		for (j=0; j<25; j++){
			pout[i*64 +j] =(0x100 +(idx++)) | 0x40000000;
		}
	}
}

static void game_sub4(){
	static int cat_nos[]={0,1,5,6};
	int delay=180;
	int i, cat_no;

	color_change_mode =4;
	color_step=0xf;
	while (g_running && --delay){
		if (!(frame_count&7))
			color_op();
		vbl();
	}
	if (!g_running)	return;

	memset(sprite_buf,0,sizeof(sprite_buf));
	memset(ScreenA, 0, 64*64*4);

	cat_no =rand() &3;
	cats_setting(cat_nos[cat_no],0x2000);
	cram_buf[0x10] =0xeee;				//背景色=白色
	for (i=0; i<0x10; i++)				//猫表情的色彩
		cram_buf[64+i] =cats_colors[i];
	cram_dirty=1;

	memset(ScreenB, 0, 64*64*4);

	show_cat();
	PLAYSOUNDFREE(SND_GAMEOVER);

	delay=180;
	while (g_running && --delay){
		vbl();
	}
	game_state =0;
}

static void game_sub5(){
	static int delays[]={20,20,20,20,10,10,10,10};
	static unsigned char msg[] ="您的战斗贪吃蛇技巧评价：";
	int cat_no =-1, tmp_no, i, delay, skip=0;
	int your_level;

	memset(sprite_buf,0,sizeof(sprite_buf));
	memset(ScreenA, 0, 64*64*4);
	memset(ScreenB, 0, 64*64*4);

	color_change_mode =2;
	color_step=0xf;
	color_op();

	write_msg(5, 10, 0x20000000, ScreenA, msg);
	delay=220;
	while (g_running && --delay){
		if (!(frame_count&1))
			color_op();
		vbl();
	}
	if (!g_running)	return;

	memset(ScreenA, 0, 64*64*4);
	cram_buf[0x10] =0xeee;				//背景色=白色
	for (i=0; i<0x10; i++)				//猫表情的色彩
		cram_buf[64+i] =cats_colors[i];
	cram_dirty=1;

	if (your_score>=104)
		your_level =3;
	else if (your_score>=78)
		your_level =4;
	else if (your_score>=52)
		your_level =8;
	else if (your_score>=26)
		your_level =2;
	else
		your_level =1;

	PLAYSOUNDFREE(SND_RATING);
	i=0;
	while (g_running && i<8){
		if (i!=7){
			while ((tmp_no =(rand()%9)) ==cat_no);
		}else{
			while (1){
				tmp_no =(rand()%9);
				if ((tmp_no !=cat_no) && (tmp_no !=your_level))
					break;
			}
		}
		cat_no =tmp_no;
		cats_setting(cat_no,0x2000);
		show_cat();
		delay =delays[i];
		while (g_running && delay){
			delay--;
			vbl();
		}
		i++;
	}
	if (!g_running)	return;

	cats_setting(your_level,0x2000);
	show_cat();

	delay =360;
	while (g_running && --delay){
		vbl();
		if (P1_Triggers & 0x80){
			STOPSOUNDALL;
			skip++;
			break;
		}
	}
	if (!g_running)	return;

	if (!skip){
		while (g_running){
			vbl();
			if (P1_Triggers & 0x80){
				STOPSOUNDALL;
				break;
			}
		}
	}

	if (ending_showed)
		game_state =0;
	else{
		ending_showed++;
		game_state++;
	}

}

static void show_hz_6x6(int no, unsigned int *pout){
	int ti =0x100+no*36, i,j;

	for (i=0; i<6; i++){
		for (j=0; j<6; j++){
			pout[i*64+j] =ti++;
		}
	}
}

static void update_ending_color(){
	int b,g,r;
	unsigned short color;

	b=(rand() & 3)+4;
	g=(rand() & 3)+4;
	r=(rand() & 3)+4;
	color =(b<<9) | (g<<5) | (r<<1);
	cram_buf[4] =cram_buf[3]; 
	cram_buf[3] =cram_buf[2]; 
	cram_buf[2] =cram_buf[1]; 
	cram_buf[1] =color; 
	cram_dirty=1;
}

static void game_sub6(){
	unsigned int *pout;
	int i, color_delay, delay;
	int tx, ty, msgidx, msgend, block_f;

	open_bgm("ending.raw",0);
	play_bgm(0);

	memset(ScreenA, 0, 64*64*4);
	memcpy(cram_buf, cram_buf_org, sizeof(cram_buf));
	cram_buf[0x10] =0;				//背景色=黑色
	v_scroll_pa =-72;

	gfx_setting(5, 0x2000);
	pout =&ScreenA[64*1+2];

	for (i=0; i<4; i++){
		show_hz_6x6(i, pout);
		pout +=7;
	}

	color_delay =1;
	delay =1050;
	while (g_running && --delay){
		if (--color_delay==0){
			color_delay =12;
			update_ending_color();
		}
		vbl();
	}
	if (!g_running)	return;

	h_scroll_pb =v_scroll_pb =0;
	msgidx =msgend =block_f =0;
	tx =2;	ty =0x1c;
	while (g_running){
		if (--color_delay==0){
			color_delay =12;
			update_ending_color();
		}

		if (v_scroll_pa && (frame_count &1))
			v_scroll_pa++;

		if ((v_scroll_pb & 0xf)==0){
			if (end_msg[msgidx]){
				if (!block_f){
					block_f++;
					write_msg(tx, ty, 0x20000000, ScreenB, end_msg[msgidx]);
					msgidx++;
					ty +=2;
				}
			}else
				msgend =1;
		}else
			block_f =0;
		if (!msgend)
			if (!(frame_count &3))
				v_scroll_pb++;
		vbl();
		if (P1_Triggers & 0x80){
			stop_bgm();
			game_state =0;
			break;
		}
	}
}

static void main_sub(){	
	game_jtbl[game_state]();
}

static void game(){
	while (g_running){
		main_sub();
	}

}

extern "C" unsigned int hook(){
	unsigned int a;
	__asm {
		mov a, eax
	}
	return a;
}