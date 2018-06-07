#include <windows.h>
#include "assert.h"
#include "graphics.h"
#include "sound.h"
#include "globals.h"
#include "timing.h"
#include "player.h"

static SP_DATA enemy_pool[MAX_ENEMIES_NODES];
static SP_DATA *e_freehead, *e_freetail;
SP_DATA *g_enemys[MAX_ENEMIES];
static SP_DATA *g_p_enemy, *g_e_node;
static g_e_idx;

int e_snakes =0;

static void enemy_sub0();
static void enemy_sub1();
static void enemy_sub2();
static void enemy_sub3();
static void enemy_sub4();
static void enemy_sub5();
static void enemy_sub6();

static SUB enemy_jtbl[] ={
	enemy_sub0, enemy_sub1, enemy_sub2, enemy_sub3,
	enemy_sub4, enemy_sub5, enemy_sub6
};

static SP_DATA *e_alloc_node(){
	SP_DATA *node =e_freehead;
	if (e_freehead ==e_freetail){
		if (e_freetail)
			e_freetail =e_freetail->next;
	}
	if (e_freehead)
		e_freehead =e_freehead->next;
	if (node)
		node->next =NULL;
	return node;
}

static void e_free_node(SP_DATA *node){
	if (node)
		memset(node, 0, sizeof(SP_DATA));

	if (e_freetail){
		e_freetail->next =node;
		node->next =NULL;
		e_freetail =node;
	}else{
		e_freehead =e_freetail=node;
	}
}

static int e_get_free_idx(){
	int i;
	for (i=0; i<MAX_ENEMIES; i++)
		if (g_enemys[i]==NULL)
			return i;

	return -1;
}

void e_snake_inc_nodes(SP_DATA *snake, int n){
	int i,j;
	SP_DATA *node, *head=snake, *prev;
	int icnt=0, icount[MAX_ENEMY_NODES];

	if (head->len>=MAX_ENEMY_NODES)
		return;
	while (snake){
		prev =snake;
		if (snake->injury_cnt){
			icount[icnt++] =snake->injury_cnt;
			snake->injury_cnt =0;
		}
		snake =snake->next;
	}
	snake =prev;

	for (i=0; i<n; i++){
		node =e_alloc_node();
		if (node==NULL)
			break;
		node->state =4;
		node->x =snake->x;
		node->y =snake->y;
		node->master_sp =snake;
		node->form =9;
		node->form_idx =0;
		snake->next =node;
		snake =node;
		head->len++;
		if (head->len>=MAX_ENEMY_NODES)
			break;
	}

	if (icnt){
		i =head->len -icnt;
		snake =head;
		j =0;
		while (j++<i)
			snake =snake->next;
		i=0;
		while (snake){
			snake->injury_cnt =icount[i++];
			snake =snake->next;
		}
	}
}

void e_injury_from(SP_DATA *node){
	while (node){
		if (node->next || node->injury_cnt==0)
			node->injury_cnt =ENEMY_INJURY_CNT;
		node =node->next;
	}
}

static int e_count_injurys(){
	int i, cnt=0;
	SP_DATA *node;
	for (i=0; i<MAX_ENEMIES; i++){
		if (g_enemys[i]){
			node =g_enemys[i];
			while (node){
				if (node->injury_cnt){
					cnt++;
					break;
				}
				node =node->next;
			}
		}
	}
	return cnt;
}

static void e_snake_lose_tail(SP_DATA *snake){
	SP_DATA *head=snake, *prev;
	while (snake->next){
		prev =snake;
		snake =snake->next;
	}
	prev->next=NULL;
	e_free_node(snake);
	head->len--;
}

static int e_alloc_snake(int n){
	int idx =e_get_free_idx();
	SP_DATA *head;

	if (idx==-1)
		return 0;
	head =e_alloc_node();
	if (head==NULL)
		return 0;
	head->state =1;
	head->len =1;
	head->form =5;
	head->x =108;
	head->y =-16;
	head->move_cnt =ENEMY_MOVE_CNT;
	g_enemys[idx] =head;
	if (--n)
		e_snake_inc_nodes(head,n);

	e_snakes+=1;
	return 1;
}

static int e_alloc_food(short x, short y){
	int idx =e_get_free_idx();
	SP_DATA *head;

	if (idx==-1)
		return 0;
	head =e_alloc_node();
	if (head==NULL)
		return 0;
	head->state =5;
	head->len =1;
	head->form =9;
	head->x =x;
	head->y =y;
	head->food_cnt =ENEMY_FOOD_CNT;
	head->move_cnt =0;
	g_enemys[idx] =head;

	e_snakes+=1;
	return 1;
}

