#include <windows.h>
#include "assert.h"
#include "graphics.h"
#include "sound.h"
#include "globals.h"
#include "enemy.h"

static SP_DATA player_pool[MAX_PLAYER_NODES];
static SP_DATA *p_freehead, *p_freetail;
SP_DATA *g_player;
static SP_DATA *g_p_node;

int LIVES =0;
int player_lives =0;
float your_score =0;

static SP_DATA *p_alloc_node();
static void player_move();

static void player_sub0();
static void player_sub1();
static void player_sub2();
static void player_sub3();
static void player_sub4();
static void player_sub5();
static void player_sub6();
static void player_sub7();
static void player_sub8();

static SUB player_jtbl[] ={
	player_sub0, player_sub1, player_sub2, player_sub3,
	player_sub4, player_sub5, player_sub6, player_sub7,
	player_sub8
};

static SP_DATA *p_alloc_node(){
	SP_DATA *node =p_freehead;
	if (p_freehead ==p_freetail){
		if (p_freetail)
			p_freetail =p_freetail->next;
	}
	if (p_freehead)
		p_freehead =p_freehead->next;
	if (node)
		node->next =NULL;
	return node;
}

static void p_free_node(SP_DATA *node){
	if (node)
		memset(node, 0, sizeof(SP_DATA));

	if (p_freetail){
		p_freetail->next =node;
		node->next =NULL;
		p_freetail =node;
	}else{
		assert(p_freehead==NULL);
		p_freehead =p_freetail=node;
	}
}

static void p_snake_inc_nodes(int n){
	int i;
	SP_DATA *node, *snake =g_player;

	if (g_player->len>=MAX_PLAYER_NODES)
		return;
	g_player->speed =1;
	while (snake->next)
		snake =snake->next;
	for (i=0; i<n; i++){
		node =p_alloc_node();
		assert(node);
		if (node==NULL)
			return;
		node->state =4;
		node->x =snake->x;
		node->y =snake->y;
		node->master_sp =snake;
		node->form =04;
		node->form_idx =0;
		snake->next =node;
		snake =node;
		g_player->len++;
		if (g_player->len>=MAX_PLAYER_NODES)
			return;
	}
}

void p_snake_lose_nodes(SP_DATA *startnode){
	SP_DATA *snake =g_player, *prev;
	while (snake !=startnode){
		prev =snake;
		snake =snake->next;
	}
	prev->next=NULL;
	while (snake){
		prev =snake->next;
		p_free_node(snake);
		snake =prev;
		g_player->len--;
	}
	if (g_player->len ==1){
		g_player->x &=0xfffe;
		g_player->y &=0xfffe;
		g_player->speed =2;
	}
}

static void p_free_snake(){
	SP_DATA *head =g_player, *tmp;
	while(head){
		tmp =head->next;
		p_free_node(head);
		head =tmp;
	}
	g_player =NULL;
}

void player_init(){
	SP_DATA *pdata;

	memset(player_pool,0, sizeof(player_pool));

	pdata =&player_pool[0];
	for (int i=1; i<MAX_PLAYER_NODES; i++){
		pdata->next =&player_pool[i];
		pdata =pdata->next;
	}
	pdata->next=NULL;

	p_freetail =pdata;
	p_freehead =&player_pool[0];
	g_player =p_alloc_node();		//主角蛇初始只有1个头, 无需alloc_snake
	g_player->len =1;
	g_player->y =-16;
	g_player->state =1;
	g_player->move_cnt =44;
}

void proc_player(){
	SP_DATA *pdata;

	if (!g_player)
		return;

	pdata =g_player;
	while (pdata){
		g_p_node =pdata;
		player_jtbl[g_p_node->state]();
		pdata =pdata->next;
	}
}

static void player_sub0(){
}

static void player_sub1(){
	g_player->x =108;
	g_player->y =-16;
	g_player->speed =1;
	g_player->is_auto =1;
	g_player->hidden_cnt =HIDDEN_CNT-1;
	g_player->move_cnt =44;
	g_player->move_flag =g_player->last_move_flag=2;
	g_player->form =1;
	g_player->form_idx =0;
	g_player->state++;
}

