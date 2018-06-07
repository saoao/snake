%include "nasmhead.inc"

%define HIGH_B   0x80
%define SHAD_B   0x40
%define PRIO_B   0x01
%define SPR_B    0x20

%define HIGH_W   0x8080
%define SHAD_W   0x4040
%define NOSHAD_W 0xBFBF
%define PRIO_W   0x0100
%define SPR_W    0x2000

%define SHAD_D   0x40404040
%define NOSHAD_D 0xBFBFBFBF

srcPtr        equ 8
srcPitch      equ 12
width         equ 16
dstOffset     equ 20
dstPitch      equ 24

colorI   equ -2
colorE   equ 0
colorF   equ 2
colorJ   equ 4

colorG   equ -2
colorA   equ 0
colorB   equ 2
colorK   equ 4

colorH   equ -2
colorC   equ 0
colorD   equ 2
colorL   equ 4

colorM   equ -2
colorN   equ 0
colorO   equ 2
colorP   equ 4

section .data align=64

	DECL TAB336

	%assign i 0
	%rep 240
		dd (i * 336)
	%assign i i+1
	%endrep

	ALIGN32

	DECL TAB320

	%assign i 0
	%rep 240
		dd (i * 336)
	%assign i i+1
	%endrep

	ALIGN32
	
	Mask_N	dd 0xFFFFFFFF, 0xF0FFFFFF, 0x00FFFFFF, 0x00F0FFFF, 
			dd 0x0000FFFF, 0x0000F0FF, 0x000000FF, 0x000000F0

	Mask_F	dd 0xFFFFFFFF, 0xFFFFFF0F, 0xFFFFFF00, 0xFFFF0F00
			dd 0xFFFF0000, 0xFF0F0000, 0xFF000000, 0x0F000000

	Backdrop_p0		dd 0

	; 2xSAI

	ALIGNB32

	colorMask:		dd 0xF7DEF7DE,0xF7DEF7DE
	lowPixelMask:	dd 0x08210821,0x08210821

	qcolorMask:		dd 0xE79CE79C,0xE79CE79C
	qlowpixelMask:	dd 0x18631863,0x18631863

	darkenMask:		dd 0xC718C718,0xC718C718
	GreenMask:		dd 0x07E007E0,0x07E007E0
	RedBlueMask:	dd 0xF81FF81F,0xF81FF81F

	FALSE:			dd 0x00000000,0x00000000
	TRUE:			dd 0xffffffff,0xffffffff
	ONE:			dd 0x00010001,0x00010001

	colorMask15		dd 0x7BDE7BDE,0x7BDE7BDE
	lowPixelMask15	dd 0x04210421,0x04210421

	qcolorMask15	dd 0x739C739C,0x739C739C
	qlowpixelMask15	dd 0x0C630C63,0x0C630C63

	darkenMask15	dd 0x63186318,0x63186318
	GreenMask15		dd 0x03E003E0,0x03E003E0
	RedBlueMask15	dd 0x7C1F7C1F,0x7C1F7C1F

section .bss align=64

	DECL VRam
	resb 0x115580

	DECL CRam
	resw 128

	DECL ScreenA
	resd 64*64

	DECL ScreenB
	resd 64*64

	DECL Window
	resd 64*32

	DECL Sprite
	resw 80*4

	DECL HSRam
	resw 240*2

	DECL VSRam
	resd 64

	DECL CRam_Flag
	resd 1

	DECL VRam_Flag
	resd 1

	DECL VDP_Current_Line
	resd 1

	DECL SP_colide					;B5£º1=ÓĞÈÎºÎ2¸öspriteµÄ·ÇÍ¸Ã÷µãÅö×²
	resd 1

	DECL H_Cell
	resd 1
	DECL H_Win_Mul
	resd 1
	DECL H_Pix
	resd 1
	DECL H_Pix_Begin
	resd 1

	DECL H_Scroll_Mask
	resd 1
	DECL H_Scroll_CMul
	resd 1
	DECL H_Scroll_CMask
	resd 1
	DECL V_Scroll_CMask
	resd 1
	DECL V_Scroll_MMask
	resd 1

	DECL Win_X_Pos
	resd 1
	DECL Win_Y_Pos
	resd 1
	DECL Win_lr
	resd 1
	DECL Win_ud
	resd 1

	DECL Hbl_state;
	resd 1

	DECL Vbl_state;
	resd 1

	DECL Disp_state;
	resd 1

	DECL DMA_state;
	resd 1

	DECL BG_Color;
	resd 1

	DECL HInt_Counter;
	resd 1

	DECL STE_state;
	resd 1

	DECL interlace_state;
	resd 1

	DECL Auto_Inc;
	resd 1


	DECL MD_Screen
	resw (336 * 240)
	
	resw (320 + 32)

	DECL MD_Screen32
	resd (336 * 240)

	DECL MD_Palette
	resw 0x100

	DECL MD_Palette32
	resd 0x100

	DECL Palette
	resw 0x1000

	DECL Palette32
	resd 0x1000

	DECL Crt_BPP
	resd 1

	DECL Sprite_Struct
	resd (0x100 * 8)
	
	DECL Sprite_Visible
	resd 0x100

	DECL Data_Spr
	.H_Min			resd 1
	.H_Max			resd 1

	ALIGN_32
	
	DECL Data_Misc
	.Pattern_Adr	resd 1
	.Line_7			resd 1
	.X				resd 1
	.Cell			resd 1
	.Start_A		resd 1
	.Lenght_A		resd 1
	.Start_W		resd 1
	.Lenght_W		resd 1
	.Mask			resd 1
	.Spr_End		resd 1
	.Next_Cell		resd 1
	.Palette		resd 1
	.Borne			resd 1

	ALIGN_4
	
	DECL Have_MMX
	resd 1

	; 2xSAI

	LineBuffer:	resb 32
	Mask1:		resb 8
	Mask2:		resb 8
	ACPixel:	resb 8

	Line1Int:	resb 640 * 2
	Line2Int:	resb 640 * 2
	Line1IntP:	resd 1
	Line2IntP:	resb 1

section .text align=64
extern _hook
;****************************************
; È¡A/BÃæµÄ±¾É¨ÃèĞĞH¾í¶¯Öµ
; ²ÎÊı1: 0=BÃæ  1=AÃæ
; ³ö¿Ú: si=¾í¶¯Öµ

%macro GET_X_OFFSET 1

	mov eax, [VDP_Current_Line]
	mov ebx, HSRam			;
	mov edi, eax
	and eax, [H_Scroll_Mask]

%if %1 > 0
	mov esi, [ebx + eax * 4]			;
%else
	mov si, [ebx + eax * 4 + 2]			;
%endif

%endmacro


;****************************************
; ÈçÏÖÊä³öµÄTÁĞ#ÎªÅ¼, ÔòÈ¡ÏÂÒ»¸öV¾í¶¯Á¿, 
; ²¢¸üĞÂediÖĞµÄVĞĞ(T)¼°Data_Misc.Line_7µÄVÓàµã
; ²ÎÊı1: 0=BÃæ  1=AÃæ
; ²ÎÊı2: 0=ÆÕÍ¨  1=Interlace
; ³ö¿Ú:
; edi =(Ô­ÏÈµÄ»ò¸üĞÂµÄ) VĞĞ(T),   Data_Misc.Line_7=(Ô­ÏÈµÄ»ò¸üĞÂµÄ) VÓàµã

%macro UPDATE_Y_OFFSET 2

	mov eax, [Data_Misc.Cell]				;È¡ÏÖÊä³öµÄTÁĞ#
	test eax, 0xFF81						;ÈçÎª¸º»òÆæ, 
	jnz short %%End							;ÔòÈÔÊ¹ÓÃÏÖV¾í¶¯Á¿, ×ª·µ
	mov edi, [VDP_Current_Line]				;edi = ±¾É¨ÃèĞĞ#

%if %1 > 0
	mov eax, [VSRam + eax * 2 + 0]			;È¡AÃæ/BÃæµÄÏÂÒ»¸öV¾í¶¯Á¿