void e_free_snake(int idx){
	SP_DATA *head =g_enemys[idx], *tmp;

	assert(idx<MAX_ENEMIES);

	while(head){
		tmp =head->next;
		e_free_node(head);
		head =tmp;
	}
	g_enemys[idx] =NULL;
	e_snakes--;
}

void enemy_init(){
	SP_DATA *pdata;
	int i, snakes;

	memset(enemy_pool,0, sizeof(enemy_pool));
	memset(g_enemys,0, sizeof(g_enemys));
	e_snakes =0;
	pdata =&enemy_pool[0];

	for (i=1; i<MAX_ENEMIES_NODES; i++){
		pdata->next =&enemy_pool[i];
		pdata =pdata->next;
	}
	pdata->next=NULL;

	e_freetail =pdata;
	e_freehead =&enemy_pool[0];

	snakes =stage_data[stage].snakes;
	for (i=0; i<snakes; i++)
		e_alloc_snake(6);
}

void proc_enemy(SP_DATA *enemy){
	SP_DATA *pdata;

	g_p_enemy =pdata =enemy;
	while (pdata){
		g_e_node =pdata;
		enemy_jtbl[g_e_node->state]();
		pdata =pdata->next;
	}
}

void proc_enemys(){
	SP_DATA *pdata;

	int i;
	for (i=0; i<MAX_ENEMIES; i++){
		if (g_enemys[i]){
			g_p_enemy =pdata =g_enemys[i];
			while (pdata){
				g_e_node =pdata;
				g_e_idx =i;
				enemy_jtbl[g_e_node->state]();
				pdata =pdata->next;
			}
		}
	}
}

void enemy_sub0(){
}

void enemy_sub1(){
	g_p_enemy->speed =1;
	g_p_enemy->form_idx =0;
	g_p_enemy->move_flag =2;
	g_p_enemy->state++;
}

static void enemy_move(){
	int move_flag =g_p_enemy->move_flag;
	int xdelta=0, ydelta=0, delta=g_p_enemy->speed;

	if (move_flag &1)
		ydelta =-delta;
	if (move_flag &2)
		ydelta =delta;
	if (move_flag &4)
		xdelta =-delta;
	if (move_flag &8)
		xdelta =delta;
	g_p_enemy->x +=xdelta;
	g_p_enemy->y +=ydelta;
}

void enemy_sub2(){
	static int dir_mask[]={0,0xfd,0xfe,0,  0xf7,0,0,0,  0xfb,0,0,0, 0,0,0,0};
	static forms[]={0,5,6,0,7,0,0,0, 8,0,0,0,0,0,0,0};
	int tx, ty;
	int i, rnd, tmp;
	char dir;

	if (g_p_enemy->move_cnt){
		g_p_enemy->move_cnt--;
		enemy_move();
		if (g_p_enemy->move_cnt<(ENEMY_MOVE_CNT-40)){
			tx =g_p_enemy->x-4;	ty =g_p_enemy->y-4;
			if ( !( (tx & 7) || (ty & 7) ) ){
				dir =0xf;
				dir &=dir_mask[g_p_enemy->move_flag];
				for (i=0; i<4; i++){
					tmp =1<<i;
					if (dir & tmp){
						if (check_bg(g_p_enemy->x, g_p_enemy->y, &tmp, 0))
							dir &=~tmp;
					}
				}
				if ( (dir & 2) && (rand() & 1) )
					dir =2;
				else{
					if (dir ==0)	//如进入死胡同, 则运动方向=原来的反向 (如不这样处理, 下面会无限循环)
						dir =~dir_mask[g_p_enemy->move_flag];
					if (dir_mask[dir]==0){
						rnd =1<<(rand() & 3);
						while (!(dir & rnd))
							rnd =1<<(rand() & 3);
						dir =rnd;
					}
				}
				g_p_enemy->move_flag =dir;
			}//if ( !( (tx & 7) || (ty & 7) ) )
		}//if (g_p_enemy->move_cnt<(ENEMY_MOVE_CNT-40))
		g_p_enemy->form =forms[g_p_enemy->move_flag];
	}
}

static void check_e_head_p_node(){
	SP_DATA *node;
	int cnt=0;

	if (!g_player) return;

	if (g_player->state ==3){
		node =g_player->next;
		while (node){
			if (col_detect(g_p_enemy, node)){
				PLAYSOUNDFREE(SND_P_INJURY);
				p_snake_lose_nodes(node);
				while (node){
					node =node->next;
					cnt++;
				}
				e_snake_inc_nodes(g_p_enemy, cnt);
				break;
			}
			node =node->next;
		}
	}
}

static void check_e_head_food(){
	int num =e_snakes, i=0;

	while (num){
		if (g_enemys[i]){
			if (g_enemys[i]->state ==5){
				if (col_detect(g_p_enemy, g_enemys[i])){
					e_free_snake(i);
					PLAYSOUND2(SND_E_EAT_EGG);
					e_snake_inc_nodes(g_p_enemy, 1);
				}
			}
			num--;
		}
		i++;
	}
}