static void player_sub2(){
	player_move();
	if (--g_player->move_cnt==0){
		g_player->is_auto =0;
		g_player->move_flag =0;
		g_player->state++;
		g_player->speed =2;
	}
}

static void check_head_col(){
	int num =e_snakes, i=0;

	while (num){
		if (g_enemys[i]){
			if (g_enemys[i]->state ==3 || g_enemys[i]->state ==5){
				if (col_detect(g_player, g_enemys[i])){
					if (g_enemys[i]->state ==5){
						e_free_snake(i);
						PLAYSOUNDFREE(SND_P_EAT_EGG);
						p_snake_inc_nodes(1);
					}else{
						if (g_player->len <=g_enemys[i]->len){
							init_for_explosion(g_player);
							PLAYSOUND0(SND_BLOW);
							g_player->move_cnt =0;
							e_snake_inc_nodes(g_enemys[i], g_player->len);
						}else{
							init_for_explosion(g_enemys[i]);
							PLAYSOUND0(SND_BLOW);
							g_enemys[i]->move_cnt =0;
							p_snake_inc_nodes(g_enemys[i]->len);
						}
					}
				}//if (col_detect(g_player, g_enemys[i]))
			}
			num--;
		}
		i++;
	}
}

static void check_p_head_e_node(){
	int num =e_snakes, i=0;
	SP_DATA *node;

	while (num){
		if (g_enemys[i]){
			if (g_enemys[i]->state ==3){
				node =g_enemys[i]->next;
				while (node){
					if (col_detect(g_player, node)){
						if (node->injury_cnt ==0)
							PLAYSOUND4(SND_E_INJURY);
						e_injury_from(node);
						break;
					}
					node =node->next;
				}
			}
			num--;
		}
		i++;
	}
}

static void player_sub3(){
	static forms[]={0,0,1,0,2,0,0,0, 3,0,0,0,0,0,0,0};

	player_move();
	if (g_player->move_flag)
		g_player->form =forms[g_player->move_flag];

	if (g_player->hidden_cnt)
		g_player->hidden_cnt--;
	else{
		check_head_col();
		check_p_head_e_node();
	}
}

static void player_move(){
	int move_flag =0, dir_keys;
	int xdelta=0, ydelta=0, delta=g_player->speed;
	short spx, spy;

	if (g_player->move_flag)
		g_player->last_move_flag =g_player->move_flag;

	if (g_player->is_auto){
		move_flag =g_player->move_flag;
		delta =g_player->speed;
	}else{
		if ((dir_keys=P1_Keys & 0xf)){
			if (check_bg(g_player->x, g_player->y, &dir_keys, g_player->move_flag)==0)
				move_flag =dir_keys;
			else{
				move_flag =g_player->move_flag;
				if (!move_flag)
					move_flag =g_player->last_move_flag;
				if (move_flag){
					if (check_bg(g_player->x, g_player->y, &move_flag, move_flag))
						move_flag =0;
				}
			}
		}
	}
	pb_scroll_flag =0;
	pb_to_scroll =1;
	pb_scroll_step =g_player->speed;
	if (move_flag !=0){
		g_player->move_flag =move_flag;
		if (move_flag &1)
			ydelta =-delta;
		if (move_flag &2)
			ydelta =delta;
		if (move_flag &4)
			xdelta =-delta;
		if (move_flag &8)
			xdelta =delta;
		g_player->x +=xdelta;
		g_player->y +=ydelta;

		spx =g_player->x -h_scroll_pb;
		spy =g_player->y -v_scroll_pb;
		if (spx>=0 && spy>=0){
			if (spx<=(0x58-X_MARGIN))
				pb_scroll_flag |=4;
			else if (spx>=(0x98-X_MARGIN))
				pb_scroll_flag |=8;
			if (spy<=0x58)
				pb_scroll_flag |=1;
			else if (spy>=0x98)
				pb_scroll_flag |=2;
		}
	}else{
		g_player->move_flag =0;
	}
}

