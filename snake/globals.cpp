#include <windows.h>
#include <stdio.h>
#include "globals.h"

unsigned char *snake_gfx=0;

int frame_count =0;

#define MAX_SOUNDS 35
Mix_Chunk* g_sound[MAX_SOUNDS];

int color_no=0;
int color_change_mode=0;
int color_step=0;

short h_scroll_pa=0, v_scroll_pa=0;
short h_scroll_pb=0, v_scroll_pb=0;

int	pb_scroll_step;
int pb_to_scroll=0;
int pb_scroll_flag=0;

SPRITE sprite_buf[80];
int sprite_cnt=0;

unsigned short cram_buf[0x80];
unsigned short cram_buf_org[0x80];
int cram_dirty=0;