%else										;(×¢ÒâTÁĞ#*2, ÒòTÁĞ#ÎªÅ¼Ê±²Å³Ë2, ÊµÎª*4)
	mov ax, [VSRam + eax * 2 + 2]
%endif

%if %2 > 0
	shr eax, 1								; on divise le Y scroll par 2 si on est en entrelacé
%endif

	add edi, eax							;edi<==±¾É¨ÃèĞĞ# +V¾í¶¯Á¿, ¼´¾í¶¯ºóµÄÊµ¼ÊµãĞĞ#
	mov eax, edi							;
	shr edi, 3								;edi<==Êµ¼ÊµãĞĞ»¯ÎªVĞĞ(T)
	and eax, byte 7							;È¡Ä£
	and edi, [V_Scroll_CMask]				;
	mov [Data_Misc.Line_7], eax				;VÓàµã

%%End

%endmacro


;****************************************
; È¡µ±Ç°TI
; Èë¿Ú:
; edi = VĞĞ(T)
; esi = HÁĞ(T)
; ²ÎÊı1: 0=BÃæ  1=AÃæ
; ³ö¿Ú :
; ax = TI (Tile Info)

%macro GET_PATTERN_INFO 1

	mov cl, [H_Scroll_CMul]						;ĞĞTÖ¸Êı
	mov eax, edi								;
	shl eax, cl									;eax = VĞĞ(T) * (2µÄĞĞTÖ¸Êı´Î·½)
												;(¼´V¾í¶¯ºó¶ÔÓ¦µÄVĞĞ(T)ÔÚÃû×Ö±íÖĞµÄÆ«ÒÆ)
	mov edx, esi								;edx = HÁĞ(T)
	add edx, eax								;edx = VĞĞ(T)Æ«ÒÆ +HÁĞ(T)
												;(¼´ÒªÈ¡µÄTIµÄÆ«ÒÆ, !!ÊÇTIÆ«ÒÆ, ·Ç×Ö½ÚÆ«ÒÆ)

%if %1 > 0
	mov ebx, ScreenA							;¸ù¾İ²ÎÊı1, È¡AÃæ/BÃæµÄ
%else
	mov ebx, ScreenB
%endif

	mov eax, [ebx + edx * 4]						; eax = TI  (*4¼´TÆ«ÒÆ»¯Îª×Ö½ÚÆ«ÒÆ)

%endmacro


;****************************************
; È¡µ±Ç°TÄÚµÄ, ¶ÔÓ¦±¾É¨ÃèĞĞµÄÄÇĞĞµãÕóÊı¾İ (³¤×Ö)
; Èë¿Ú:
; eax = TI
; ²ÎÊı1 = 0=ÆÕÍ¨  1=Interlace
; ²ÎÊı2 = ÎŞĞ§
; ³ö¿Ú:
; ebx = µãÕó³¤×Ö (º¬8µã)
; edx = É«×é*016

%macro GET_PATTERN_DATA 2

	mov ebx, [Data_Misc.Line_7]					;ebx = VÓàµã, ¼´TÄÚµãĞĞ#
	mov edx, eax								;edx = TI
	mov ecx, eax								;ecx = TI
	shr edx, 24
	and edx, byte 0x70							;edx = É«×é*016  (É«×é0-7)
	and ecx, 0x3FFFFFF							;ecx = T# (26Î»)

%if %1 > 0
	shl ecx, 6									;ecx = T#*064, µÃTµÄµãÕóÊı¾İÆ«ÒÆ
												;(1¸öTileÓĞ064¸ö×Ö½Ú) 
%else
	shl ecx, 5									;ecx = T#*032, µÃTµÄµãÕóÊı¾İÆ«ÒÆ
												;(1¸öTileÓĞ032¸ö×Ö½Ú) 
%endif

	test eax, 0x8000000							; ÈçÖ¸¶¨V·­×ª, ÔòTÄÚµãĞĞ# Òì»ò 7
	jz %%No_V_Flip								; (0-7 ±äÎª 7-0)

	xor ebx, byte 7

%%No_V_Flip

%if %1 > 0
	mov ebx, [VRam + ecx + ebx * 8]				;(³Ë8ÊÇÒòÃ¿2µãĞĞÊä³ö1µãĞĞ, ´ÎµãĞĞ4×Ö½Ú²»ÓÃ)
%else
	mov ebx, [VRam + ecx + ebx * 4]				;µãÕóÊı¾İ ÔÚVRAMÄÚµÄ (TµÄµãÕóÊı¾İÆ«ÒÆ)+
%endif											;TÄÚµãĞĞ#*4´¦ (³Ë4ÊÇÒòÃ¿µãĞĞµãÕóÊı¾İ4×Ö½Ú)

%endmacro


;****************************************
;¸ù¾İSpriteÊôĞÔÇøÖØÉèSprite_Struct±í
; ²ÎÊı1 = 0=ÆÕÍ¨  1=Interlace


%macro MAKE_SPRITE_STRUCT 1

	mov ebp, Sprite							;esi=ebpÖ¸Ïò(VRAMµÄ)SpriteÊôĞÔÇø
	mov esi, ebp							;
	xor edi, edi							;edi = 0, ´ÓSprite_StructÊ×ÏîÆğĞ´Èë
	jmp short %%Loop

	ALIGN32
	
%%Loop
		mov ax, [ebp + 0]						;ax = Pos Y
		mov cx, [ebp + 6]						;cx = Pos X
		mov edx,0
		mov [Sprite_Struct + edi + 28], edx
		mov dl, [ebp + (2 ^ 1)]					;dl = Sprite³ß´ç (^1ÊÇÒòÎªVRAMµßµ¹, ÏÂÍ¬)
		test dl, 0x80
		jz %%cg0_3
		or byte [Sprite_Struct + edi + 28],0x40	;Èç¹ûÓÎÏ·²»ÓÃSprite³ß´çµÄ¸ß4Î», Ôò¿ÉÊ¹ÓÃ±¾¾ä, À´Ôö¼ÓSPRITE¿ÉÓÃÉ«×é
%%cg0_3
	%if %1 > 0
		shr eax, 1								; si entrelacé, la position est divisé par 2
	%endif
		mov dh, dl								;dh =dl =Sprite³ß´ç
		and eax, 0x1FF							;Pos Y,X¹æ·¶
		and ecx, 0x1FF
		and edx, 0x0C03							;dh =(X³ß´ç-1)*4, dl =(Y³ß´ç-1)
		sub eax, 0x80							;eax = YÏÔÊ¾×ø±ê (×¢Òâ¿ÉÎª¸º)
		sub ecx, 0x80							;ecx = XÏÔÊ¾×ø±ê (×¢Òâ¿ÉÎª¸º)
		mov [Sprite_Struct + edi + 4], eax		;YÏÔÊ¾×ø±ê ´æÈëSprite_Struct
		mov [Sprite_Struct + edi + 0], ecx		;XÏÔÊ¾×ø±ê ´æÈëSprite_Struct
		shr dh, 2								;dh = X³ß´ç-1
		inc dh									;dh = X³ß´ç
		mov [Sprite_Struct + edi + 8], dh		;X³ß´ç ´æÈëSprite_Struct
		mov bl, dh								;bl = X³ß´ç
		and ebx, byte 7							;ebx = X³ß´ç
		mov [Sprite_Struct + edi + 12], dl		;Y³ß´ç-1 ´æÈëSprite_Struct
		and edx, byte 3							;edx = Y³ß´ç-1
		lea ecx, [ecx + ebx * 8 - 1]			;ecx = ÓÒ¼«ÏŞ
		lea eax, [eax + edx * 8 + 7]			;eax = ÏÂ¼«ÏŞ (+7=+8-1, +8ÒòY³ß´ç-1)
		mov [Sprite_Struct + edi + 16], ecx		;ÓÒ¼«ÏŞ ´æÈëSprite_Struct
		mov [Sprite_Struct + edi + 20], eax		;ÏÂ¼«ÏŞ ´æÈëSprite_Struct
		mov bl, [ebp + (3 ^ 1)]					;bl = ÏÂÒ»SP#
		mov dx, [ebp + 4]						;dx = Ê×TI
		add edi, byte (8 * 4)					;ediÖ¸ÏòÏÂÒ»Sprite_StructÏî
		and ebx, byte 0x7F						;ebx = ÏÂÒ»SP#
		mov [Sprite_Struct + edi - 32 + 24], dx	;Ê×TI ´æÈëSprite_Struct (-32ÊÇÒò¸Õ+32)
		jz short %%End							;ÈçÏÂÒ»SP#Îª0, ÔòÔÙÎŞSP, ×ªÌø³öÑ­»·
		lea ebp, [esi + ebx * 8]				;ebpÖ¸ÏòÏÂÒ»SPÊôĞÔ
		cmp edi, (8 * 4 * 80)					;ÈçÎ´³¬Ô½SpriteÊôĞÔÇø, Ôò×ªÑ­»·
		jb near %%Loop

%%End
	sub edi, 8 * 4							;
	mov [Data_Misc.Spr_End], edi			;±£´æSprite_Struct±í×îºóÒ»ÏîµÄÆ«ÒÆ

%endmacro


;****************************************
;É¨ÃèSprite_Struct±í¸÷Ïî, ½«±¾É¨ÃèĞĞº¬ÓĞÇÒ¿É¼ûµÄ¸÷SpriteµÄÏîÆ«ÒÆ±£´æµ½Sprite_VisibleÇø,
;²¢´¦ÀíSpriteÆÁ±Î
;³ö¿Ú:
; edx =±¾É¨ÃèĞĞ#

%macro UPDATE_MASK_SPRITE 0

	xor edi, edi					;´ÓSprite_Struct±íµÚ0ÏîÆğ²éÕÒ
	xor ax, ax
	mov ebx, [H_Pix]				;ebx=ÏÔÊ¾µãÊı
	xor esi, esi					;Sprite_VisibleµÄ±£´æÖ¸Õë
	mov edx, [VDP_Current_Line]		;edx=±¾É¨ÃèĞĞ#
	jmp short %%Loop_1

	ALIGN4
	;(Loop_1Ñ­»·ÓÃÀ´²éÕÒÊ×¸ö±¾É¨ÃèĞĞº¬ÓĞµÄSprite)
%%Loop_1
		cmp [Sprite_Struct + edi + 4], edx			;YÏÔÊ¾×ø±ê>±¾É¨ÃèĞĞ#? ÊÇ×ªÏÂÒ»Ïî
		jg short %%Out_Line_1
		cmp [Sprite_Struct + edi + 20], edx			;ÏÂ¼«ÏŞ<±¾É¨ÃèĞĞ#? ÊÇ×ªÏÂÒ»Ïî
		jl short %%Out_Line_1

		;(ÕÒµ½Ê×¸ö±¾É¨ÃèĞĞº¬ÓĞµÄSprite, ÅĞÆäÊÇ·ñ¿É¼û)
		cmp [Sprite_Struct + edi + 0], ebx			;XÏÔÊ¾×ø±ê >ÏÔÊ¾µãÊı?
		jge short %%Out_Line_1_2					;ÊÇ, ×ªÏÂÒ»Ïî²¢½øÈëLoop_2
		cmp dword [Sprite_Struct + edi + 16], 0		;ÓÒ¼«ÏŞ<0?
		jl short %%Out_Line_1_2						;ÊÇ, ×ªÏÂÒ»Ïî²¢½øÈëLoop_2

		mov [Sprite_Visible + esi], edi				;ÕÒµ½±¾É¨ÃèĞĞ¿É¼ûµÄSprite, ±£´æÆäÆ«ÒÆ
		add esi, byte 4								;±£´æÖ¸Õë+=4, ÏÂÒ»±£´æÎ»ÖÃ

		;(½øÈëÕâ¶ùÊ±, ÒÑÕÒµ½Ê×¸ö±¾É¨ÃèĞĞº¬ÓĞµÄSprite (¿É¼û»ò²»¿É¼û))
%%Out_Line_1_2
		add edi, byte (8 * 4)						;ÏÂÒ»Sprite_StructÏî
		cmp edi, [Data_Misc.Spr_End]				;ÒÑ³¬Ô½Sprite_StructËùÓĞÏî?
		jle short %%Loop_2							;·ñ, Ôò×ªLoop_2Ñ­»·

		jmp %%End									;ÊÇ, Ôò×ª½áÊø

	ALIGN4

		;(½øÈëÕâ¶ùÊ±, ÈÔÈ»Î´ÕÒµ½Ê×¸ö±¾É¨ÃèĞĞº¬ÓĞµÄSprite)
%%Out_Line_1
		add edi, byte (8 * 4)						;ÏÂÒ»Sprite_StructÏî
		cmp edi, [Data_Misc.Spr_End]				
		jle short %%Loop_1							;ÒÑ³¬Ô½Sprite_StructËùÓĞÏî?
													;·ñ, Ôò×ªLoop_1Ñ­»·, ¼ÌĞø²éÊ×¸ö
		jmp %%End									;ÊÇ, Ôò×ª½áÊø

	ALIGN4

	;(Loop_2Ñ­»·ÓÃÀ´²éÕÒ´Î¸öÆğµÄ±¾É¨ÃèĞĞº¬ÓĞµÄSprite)
%%Loop_2
		cmp [Sprite_Struct + edi + 4], edx			;YÏÔÊ¾×ø±ê>±¾É¨ÃèĞĞ#? ÊÇ×ªÏÂÒ»Ïî
		jg short %%Out_Line_2
		cmp [Sprite_Struct + edi + 20], edx			;ÏÂ¼«ÏŞ<±¾É¨ÃèĞĞ#? ÊÇ×ªÏÂÒ»Ïî
		jl short %%Out_Line_2

		cmp dword [Sprite_Struct + edi + 0], -128	;ÈçXÏÔÊ¾×ø±êÎª-80 (ËµÃ÷XÎ»ÖÃÎª0)
		je short %%End								;ÔòÖ±½Ó×ª½áÊø (ÆäËüSprite±»ÆÁ±Î
													; ÒòËüÃÇÓÅÏÈ¼¶¿Ï¶¨¸üµÍ)

		cmp [Sprite_Struct + edi + 0], ebx			;XÏÔÊ¾×ø±ê >ÏÔÊ¾µãÊı? ÊÇ×ªÏÂÒ»Ïî
		jge short %%Out_Line_2
		cmp dword [Sprite_Struct + edi + 16], 0		;ÓÒ¼«ÏŞ<0? ÊÇ×ªÏÂÒ»Ïî
		jl short %%Out_Line_2

		mov [Sprite_Visible + esi], edi				;ÕÒµ½±¾É¨ÃèĞĞ¿É¼ûµÄSprite, ±£´æÆäÆ«ÒÆ
		add esi, byte 4								;±£´æÖ¸Õë+=4, ÏÂÒ»±£´æÎ»ÖÃ

%%Out_Line_2
		add edi, byte (8 * 4)
		cmp edi, [Data_Misc.Spr_End]
		jle short %%Loop_2
		jmp short %%End

	ALIGN4

%%End
	mov [Data_Misc.Borne], esi						;±£´æSprite_VisibleÇøÎ²(²»º¬)


%endmacro


;****************************************
; Êä³öA/BÃæµÄµÍPRIµã
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
;  edx = É«×é*016
; ²ÎÊı1 = ebxµãÕó³¤×Ö(8µã)µÄµã#
; ²ÎÊı2 = È¡³ö¸ÃµãÖµµÄMASK
; ²ÎÊı3 = ¸ÃµãÖµµÄÓÒÒÆÎ»Êı
; ²ÎÊı4 = 0=BÃæ  1=ÆäËü
; ²ÎÊı5 = 1=¸ßÁÁ/ÒõÓ°

%macro PUTPIXEL_P0 5

	mov eax, ebx			;Èç¸ÃµãÎª0000ÔòÊÇÍ¸Ã÷,
	and eax, %2
	jnz short %%no_trans1	;²»»­, Ö±½Ó·µ
	jmp short %%Trans

;(·Ç0000µã)
;(ÏÂÃæÒª¼ì²âÊÇ·ñAÃæ, ÈçÊÇ, ÒªÅĞ±¾µãÊä³ö´¦ÊÇ·ñÒÑÓĞBÃæ¸ßPriµã, ÊÇÔò²»ÄÜ¸²¸Ç, ×ª·µ
; ×¢ÒâBÃæ²»ÓÃ¼ì²âÖ±½Ó»­, ÒòBÃæÊÇ×îÏÈ´¦ÀíµÄ, ÆäÏÂÖ»ÓĞ1¸ö¼¶±ğ¸üµÍµÄBackdrop, ËùÒÔÖ±½Ó»­)
%%no_trans1
%if %4 > 0														;ÊÇAÃæ?
	%if %5 > 0													;¸ßÁÁ/ÒõÓ°Ä£Ê½?
		mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 1]			;ÊÇ, ÔòÈ¡¸ÃÊä³öµã¸ß×Ö½Ú
		test cl, PRIO_B											;¸ÃµãÒÑÓĞBÃæ¸ßPriµã?
		jz short %%no_trans2									;ÊÇÔò²»»­, ·µ
																;(µÍPriµÄA²»ÄÜ¸²¸ÇËü)
	%else
																;²»ÊÇ¸ßÁÁ/ÒõÓ°Ä£Ê½
		test byte [MD_Screen + ebp * 2 + (%1 * 2) + 1], PRIO_B	;È¡µã¸ß×Ö½Ú
		jz short %%no_trans2									;ÈçÒÑÓĞBÃæ¸ßPriµã, Ôò·µ
	%endif
	jmp short %%Trans
%endif

%%no_trans2
%if %3 > 0
	shr eax, %3									;½«µãÓÒÒÆ, µÃµãÖµ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3

;(A,BÃæ·Ö±ğ´¦Àí)
%if %4 > 0
	;(AÃæ)
	%if %5 > 0
		;(AÃæÓĞÎŞÒõÓ°ËæBÃæ¶ø¶¨)
		;(¸ßÁÁ/ÒõÓ°Ê±, µÍPRIµÄBÃæ,Backdrop¶¼ÊÇÒõÓ°, ËäÈ»¸ßPRIµÄBÎŞÒõÓ° (º¬Backdrop), 
		; µ«µÍPRIµÄAÎŞ·¨¸²¸Ç¸ßPRIµÄB, Ã²ËÆÕâ¶ù¿ÉÓÃor al, SHAD_B, 
		; µ«¸ßPRIµÄ BÖĞÈÔÓĞ0000µã, ´ËÊ±µÍPRIµÄAÄÜ¸²¸ÇÕâĞ©0000µã, ÇÒÎŞÒõÓ°, ËùÒÔÒªÓÃand)
		and cl, SHAD_B							;¸ßÁÁ/ÒõÓ°Ê±µÄÉ«²Ê# =0x40(Èç¹ûÔ­ÏÈÓĞÒõÓ°)
		add al, dl								; +É«×é*16
		add al, cl								; +µãÖµ (0-F)
	%else
		add al, dl								;ÆÕÍ¨Ê±µÄÉ«²Ê# =É«×é*16 +µãÖµ (0-F)
	%endif
%else
	;(BÃæ)
	%if %5 > 0
		lea eax, [eax + edx + SHAD_W]			;¸ßÁÁ/ÒõÓ°Ê±µÄÉ«²Ê# =0x40 (×¢ÒâÖ»ÄÜÊÇÒõÓ°)
												; +É«×é*16 +µãÖµ (0-F)
	%else
		add al, dl								;ÆÕÍ¨Ê±µÄÉ«²Ê# =É«×é*16 +µãÖµ (0-F)
	%endif
%endif

%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], al	;Ğ´ÈëÉ«²Ê#Öµ

%%Trans

%endmacro


;****************************************
; Êä³öA/BÃæµÄ¸ßPRIµã
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
;  edx = É«×é*016
; ²ÎÊı1 = ebxµãÕó³¤×Ö(8µã)µÄµã#
; ²ÎÊı2 = È¡³ö¸ÃµãÖµµÄMASK
; ²ÎÊı3 = ¸ÃµãÖµµÄÓÒÒÆÎ»Êı
; ²ÎÊı4 = 1=¸ßÁÁ/ÒõÓ°  (ÎŞĞ§)

%macro PUTPIXEL_P1 4

	mov eax, ebx			;Èç¸ÃµãÎª0000ÔòÊÇÍ¸Ã÷,
	and eax, %2
	jnz short %%no_trans
	jmp short %%Trans		;²»»­, Ö±½Ó·µ (×¢Òâ, ¾¡¹ÜTÊÇ¸ßPRI, µ«ÆäÍ¸Ã÷µãÎ´´¦Àí, Æä¸ß×Ö½Ú
							; PRIÎ»ÈÔÎª0)
%%no_trans
%if %3 > 0
	shr eax, %3				;½«µãÓÒÒÆ, µÃµãÖµ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


;(Ö±½ÓĞ´Èë: ÒòÎªÈçÊÇBÃæµÄµã, µ±È»Ö±½ÓĞ´Èë, 
; ÈçÊÇAÃæµÄµã, ÒòÆäÊÇ¸ßPRI, ×ÜÊÇ¸²¸ÇBÃæµÄµã, ¶ø²»¹ÜBÃæPRIÊÇ¸ßÊÇµÍ
; Ò²²»ÓÃ¿¼ÂÇÒõÓ°, A,BÃæTÖ»ÒªÓĞÒ»ÊÇ¸ßPRI, ¾ÍÃ»ÓĞÒõÓ° (¼´Ê¹Ô­ÏÈÓĞ, Ò²ÒÑÔÚPUTLINE_P1ÖĞÈ¥³ı))
	lea eax, [eax + edx + PRIO_W]				;É«²Ê# =É«×é*16 +µãÖµ (0-F), ¸ß×Ö½Ú±íÃ÷
												; ±¾µãÒÑÓÉ(A/BÃæµÄ)¸ßPriµãÊä³ö
%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], ax	;Ğ´ÈëÉ«²Ê#Öµ (º¬¸ß×Ö½Ú)

%%Trans

%endmacro


;****************************************
; Êä³öSpriteµã
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
;  edx = É«×é*016
; ²ÎÊı1 = ebxµãÕó³¤×Ö(8µã)µÄµã#
; ²ÎÊı2 = È¡³ö¸ÃµãÖµµÄMASK
; ²ÎÊı3 = ¸ÃµãÖµµÄÓÒÒÆÎ»Êı
; ²ÎÊı4 = PRI
; ²ÎÊı5 = 1=¸ßÁÁ/ÒõÓ°