static void player_sub4(){
	SP_DATA *p_master =g_p_node->master_sp;

	unsigned short o_flag; 
	g_p_node->move_flag=0;
	if (p_master->move_flag){
		o_flag =g_p_node->master_mflags_array[g_p_node->master_mflags_array_idx];
		g_p_node->master_mflags_array[g_p_node->master_mflags_array_idx++] =p_master->move_flag;
		//p_master->move_flag=0;
		g_p_node->master_mflags_array_idx %=10;
		if (o_flag&2){
			g_p_node->move_flag |=2;
			g_p_node->y+=g_player->speed;
		}
		if (o_flag&1){
			g_p_node->move_flag |=1;
			g_p_node->y-=g_player->speed;
		}
		if (o_flag&8){
			g_p_node->move_flag |=8;
			g_p_node->x+=g_player->speed;
		}
		if (o_flag&4){
			g_p_node->move_flag |=4;
			g_p_node->x-=g_player->speed;
		}
	}
}

static void player_sub5(){
}

static void player_sub6(){
	unsigned int *ptbl;

	if (g_p_node->form_cnt){
		g_p_node->form_cnt--;
		if (!g_p_node->form_cnt)
			g_p_node->form_idx++;
	}else{
		ptbl =sp_form_data[0xa];
		g_p_node->form_cnt =ptbl[g_p_node->form_idx <<1];
		if (!g_p_node->form_cnt){
			g_p_node->state =5;
			if (g_p_node->next){
				init_for_explosion(g_p_node->next);
				PLAYSOUND0(SND_BLOW);
			}else{
				p_free_snake();
				if (--player_lives){
					g_player =p_alloc_node();		//主角蛇初始只有1个头, 无需alloc_snake
					g_player->len =1;
					g_player->state =7;
					g_player->y =-16;
				}
			}
		}
	}
}

static void player_sub7(){
	if (v_scroll_pb){
		pb_scroll_flag =1;
		pb_to_scroll =2;
		pb_scroll_step =2;
	}else{
		pb_scroll_flag =0;
		g_player->state =1;
	}
}

static void player_sub8(){
	static int dir_mask[]={0xff,0xfd,0xfe,0,  0xf7,0,0,0,  0xfb,0,0,0, 0,0,0,0};
	static forms[]={0,0,1,0,2,0,0,0, 3,0,0,0,0,0,0,0};
	int tx, ty;
	int dir, i, rnd, tmp, pdir=0;

	if (g_player->x==0x4c && g_player->y==0x34)
		pdir=pdir;
	tx =g_player->x-4;	ty =g_player->y-4;
	if (ty>=0){
		if (!( (tx & 7) || (ty & 7) ) ){
			dir =0xf;
			dir &=dir_mask[g_player->move_flag];
			for (i=0; i<4; i++){
				tmp =1<<i;
				if (dir & tmp){
					if (check_bg(g_player->x, g_player->y, &tmp, 0))
						dir &=~tmp;
				}
			}
			if (g_player->x<108 && (dir &8))
				dir =8;
			else if (g_player->x>108 && (dir &4))
				dir =4;
			else if (dir & 1)
				dir =1;
			else{
				if (dir & 2){
					if (dir ^ 2)
						dir ^=2;
				}
				if (dir_mask[dir]==0){
					rnd =1<<(rand() & 3);
					while (!(dir & rnd))
						rnd =1<<(rand() & 3);
					dir =rnd;
				}
			}
			g_player->move_flag =dir;
		}//if (!( (tx & 7) || (ty & 7) ) )
	}

	player_move();
	if (g_player->move_flag)
		g_player->form =forms[g_player->move_flag];
}

void p_set_state_8(){
	g_player->state =8;
	g_player->is_auto =1;
	if (g_player->move_flag==0)
		g_player->move_flag =g_player->last_move_flag;
}
