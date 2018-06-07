#ifndef SOUND_H
#define SOUND_H


#include <stdlib.h>
#include <stdio.h>

#include "sdl/include/SDL.h"

#define SOUNDFMT AUDIO_U16
#define SOUNDCHANS 1
#define CHUNKSIZ 1024
#define SOUNDRATE 22050
#define SILENT_DATA 0x80
#define MAXBGM 6

struct Musicdata{
	char name[60];
	char* buf;
	int size;
	unsigned int reset;
};

int initSound(int format, int chans, int rate, int chunksiz);
void shutdownSound();

void open_bgm(char*filename, int index);
void play_bgm(int index);
void stop_bgm();
void play_bgm_mix();
void stop_bgm_mix();
void pause_bgm();
void resume_bgm();

extern int g_bgmplaying;

#define PLAYSOUND0(n) Mix_PlayChannel(0,g_sound[n],0)
#define PLAYSOUND1(n) Mix_PlayChannel(1,g_sound[n],0)
#define PLAYSOUND2(n) Mix_PlayChannel(2,g_sound[n],0)
#define PLAYSOUND3(n) Mix_PlayChannel(3,g_sound[n],0)
#define PLAYSOUND4(n) Mix_PlayChannel(4,g_sound[n],0)

#define PLAYSOUNDFREE(n) Mix_PlayChannel(-1,g_sound[n],0)

#define STOPSOUND(n) Mix_HaltChannel(n)
#define STOPSOUNDALL Mix_HaltChannel(-1)

#endif

