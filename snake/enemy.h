#ifndef ENEMY_H
#define ENEMY_H

extern SP_DATA *g_enemys[MAX_ENEMIES];
extern int e_snakes;

void enemy_init();
void proc_enemy(SP_DATA *enemy);
void proc_enemys();

void e_snake_inc_nodes(SP_DATA *snake, int n);
void e_injury_from(SP_DATA *node);
void e_free_snake(int idx);
void e_set_states_3();

int no_enemy();

#endif