#ifndef PLAYER_H
#define PLAYER_H

extern SP_DATA *g_player;
extern int LIVES;
extern int player_lives;
extern float your_score;

void player_init();
void proc_player();

void p_snake_lose_nodes(SP_DATA *startnode);

void p_set_state_8();

#endif