%macro PUTPIXEL_SPRITE 5

	mov eax, ebx			;Èç¸ÃµãÎª0000ÔòÊÇÍ¸Ã÷,
	and eax, %2
	jz near %%Trans			;²»»­, Ö±½Ó·µ (×¢Òâ, Í¸Ã÷µãµÄ¸ß×Ö½ÚÎŞ ÒÑÓÉÆäËüSpriteÊä³ö±êÖ¾,
							; ÆäºóSprite¿É¸²¸ÇËü)

	;(·Ç0000µã)
	mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1]	;È¡¸ÃÊä³öµã¸ß×Ö½Ú
													;(16=2*8, Ìø¹ıÇ°8µã, ÒòSprite²»ÓÃµ÷Õû)
	test cl, (PRIO_B + SPR_B - %4)		;Èç ÒÑÓÉÆäËüSpriteÊä³ö, »òÊÇÒÑÓÉ(A/BÃæµÄ)¸ßPriµã
										;Êä³ö¶ø±¾SpriteµãÊÇµÍPRI, Ôò²»Êä³ö±¾µã
	jz short %%Affich					;·ñÔò×ªÊä³ö±¾µã

;(²»Êä³ö±¾µã)
%%Prio
	or ch, cl			;ch¸ú×Ù²»Êä³ö¸÷µãÊ±, ÆäÏàÓ¦Ô­Êä³öµãÊÇ·ñº¬ ÒÑÓÉÆäËüSpriteÊä³ö±êÖ¾,
						;ÈçÓĞ, ÔòËµÃ÷Ä³SpriteµÄ·Ç0µãÓëÖ®Ç°»­µÄÄ³SpriteÓĞ³åÍ», ¿ÉÓÃÀ´ÉèÖÃ
						;SP_colide (ÓĞÈÎºÎ2¸öspriteµÄ·ÇÍ¸Ã÷µãÅö×²)

%if %4 < 1				;ÈçÊÇµÍPRIµÄSpriteµã²»Êä³ö, ÓĞ¿ÉÄÜÊÇ±» ABÃæµÄ¸ßPRIµã×è¶Ï, ÎªÃâ±»
						;Ö®ºóµÄµÍ¼¶±ğ(µ«¸ßPRI) Sprite¸²¸Ç, 
	or byte [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1], SPR_B	;ÖÃ ±¾µãÒÑÓÉÆäËüSpriteÊä³ö
%endif
	jmp %%Trans			;×ª·µ

;(Êä³ö±¾µã)

ALIGN4

%%Affich

%if %3 > 0
	shr eax, %3						;½«µãÓÒÒÆ, µÃµãÖµ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


	;(·Ç¸ßÁÁ/ÒõÓ°Ê±)
	lea eax, [eax + edx + SPR_W]	;É«²Ê# =É«×é*16 +µãÖµ (0-F), 
									;¸ß×Ö½ÚÖÃ ±¾µãÒÑÓÉÆäËüSpriteÊä³ö

%if %5 > 0
;(¸ßÁÁ/ÒõÓ°Ê±)
	;ÏÈ¼ÆËã ·ÇÌØÊâÉ«²Ê# (3E, 3F)µÄSpriteµã¸²¸ÇABÃæµãÊ±, Æä¸ßÁÁ/ÒõÓ°/ÆÕÍ¨×´Ì¬
	%if %4 < 1
		and cl, SHAD_B | HIGH_B		;µÍPRIµÄSpriteµãËæABÃæµÄ¸ßÁÁ/ÒõÓ°/ÆÕÍ¨±ä»¯
	%else
		and cl, HIGH_B				;¸ßPRIµÄSpriteµãËæABÃæµÄ¸ßÁÁ/ÆÕÍ¨±ä»¯ (ÒõÓ°Ò²ËãÆÕÍ¨)
	%endif

	cmp eax, (0x3E + SPR_W)
	jb short %%Normal
	ja short %%Shadow

;(ÌØÊâÉ«²Ê#3E, Ê¹ABÃæµã¸ßÁÁ, µ«±¾Éí²»ÏÔÊ¾, µãµÄ¸ß×Ö½ÚÒ²ÎŞ ÒÑÓÉÆäËüSpriteÊä³ö)
%%Highlight
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], HIGH_W
	jmp short %%Trans			;×ª·µ
	
;(ÌØÊâÉ«²Ê#3F, Ê¹ABÃæµãÒõÓ°, µ«±¾Éí²»ÏÔÊ¾, µãµÄ¸ß×Ö½ÚÒ²ÎŞ ÒÑÓÉÆäËüSpriteÊä³ö)
%%Shadow
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], SHAD_W
	jmp short %%Trans			;×ª·µ
;(·ÇÌØÊâÉ«²Ê#)
%%Normal
	add al, cl						;É«×é*16 +µãÖµ (0-F), ¼ÓÉÏÉÏÃæ¼ÆËãµÄ¸ßÁÁ/ÒõÓ°/ÆÕÍ¨×´Ì¬

%endif

	mov [MD_Screen + ebp * 2 + (%1 * 2) + 16], ax	;Ğ´ÈëÉ«²Ê# (º¬¸ß×Ö½Ú)

%%Trans

%endmacro


;****************************************
; Êä³öA/BÃæµÄµÍPRI TµãĞĞ (8µã)
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
; ²ÎÊı1 = 0=BÃæ  1=ÆäËü
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

%macro PUTLINE_P0 2

;ÊÇÊä³öBÃæ T? (Ö»ÓĞBÃæ¿ÉÖ±½ÓÉèÖÃBackdrop, AÃæ²»¿É)
%if %1 < 1
;ÉèÖÃ±¾µãĞĞ(8µã)µÄBackdrop (¹²8*2=016×Ö½Ú)
	%if %2 > 0
	;ÒõÓ°Ê±Backdrop (40ÊÇÒõÓ°µÄÉ«×é0É«0) (×¢ÒâÁ¬¸ß×Ö½ÚÒ²Ò»²¢ÉèÖÃ)
		mov dword [MD_Screen + ebp * 2 +  0], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  4], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  8], SHAD_D
		mov dword [MD_Screen + ebp * 2 + 12], SHAD_D
		mov dword [Backdrop_p0], SHAD_D
	%else
	;ÎŞÒõÓ°Ê±Backdrop (0ÊÇÉ«×é0É«0) (×¢ÒâÁ¬¸ß×Ö½ÚÒ²Ò»²¢ÉèÖÃ)
		mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
		mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
		mov dword [Backdrop_p0], 0x00000000
	%endif
%endif

	test ebx, ebx			;Èç±¾µãĞĞ¾ùÎª0000µã, Ôò²»ÓÃ»­, Ö±½Ó·µ
	jz near %%Full_Trans
	;8¸ö»­µã²Ù×÷ (×¢Òâebx¶ÁµÄÊÇ³¤×Ö)
	PUTPIXEL_P0 0, 0x000000f0,  4, %1, %2
	PUTPIXEL_P0 1, 0x0000000f,  0, %1, %2
	PUTPIXEL_P0 2, 0x0000f000, 12, %1, %2
	PUTPIXEL_P0 3, 0x00000f00,  8, %1, %2
	PUTPIXEL_P0 4, 0x00f00000, 20, %1, %2
	PUTPIXEL_P0 5, 0x000f0000, 16, %1, %2
	PUTPIXEL_P0 6, 0xf0000000, 28, %1, %2
	PUTPIXEL_P0 7, 0x0f000000, 24, %1, %2

%%Full_Trans

%endmacro


;****************************************
; Êä³öA/BÃæµÄµÍPRI TµãĞĞ (8µã), X·­×ª
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
; ²ÎÊı1 = 0=BÃæ  1=ÆäËü
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

;(Í¬ÉÏ, ½ö8¸ö»­µã²Ù×÷ÓĞÒì)

%macro PUTLINE_FLIP_P0 2

%if %1 < 1
	%if %2 > 0
		mov dword [MD_Screen + ebp * 2 +  0], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  4], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  8], SHAD_D
		mov dword [MD_Screen + ebp * 2 + 12], SHAD_D
		mov dword [Backdrop_p0], SHAD_D
	%else
		mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
		mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
		mov dword [Backdrop_p0], 0x00000000
	%endif
%endif

	test ebx, ebx
	jz near %%Full_Trans
	;8¸ö»­µã²Ù×÷ (ÓëÉÏÏà±È¿É¼ûX·­×ªĞ§¹û)
	PUTPIXEL_P0 0, 0x0f000000, 24, %1, %2
	PUTPIXEL_P0 1, 0xf0000000, 28, %1, %2
	PUTPIXEL_P0 2, 0x000f0000, 16, %1, %2
	PUTPIXEL_P0 3, 0x00f00000, 20, %1, %2
	PUTPIXEL_P0 4, 0x00000f00,  8, %1, %2
	PUTPIXEL_P0 5, 0x0000f000, 12, %1, %2
	PUTPIXEL_P0 6, 0x0000000f,  0, %1, %2
	PUTPIXEL_P0 7, 0x000000f0,  4, %1, %2

%%Full_Trans

%endmacro


;****************************************
; Êä³öA/BÃæµÄ¸ßPRI TµãĞĞ (8µã)
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
; ²ÎÊı1 = 0=BÃæ  1=ÆäËü
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

%macro PUTLINE_P1 2

;(¸ßPRIµãÎŞÒõÓ°, ËùÒÔÏÈ½øĞĞÎŞÒõÓ°»òÈ¥³ıÒõÓ°´¦Àí)

%if %1 < 1
	;BÃæÊ±, Ö±½ÓÉèBackdrop (0ÊÇÉ«×é0É«0) (×¢ÒâÁ¬¸ß×Ö½ÚÒ²Ò»²¢ÉèÖÃ)
	;(ÊÇ·ñ¸ßÁÁ/ÒõÓ°ÔÚÕâ¶ù±»ºöÊÓ)
	mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
	mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
%else
	%if %2 > 0
	;(AÃæÇÒ¸ßÁÁ/ÒõÓ°Ê±)
	;(µÍPRIµÄBÃæÓ¦¸ÃÊÇÒõÓ°, µ«±¾AÃæTÊÇ¸ßPRI, ËùÒÔÏàÓ¦Î»ÖÃµÄBÃæµãÒªÏÈÈ¥³ıÒõÓ°)
		; Faster on almost CPU (because of pairable instructions)

		mov eax, [MD_Screen + ebp * 2 +  0]
		mov ecx, [MD_Screen + ebp * 2 +  4]
		and eax, NOSHAD_D
		and ecx, NOSHAD_D
		mov [MD_Screen + ebp * 2 +  0], eax
		mov [MD_Screen + ebp * 2 +  4], ecx
		mov eax, [MD_Screen + ebp * 2 +  8]
		mov ecx, [MD_Screen + ebp * 2 + 12]
		and eax, NOSHAD_D
		and ecx, NOSHAD_D
		mov [MD_Screen + ebp * 2 +  8], eax
		mov [MD_Screen + ebp * 2 + 12], ecx

		; Faster on K6 CPU

		;and dword [MD_Screen + ebp * 2 +  0], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 +  4], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 +  8], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 + 12], NOSHAD_D
	%endif
%endif

	test ebx, ebx			;Èç±¾µãĞĞ¾ùÎª0000µã, Ôò²»ÓÃ»­, Ö±½Ó·µ
	jz near %%Full_Trans
	;8¸ö»­µã²Ù×÷ (×¢Òâebx¶ÁµÄÊÇ³¤×Ö)
	PUTPIXEL_P1 0, 0x000000f0,  4, %1
	PUTPIXEL_P1 1, 0x0000000f,  0, %1
	PUTPIXEL_P1 2, 0x0000f000, 12, %1
	PUTPIXEL_P1 3, 0x00000f00,  8, %1
	PUTPIXEL_P1 4, 0x00f00000, 20, %1
	PUTPIXEL_P1 5, 0x000f0000, 16, %1
	PUTPIXEL_P1 6, 0xf0000000, 28, %1
	PUTPIXEL_P1 7, 0x0f000000, 24, %1

%%Full_Trans

%endmacro


;****************************************
; Êä³öA/BÃæµÄ¸ßPRI TµãĞĞ (8µã), X·­×ª
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ
; ²ÎÊı1 = 0=BÃæ  1=ÆäËü
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

;(Í¬ÉÏ, ½ö8¸ö»­µã²Ù×÷ÓĞÒì)

%macro PUTLINE_FLIP_P1 2

%if %1 < 1
	mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
	mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
%else
	%if %2 > 0

		; Faster on almost CPU (because of pairable instructions)

		mov eax, [MD_Screen + ebp * 2 +  0]
		mov ecx, [MD_Screen + ebp * 2 +  4]
		and eax, NOSHAD_D
		and ecx, NOSHAD_D
		mov [MD_Screen + ebp * 2 +  0], eax
		mov [MD_Screen + ebp * 2 +  4], ecx
		mov eax, [MD_Screen + ebp * 2 +  8]
		mov ecx, [MD_Screen + ebp * 2 + 12]
		and eax, NOSHAD_D
		and ecx, NOSHAD_D
		mov [MD_Screen + ebp * 2 +  8], eax
		mov [MD_Screen + ebp * 2 + 12], ecx

		; Faster on K6 CPU

		;and dword [MD_Screen + ebp * 2 +  0], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 +  4], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 +  8], NOSHAD_D
		;and dword [MD_Screen + ebp * 2 + 12], NOSHAD_D
	%endif
%endif

	test ebx, ebx
	jz near %%Full_Trans
	;8¸ö»­µã²Ù×÷ (ÓëÉÏÏà±È¿É¼ûX·­×ªĞ§¹û)
	PUTPIXEL_P1 0, 0x0f000000, 24, %1
	PUTPIXEL_P1 1, 0xf0000000, 28, %1
	PUTPIXEL_P1 2, 0x000f0000, 16, %1
	PUTPIXEL_P1 3, 0x00f00000, 20, %1
	PUTPIXEL_P1 4, 0x00000f00,  8, %1
	PUTPIXEL_P1 5, 0x0000f000, 12, %1
	PUTPIXEL_P1 6, 0x0000000f,  0, %1
	PUTPIXEL_P1 7, 0x000000f0,  4, %1

%%Full_Trans

%endmacro


;****************************************
;Êä³öSpriteµ±Ç°TµÄµãĞĞ (8µã)
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ (´¿Æ«ÒÆ, ²»º¬É¨ÃèĞĞÊ××ÔÉíÆ«ÒÆ)
; ³ö¿Ú :
;  ch  = 20 (ÈçÓĞSprite·Ç0000µã³åÍ»)
; ²ÎÊı1  = PRI
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