static void e_set_move_flag(int force){
	static int dir_mask[]={0xff,0xfd,0xfe,0,  0xf7,0,0,0,  0xfb,0,0,0, 0,0,0,0};
	int tx, ty;
	int dir, i, rnd, tmp;

	tx =g_p_enemy->x-4;	ty =g_p_enemy->y-4;
	if (force || !( (tx & 7) || (ty & 7) ) ){
		dir =0xf;
		dir &=dir_mask[g_p_enemy->move_flag];
		for (i=0; i<4; i++){
			tmp =1<<i;
			if (dir & tmp){
				if (check_bg(g_p_enemy->x, g_p_enemy->y, &tmp, 0))
					dir &=~tmp;
			}
		}
		if (dir_mask[dir]==0){
			rnd =1<<(rand() & 3);
			while (!(dir & rnd))
				rnd =1<<(rand() & 3);
			dir =rnd;
		}
		g_p_enemy->move_flag =dir;
	}
}

void enemy_sub3(){
	static forms[]={0,5,6,0,7,0,0,0, 8,0,0,0,0,0,0,0};
	SP_DATA *node, *prev;

	enemy_move();
	e_set_move_flag(0);
	g_p_enemy->form =forms[g_p_enemy->move_flag];

	check_e_head_p_node();
	check_e_head_food();

	if (e_snakes +e_count_injurys()<stage_data[stage].snakes){
		node =g_p_enemy;
		while (node){
			prev =node;
			node =node->next;
		}
		if ((prev !=g_p_enemy) && (!prev->injury_cnt))
			e_injury_from(prev);
	}
}

void enemy_sub4(){
	SP_DATA *p_master =g_e_node->master_sp;

	unsigned short o_flag; 
	g_e_node->move_flag=0;
	if (p_master->move_flag){
		o_flag =g_e_node->master_mflags_array[g_e_node->master_mflags_array_idx];
		g_e_node->master_mflags_array[g_e_node->master_mflags_array_idx++] =p_master->move_flag;
		g_e_node->master_mflags_array_idx %=10;
		if (o_flag&2){
			g_e_node->move_flag |=2;
			g_e_node->y+=g_p_enemy->speed;
		}
		if (o_flag&1){
			g_e_node->move_flag |=1;
			g_e_node->y-=g_p_enemy->speed;
		}
		if (o_flag&8){
			g_e_node->move_flag |=8;
			g_e_node->x+=g_p_enemy->speed;
		}
		if (o_flag&4){
			g_e_node->move_flag |=4;
			g_e_node->x-=g_p_enemy->speed;
		}
	}
	if ((!g_e_node->next) && g_e_node->injury_cnt){
		if (--g_e_node->injury_cnt==0){
			if (e_alloc_food(g_e_node->x, g_e_node->y)){
				PLAYSOUND1(SND_LAY_EGG);
				e_snake_lose_tail(g_p_enemy);
			}
		}
	}
}

void enemy_sub5(){
	int idx;

	if (g_p_enemy->form_cnt)
		g_p_enemy->form_cnt--;
	else{
		if (g_p_enemy->food_cnt<0x140){
			g_p_enemy->form_cnt =g_p_enemy->food_cnt>>4;
			idx =(g_p_enemy->move_cnt++) & 1;
			g_p_enemy->form =(idx) ?6 :9;
		}else
			g_p_enemy->form =9;
	}
	if (--g_p_enemy->food_cnt==0){
		PLAYSOUND3(SND_REBORN);
		g_p_enemy->state =3;
		g_p_enemy->speed =1;
		if (g_p_enemy->x & 1)
			g_p_enemy->x--;
		if (g_p_enemy->y & 1)
			g_p_enemy->y--;
		e_set_move_flag(1);
	}
}

void enemy_sub6(){
	unsigned int *ptbl;

	if (g_e_node->form_cnt){
		g_e_node->form_cnt--;
		if (!g_e_node->form_cnt)
			g_e_node->form_idx++;
	}else{
		ptbl =sp_form_data[0xa];
		g_e_node->form_cnt =ptbl[g_e_node->form_idx <<1];
		if (!g_e_node->form_cnt){
			g_e_node->state =0;
			if (g_e_node->next){
				init_for_explosion(g_e_node->next);
				PLAYSOUND0(SND_BLOW);
			}else{
				e_free_snake(g_e_idx);
			}
		}
	}
}

void e_set_states_3(){
	int i;

	for (i=0; i<e_snakes; i++){
		g_enemys[i]->state =3;
	}
}

int no_enemy(){
	return (e_snakes ==0);
}