%macro PUTLINE_SPRITE 2

	xor ecx, ecx
	add ebp, [esp]		;ebp +=É¨ÃèĞĞÊ××ÔÉíÆ«ÒÆ (É¨ÃèĞĞ# *0336)

	;8¸ö»­µã²Ù×÷
	PUTPIXEL_SPRITE 0, 0x000000f0,  4, %1, %2
	PUTPIXEL_SPRITE 1, 0x0000000f,  0, %1, %2
	PUTPIXEL_SPRITE 2, 0x0000f000, 12, %1, %2
	PUTPIXEL_SPRITE 3, 0x00000f00,  8, %1, %2
	PUTPIXEL_SPRITE 4, 0x00f00000, 20, %1, %2
	PUTPIXEL_SPRITE 5, 0x000f0000, 16, %1, %2
	PUTPIXEL_SPRITE 6, 0xf0000000, 28, %1, %2
	PUTPIXEL_SPRITE 7, 0x0f000000, 24, %1, %2

	sub ebp, [esp]		;ebp»Ö¸´Îª´¿Æ«ÒÆ
	and ch, 0x20				;ÈçÓĞSprite·Ç0000µã³åÍ»,
	or byte [SP_colide], ch	;ÖÃSP_colideµÄ ÓĞÈÎºÎ2¸öspriteµÄ·ÇÍ¸Ã÷µãÅö×²

%endmacro


;****************************************
;Êä³öSpriteµ±Ç°TµÄµãĞĞ (8µã), X·­×ª
; Èë¿Ú :
;  ebx = µãÕó³¤×Ö
;  ebp = µ±Ç°TÊä³öÎ»ÖÃ (´¿Æ«ÒÆ, ²»º¬É¨ÃèĞĞÊ××ÔÉíÆ«ÒÆ)
; ³ö¿Ú :
;  ch  = 20 (ÈçÓĞSprite·Ç0000µã³åÍ»)
; ²ÎÊı1  = PRI
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

;(Í¬ÉÏ, ½ö8¸ö»­µã²Ù×÷ÓĞÒì)

%macro PUTLINE_SPRITE_FLIP 2

	xor ecx, ecx
	add ebp, [esp]

	;8¸ö»­µã²Ù×÷ (ÓëÉÏÏà±È¿É¼ûX·­×ªĞ§¹û)
	PUTPIXEL_SPRITE 0, 0x0f000000, 24, %1, %2
	PUTPIXEL_SPRITE 1, 0xf0000000, 28, %1, %2
	PUTPIXEL_SPRITE 2, 0x000f0000, 16, %1, %2
	PUTPIXEL_SPRITE 3, 0x00f00000, 20, %1, %2
	PUTPIXEL_SPRITE 4, 0x00000f00,  8, %1, %2
	PUTPIXEL_SPRITE 5, 0x0000f000, 12, %1, %2
	PUTPIXEL_SPRITE 6, 0x0000000f,  0, %1, %2
	PUTPIXEL_SPRITE 7, 0x000000f0,  4, %1, %2

	and ch, 0x20
	sub ebp, [esp]
	or byte [SP_colide], ch

%endmacro

;****************************************
;½«GenesisµÄCRam×ª»¯ÎªPC¸ñÊ½MD_Palette
; ²ÎÊı1: 1=¸ßÁÁ/ÒõÓ°

%macro UPDATE_PALETTE 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; ÒÑ´¦Àí, ËùÒÔÇåCRam¸Ä±ä±êÖ¾
	mov cx, 0x7BEF								; 0111 1011 1110 1111 (r4g5b4)
	xor edx, edx								; Ã¿¸öÉ«²ÊÓÒÒÆ1Î», ÔÙÓë´ËÏà"Óë", ¿ÉÊ¹Ã¿¸öÉ«²Êbgr·ÖÁ¿¼õ°ë(°µ)
	mov ebx, (128 / 2) - 1						; ebx = É«²ÊÑ­»·Êı, 128ÊÇÉ«²Ê×ÜÊı(8É«×é)
	jmp short %%Loop							; (³ı2ÒòÃ¿´Î´¦Àí2¸öÉ«²Ê)
	
	ALIGN32

	%%Loop										;Ñ­»·
		mov ax, [CRam + ebx * 4 + 0]					; ax = µ±Ç°É«²Ê1
		mov dx, [CRam + ebx * 4 + 2]					; dx = µ±Ç°É«²Ê2
		cmp ebx, 0x20
		jb %%cg0_3
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 0], ax	; É«×é4-7Ö±½Ó´æÈëÄ¿±ê
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 2], dx	; 
		jmp short %%Next_c
	%%cg0_3
		and ax, 0x0FFF									; É«²Ê×Öbbb0 ggg0 rrr0
		and dx, 0x0FFF									; Ö»ÓĞ12Î»
		
		mov ax, [Palette + eax * 2]						; É«²Ê1,2»¯ÎªPC¸ñÊ½
		mov dx, [Palette + edx * 2]
		mov [MD_Palette + ebx * 4 + 0], ax				; ´æÈëÄ¿±ê
		mov [MD_Palette + ebx * 4 + 2], dx				; 

%if %1 > 0												;ÈçÖ¸¶¨Highlight/Shadow
		shr ax, 1
		shr dx, 1
		and ax, cx										; PCÉ«²Ê1,2»¯Îª°µÉ«
		and dx, cx										; 
		mov [MD_Palette + ebx * 4 + 64 * 2 + 0], ax		; 64-127±£´æ°µÉ«
		mov [MD_Palette + ebx * 4 + 64 * 2 + 2], dx		; 
		add ax, cx										; PC°µÉ«²Ê1,2»¯ÎªÁÁÉ«
		add dx, cx
		mov [MD_Palette + ebx * 4 + 128 * 2 + 0], ax	; 128-191±£´æÁÁÉ«
		mov [MD_Palette + ebx * 4 + 128 * 2 + 2], dx	; 
%endif

	%%Next_c
		dec ebx										; Ñ­»·´¦ÀíËùÓĞ64¸öÉ«²Ê
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;É«×é0É«0¸ÄÎª±³¾°É«¼Ä´æÆ÷Ö¸¶¨É«
		and ebx, byte 0x3F					;(¼´ABÃæÖĞËùÓĞÉ«×é0tileµÄ0000µã¶¼
		mov ax, [MD_Palette + ebx * 2]		; ÏÔÊ¾Îª´Ë±³¾°É«)
		mov [MD_Palette + 0 * 2], ax

%if %1 > 0										;ÈçÖ¸¶¨Highlight/Shadow
		shr ax, 1								;¸ÄÎª±³¾°É«¼Ä´æÆ÷Ö¸¶¨É«µÄ°µ, ÁÁ°æ±¾
		and ax, cx
		mov [MD_Palette + 0 * 2 + 64 * 2], ax
		add ax, cx
		mov [MD_Palette + 0 * 2 + 128 * 2], ax
%endif

%endmacro

;****************************************
;½«GenesisµÄCRam×ª»¯ÎªPC32¸ñÊ½MD_Palette32
; ²ÎÊı1: 1=¸ßÁÁ/ÒõÓ°

%macro UPDATE_PALETTE32 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; ÒÑ´¦Àí, ËùÒÔÇåCRam¸Ä±ä±êÖ¾
	mov ecx, 0x7f7f7f							; (r7g7b7)
	xor edx, edx								; Ã¿¸öÉ«²ÊÓÒÒÆ1Î», ÔÙÓë´ËÏà"Óë",¿ÉÊ¹Ã¿¸öÉ«²Êbgr·ÖÁ¿¼õ°ë(°µ)
	mov ebx, (128 / 2) - 1						; ebx = É«²ÊÑ­»·Êı, 128ÊÇÉ«²Ê×ÜÊı(8É«×é)(³ı2ÒòÃ¿´Î´¦Àí2¸öÉ«²Ê)
	jmp short %%Loop

	ALIGN32

	%%Loop												;Ñ­»·
		mov ax, [CRam + ebx * 4 + 0]					; ax = µ±Ç°É«²Ê1
		mov dx, [CRam + ebx * 4 + 2]					; dx = µ±Ç°É«²Ê2
		cmp ebx, 0x20
		jb %%cg0_3
		mov esi, eax									; eax=»¯Îª32Î»¸ñÊ½
		mov edi, eax
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and eax, 0x1F
		shl eax, 3
		or  eax, esi
		or  eax, edi
		mov esi, edx									; edx=»¯Îª32Î»¸ñÊ½
		mov edi, edx
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and edx, 0x1F
		shl edx, 3
		or  edx, esi
		or  edx, edi
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 0], eax	; É«×é4-7Ö±½Ó´æÈëÄ¿±ê
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 4], edx	; 
		jmp short %%Next_c
	%%cg0_3
		and eax, 0x0FFF									; É«²Ê×Öbbb0 ggg0 rrr0
		and edx, 0x0FFF									; Ö»ÓĞ12Î»
		
		mov eax, [Palette32 + eax * 4]						; É«²Ê1,2»¯ÎªPC¸ñÊ½
		mov edx, [Palette32 + edx * 4]
		mov [MD_Palette32 + ebx * 8 + 0], eax				; ´æÈëÄ¿±ê
		mov [MD_Palette32 + ebx * 8 + 4], edx				; 

%if %1 > 0												;ÈçÖ¸¶¨Highlight/Shadow
		shr eax, 1
		shr edx, 1
		and eax, ecx										; PCÉ«²Ê1,2»¯Îª°µÉ«
		and edx, ecx										; 
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 0], eax		; 64-127±£´æ°µÉ«
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 4], edx		; 
		add eax, ecx										; PC°µÉ«²Ê1,2»¯ÎªÁÁÉ«
		add edx, ecx
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 0], eax	; 128-191±£´æÁÁÉ«
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 4], edx	; 
%endif

	%%Next_c
		dec ebx										; Ñ­»·´¦ÀíËùÓĞ64¸öÉ«²Ê
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;É«×é0É«0¸ÄÎª±³¾°É«¼Ä´æÆ÷Ö¸¶¨É«
		and ebx, byte 0x3F					;(¼´ABÃæÖĞËùÓĞÉ«×é0tileµÄ0000µã¶¼
		mov eax, [MD_Palette32 + ebx * 4]		; ÏÔÊ¾Îª´Ë±³¾°É«)
		mov [MD_Palette32 + 0 * 4], eax

%if %1 > 0										;ÈçÖ¸¶¨Highlight/Shadow
		shr eax, 1								;¸ÄÎª±³¾°É«¼Ä´æÆ÷Ö¸¶¨É«µÄ°µ, ÁÁ°æ±¾
		and eax, ecx
		mov [MD_Palette32 + 0 * 4 + 64 * 4], eax
		add eax, ecx
		mov [MD_Palette32 + 0 * 4 + 128 * 4], eax
%endif

%endmacro

;****************************************
; Êä³öBÃæ ±¾É¨ÃèĞĞ
; ²ÎÊı1 = 0=ÆÕÍ¨  1=Interlace
; ²ÎÊı2 = 0=VÈ«ÆÁ 1=V2TÁĞ
; ²ÎÊı3 = 1=¸ßÁÁ/ÒõÓ°

%macro RENDER_LINE_SCROLL_B 3

	mov ebp, [esp]				;ebpÖ¸ÏòMD_ScreenÄÚ±¾É¨ÃèĞĞÊä³öÎ»ÖÃ (É¨ÃèĞĞ# *336)

	GET_X_OFFSET 0				;si<==È¡BÃæµÄ±¾É¨ÃèĞĞH¾í¶¯Öµ

	mov eax, esi
	xor esi, 0x3FF				;esi =Êµ¼ÊH¾í¶¯Öµ
	shr esi, 3					;esi = HÁĞ(T)
	and eax, byte 7				;eax = HÓàµã
	add ebp, eax				;ebp +=HÓàµã, Í¨¹ıÊä³öÎ»ÖÃµ÷ÕûÊµÏÖH¾í¶¯ (Ïê¼ûMD_Screen)
	mov ebx, esi
	and esi, [H_Scroll_CMask]	;esi µÄHÁĞ(T) È¡Ä£ (³¬¹ı×î´óTÊıÔò»Ø¾í)
	and ebx, byte 1				;ebx =Ê×ÁĞÆæÅ¼ (1=Ææ)
								;(×¢Òâ, Ê×ÁĞÎ»ÓÚĞĞÊä³öµ÷ÕûÇø, ¸ù¾İ¾í¶¯Öµ, 8µã×î¶à7µã¿É¼û)
	sub ebx, byte 2				;
	mov [Data_Misc.Cell], ebx	;ÏÖÊä³öµÄTÁĞ#³õÖµ = -1 (Ê×ÁĞÆæ)  -2(Ê×ÁĞÅ¼)
								;(×¢Òâ! µ±ÏÖÊä³öµÄTÁĞ#Îª¸ºÊ±, Ê¹ÓÃÊ×¸öV¾í¶¯Á¿, 
								; ¶øµ±ÏÖÊä³öµÄTÁĞ#Îª0Ê±, Ò²Ê¹ÓÃÊ×¸öV¾í¶¯Á¿,
								; ×îÑÏÖØÊ± (Ê×ÁĞÅ¼, HÓàµã=7)»áÓĞ½ü4¸öTÁĞ¶¼Ê¹ÓÃÊ×¸öV¾í¶¯Á¿,
								; ËùÒÔV2TÁĞ¾í¶¯²»Ó¦ÓëH¾í¶¯Í¬Ê±Ê¹ÓÃ
								; ÕâÊÇÓ²¼ş±¾ÉíµÄÎÊÌâ, ÒÑ²âÊÔFusionÒ²ÊÇÕâÑùÄ£ÄâµÄ)
	mov eax, [H_Cell]
	mov [Data_Misc.X], eax		;temp=ĞĞTÊı (×÷ÎªÊ£ÓàÎ´Êä³öTÊı)


	mov edi, [VDP_Current_Line]	;edi = ±¾É¨ÃèĞĞ#
	mov eax, [VSRam + 2]		;ÏÖÊä³öµÄÊ×¸öTÁĞÊ¹ÓÃÊ×¸öV¾í¶¯Á¿

%if %1 > 0
	shr eax, 1					; on divise le Y scroll par 2 si on est en entrelacé
%endif

	add edi, eax				;É¨ÃèĞĞ# + Ê×¸öV¾í¶¯Öµ, ÎªVÎ»ÖÃ
	mov eax, edi
	shr edi, 3					;VĞĞ(T)
	and edi, [V_Scroll_CMask]	;VĞĞ(T)È¡Ä£ (³¬¹ı×î´óTÊıÔò»Ø¾í)
	and eax, byte 7				;VÓàµã
	mov [Data_Misc.Line_7], eax	;±£´æVÓàµã

	jmp short %%First_Loop		;×ª¼ÌĞø (V¾í¶¯ÒÑÕıÈ·, ËùÒÔÌø¹ıV¾í¶¯¸üĞÂ)

	ALIGN32

	;(¸÷TÑ­»·)
	%%Loop

%if %2 > 0
		UPDATE_Y_OFFSET 0, %1	;ÈçV2TÁĞ¾í¶¯, Ñ­»·Ê±ÒªÅĞÊÇ·ñ¸üĞÂV¾í¶¯
								;(ÈçÏÖÊä³öµÄTÁĞ#ÎªÅ¼, ÔòÈ¡ÏÂÒ»¸öV¾í¶¯Á¿, 
								; ²¢¸üĞÂediÖĞµÄVĞĞ(T)¼°Data_Misc.Line_7µÄVÓàµã)
%endif

	%%First_Loop

		GET_PATTERN_INFO 0		;ax<==È¡µ±Ç°TI

		GET_PATTERN_DATA %1, 0	;ebx<==È¡µ±Ç°TÄÚµÄ, ¶ÔÓ¦±¾É¨ÃèĞĞµÄÄÇĞĞµãÕóÊı¾İ (³¤×Ö)
		
		test eax, 0x4000000		;H·­×ª? (V·­×ªÔÚÈ¡µãÕóÊı¾İÊ±ÒÑ´¦Àí)
		jz near %%No_H_Flip		;·Ç×ª

	;(H·­×ª)
	%%H_Flip

			test eax, 0x80000000		;¸ßPRI? ÊÇ×ª
			jnz near %%H_Flip_P1

	;(H·­×ª, µÍPRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 0, %3	;Êä³öBÃæµÄµÍPRI TµãĞĞ (8µã), X·­×ª
				jmp %%End_Loop

	ALIGN32

	;(H·­×ª, ¸ßPRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 0, %3	;Êä³öBÃæµÄ¸ßPRI TµãĞĞ (8µã), X·­×ª
				jmp %%End_Loop

	ALIGN32
	
	;(·ÇH·­×ª)
	%%No_H_Flip

			test eax, 0x80000000			;¸ßPRI? ÊÇ×ª
			jnz near %%No_H_Flip_P1

	;(·ÇH·­×ª, µÍPRI)
	%%No_H_Flip_P0
				PUTLINE_P0 0, %3		;Êä³öBÃæµÄµÍPRI TµãĞĞ (8µã)
				jmp %%End_Loop

	ALIGN32

	;(·ÇH·­×ª, ¸ßPRI)
	%%No_H_Flip_P1
				PUTLINE_P1 0, %3		;Êä³öBÃæµÄ¸ßPRI TµãĞĞ (8µã)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;ÏÖÊä³öµÄTÁĞ# ++
		inc esi							;esiÔ´++, ÏÂÒ»TI
		and esi, [H_Scroll_CMask]		;È¡Ä£  (³¬¹ı×î´óTÊıÔò»Ø¾í)
		add ebp, byte 8					;Êä³öÎ»ÖÃ+=8, ÏÂÒ»TÊä³öÎ»ÖÃ
		dec byte [Data_Misc.X]			;tempµÄÊ£ÓàTÊı --
		jns near %%Loop					;·Ç¸ºÔòÑ­»·
										;(×¢ÒâÊÇ·Ç¸º, ËùÒÔ±ÈÊµ¼ÊTÊı¶à1, ÕâÊÇµ÷ÕûËùĞèµÄ)
		
%%End


%endmacro


;****************************************
; Êä³öAÃæ/Window ±¾É¨ÃèĞĞ
; ²ÎÊı1 = 0=ÆÕÍ¨  1=Interlace
; ²ÎÊı2 = 0=VÈ«ÆÁ 1=V2TÁĞ
; ²ÎÊı3 = 1=¸ßÁÁ/ÒõÓ°

%macro RENDER_LINE_SCROLL_A_WIN 3

	mov ebx, [H_Cell]					;ebx =ĞĞTÊı
	mov cl, [Win_ud]
	shr cl, 7							;cl = 0:ÉÏWindow  1:ÏÂWindow
	mov eax, [VDP_Current_Line]
	shr eax, 3							;eax =±¾É¨ÃèĞĞËùÔÚTĞĞ (¼´ÏÖTĞĞ)
	cmp eax, [Win_Y_Pos]				;Èç¹û ÏÖTĞĞ>= Window V·Ö½çÎ»ÖÃ
	setae ch							;Ôò ch <== 1 
	xor cl, ch							;Èç¹ûÊÇ ÉÏWindowÇÒ ÏÖTĞĞ< Window V·Ö½çÎ»ÖÃ
										;	  »òÏÂWindowÇÒ ÏÖTĞĞ>= Window V·Ö½çÎ»ÖÃ
	jz near %%Full_Win					;Ôò±¾É¨ÃèĞĞÈ«ÊÇWindow, ×ª´¦Àí

	;(±¾É¨ÃèĞĞÔÚWindow V·Ö½çÎ»ÖÃÍâ, ÓÉWindow H·Ö½çÎ»ÖÃ¾ö¶¨WindowºáÏòÎ»ÖÃ)
	mov edx, [Win_X_Pos]				;edx =Window H·Ö½çÎ»ÖÃ
	test byte [Win_lr], 0x80	;×óWindow? ÊÇ×ª
	jz short %%Win_Left

;(ÓÒWindow)
%%Win_Right
	sub ebx, edx
	mov [Data_Misc.Start_W], edx		;Window HÊ¼ = H·Ö½çÎ»ÖÃ
	mov [Data_Misc.Lenght_W], ebx		;Window H³¤ = ĞĞTÊı -H·Ö½çÎ»ÖÃ
	dec edx								;
	mov dword [Data_Misc.Start_A], 0	;AÃæ HÊ¼ = 0
	mov [Data_Misc.Lenght_A], edx		;AÃæ H³¤ = H·Ö½çÎ»ÖÃ-1 (±ÈÊµ¼ÊÉÙ1)
	jns short %%Scroll_A				;ÈçH·Ö½çÎ»ÖÃ·Ç0, Ôò¿Ï¶¨ÓĞAÃæ, ×ªÏÈ´¦ÀíAÃæ
	jmp %%Window						;·ñÔòÈ«ÊÇWindow, ×ª´¦Àí

	ALIGN4

;(×óWindow)
%%Win_Left
	sub ebx, edx
	mov dword [Data_Misc.Start_W], 0	;Window HÊ¼ = 0
	mov [Data_Misc.Lenght_W], edx		;Window H³¤ = H·Ö½çÎ»ÖÃ
	dec ebx								;
	mov [Data_Misc.Start_A], edx		;AÃæ HÊ¼ = H·Ö½çÎ»ÖÃ
	mov [Data_Misc.Lenght_A], ebx		;AÃæ H³¤ = ĞĞTÊı -H·Ö½çÎ»ÖÃ-1 (±ÈÊµ¼ÊÉÙ1)
	jns short %%Scroll_A				;ÈçAÃæ H³¤>=0, Ôò¿Ï¶¨ÓĞAÃæ, ×ªÏÈ´¦ÀíAÃæ
										;(×¢ÒâAÃæ H³¤=0Ò²ÓĞAÃæ, Òò±ÈÊµ¼ÊÉÙ1)
	jmp %%Window						;·ñÔòÈ«ÊÇWindow, ×ª´¦Àí

	ALIGN4

;(¿Ï¶¨ÓĞAÃæ, ÏÈ´¦Àí, ÔÙ´¦ÀíWindow(ÈçÓĞ))
%%Scroll_A
	mov ebp, [esp]					;ebpÖ¸ÏòMD_ScreenÄÚ±¾É¨ÃèĞĞÊä³öÎ»ÖÃ (É¨ÃèĞĞ# *336)

	GET_X_OFFSET 1					;si<==È¡AÃæµÄ±¾É¨ÃèĞĞH¾í¶¯Öµ

	mov ebx, [Data_Misc.Start_A]	;ebx =AÃæÊ¼TÎ»ÖÃ (T)
	mov eax, esi					;
	xor esi, 0x3FF					;esi = Êµ¼ÊH¾í¶¯Öµ
	and eax, byte 7					;eax = HÓàµã
	shr esi, 3						;esi = HÁĞT
	mov [Data_Misc.Mask], eax		;
	mov ecx, esi					;
	add esi, ebx					;esi = HÁĞT +AÃæÊ¼TÎ»ÖÃ, Îª¿¼ÂÇ¾í¶¯ºóµÄAÃæÊ¼TÔ´Î»ÖÃ
	and esi, [H_Scroll_CMask]		;È¡Ä£ (³¬¹ı×î´óTÊıÔò»Ø¾í)
	lea eax, [eax + ebx * 8]		;
	add ebp, eax					;ebp += (Óàµã +Ê¼TÎ»ÖÃ*8), 
									;¼´H¾í¶¯µ÷ÕûºóÖ¸ÏòÊ¼TÊä³öÎ»ÖÃ
	and ecx, byte 1
	sub ecx, byte 2					;ÏÖÊä³öµÄTÁĞ#³õÖµ = -1 (Ê×ÁĞÆæ)  -2(Ê×ÁĞÅ¼)
	add ebx, ecx					;Ê¼TÎ»ÖÃ+ ÏÖÊä³öµÄTÁĞ#³õÖµ, ×÷ÎªÊµ¼ÊµÄ ÏÖÊä³öµÄTÁĞ#
	mov [Data_Misc.Cell], ebx		;±£´æ(Êµ¼ÊµÄ) ÏÖÊä³öµÄTÁĞ#
	mov edi, [VDP_Current_Line]		;edi = ±¾É¨ÃèĞĞ#
	jns short %%Not_First_Cell		;ÈçÏÖÊä³öµÄTÁĞ#Îª¸º, ÔòÏÖÊä³öµÄTÊôÓÚÃû×Ö±íÊ×TÁĞ,

	mov eax, [VSRam + 0]			;ÔòÊ¹ÓÃÊ×¸öV¾í¶¯Á¿
	jmp short %%First_VScroll_OK

%%Not_First_Cell
	and ebx, [V_Scroll_MMask]		;·ñÔò¶ÔÏÖÊä³öµÄTÁĞ#È¡Ä£
									;(VÕûÌåÊ±Îª0, È¡Ä£ºó¾ÍÖ»»áÈ¡V¾í¶¯Á¿0, 
									; V2TÁĞÊ±Îª7E, È¡Ä£ºóÎªÅ¼ÊıÇÒÏŞ¶¨·¶Î§)
	mov eax, [VSRam + ebx * 2]		;È¡µÃÏàÓ¦V¾í¶¯Á¿

;(ÒÑÈ¡µÃ×î³õÊ¹ÓÃµÄV¾í¶¯Á¿)
%%First_VScroll_OK

%if %1 > 0
	shr eax, 1						; on divise le Y scroll par 2 si on est en entrelacé
%endif

	add edi, eax					;É¨ÃèĞĞ# + Ê×¸öV¾í¶¯Öµ, ÎªVÎ»ÖÃ
	mov eax, edi
	shr edi, 3						;VĞĞ(T)
	and edi, [V_Scroll_CMask]		;VĞĞ(T)È¡Ä£ (³¬¹ı×î´óTÊıÔò»Ø¾í)
	and eax, byte 7					;VÓàµã
	mov [Data_Misc.Line_7], eax		;±£´æVÓàµã

	jmp short %%First_Loop_SCA		;×ª¼ÌĞø (V¾í¶¯ÒÑÕıÈ·, ËùÒÔÌø¹ıV¾í¶¯¸üĞÂ)

	ALIGN32

;(AÃæ¸÷TÑ­»·)
%%Loop_SCA

%if %2 > 0
		UPDATE_Y_OFFSET 1, %1		;ÈçV2TÁĞ¾í¶¯, Ñ­»·Ê±ÒªÅĞÊÇ·ñ¸üĞÂV¾í¶¯
									;(ÈçÏÖÊä³öµÄTÁĞ#ÎªÅ¼, ÔòÈ¡ÏÂÒ»¸öV¾í¶¯Á¿, 
									; ²¢¸üĞÂediÖĞµÄVĞĞ(T)¼°Data_Misc.Line_7µÄVÓàµã)
%endif

%%First_Loop_SCA
	;call _hook


		GET_PATTERN_INFO 1			;ax<==È¡µ±Ç°TI
		GET_PATTERN_DATA %1, 0		;ebx<==È¡µ±Ç°TÄÚµÄ, ¶ÔÓ¦±¾É¨ÃèĞĞµÄÄÇĞĞµãÕóÊı¾İ (³¤×Ö)
		
		test eax, 0x4000000			;H·­×ª? (V·­×ªÔÚÈ¡µãÕóÊı¾İÊ±ÒÑ´¦Àí)
		jz near %%No_H_Flip			;·Ç×ª

	;(H·­×ª)
	%%H_Flip
			test eax, 0x80000000	;¸ßPRI? ÊÇ×ª
			jnz near %%H_Flip_P1

	;(H·­×ª, µÍPRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 1, %3	;Êä³öAÃæµÄµÍPRI TµãĞĞ (8µã), X·­×ª
				jmp %%End_Loop

	ALIGN32

	;(H·­×ª, ¸ßPRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 1, %3	;Êä³öAÃæµÄ¸ßPRI TµãĞĞ (8µã), X·­×ª
				jmp %%End_Loop

	ALIGN32
	
	;(·ÇH·­×ª)
	%%No_H_Flip
			test eax, 0x80000000		;¸ßPRI? ÊÇ×ª
			jnz near %%No_H_Flip_P1

	;(·ÇH·­×ª, µÍPRI)
	%%No_H_Flip_P0
				PUTLINE_P0 1, %3		;Êä³öAÃæµÄµÍPRI TµãĞĞ (8µã)
				jmp %%End_Loop

	ALIGN32

	;(·ÇH·­×ª, ¸ßPRI)
	%%No_H_Flip_P1
				PUTLINE_P1 1, %3		;Êä³öAÃæµÄ¸ßPRI TµãĞĞ (8µã)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;ÏÖÊä³öµÄTÁĞ# --
		inc esi							;esiÔ´++, ÏÂÒ»TI
		and esi, [H_Scroll_CMask]		;È¡Ä£  (³¬¹ı×î´óTÊıÔò»Ø¾í)
		add ebp, byte 8					;Êä³öÎ»ÖÃ+8, ÏÂÒ»TÊä³öÎ»ÖÃ
		dec byte [Data_Misc.Lenght_A]	;AÃæÊ£Óà³¤¶È--
		jns near %%Loop_SCA				;·Ç¸ºÔòÑ­»· (ÒòÎªÊÇ·Ç¸º, ËùÒÔÉÙµÄ1±»²¹ÉÏ)


;(ÒòÊä³öÊ±µÄH¾í¶¯µ÷Õû, AÃæ×îºó¿ÉÄÜÉÙ8ÖÁ1µã, Òª²¹ÉÏ)
;(±ÈÈçHÓàµãÎª0, ÔòÊä³öµÄAÃæÊ×¸öT±»ÍêÈ«Ìø¹ı(ÒòÍêÈ«ÔÚÇ°µ÷ÕûÇø), Òª²¹8µã
; HÓàµãÎª1, ÔòÊä³öµÄAÃæÊ×¸öT±»Ìø¹ı7µã, Òª²¹7µã
; ...HÓàµãÎª7, ÔòÊä³öµÄAÃæÊ×¸öT±»Ìø¹ı1µã, Òª²¹1µã)
;(Ö®ËùÒÔÕâÑù´¦Àí, ÊÇÒòÎªÊä³öÇø¶ÔÓ¦ AÃæ×îºó µÄµØ·½²»ÊÇºóµ÷ÕûÇø, ¶ø¿ÉÄÜÊÇWindowÊä³ö²¿·Ö)
%%LC_SCA

%if %2 > 0
	UPDATE_Y_OFFSET 1, %1				;ÈçV2TÁĞ¾í¶¯, ÒªÅĞÊÇ·ñ¸üĞÂV¾í¶¯
%endif

	GET_PATTERN_INFO 1					;ax<==È¡×îºóÒª²¹µÄTI
	GET_PATTERN_DATA %1, 0				;ebx<==¸ÃTÄÚµÄ, ¶ÔÓ¦±¾É¨ÃèĞĞµÄÄÇĞĞµãÕóÊı¾İ (³¤×Ö)

	mov ecx, [Data_Misc.Mask]			;È¡HÓàµã
	test eax, 0x4000000					;H·­×ª? (V·­×ªÔÚÈ¡µãÕóÊı¾İÊ±ÒÑ´¦Àí)
	jz near %%LC_SCA_No_H_Flip			;·Ç×ª

	;(H·­×ª)
	%%LC_SCA_H_Flip
		and ebx, [Mask_F + ecx * 4]		;ebx<==¸ù¾İHÓàµã±£ÁôÒª²¹µã, ÆäÓàÇå0 (0µã¶ÔWindowÎŞº¦)
		test eax, 0x80000000			;¸ßPRI? ÊÇ×ª
		jnz near %%LC_SCA_H_Flip_P1

	;(H·­×ª, µÍPRI)
	%%LC_SCA_H_Flip_P0
			PUTLINE_FLIP_P0 1, %3		;Êä³öAÃæµÄµÍPRI TµãĞĞ (8µã), X·­×ª
			jmp %%LC_SCA_End

	ALIGN32

	;(H·­×ª, ¸ßPRI)
	%%LC_SCA_H_Flip_P1
			PUTLINE_FLIP_P1 1, %3		;Êä³öAÃæµÄ¸ßPRI TµãĞĞ (8µã), X·­×ª
			jmp %%LC_SCA_End

	ALIGN32
	
	;(·ÇH·­×ª)
	%%LC_SCA_No_H_Flip
		and ebx, [Mask_N + ecx * 4]		;ebx<==¸ù¾İHÓàµã±£ÁôÒª²¹µã, ÆäÓàÇå0 (0µã¶ÔWindowÎŞº¦)
		test eax, 0x80000000			;¸ßPRI? ÊÇ×ª
		jnz near %%LC_SCA_No_H_Flip_P1

	;(·ÇH·­×ª, µÍPRI)
	%%LC_SCA_No_H_Flip_P0
			PUTLINE_P0 1, %3			;Êä³öAÃæµÄµÍPRI TµãĞĞ (8µã)
			jmp %%LC_SCA_End

	ALIGN32

	;(·ÇH·­×ª, ¸ßPRI)
	%%LC_SCA_No_H_Flip_P1
			PUTLINE_P1 1, %3			;Êä³öAÃæµÄ¸ßPRI TµãĞĞ (8µã)
			jmp short %%LC_SCA_End

	ALIGN32

;(²¹µã½áÊø)
%%LC_SCA_End
	test byte [Data_Misc.Lenght_W], 0xFF	;ÓĞWindow H³¤?
	jnz short %%Window						;ÊÇ, ×ªWindow´¦Àí
	jmp %%End								;·ñ, ÔòÎŞWindow, ×ª½áÊø





	ALIGN4

;(±¾É¨ÃèĞĞÈ«ÊÇWindowÊ±)
%%Full_Win
	xor esi, esi							;esi =Window HÊ¼ (T) =0
	mov edi, ebx							;edi =Window H³¤ (T) =ĞĞTÊı
	jmp short %%Window_Initialised			;×ª¼ÌĞø

	ALIGN4

;(±¾É¨ÃèĞĞ²¿·ÖÊÇWindowÊ±)
%%Window
	mov esi, [Data_Misc.Start_W]			;esi =Window HÊ¼ (T)
	mov edi, [Data_Misc.Lenght_W]			;edi =Window H³¤ (T)

%%Window_Initialised
	mov ebp, [esp]							;ebpÖ¸Ïò±¾É¨ÃèĞĞÊä³öÎ»ÖÃ (É¨ÃèĞĞ# *336)
	lea ebp, [ebp + esi * 8 + 8]			;ebpÖ¸ÏòWindowÊ×TÊä³öÎ»ÖÃ (+8ÒòÎŞĞèµ÷Õû)
	mov edx, [VDP_Current_Line]				;
	mov ebx, edx							;
	shr edx, 3								;edx = ±¾É¨ÃèĞĞËùÔÚTĞĞ#
	mov cl, [H_Win_Mul]
	shl edx, cl								;edx = ±¾É¨ÃèĞĞËùÔÚTĞĞ# * WindowÃû×Ö±íĞĞTÊı
											;¼´ ËùÔÚTĞĞÔÚWindowÃû×Ö±íÄÚµÄÆ«ÒÆ(T)
	mov eax, Window
	lea eax, [eax + edx * 4]				;eax Ö¸ÏòWindowÃû×Ö±íÄÚËùÔÚTĞĞĞĞÊ×
	mov [Data_Misc.Pattern_Adr], eax		;Ôİ´æ
	and ebx, byte 7							;ebx = ±¾É¨ÃèĞĞ¶ÔÓ¦µÄVÓàµã
	mov [Data_Misc.Line_7], ebx				;Ôİ´æ
	jmp short %%Loop_Win					;×ªÑ­»·

	ALIGN32

%%Loop_Win
		mov ebx, [Data_Misc.Pattern_Adr]	;È¡±¾É¨ÃèĞĞËùÔÚTĞĞÔÚWindowÃû×Ö±íÄÚµÄÆ«ÒÆ(T)
		mov eax, [ebx + esi * 4]			; + µ±Ç°TÎ»ÖÃ*4, ¾ÍÄÜÈ¡³öµ±Ç°TI

		GET_PATTERN_DATA %1, 1				;È¡µ±Ç°TÄÚµÄ, ¶ÔÓ¦±¾É¨ÃèĞĞµÄÄÇĞĞµãÕóÊı¾İ(³¤×Ö)

		test eax, 0x4000000					;H·­×ª?
		jz near %%W_No_H_Flip				;·Ç×ª

	;(H·­×ª)
	%%W_H_Flip
			test eax, 0x80000000			;¸ßPRI? ÊÇ×ª
			jnz near %%W_H_Flip_P1

	;(H·­×ª, µÍPRI)
	%%W_H_Flip_P0
				PUTLINE_FLIP_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(H·­×ª, ¸ßPRI)
	%%W_H_Flip_P1
				PUTLINE_FLIP_P1 2, %3
				jmp %%End_Loop_Win

	ALIGN32
	
	;(·ÇH·­×ª)
	%%W_No_H_Flip
			test eax, 0x80000000				;¸ßPRI? ÊÇ×ª
			jnz near %%W_No_H_Flip_P1

	;(·ÇH·­×ª, µÍPRI)
	%%W_No_H_Flip_P0
				PUTLINE_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(·ÇH·­×ª, ¸ßPRI)
	%%W_No_H_Flip_P1
				PUTLINE_P1 2, %3
				jmp short %%End_Loop_Win

	ALIGN32

	%%End_Loop_Win
		inc esi						;esiÔ´++, ÏÂÒ»Window T
		add ebp, byte 8				;ebp +=8, ÏÂÒ»TÊä³öÎ»ÖÃ
		dec edi						;Ê£ÓàH³¤ --
		jnz near %%Loop_Win			;·Ç0ÔòÑ­»·

%%End


%endmacro


;****************************************
; Êä³öËùÓĞ±¾É¨ÃèĞĞ¿É¼ûµÄËùÓĞSpriteµÄµãĞĞ
; ²ÎÊı1 = 0=ÆÕÍ¨  1=Interlace
; ²ÎÊı2 = 1=¸ßÁÁ/ÒõÓ°

%macro RENDER_LINE_SPR 2

	UPDATE_MASK_SPRITE			;É¨ÃèSprite_Struct±í¸÷Ïî, ½«±¾É¨ÃèĞĞº¬ÓĞÇÒ¿É¼ûµÄ
								;¸÷SpriteµÄÏîÆ«ÒÆ±£´æµ½Sprite_VisibleÇø, ²¢´¦ÀíSpriteÆÁ±Î
								;(×¢Òâ: edx =±¾É¨ÃèĞĞ#)
	xor edi, edi				;ediÎªSprite_VisibleÇø¶ÁÖ¸Õë
	mov dword [Data_Misc.X], edi;Ôİ´æ
	test esi, esi				;Èç±¾É¨ÃèĞĞÉÏÃ»ÓĞ¿É¼ûµÄSprite
	jnz short %%First_Loop
	jmp %%End					;ÔòÖ±½Ó½áÊø

;(ÓĞ¿É¼ûµÄSprite)
	ALIGN32

%%Sprite_Loop
		mov edx, [VDP_Current_Line]				;edx =±¾É¨ÃèĞĞ#
%%First_Loop
		mov edi, [Sprite_Visible + edi]			;È¡µ±Ç°¿É¼ûSpriteµÄSprite_StructÏîÆ«ÒÆ
		mov eax, [Sprite_Struct + edi + 24]		;eax =Ê×TI
		mov esi, eax							;esi =Ê×TI
		mov ebx, eax							;ebx =Ê×TI
		shr bx, 9								;
		and ebx, 0x30							;ebx =É«×é*016
		or ebx,[Sprite_Struct + edi + 28]
		mov [Data_Misc.Palette], ebx			;±£´æ
		and esi, 0x7FF							;esi = T#
		sub edx, [Sprite_Struct + edi + 4]		;edx = ±¾É¨ÃèĞĞ# - SP YÏÔÊ¾×ø±ê (YÆ«ÒÆ)
		mov ecx, edx							;
		and edx, 0xF8							;edx = YÆ«ÒÆ(T) *8
		and ecx, byte 7							;ecx = YÓàµã
		mov ebx, [Sprite_Struct + edi + 12]		;ebx = Y³ß´ç-1
%if %1 > 0
		shl ebx, 6								;ebx = (Y³ß´ç-1) * 64
		lea edx, [edx * 8]						;edx = YÆ«ÒÆ(T) * 64
		shl esi, 6								;esi = (VRAMÖĞµÄ)Ê×TÆ«ÒÆ
%else
		shl ebx, 5								;ebx = (Y³ß´ç-1) * 32
		lea edx, [edx * 4]						;edx = YÆ«ÒÆ(T) * 32
		shl esi, 5								;esi = (VRAMÖĞµÄ)Ê×TÆ«ÒÆ
%endif

		test eax, 0x1000						;SP V·­×ª
		jz %%No_V_Flip							;·Ç×ª

	;(V·­×ª)
	%%V_Flip
		xor ecx, 7								;ecx = YÓàµã Òì»ò 7 (0-7±äÎª7-0)
		sub ebx, edx							;(V·­×ªÊ±Ö»Ğèµ÷ÕûesiÔ´Ö¸Õë)
		add esi, ebx							;esi = VRAMÖĞµÄÊ×TÆ«ÒÆ +(Y³ß´ç-1) * 32(64)
												;	   - YÆ«ÒÆ(T) * 32(64)
												;(¹Û²ìYÆ«ÒÆ(T) ´Ó0-3Ê±, 
												; esiÖ¸ÏòYÄ©T, YÄ©T-1...YÄ©T-3µÄµãÕóÊ×
												; ËùÒÔÕıÈ·)
%if %1 > 0
		lea ebx, [ebx + edx + 64]				;ebx»Ö¸´Ô­Öµ, ÔÙ¼Ó64, ¼´ebx =Y³ß´ç* 64
												;¼´ebxÎªSP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		lea esi, [esi + ecx * 8]				;esiÖ¸ÏòSPÊ×TÁĞÖĞµÄ±¾É¨ÃèĞĞ¶ÔÓ¦µÄTÄÚµãĞĞ
		jmp short %%Suite
%else
		lea ebx, [ebx + edx + 32]				;ebx»Ö¸´Ô­Öµ, ÔÙ¼Ó32, ¼´ebx =Y³ß´ç* 32
												;¼´ebxÎªSP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		lea esi, [esi + ecx * 4]				;esiÖ¸ÏòSPÊ×TÁĞÖĞµÄ±¾É¨ÃèĞĞ¶ÔÓ¦µÄTÄÚµãĞĞ
		jmp short %%Suite
%endif

	ALIGN4
	
	;(·ÇV·­×ª)
	%%No_V_Flip
		add esi, edx							;esiÖ¸ÏòSPÊ×TÁĞÖĞµÄ±¾É¨ÃèĞĞ¶ÔÓ¦µÄT
%if %1 > 0
		add ebx, byte 64						;ebx=Y³ß´ç*64, ¼´ÎªSP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		lea esi, [esi + ecx * 8]				;esiÖ¸ÏòSPÊ×TÁĞÖĞµÄ±¾É¨ÃèĞĞ¶ÔÓ¦µÄTÄÚµãĞĞ
%else			
		add ebx, byte 32						;ebx=Y³ß´ç*32, ¼´ÎªSP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		lea esi, [esi + ecx * 4]				;esiÖ¸ÏòSPÊ×TÁĞÖĞµÄ±¾É¨ÃèĞĞ¶ÔÓ¦µÄTÄÚµãĞĞ
%endif

	%%Suite
		mov [Data_Misc.Next_Cell], ebx			;±£´æSP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		mov edx, [Data_Misc.Palette]			;edx = É«×é*016

		test eax, 0x800							;H·­×ª? ·Ç×ª
		jz near %%No_H_Flip

	;(H·­×ª)
	;(H·­×ªÊ±, esiÔ´²»¸Ä±ä, ¶ø½«ebpÊä³öÎ»ÖÃ¼°Êä³ö´ÎĞò¸Ä±ä
	; ebp´ÓSP×îÓÒTµÄÊä³öÎ»ÖÃÆğ, µ¹ĞòÊä³ö¸÷T)
	%%H_Flip
		mov ebx, [Sprite_Struct + edi + 0]		;ebx =SP XÏÔÊ¾×ø±ê
		mov ebp, [Sprite_Struct + edi + 16]		;ebp =SP ÓÒ¼«ÏŞ(º¬)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
		cmp ebx, -7								;(ÉèÖÃSP Êä³öÎ»ÖÃ×óÓÒ¼«ÏŞ)
		jg short %%Spr_X_Min_Norm
		mov ebx, -7								;ÈçXÏÔÊ¾×ø±ê<-7, Ôò×ó¼«ÏŞ = -7
												;(ÒòÊÇµ¹´ÎĞòÊä³ö, ebpÒ»µ©<-7¾Í¿ÉÍ£Ö¹Êä³ö)
												;(Ö®ËùÒÔ-7, ÊÇÒòÎª-7´¦Êä³öµÄTÈÔÄÜ¿´µ½1µã
												; -7ÒÔ×óµÄÎ»ÖÃ, Êä³öTÒ²²»¿É¼û)
	%%Spr_X_Min_Norm
		mov [Data_Spr.H_Min], ebx				;·ñÔò×ó¼«ÏŞ = XÏÔÊ¾×ø±ê (º¬)

	;(Êä³öÎ»ÖÃ×ó¼«ÏŞOK)
	%%Spr_X_Min_OK								;(SP Êä³öÎ»ÖÃÓÒ¼«ÏŞÖ±½ÓÉèÖÃµ½ebp)
		sub ebp, byte 7							;ebp³õÊ¼Î»ÖÃ = ×îÓÒTÊä³öÎ»ÖÃ (ÓëesiÔ´¶ÔÓ¦)
												;(¼õ7ÊµÎª¼õ8, ÒòSPÓÒ¼«ÏŞ°üº¬ÔÚSP·¶Î§ÄÚ,
												; ¼´SPÓÒ¼«ÏŞ =XÏÔÊ¾×ø±ê +X³ß´ç*8 -1)
		jmp short %%Spr_Test_X_Max				;×ªebpÊä³öÓÒ¼«ÏŞºÏ·¨ÅĞ¶Ï¼°µ÷Õû

	ALIGN4

	%%Spr_Test_X_Max_Loop
			sub ebp, byte 8						;ebp -=8, ×óÇ°Ò»TÊä³öÎ»ÖÃ
			add esi, edi						;esiÔ´ Ö¸ÏòXÏòÏÂÒ»T(µãĞĞ)Êı¾İÎ»ÖÃ

	%%Spr_Test_X_Max
			cmp ebp, [H_Pix]					;Èç ebp>=ĞĞµãÊı, Ôò·Ç·¨, ×ªµ÷ÕûÑ­»·
												;(ÒòÊä³öÁËÒ²¿´²»¼û)
												;(²»ÓÃµ£ĞÄµ÷Õû¹ıÍ·, Òò±¾SP¿Ï¶¨¿É¼û)
			jge %%Spr_Test_X_Max_Loop
	;(ebpÊä³öÎ»ÖÃºÏ·¨)
		test eax, 0x8000						;¸ßPRI? ÊÇ×ª
		jnz near %%H_Flip_P1
		jmp short %%H_Flip_P0

	ALIGN32
	
	;(H·­×ª, µÍPRI)
	%%H_Flip_P0
	%%H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SPµ±Ç°TÁĞµÄµãÕó³¤×Ö
			PUTLINE_SPRITE_FLIP 0, %2				;Êä³öSPµ±Ç°TµÄµãĞĞ (8µã), X·­×ª, µÍPRI

			sub ebp, byte 8							;ebpÊä³öÎ»ÖÃ -=8, ×óÇ°Ò»TÊä³öÎ»ÖÃ
			add esi, edi							;esiÔ´ Ö¸ÏòXÏòÏÂÒ»T(µãĞĞ)Êı¾İÎ»ÖÃ
			cmp ebp, [Data_Spr.H_Min]				;ebpÊä³öÎ»ÖÃÒÑ³¬Ô½×ó¼«ÏŞ?
			jge near %%H_Flip_P0_Loop				;·ñ, ÔòÑ­»·Êä³öÏÂÒ»T(µÄµãĞĞ)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(H·­×ª, ¸ßPRI)									;Í¬ÉÏ, µ«ÊÇ¸ßPRI
	%%H_Flip_P1
	%%H_Flip_P1_Loop
			mov ebx, [VRam + esi]
			PUTLINE_SPRITE_FLIP 1, %2

			sub ebp, byte 8
			add esi, edi
			cmp ebp, [Data_Spr.H_Min]
			jge near %%H_Flip_P1_Loop
		jmp %%End_Sprite_Loop
				
	ALIGN32
	
	;(·ÇH·­×ª)
	;(·ÇH·­×ªÊ±, ebp´Ó×î×óTµÄÊä³öÎ»ÖÃÆğ, Ë³ĞòÊä³ö¸÷T)
	%%No_H_Flip
		mov ebx, [Sprite_Struct + edi + 16]		;ebx =SP ÓÒ¼«ÏŞ(º¬)
		mov ecx, [H_Pix]
		mov ebp, [Sprite_Struct + edi + 0]		;ebp =SP XÏÔÊ¾×ø±ê (×÷ÎªÊä³öÎ»ÖÃ)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP XÏàÁÚTÖ®¼äµÄÊı¾İ¼ä¾à
												;(ÉèÖÃSP Êä³öÎ»ÖÃ×óÓÒ¼«ÏŞ)
		cmp ebx, ecx							;ÈçSP ÓÒ¼«ÏŞ(º¬) >=ĞĞµãÊı,
		jl %%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ecx				;ÔòÊä³öÓÒ¼«ÏŞ =ĞĞµãÊı
		jmp short %%Spr_Test_X_Min

	ALIGN4

	%%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ebx				;·ñÔòÊä³öÓÒ¼«ÏŞ =SP ÓÒ¼«ÏŞ(º¬)
												;(SP Êä³öÎ»ÖÃÓÒ¼«ÏŞOK)
												;(SP Êä³öÎ»ÖÃ×ó¼«ÏŞÖ±½ÓÉèÖÃµ½ebp)
		jmp short %%Spr_Test_X_Min				;×ªebpÊä³ö×ó¼«ÏŞºÏ·¨ÅĞ¶Ï¼°µ÷Õû

	ALIGN4

	%%Spr_Test_X_Min_Loop
			add ebp, byte 8						;ebp +=8, XÏòÏÂÒ»TÊä³öÎ»ÖÃ
			add esi, edi						;esiÔ´ Ö¸ÏòXÏòÏÂÒ»T(µãĞĞ)Êı¾İÎ»ÖÃ

	%%Spr_Test_X_Min
			cmp ebp, -7							;Èç ebp<-7, Ôò·Ç·¨, ×ªµ÷ÕûÑ­»·
			jl %%Spr_Test_X_Min_Loop

		test ax, 0x8000							;¸ßPRI? ÊÇ×ª
		jnz near %%No_H_Flip_P1
		jmp short %%No_H_Flip_P0

	ALIGN32
	
	;(·ÇH·­×ª, µÍPRI)
	%%No_H_Flip_P0
	%%No_H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SPµ±Ç°TÁĞµÄµãÕó³¤×Ö
			PUTLINE_SPRITE 0, %2					;Êä³öSPµ±Ç°TµÄµãĞĞ (8µã), µÍPRI

			add ebp, byte 8							;ebpÊä³öÎ»ÖÃ +=8, ÏÂÒ»TÊä³öÎ»ÖÃ
			add esi, edi							;esiÔ´ Ö¸ÏòXÏòÏÂÒ»T(µãĞĞ)Êı¾İÎ»ÖÃ
			cmp ebp, [Data_Spr.H_Max]				;ebpÊä³öÎ»ÖÃÒÔ´ïµ½ÓÒ¼«ÏŞ?
			jl near %%No_H_Flip_P0_Loop				;·ñ, ÔòÑ­»·Êä³öÏÂÒ»T(µÄµãĞĞ)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(·ÇH·­×ª, ¸ßPRI)								;Í¬ÉÏ, µ«ÊÇ¸ßPRI
	%%No_H_Flip_P1
	%%No_H_Flip_P1_Loop
			mov ebx, [VRam + esi]
			PUTLINE_SPRITE 1, %2

			add ebp, byte 8
			add esi, edi
			cmp ebp, [Data_Spr.H_Max]
			jl near %%No_H_Flip_P1_Loop
		jmp short %%End_Sprite_Loop
				
	ALIGN32
	
	;(µ±Ç°SPÊä³ö½áÊø, ÏÂÒ»SP)
	%%End_Sprite_Loop
		mov edi, [Data_Misc.X]						;edi =Sprite_VisibleÇø¶ÁÖ¸Õë
		add edi, byte 4								;edi +=4, ÏÂÒ»Sprite_VisibleÇøÏî
		mov [Data_Misc.X], edi						;¸üĞÂ
		cmp edi, [Data_Misc.Borne]					;ÒÑ´ïSprite_VisibleÇøÎ²?
		jb near %%Sprite_Loop						;·ñ, ÔòÑ­»·Êä³öÏÂÒ»SP

%%End

%endmacro


;****************************************

; macro RENDER_LINE
; param :
; %1 = 1 pour mode entrelacé et 0 sinon
; %2 = Shadow / Highlight (0 = Disable et 1 = Enable)

%macro RENDER_LINE 2

	test dword [V_Scroll_MMask], 0x7e
	jz near %%Full_VScroll

%%Cell_VScroll
	RENDER_LINE_SCROLL_B     %1, 1, %2

%%NoCell_VScrollB
	RENDER_LINE_SCROLL_A_WIN %1, 1, %2
	jmp %%Scroll_OK

%%Full_VScroll
	RENDER_LINE_SCROLL_B     %1, 0, %2

%%NoFull_VScrollB
	RENDER_LINE_SCROLL_A_WIN %1, 0, %2

%%Scroll_OK
	RENDER_LINE_SPR          %1, %2

%%Scroll_End

%endmacro


; *******************************************************

	DECL Render_Line

		pushad

		mov ebx, [VDP_Current_Line]
		xor eax, eax
		mov edi, [TAB336 + ebx * 4]
		push edi								; on va se avoir besoin de cette valeur plus tard

		test byte [STE_state], 0x01
		cld
		mov ecx, 160

		jz short .No_Shadow

		mov eax, SHAD_D ;;0x40404040

	.No_Shadow
		lea edi, [MD_Screen + edi * 2 + 8 * 2]
		rep stosd
		test dword [Disp_state], 0x01		; on teste si le VDP est activé
		jnz short .VDP_Enable					; sinon, on n'affiche rien
		jmp .VDP_OK



	ALIGN4

	.VDP_Enable
		mov ebx, [VRam_Flag]
		mov eax, [interlace_state]
		and ebx, byte 3
		shl eax, byte 2
		mov byte [VRam_Flag], 0
		jmp [.Table_Sprite_Struct + ebx * 8 + eax]

	ALIGN4
	
	.Table_Sprite_Struct
		dd 	.Sprite_Struc_OK
		dd 	.Sprite_Struc_OK
		dd 	.MSS_Complete, .MSS_Complete_Interlace

	ALIGN4

	.MSS_Complete
			MAKE_SPRITE_STRUCT 0
			jmp .Sprite_Struc_OK

	ALIGN32

	.MSS_Complete_Interlace
			MAKE_SPRITE_STRUCT 1
			jmp .Sprite_Struc_OK

	ALIGN32
	
	.Sprite_Struc_OK
		mov eax, [STE_state]
		shl eax, byte 1
		or eax, [interlace_state]
		shl eax, byte 2
		jmp [.Table_Render_Line + eax]

	ALIGN4
	
	.Table_Render_Line
		dd 	.NHS_NInterlace
		dd 	.NHS_Interlace
		dd 	.HS_NInterlace
		dd 	.HS_Interlace
		
	ALIGN4

	.NHS_NInterlace
			RENDER_LINE 0, 0
			jmp .VDP_OK

	ALIGN32
	
	.NHS_Interlace
			RENDER_LINE 1, 0
			jmp .VDP_OK

	ALIGN32

	.HS_NInterlace
			RENDER_LINE 0, 1
			jmp .VDP_OK

	ALIGN32
	
	.HS_Interlace
			RENDER_LINE 1, 1
			jmp short .VDP_OK

	ALIGN32
	
	.VDP_OK
		test byte [CRam_Flag], 1		; CRam¸Ä±ä? (Òª¸üĞÂMD_Palette?)
		jz near .Palette_OK				; ·ñ, ÔòÎŞĞè´¦Àí, Ìø¹ı

		cmp dword [Crt_BPP], 32
		je near .Palette32
		test byte [STE_state], 8
		jnz near .Palette_HS

		UPDATE_PALETTE 0				;½«GenesisµÄCRam×ª»¯ÎªPC¸ñÊ½, ÎŞÁÁ°µ
		jmp .Palette_OK

	ALIGN4
	.Palette_HS
		UPDATE_PALETTE 1				;½«GenesisµÄCRam×ª»¯ÎªPC¸ñÊ½, ÓĞÁÁ°µ
		jmp .Palette_OK

	ALIGN4
	.Palette32
		test byte [STE_state], 8
		jnz near .Palette32_HS
		UPDATE_PALETTE32 0				;½«GenesisµÄCRam×ª»¯ÎªPC¸ñÊ½, ÎŞÁÁ°µ
		jmp .Palette_OK
	.Palette32_HS
		UPDATE_PALETTE32 1				;½«GenesisµÄCRam×ª»¯ÎªPC¸ñÊ½, ÓĞÁÁ°µ

	ALIGN4
	
	.Palette_OK
		mov edi, [esp]
		add esp, byte 4
		cmp dword [Crt_BPP], 32
		je near .Palette_OK32
		lea edi, [MD_Screen + edi * 2 + 8 * 2]
		mov ecx, 160
		mov eax, [H_Pix_Begin]
		sub ecx, eax
		shr ecx, 1
		mov esi, MD_Palette
		jmp short .Genesis_Loop

	ALIGN32
	
	.Genesis_Loop
		movzx eax, byte [edi + 0]
		movzx ebx, byte [edi + 2]
		movzx edx, byte [edi + 4]
		movzx ebp, byte [edi + 6]
		mov ax, [esi + eax * 2]
		mov bx, [esi + ebx * 2]
		mov dx, [esi + edx * 2]
		mov bp, [esi + ebp * 2]
		mov [edi + 0], ax
		mov [edi + 2], bx
		mov [edi + 4], dx
		mov [edi + 6], bp
		add edi, byte 8

		dec ecx
		jnz short .Genesis_Loop

		popad
		ret
	ALIGN4
	
.Palette_OK32
		mov edx, edi
		lea edi, [MD_Screen + edi * 2 + 8 * 2]
		lea edx, [MD_Screen32 + edx * 4 + 8 * 4]
		mov ecx, 160
		mov eax, [H_Pix_Begin]
		sub ecx, eax
		shr ecx, 1
		mov esi, MD_Palette32
		jmp short .Genesis_Loop32

	ALIGN32
	
	.Genesis_Loop32
		movzx eax, byte [edi + 0]
		movzx ebx, byte [edi + 2]
		mov eax, [esi + eax * 4]
		mov ebx, [esi + ebx * 4]
		mov [edx + 0], eax
		mov [edx + 4], ebx
		movzx eax, byte [edi + 4]
		movzx ebx, byte [edi + 6]
		mov eax, [esi + eax * 4]
		mov ebx, [esi + ebx * 4]
		mov [edx + 8], eax
		mov [edx + 12], ebx
		add edi, byte 8
		add edx, byte 16

		dec ecx
		jnz short .Genesis_Loop32

		popad
		ret



	ALIGN64
	
	;*************************************************************************
	;void Blit_2xSAI_MMX(unsigned char *Dest, int pitch, int x, int y, int offset)
	DECL Blit_2xSAI_MMX

		push ebx
		push ecx
		push edx
		push edi
		push esi

		mov ecx, [esp + 36]				; ecx = Nombre de lignes
		mov edx, [esp + 32]				; width
		mov ebx, [esp + 28]				; ebx = pitch de la surface Dest
		lea esi, [MD_Screen + 8 * 2]	; esi = Source
		mov edi, [esp + 24]				; edi = Destination

		sub esp, byte 4 * 5				; 5 params for _2xSaILine
		mov [esp], esi					; 1st Param = *Src
		mov [esp + 4], dword (336 * 2)	; 2nd Param = SrcPitch
		mov [esp + 8], edx				; 3rd Param = width
		mov [esp + 12], edi				; 4th Param = *Dest
		mov [esp + 16], ebx				; 5th Param = DestPitch
		jmp short .Loopsai

	ALIGN64

	.Loopsai
			mov word [esi + 320 * 2], 0		; clear clipping

			call _2xSaILine					; Do one line

			add esi, 336 * 2				; esi = *Src + 1 line
			lea edi, [edi + ebx * 2]		; edi = *Dest + 2 lines
			mov [esp], esi					; 1st Param = *Src
			dec ecx
			mov [esp + 12], edi				; 4th Param = *Dest
			jnz short .Loopsai

		add esp, byte 4 * 5					; Free 5 params

	.End
		pop esi
		pop edi
		pop edx
		pop ecx
		pop ebx
		emms
		ret


	ALIGN64
	
	;***********************************************************************************************
	;void _2xSaILine(uint8 *srcPtr, uint32 srcPitch, uint32 width, uint8 *dstPtr, uint32 dstPitch);
	_2xSaILine:

		push ebp
		mov ebp, esp
		pushad

		mov edx, [ebp+dstOffset]		; edx points to the screen

		mov eax, [ebp+srcPtr]			; eax points to colorA
		mov ebx, [ebp+srcPitch]
		mov ecx, [ebp+width]
		
		sub eax, ebx					; eax now points to colorE

		pxor mm0, mm0
		movq [LineBuffer], mm0
		jmp short .Loop

	ALIGN64
	
	.Loop:
			push ecx

		;1	------------------------------------------

		;if ((colorA == colorD) && (colorB != colorC) && (colorA == colorE) && (colorB == colorL)

			movq mm0, [eax+ebx+colorA]        ;mm0 and mm1 contain colorA
			movq mm2, [eax+ebx+colorB]        ;mm2 and mm3 contain colorB

			movq mm1, mm0
			movq mm3, mm2

			pcmpeqw mm0, [eax+ebx+ebx+colorD]
			pcmpeqw mm1, [eax+colorE]
			pcmpeqw mm2, [eax+ebx+ebx+colorL]
			pcmpeqw mm3, [eax+ebx+ebx+colorC]

			pand mm0, mm1
			pxor mm1, mm1
			pand mm0, mm2
			pcmpeqw mm3, mm1
			pand mm0, mm3                 ;result in mm0

		;if ((colorA == colorC) && (colorB != colorE) && (colorA == colorF) && (colorB == colorJ)

			movq mm4, [eax+ebx+colorA]        ;mm4 and mm5 contain colorA
			movq mm6, [eax+ebx+colorB]        ;mm6 and mm7 contain colorB
			movq mm5, mm4
			movq mm7, mm6

			pcmpeqw mm4, [eax+ebx+ebx+colorC]
			pcmpeqw mm5, [eax+colorF]
			pcmpeqw mm6, [eax+colorJ]
			pcmpeqw mm7, [eax+colorE]

			pand mm4, mm5
			pxor mm5, mm5
			pand mm4, mm6
			pcmpeqw mm7, mm5
			pand mm4, mm7                 ;result in mm4

			por mm0, mm4                  ;combine the masks
			movq [Mask1], mm0

		;2	-------------------------------------------

         ;if ((colorB == colorC) && (colorA != colorD) && (colorB == colorF) && (colorA == colorH)

			movq mm0, [eax+ebx+colorB]        ;mm0 and mm1 contain colorB
			movq mm2, [eax+ebx+colorA]        ;mm2 and mm3 contain colorA
			movq mm1, mm0
			movq mm3, mm2

			pcmpeqw mm0, [eax+ebx+ebx+colorC]
			pcmpeqw mm1, [eax+colorF]
			pcmpeqw mm2, [eax+ebx+ebx+colorH]
			pcmpeqw mm3, [eax+ebx+ebx+colorD]

			pand mm0, mm1
			pxor mm1, mm1
			pand mm0, mm2
			pcmpeqw mm3, mm1
			pand mm0, mm3                 ;result in mm0

		;if ((colorB == colorE) && (colorB == colorD) && (colorA != colorF) && (colorA == colorI)

			movq mm4, [eax+ebx+colorB]        ;mm4 and mm5 contain colorB
			movq mm6, [eax+ebx+colorA]        ;mm6 and mm7 contain colorA
			movq mm5, mm4
			movq mm7, mm6

			pcmpeqw mm4, [eax+ebx+ebx+colorD]
			pcmpeqw mm5, [eax+colorE]
			pcmpeqw mm6, [eax+colorI]
			pcmpeqw mm7, [eax+colorF]

			pand mm4, mm5
			pxor mm5, mm5
			pand mm4, mm6
			pcmpeqw mm7, mm5
			pand mm4, mm7                 ;result in mm4

			por mm0, mm4                  ;combine the masks
			movq [Mask2], mm0


		;interpolate colorA and colorB

			movq mm0, [eax+ebx+colorA]
			movq mm1, [eax+ebx+colorB]

			movq mm2, mm0
			movq mm3, mm1

			pand mm0, [colorMask]
			pand mm1, [colorMask]

			psrlw mm0, 1
			psrlw mm1, 1

			pand mm3, [lowPixelMask]
			paddw mm0, mm1

			pand mm3, mm2
			paddw mm0, mm3                ;mm0 contains the interpolated values

		;assemble the pixels

			movq mm1, [eax+ebx+colorA]
			movq mm2, [eax+ebx+colorB]

			movq mm3, [Mask1]
			movq mm5, mm1
			movq mm4, [Mask2]
			movq mm6, mm1

			pand mm1, mm3
			por mm3, mm4
			pxor mm7, mm7
			pand mm2, mm4

			pcmpeqw mm3, mm7
			por mm1, mm2
			pand mm0, mm3

			por mm0, mm1

			punpcklwd mm5, mm0
			punpckhwd mm6, mm0
;			movq mm0, [eax+ebx+colorA+8] ;Only the first pixel is needed

			movq [edx], mm5
			movq [edx+8], mm6

		;3 Create the Nextline  -------------------

		;if ((colorA == colorD) && (colorB != colorC) && (colorA == colorG) && (colorC == colorO)

			movq mm0, [eax+ebx+colorA]			;mm0 and mm1 contain colorA
			movq mm2, [eax+ebx+ebx+colorC]		;mm2 and mm3 contain colorC
			movq mm1, mm0
			movq mm3, mm2

			push eax
			add eax, ebx
			pcmpeqw mm0, [eax+ebx+colorD]
			pcmpeqw mm1, [eax+colorG]
			pcmpeqw mm2, [eax+ebx+ebx+colorO]
			pcmpeqw mm3, [eax+colorB]
			pop eax

			pand mm0, mm1
			pxor mm1, mm1
			pand mm0, mm2
			pcmpeqw mm3, mm1
			pand mm0, mm3                 ;result in mm0

		;if ((colorA == colorB) && (colorG != colorC) && (colorA == colorH) && (colorC == colorM)

			movq mm4, [eax+ebx+colorA]			;mm4 and mm5 contain colorA
			movq mm6, [eax+ebx+ebx+colorC]		;mm6 and mm7 contain colorC
			movq mm5, mm4
			movq mm7, mm6

			push eax
			add eax, ebx
			pcmpeqw mm4, [eax+ebx+colorH]
			pcmpeqw mm5, [eax+colorB]
			pcmpeqw mm6, [eax+ebx+ebx+colorM]
			pcmpeqw mm7, [eax+colorG]
			pop eax

			pand mm4, mm5
			pxor mm5, mm5
			pand mm4, mm6
			pcmpeqw mm7, mm5
			pand mm4, mm7                 ;result in mm4

			por mm0, mm4                  ;combine the masks
			movq [Mask1], mm0

		;4  ----------------------------------------

		;if ((colorB == colorC) && (colorA != colorD) && (colorC == colorH) && (colorA == colorF)

			movq mm0, [eax+ebx+ebx+colorC]		;mm0 and mm1 contain colorC
			movq mm2, [eax+ebx+colorA]			;mm2 and mm3 contain colorA
			movq mm1, mm0
			movq mm3, mm2

			pcmpeqw mm0, [eax+ebx+colorB]
			pcmpeqw mm1, [eax+ebx+ebx+colorH]
			pcmpeqw mm2, [eax+colorF]
			pcmpeqw mm3, [eax+ebx+ebx+colorD]

			pand mm0, mm1
			pxor mm1, mm1
			pand mm0, mm2
			pcmpeqw mm3, mm1
			pand mm0, mm3                 ;result in mm0

		;if ((colorC == colorG) && (colorC == colorD) && (colorA != colorH) && (colorA == colorI)

			movq mm4, [eax+ebx+ebx+colorC]		;mm4 and mm5 contain colorC
			movq mm6, [eax+ebx+colorA]			;mm6 and mm7 contain colorA
			movq mm5, mm4
			movq mm7, mm6

			pcmpeqw mm4, [eax+ebx+ebx+colorD]
			pcmpeqw mm5, [eax+ebx+colorG]
			pcmpeqw mm6, [eax+colorI]
			pcmpeqw mm7, [eax+ebx+ebx+colorH]

			pand mm4, mm5
			pxor mm5, mm5
			pand mm4, mm6
			pcmpeqw mm7, mm5
			pand mm4, mm7                 ;result in mm4

			por mm0, mm4                  ;combine the masks
			movq [Mask2], mm0

		;----------------------------------------------

		;interpolate colorA and colorC

			movq mm0, [eax+ebx+colorA]
			movq mm1, [eax+ebx+ebx+colorC]

			movq mm2, mm0
			movq mm3, mm1

			pand mm0, [colorMask]
			pand mm1, [colorMask]

			psrlw mm0, 1
			psrlw mm1, 1

			pand mm3, [lowPixelMask]
			paddw mm0, mm1

			pand mm3, mm2
			paddw mm0, mm3                ;mm0 contains the interpolated values

		;-------------

		;assemble the pixels

			movq mm1, [eax+ebx+colorA]
			movq mm2, [eax+ebx+ebx+colorC]

			movq mm3, [Mask1]
			movq mm4, [Mask2]

			pand mm1, mm3
			pand mm2, mm4

			por mm3, mm4
			pxor mm7, mm7
			por mm1, mm2

			pcmpeqw mm3, mm7
			pand mm0, mm3
			por mm0, mm1
			movq [ACPixel], mm0

		;////////////////////////////////
		; Decide which "branch" to take
		;--------------------------------

			movq mm0, [eax+ebx+colorA]
			movq mm1, [eax+ebx+colorB]
			movq mm6, mm0
			movq mm7, mm1
			pcmpeqw mm0, [eax+ebx+ebx+colorD]
			pcmpeqw mm1, [eax+ebx+ebx+colorC]
			pcmpeqw mm6, mm7

			movq mm2, mm0
			movq mm3, mm0

			pand mm0, mm1       ;colorA == colorD && colorB == colorC
			pxor mm7, mm7

			pcmpeqw mm2, mm7
			pand mm6, mm0
			pand mm2, mm1       ;colorA != colorD && colorB == colorC

			pcmpeqw mm1, mm7

			pand mm1, mm3       ;colorA == colorD && colorB != colorC
			pxor mm0, mm6
			por mm1, mm6
			movq mm7, mm0
			movq [Mask2], mm2
			packsswb mm7, mm7
			movq [Mask1], mm1

			movd ecx, mm7
			test ecx, ecx
			jz near .SKIP_GUESS

		;-------------------------------------
		; Map of the pixels:           I|E F|J
		;                              G|A B|K
		;                              H|C D|L
		;                              M|N O|P

			movq mm6, mm0
			movq mm4, [eax+ebx+colorA]
			movq mm5, [eax+ebx+colorB]
			pxor mm7, mm7
			pand mm6, [ONE]

			movq mm0, [eax+colorE]
			movq mm1, [eax+ebx+colorG]
			movq mm2, mm0
			movq mm3, mm1
			pcmpeqw mm0, mm4
			pcmpeqw mm1, mm4
			pcmpeqw mm2, mm5
			pcmpeqw mm3, mm5
			pand mm0, mm6
			pand mm1, mm6
			pand mm2, mm6
			pand mm3, mm6
			paddw mm0, mm1
			paddw mm2, mm3

			pxor mm3, mm3
			pcmpgtw mm0, mm6
			pcmpgtw mm2, mm6
			pcmpeqw mm0, mm3
			pcmpeqw mm2, mm3
			pand mm0, mm6
			pand mm2, mm6
			paddw mm7, mm0
			psubw mm7, mm2

			movq mm0, [eax+colorF]
			movq mm1, [eax+ebx+colorK]
			movq mm2, mm0
			movq mm3, mm1
			pcmpeqw mm0, mm4
			pcmpeqw mm1, mm4
			pcmpeqw mm2, mm5
			pcmpeqw mm3, mm5
			pand mm0, mm6
			pand mm1, mm6
			pand mm2, mm6
			pand mm3, mm6
			paddw mm0, mm1
			paddw mm2, mm3

			pxor mm3, mm3
			pcmpgtw mm0, mm6
			pcmpgtw mm2, mm6
			pcmpeqw mm0, mm3
			pcmpeqw mm2, mm3
			pand mm0, mm6
			pand mm2, mm6
			paddw mm7, mm0
			psubw mm7, mm2

			push eax
			add eax, ebx
			movq mm0, [eax+ebx+colorH]
			movq mm1, [eax+ebx+ebx+colorN]
			movq mm2, mm0
			movq mm3, mm1
			pcmpeqw mm0, mm4
			pcmpeqw mm1, mm4
			pcmpeqw mm2, mm5
			pcmpeqw mm3, mm5
			pand mm0, mm6
			pand mm1, mm6
			pand mm2, mm6
			pand mm3, mm6
			paddw mm0, mm1
			paddw mm2, mm3

			pxor mm3, mm3
			pcmpgtw mm0, mm6
			pcmpgtw mm2, mm6
			pcmpeqw mm0, mm3
			pcmpeqw mm2, mm3
			pand mm0, mm6
			pand mm2, mm6
			paddw mm7, mm0
			psubw mm7, mm2

			movq mm0, [eax+ebx+colorL]
			movq mm1, [eax+ebx+ebx+colorO]
			movq mm2, mm0
			movq mm3, mm1
			pcmpeqw mm0, mm4
			pcmpeqw mm1, mm4
			pcmpeqw mm2, mm5
			pcmpeqw mm3, mm5
			pand mm0, mm6
			pand mm1, mm6
			pand mm2, mm6
			pand mm3, mm6
			paddw mm0, mm1
			paddw mm2, mm3

			pxor mm3, mm3
			pcmpgtw mm0, mm6
			pcmpgtw mm2, mm6
			pcmpeqw mm0, mm3
			pcmpeqw mm2, mm3
			pand mm0, mm6
			pand mm2, mm6
			paddw mm7, mm0
			psubw mm7, mm2

			pop eax
			movq mm1, mm7
			pxor mm0, mm0
			pcmpgtw mm7, mm0
			pcmpgtw mm0, mm1

			por mm7, [Mask1]
			por mm1, [Mask2]
			movq [Mask1], mm7
			movq [Mask2], mm1

		.SKIP_GUESS:

		;----------------------------
		;interpolate A, B, C and D

			movq mm0, [eax+ebx+colorA]
			movq mm1, [eax+ebx+colorB]
			movq mm4, mm0
			movq mm2, [eax+ebx+ebx+colorC]
			movq mm5, mm1
			movq mm3, [qcolorMask]
			movq mm6, mm2
			movq mm7, [qlowpixelMask]

			pand mm0, mm3
			pand mm1, mm3
			pand mm2, mm3
			pand mm3, [eax+ebx+ebx+colorD]

			psrlw mm0, 2
			pand mm4, mm7
			psrlw mm1, 2
			pand mm5, mm7
			psrlw mm2, 2
			pand mm6, mm7
			psrlw mm3, 2
			pand mm7, [eax+ebx+ebx+colorD]

			paddw mm0, mm1
			paddw mm2, mm3

			paddw mm4, mm5
			paddw mm6, mm7

			paddw mm4, mm6
			paddw mm0, mm2
			psrlw mm4, 2
			pand mm4, [qlowpixelMask]
			paddw mm0, mm4      ;mm0 contains the interpolated value of A, B, C and D

		;assemble the pixels

			movq mm1, [Mask1]
			movq mm2, [Mask2]
			movq mm4, [eax+ebx+colorA]
			movq mm5, [eax+ebx+colorB]
			pand mm4, mm1
			pand mm5, mm2

			pxor mm7, mm7
			por mm1, mm2
			por mm4, mm5
			pcmpeqw mm1, mm7
			pand mm0, mm1
			por mm4, mm0        ;mm4 contains the diagonal pixels

			movq mm0, [ACPixel]
			movq mm1, mm0
			punpcklwd mm0, mm4
			punpckhwd mm1, mm4

			push edx
			add edx, [ebp+dstPitch]

			movq [edx], mm0
			movq [edx+8], mm1

			pop edx

			add edx, 16
			add eax, 8

			pop ecx
			sub ecx, 4
			cmp ecx, 0
			jg  near .Loop

	; Restore some stuff

		popad
		mov esp, ebp
		pop ebp
		emms
		ret


	; void Check_MMX()
	DECL Check_MMX

		pushad

		mov dword [Have_MMX], 0
		pushfd
		pop eax
		mov ebx, eax
		xor eax, 0x200000
		push eax
		popfd
		pushfd
		pop eax
		xor eax, ebx
		and eax, 0x200000
		jz .not_supported		; CPUID instruction not supported

		xor eax, eax
		cpuid					; get number of CPUID functions
		test eax, eax
		jz .not_supported		; CPUID function 1 not supported

		mov eax, 1
		cpuid					; get family and features
		and eax, 0x000000F00	; family
		and edx, 0x0FFFFF0FF	; features flags
		or eax, edx				; combine bits
		test eax, 0x00800000	; Having MMX ?
		setnz [Have_MMX]		; Store it

	.not_supported
		popad
		ret
