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

	DECL SP_colide					;B5��1=���κ�2��sprite�ķ�͸������ײ
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
; ȡA/B��ı�ɨ����H��ֵ
; ����1: 0=B��  1=A��
; ����: si=��ֵ

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
; ���������T��#Ϊż, ��ȡ��һ��V����, 
; ������edi�е�V��(T)��Data_Misc.Line_7��V���
; ����1: 0=B��  1=A��
; ����2: 0=��ͨ  1=Interlace
; ����:
; edi =(ԭ�ȵĻ���µ�) V��(T),   Data_Misc.Line_7=(ԭ�ȵĻ���µ�) V���

%macro UPDATE_Y_OFFSET 2

	mov eax, [Data_Misc.Cell]				;ȡ�������T��#
	test eax, 0xFF81						;��Ϊ������, 
	jnz short %%End							;����ʹ����V����, ת��
	mov edi, [VDP_Current_Line]				;edi = ��ɨ����#

%if %1 > 0
	mov eax, [VSRam + eax * 2 + 0]			;ȡA��/B�����һ��V����
%else										;(ע��T��#*2, ��T��#Ϊżʱ�ų�2, ʵΪ*4)
	mov ax, [VSRam + eax * 2 + 2]
%endif

%if %2 > 0
	shr eax, 1								; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax							;edi<==��ɨ����# +V����, �������ʵ�ʵ���#
	mov eax, edi							;
	shr edi, 3								;edi<==ʵ�ʵ��л�ΪV��(T)
	and eax, byte 7							;ȡģ
	and edi, [V_Scroll_CMask]				;
	mov [Data_Misc.Line_7], eax				;V���

%%End

%endmacro


;****************************************
; ȡ��ǰTI
; ���:
; edi = V��(T)
; esi = H��(T)
; ����1: 0=B��  1=A��
; ���� :
; ax = TI (Tile Info)

%macro GET_PATTERN_INFO 1

	mov cl, [H_Scroll_CMul]						;��Tָ��
	mov eax, edi								;
	shl eax, cl									;eax = V��(T) * (2����Tָ���η�)
												;(��V�����Ӧ��V��(T)�����ֱ��е�ƫ��)
	mov edx, esi								;edx = H��(T)
	add edx, eax								;edx = V��(T)ƫ�� +H��(T)
												;(��Ҫȡ��TI��ƫ��, !!��TIƫ��, ���ֽ�ƫ��)

%if %1 > 0
	mov ebx, ScreenA							;���ݲ���1, ȡA��/B���
%else
	mov ebx, ScreenB
%endif

	mov eax, [ebx + edx * 4]						; eax = TI  (*4��Tƫ�ƻ�Ϊ�ֽ�ƫ��)

%endmacro


;****************************************
; ȡ��ǰT�ڵ�, ��Ӧ��ɨ���е����е������� (����)
; ���:
; eax = TI
; ����1 = 0=��ͨ  1=Interlace
; ����2 = ��Ч
; ����:
; ebx = ������ (��8��)
; edx = ɫ��*016

%macro GET_PATTERN_DATA 2

	mov ebx, [Data_Misc.Line_7]					;ebx = V���, ��T�ڵ���#
	mov edx, eax								;edx = TI
	mov ecx, eax								;ecx = TI
	shr edx, 24
	and edx, byte 0x70							;edx = ɫ��*016  (ɫ��0-7)
	and ecx, 0x3FFFFFF							;ecx = T# (26λ)

%if %1 > 0
	shl ecx, 6									;ecx = T#*064, ��T�ĵ�������ƫ��
												;(1��Tile��064���ֽ�) 
%else
	shl ecx, 5									;ecx = T#*032, ��T�ĵ�������ƫ��
												;(1��Tile��032���ֽ�) 
%endif

	test eax, 0x8000000							; ��ָ��V��ת, ��T�ڵ���# ��� 7
	jz %%No_V_Flip								; (0-7 ��Ϊ 7-0)

	xor ebx, byte 7

%%No_V_Flip

%if %1 > 0
	mov ebx, [VRam + ecx + ebx * 8]				;(��8����ÿ2�������1����, �ε���4�ֽڲ���)
%else
	mov ebx, [VRam + ecx + ebx * 4]				;�������� ��VRAM�ڵ� (T�ĵ�������ƫ��)+
%endif											;T�ڵ���#*4�� (��4����ÿ���е�������4�ֽ�)

%endmacro


;****************************************
;����Sprite����������Sprite_Struct��
; ����1 = 0=��ͨ  1=Interlace


%macro MAKE_SPRITE_STRUCT 1

	mov ebp, Sprite							;esi=ebpָ��(VRAM��)Sprite������
	mov esi, ebp							;
	xor edi, edi							;edi = 0, ��Sprite_Struct������д��
	jmp short %%Loop

	ALIGN32
	
%%Loop
		mov ax, [ebp + 0]						;ax = Pos Y
		mov cx, [ebp + 6]						;cx = Pos X
		mov edx,0
		mov [Sprite_Struct + edi + 28], edx
		mov dl, [ebp + (2 ^ 1)]					;dl = Sprite�ߴ� (^1����ΪVRAM�ߵ�, ��ͬ)
		test dl, 0x80
		jz %%cg0_3
		or byte [Sprite_Struct + edi + 28],0x40	;�����Ϸ����Sprite�ߴ�ĸ�4λ, ���ʹ�ñ���, ������SPRITE����ɫ��
%%cg0_3
	%if %1 > 0
		shr eax, 1								; si entrelac�, la position est divis� par 2
	%endif
		mov dh, dl								;dh =dl =Sprite�ߴ�
		and eax, 0x1FF							;Pos Y,X�淶
		and ecx, 0x1FF
		and edx, 0x0C03							;dh =(X�ߴ�-1)*4, dl =(Y�ߴ�-1)
		sub eax, 0x80							;eax = Y��ʾ���� (ע���Ϊ��)
		sub ecx, 0x80							;ecx = X��ʾ���� (ע���Ϊ��)
		mov [Sprite_Struct + edi + 4], eax		;Y��ʾ���� ����Sprite_Struct
		mov [Sprite_Struct + edi + 0], ecx		;X��ʾ���� ����Sprite_Struct
		shr dh, 2								;dh = X�ߴ�-1
		inc dh									;dh = X�ߴ�
		mov [Sprite_Struct + edi + 8], dh		;X�ߴ� ����Sprite_Struct
		mov bl, dh								;bl = X�ߴ�
		and ebx, byte 7							;ebx = X�ߴ�
		mov [Sprite_Struct + edi + 12], dl		;Y�ߴ�-1 ����Sprite_Struct
		and edx, byte 3							;edx = Y�ߴ�-1
		lea ecx, [ecx + ebx * 8 - 1]			;ecx = �Ҽ���
		lea eax, [eax + edx * 8 + 7]			;eax = �¼��� (+7=+8-1, +8��Y�ߴ�-1)
		mov [Sprite_Struct + edi + 16], ecx		;�Ҽ��� ����Sprite_Struct
		mov [Sprite_Struct + edi + 20], eax		;�¼��� ����Sprite_Struct
		mov bl, [ebp + (3 ^ 1)]					;bl = ��һSP#
		mov dx, [ebp + 4]						;dx = ��TI
		add edi, byte (8 * 4)					;ediָ����һSprite_Struct��
		and ebx, byte 0x7F						;ebx = ��һSP#
		mov [Sprite_Struct + edi - 32 + 24], dx	;��TI ����Sprite_Struct (-32�����+32)
		jz short %%End							;����һSP#Ϊ0, ������SP, ת����ѭ��
		lea ebp, [esi + ebx * 8]				;ebpָ����һSP����
		cmp edi, (8 * 4 * 80)					;��δ��ԽSprite������, ��תѭ��
		jb near %%Loop

%%End
	sub edi, 8 * 4							;
	mov [Data_Misc.Spr_End], edi			;����Sprite_Struct�����һ���ƫ��

%endmacro


;****************************************
;ɨ��Sprite_Struct�����, ����ɨ���к����ҿɼ��ĸ�Sprite����ƫ�Ʊ��浽Sprite_Visible��,
;������Sprite����
;����:
; edx =��ɨ����#

%macro UPDATE_MASK_SPRITE 0

	xor edi, edi					;��Sprite_Struct���0�������
	xor ax, ax
	mov ebx, [H_Pix]				;ebx=��ʾ����
	xor esi, esi					;Sprite_Visible�ı���ָ��
	mov edx, [VDP_Current_Line]		;edx=��ɨ����#
	jmp short %%Loop_1

	ALIGN4
	;(Loop_1ѭ�����������׸���ɨ���к��е�Sprite)
%%Loop_1
		cmp [Sprite_Struct + edi + 4], edx			;Y��ʾ����>��ɨ����#? ��ת��һ��
		jg short %%Out_Line_1
		cmp [Sprite_Struct + edi + 20], edx			;�¼���<��ɨ����#? ��ת��һ��
		jl short %%Out_Line_1

		;(�ҵ��׸���ɨ���к��е�Sprite, �����Ƿ�ɼ�)
		cmp [Sprite_Struct + edi + 0], ebx			;X��ʾ���� >��ʾ����?
		jge short %%Out_Line_1_2					;��, ת��һ�����Loop_2
		cmp dword [Sprite_Struct + edi + 16], 0		;�Ҽ���<0?
		jl short %%Out_Line_1_2						;��, ת��һ�����Loop_2

		mov [Sprite_Visible + esi], edi				;�ҵ���ɨ���пɼ���Sprite, ������ƫ��
		add esi, byte 4								;����ָ��+=4, ��һ����λ��

		;(�������ʱ, ���ҵ��׸���ɨ���к��е�Sprite (�ɼ��򲻿ɼ�))
%%Out_Line_1_2
		add edi, byte (8 * 4)						;��һSprite_Struct��
		cmp edi, [Data_Misc.Spr_End]				;�ѳ�ԽSprite_Struct������?
		jle short %%Loop_2							;��, ��תLoop_2ѭ��

		jmp %%End									;��, ��ת����

	ALIGN4

		;(�������ʱ, ��Ȼδ�ҵ��׸���ɨ���к��е�Sprite)
%%Out_Line_1
		add edi, byte (8 * 4)						;��һSprite_Struct��
		cmp edi, [Data_Misc.Spr_End]				
		jle short %%Loop_1							;�ѳ�ԽSprite_Struct������?
													;��, ��תLoop_1ѭ��, �������׸�
		jmp %%End									;��, ��ת����

	ALIGN4

	;(Loop_2ѭ���������Ҵθ���ı�ɨ���к��е�Sprite)
%%Loop_2
		cmp [Sprite_Struct + edi + 4], edx			;Y��ʾ����>��ɨ����#? ��ת��һ��
		jg short %%Out_Line_2
		cmp [Sprite_Struct + edi + 20], edx			;�¼���<��ɨ����#? ��ת��һ��
		jl short %%Out_Line_2

		cmp dword [Sprite_Struct + edi + 0], -128	;��X��ʾ����Ϊ-80 (˵��Xλ��Ϊ0)
		je short %%End								;��ֱ��ת���� (����Sprite������
													; ���������ȼ��϶�����)

		cmp [Sprite_Struct + edi + 0], ebx			;X��ʾ���� >��ʾ����? ��ת��һ��
		jge short %%Out_Line_2
		cmp dword [Sprite_Struct + edi + 16], 0		;�Ҽ���<0? ��ת��һ��
		jl short %%Out_Line_2

		mov [Sprite_Visible + esi], edi				;�ҵ���ɨ���пɼ���Sprite, ������ƫ��
		add esi, byte 4								;����ָ��+=4, ��һ����λ��

%%Out_Line_2
		add edi, byte (8 * 4)
		cmp edi, [Data_Misc.Spr_End]
		jle short %%Loop_2
		jmp short %%End

	ALIGN4

%%End
	mov [Data_Misc.Borne], esi						;����Sprite_Visible��β(����)


%endmacro


;****************************************
; ���A/B��ĵ�PRI��
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
;  edx = ɫ��*016
; ����1 = ebx������(8��)�ĵ�#
; ����2 = ȡ���õ�ֵ��MASK
; ����3 = �õ�ֵ������λ��
; ����4 = 0=B��  1=����
; ����5 = 1=����/��Ӱ

%macro PUTPIXEL_P0 5

	mov eax, ebx			;��õ�Ϊ0000����͸��,
	and eax, %2
	jnz short %%no_trans1	;����, ֱ�ӷ�
	jmp short %%Trans

;(��0000��)
;(����Ҫ����Ƿ�A��, ����, Ҫ�б���������Ƿ�����B���Pri��, �����ܸ���, ת��
; ע��B�治�ü��ֱ�ӻ�, ��B�������ȴ����, ����ֻ��1��������͵�Backdrop, ����ֱ�ӻ�)
%%no_trans1
%if %4 > 0														;��A��?
	%if %5 > 0													;����/��Ӱģʽ?
		mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 1]			;��, ��ȡ���������ֽ�
		test cl, PRIO_B											;�õ�����B���Pri��?
		jz short %%no_trans2									;���򲻻�, ��
																;(��Pri��A���ܸ�����)
	%else
																;���Ǹ���/��Ӱģʽ
		test byte [MD_Screen + ebp * 2 + (%1 * 2) + 1], PRIO_B	;ȡ����ֽ�
		jz short %%no_trans2									;������B���Pri��, ��
	%endif
	jmp short %%Trans
%endif

%%no_trans2
%if %3 > 0
	shr eax, %3									;��������, �õ�ֵ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3

;(A,B��ֱ���)
%if %4 > 0
	;(A��)
	%if %5 > 0
		;(A��������Ӱ��B�����)
		;(����/��Ӱʱ, ��PRI��B��,Backdrop������Ӱ, ��Ȼ��PRI��B����Ӱ (��Backdrop), 
		; ����PRI��A�޷����Ǹ�PRI��B, ò���������or al, SHAD_B, 
		; ����PRI�� B������0000��, ��ʱ��PRI��A�ܸ�����Щ0000��, ������Ӱ, ����Ҫ��and)
		and cl, SHAD_B							;����/��Ӱʱ��ɫ��# =0x40(���ԭ������Ӱ)
		add al, dl								; +ɫ��*16
		add al, cl								; +��ֵ (0-F)
	%else
		add al, dl								;��ͨʱ��ɫ��# =ɫ��*16 +��ֵ (0-F)
	%endif
%else
	;(B��)
	%if %5 > 0
		lea eax, [eax + edx + SHAD_W]			;����/��Ӱʱ��ɫ��# =0x40 (ע��ֻ������Ӱ)
												; +ɫ��*16 +��ֵ (0-F)
	%else
		add al, dl								;��ͨʱ��ɫ��# =ɫ��*16 +��ֵ (0-F)
	%endif
%endif

%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], al	;д��ɫ��#ֵ

%%Trans

%endmacro


;****************************************
; ���A/B��ĸ�PRI��
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
;  edx = ɫ��*016
; ����1 = ebx������(8��)�ĵ�#
; ����2 = ȡ���õ�ֵ��MASK
; ����3 = �õ�ֵ������λ��
; ����4 = 1=����/��Ӱ  (��Ч)

%macro PUTPIXEL_P1 4

	mov eax, ebx			;��õ�Ϊ0000����͸��,
	and eax, %2
	jnz short %%no_trans
	jmp short %%Trans		;����, ֱ�ӷ� (ע��, ����T�Ǹ�PRI, ����͸����δ����, ����ֽ�
							; PRIλ��Ϊ0)
%%no_trans
%if %3 > 0
	shr eax, %3				;��������, �õ�ֵ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


;(ֱ��д��: ��Ϊ����B��ĵ�, ��Ȼֱ��д��, 
; ����A��ĵ�, �����Ǹ�PRI, ���Ǹ���B��ĵ�, ������B��PRI�Ǹ��ǵ�
; Ҳ���ÿ�����Ӱ, A,B��TֻҪ��һ�Ǹ�PRI, ��û����Ӱ (��ʹԭ����, Ҳ����PUTLINE_P1��ȥ��))
	lea eax, [eax + edx + PRIO_W]				;ɫ��# =ɫ��*16 +��ֵ (0-F), ���ֽڱ���
												; ��������(A/B���)��Pri�����
%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], ax	;д��ɫ��#ֵ (�����ֽ�)

%%Trans

%endmacro


;****************************************
; ���Sprite��
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
;  edx = ɫ��*016
; ����1 = ebx������(8��)�ĵ�#
; ����2 = ȡ���õ�ֵ��MASK
; ����3 = �õ�ֵ������λ��
; ����4 = PRI
; ����5 = 1=����/��Ӱ

%macro PUTPIXEL_SPRITE 5

	mov eax, ebx			;��õ�Ϊ0000����͸��,
	and eax, %2
	jz near %%Trans			;����, ֱ�ӷ� (ע��, ͸����ĸ��ֽ��� ��������Sprite�����־,
							; ���Sprite�ɸ�����)

	;(��0000��)
	mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1]	;ȡ���������ֽ�
													;(16=2*8, ����ǰ8��, ��Sprite���õ���)
	test cl, (PRIO_B + SPR_B - %4)		;�� ��������Sprite���, ��������(A/B���)��Pri��
										;�������Sprite���ǵ�PRI, ���������
	jz short %%Affich					;����ת�������

;(���������)
%%Prio
	or ch, cl			;ch���ٲ��������ʱ, ����Ӧԭ������Ƿ� ��������Sprite�����־,
						;����, ��˵��ĳSprite�ķ�0����֮ǰ����ĳSprite�г�ͻ, ����������
						;SP_colide (���κ�2��sprite�ķ�͸������ײ)

%if %4 < 1				;���ǵ�PRI��Sprite�㲻���, �п����Ǳ� AB��ĸ�PRI�����, Ϊ�ⱻ
						;֮��ĵͼ���(����PRI) Sprite����, 
	or byte [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1], SPR_B	;�� ������������Sprite���
%endif
	jmp %%Trans			;ת��

;(�������)

ALIGN4

%%Affich

%if %3 > 0
	shr eax, %3						;��������, �õ�ֵ (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


	;(�Ǹ���/��Ӱʱ)
	lea eax, [eax + edx + SPR_W]	;ɫ��# =ɫ��*16 +��ֵ (0-F), 
									;���ֽ��� ������������Sprite���

%if %5 > 0
;(����/��Ӱʱ)
	;�ȼ��� ������ɫ��# (3E, 3F)��Sprite�㸲��AB���ʱ, �����/��Ӱ/��ͨ״̬
	%if %4 < 1
		and cl, SHAD_B | HIGH_B		;��PRI��Sprite����AB��ĸ���/��Ӱ/��ͨ�仯
	%else
		and cl, HIGH_B				;��PRI��Sprite����AB��ĸ���/��ͨ�仯 (��ӰҲ����ͨ)
	%endif

	cmp eax, (0x3E + SPR_W)
	jb short %%Normal
	ja short %%Shadow

;(����ɫ��#3E, ʹAB������, ��������ʾ, ��ĸ��ֽ�Ҳ�� ��������Sprite���)
%%Highlight
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], HIGH_W
	jmp short %%Trans			;ת��
	
;(����ɫ��#3F, ʹAB�����Ӱ, ��������ʾ, ��ĸ��ֽ�Ҳ�� ��������Sprite���)
%%Shadow
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], SHAD_W
	jmp short %%Trans			;ת��
;(������ɫ��#)
%%Normal
	add al, cl						;ɫ��*16 +��ֵ (0-F), �����������ĸ���/��Ӱ/��ͨ״̬

%endif

	mov [MD_Screen + ebp * 2 + (%1 * 2) + 16], ax	;д��ɫ��# (�����ֽ�)

%%Trans

%endmacro


;****************************************
; ���A/B��ĵ�PRI T���� (8��)
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
; ����1 = 0=B��  1=����
; ����2 = 1=����/��Ӱ

%macro PUTLINE_P0 2

;�����B�� T? (ֻ��B���ֱ������Backdrop, A�治��)
%if %1 < 1
;���ñ�����(8��)��Backdrop (��8*2=016�ֽ�)
	%if %2 > 0
	;��ӰʱBackdrop (40����Ӱ��ɫ��0ɫ0) (ע�������ֽ�Ҳһ������)
		mov dword [MD_Screen + ebp * 2 +  0], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  4], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  8], SHAD_D
		mov dword [MD_Screen + ebp * 2 + 12], SHAD_D
		mov dword [Backdrop_p0], SHAD_D
	%else
	;����ӰʱBackdrop (0��ɫ��0ɫ0) (ע�������ֽ�Ҳһ������)
		mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
		mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
		mov dword [Backdrop_p0], 0x00000000
	%endif
%endif

	test ebx, ebx			;�籾���о�Ϊ0000��, ���û�, ֱ�ӷ�
	jz near %%Full_Trans
	;8��������� (ע��ebx�����ǳ���)
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
; ���A/B��ĵ�PRI T���� (8��), X��ת
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
; ����1 = 0=B��  1=����
; ����2 = 1=����/��Ӱ

;(ͬ��, ��8�������������)

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
	;8��������� (������ȿɼ�X��תЧ��)
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
; ���A/B��ĸ�PRI T���� (8��)
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
; ����1 = 0=B��  1=����
; ����2 = 1=����/��Ӱ

%macro PUTLINE_P1 2

;(��PRI������Ӱ, �����Ƚ�������Ӱ��ȥ����Ӱ����)

%if %1 < 1
	;B��ʱ, ֱ����Backdrop (0��ɫ��0ɫ0) (ע�������ֽ�Ҳһ������)
	;(�Ƿ����/��Ӱ�����������)
	mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
	mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
%else
	%if %2 > 0
	;(A���Ҹ���/��Ӱʱ)
	;(��PRI��B��Ӧ������Ӱ, ����A��T�Ǹ�PRI, ������Ӧλ�õ�B���Ҫ��ȥ����Ӱ)
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

	test ebx, ebx			;�籾���о�Ϊ0000��, ���û�, ֱ�ӷ�
	jz near %%Full_Trans
	;8��������� (ע��ebx�����ǳ���)
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
; ���A/B��ĸ�PRI T���� (8��), X��ת
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ��
; ����1 = 0=B��  1=����
; ����2 = 1=����/��Ӱ

;(ͬ��, ��8�������������)

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
	;8��������� (������ȿɼ�X��תЧ��)
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
;���Sprite��ǰT�ĵ��� (8��)
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ�� (��ƫ��, ����ɨ����������ƫ��)
; ���� :
;  ch  = 20 (����Sprite��0000���ͻ)
; ����1  = PRI
; ����2 = 1=����/��Ӱ

%macro PUTLINE_SPRITE 2

	xor ecx, ecx
	add ebp, [esp]		;ebp +=ɨ����������ƫ�� (ɨ����# *0336)

	;8���������
	PUTPIXEL_SPRITE 0, 0x000000f0,  4, %1, %2
	PUTPIXEL_SPRITE 1, 0x0000000f,  0, %1, %2
	PUTPIXEL_SPRITE 2, 0x0000f000, 12, %1, %2
	PUTPIXEL_SPRITE 3, 0x00000f00,  8, %1, %2
	PUTPIXEL_SPRITE 4, 0x00f00000, 20, %1, %2
	PUTPIXEL_SPRITE 5, 0x000f0000, 16, %1, %2
	PUTPIXEL_SPRITE 6, 0xf0000000, 28, %1, %2
	PUTPIXEL_SPRITE 7, 0x0f000000, 24, %1, %2

	sub ebp, [esp]		;ebp�ָ�Ϊ��ƫ��
	and ch, 0x20				;����Sprite��0000���ͻ,
	or byte [SP_colide], ch	;��SP_colide�� ���κ�2��sprite�ķ�͸������ײ

%endmacro


;****************************************
;���Sprite��ǰT�ĵ��� (8��), X��ת
; ��� :
;  ebx = ������
;  ebp = ��ǰT���λ�� (��ƫ��, ����ɨ����������ƫ��)
; ���� :
;  ch  = 20 (����Sprite��0000���ͻ)
; ����1  = PRI
; ����2 = 1=����/��Ӱ

;(ͬ��, ��8�������������)

%macro PUTLINE_SPRITE_FLIP 2

	xor ecx, ecx
	add ebp, [esp]

	;8��������� (������ȿɼ�X��תЧ��)
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
;��Genesis��CRamת��ΪPC��ʽMD_Palette
; ����1: 1=����/��Ӱ

%macro UPDATE_PALETTE 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; �Ѵ���, ������CRam�ı��־
	mov cx, 0x7BEF								; 0111 1011 1110 1111 (r4g5b4)
	xor edx, edx								; ÿ��ɫ������1λ, �������"��", ��ʹÿ��ɫ��bgr��������(��)
	mov ebx, (128 / 2) - 1						; ebx = ɫ��ѭ����, 128��ɫ������(8ɫ��)
	jmp short %%Loop							; (��2��ÿ�δ���2��ɫ��)
	
	ALIGN32

	%%Loop										;ѭ��
		mov ax, [CRam + ebx * 4 + 0]					; ax = ��ǰɫ��1
		mov dx, [CRam + ebx * 4 + 2]					; dx = ��ǰɫ��2
		cmp ebx, 0x20
		jb %%cg0_3
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 0], ax	; ɫ��4-7ֱ�Ӵ���Ŀ��
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 2], dx	; 
		jmp short %%Next_c
	%%cg0_3
		and ax, 0x0FFF									; ɫ����bbb0 ggg0 rrr0
		and dx, 0x0FFF									; ֻ��12λ
		
		mov ax, [Palette + eax * 2]						; ɫ��1,2��ΪPC��ʽ
		mov dx, [Palette + edx * 2]
		mov [MD_Palette + ebx * 4 + 0], ax				; ����Ŀ��
		mov [MD_Palette + ebx * 4 + 2], dx				; 

%if %1 > 0												;��ָ��Highlight/Shadow
		shr ax, 1
		shr dx, 1
		and ax, cx										; PCɫ��1,2��Ϊ��ɫ
		and dx, cx										; 
		mov [MD_Palette + ebx * 4 + 64 * 2 + 0], ax		; 64-127���氵ɫ
		mov [MD_Palette + ebx * 4 + 64 * 2 + 2], dx		; 
		add ax, cx										; PC��ɫ��1,2��Ϊ��ɫ
		add dx, cx
		mov [MD_Palette + ebx * 4 + 128 * 2 + 0], ax	; 128-191������ɫ
		mov [MD_Palette + ebx * 4 + 128 * 2 + 2], dx	; 
%endif

	%%Next_c
		dec ebx										; ѭ����������64��ɫ��
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;ɫ��0ɫ0��Ϊ����ɫ�Ĵ���ָ��ɫ
		and ebx, byte 0x3F					;(��AB��������ɫ��0tile��0000�㶼
		mov ax, [MD_Palette + ebx * 2]		; ��ʾΪ�˱���ɫ)
		mov [MD_Palette + 0 * 2], ax

%if %1 > 0										;��ָ��Highlight/Shadow
		shr ax, 1								;��Ϊ����ɫ�Ĵ���ָ��ɫ�İ�, ���汾
		and ax, cx
		mov [MD_Palette + 0 * 2 + 64 * 2], ax
		add ax, cx
		mov [MD_Palette + 0 * 2 + 128 * 2], ax
%endif

%endmacro

;****************************************
;��Genesis��CRamת��ΪPC32��ʽMD_Palette32
; ����1: 1=����/��Ӱ

%macro UPDATE_PALETTE32 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; �Ѵ���, ������CRam�ı��־
	mov ecx, 0x7f7f7f							; (r7g7b7)
	xor edx, edx								; ÿ��ɫ������1λ, �������"��",��ʹÿ��ɫ��bgr��������(��)
	mov ebx, (128 / 2) - 1						; ebx = ɫ��ѭ����, 128��ɫ������(8ɫ��)(��2��ÿ�δ���2��ɫ��)
	jmp short %%Loop

	ALIGN32

	%%Loop												;ѭ��
		mov ax, [CRam + ebx * 4 + 0]					; ax = ��ǰɫ��1
		mov dx, [CRam + ebx * 4 + 2]					; dx = ��ǰɫ��2
		cmp ebx, 0x20
		jb %%cg0_3
		mov esi, eax									; eax=��Ϊ32λ��ʽ
		mov edi, eax
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and eax, 0x1F
		shl eax, 3
		or  eax, esi
		or  eax, edi
		mov esi, edx									; edx=��Ϊ32λ��ʽ
		mov edi, edx
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and edx, 0x1F
		shl edx, 3
		or  edx, esi
		or  edx, edi
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 0], eax	; ɫ��4-7ֱ�Ӵ���Ŀ��
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 4], edx	; 
		jmp short %%Next_c
	%%cg0_3
		and eax, 0x0FFF									; ɫ����bbb0 ggg0 rrr0
		and edx, 0x0FFF									; ֻ��12λ
		
		mov eax, [Palette32 + eax * 4]						; ɫ��1,2��ΪPC��ʽ
		mov edx, [Palette32 + edx * 4]
		mov [MD_Palette32 + ebx * 8 + 0], eax				; ����Ŀ��
		mov [MD_Palette32 + ebx * 8 + 4], edx				; 

%if %1 > 0												;��ָ��Highlight/Shadow
		shr eax, 1
		shr edx, 1
		and eax, ecx										; PCɫ��1,2��Ϊ��ɫ
		and edx, ecx										; 
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 0], eax		; 64-127���氵ɫ
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 4], edx		; 
		add eax, ecx										; PC��ɫ��1,2��Ϊ��ɫ
		add edx, ecx
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 0], eax	; 128-191������ɫ
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 4], edx	; 
%endif

	%%Next_c
		dec ebx										; ѭ����������64��ɫ��
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;ɫ��0ɫ0��Ϊ����ɫ�Ĵ���ָ��ɫ
		and ebx, byte 0x3F					;(��AB��������ɫ��0tile��0000�㶼
		mov eax, [MD_Palette32 + ebx * 4]		; ��ʾΪ�˱���ɫ)
		mov [MD_Palette32 + 0 * 4], eax

%if %1 > 0										;��ָ��Highlight/Shadow
		shr eax, 1								;��Ϊ����ɫ�Ĵ���ָ��ɫ�İ�, ���汾
		and eax, ecx
		mov [MD_Palette32 + 0 * 4 + 64 * 4], eax
		add eax, ecx
		mov [MD_Palette32 + 0 * 4 + 128 * 4], eax
%endif

%endmacro

;****************************************
; ���B�� ��ɨ����
; ����1 = 0=��ͨ  1=Interlace
; ����2 = 0=Vȫ�� 1=V2T��
; ����3 = 1=����/��Ӱ

%macro RENDER_LINE_SCROLL_B 3

	mov ebp, [esp]				;ebpָ��MD_Screen�ڱ�ɨ�������λ�� (ɨ����# *336)

	GET_X_OFFSET 0				;si<==ȡB��ı�ɨ����H��ֵ

	mov eax, esi
	xor esi, 0x3FF				;esi =ʵ��H��ֵ
	shr esi, 3					;esi = H��(T)
	and eax, byte 7				;eax = H���
	add ebp, eax				;ebp +=H���, ͨ�����λ�õ���ʵ��H�� (���MD_Screen)
	mov ebx, esi
	and esi, [H_Scroll_CMask]	;esi ��H��(T) ȡģ (�������T����ؾ�)
	and ebx, byte 1				;ebx =������ż (1=��)
								;(ע��, ����λ�������������, ���ݾ�ֵ, 8�����7��ɼ�)
	sub ebx, byte 2				;
	mov [Data_Misc.Cell], ebx	;�������T��#��ֵ = -1 (������)  -2(����ż)
								;(ע��! ���������T��#Ϊ��ʱ, ʹ���׸�V����, 
								; �����������T��#Ϊ0ʱ, Ҳʹ���׸�V����,
								; ������ʱ (����ż, H���=7)���н�4��T�ж�ʹ���׸�V����,
								; ����V2T�о���Ӧ��H��ͬʱʹ��
								; ����Ӳ�����������, �Ѳ���FusionҲ������ģ���)
	mov eax, [H_Cell]
	mov [Data_Misc.X], eax		;temp=��T�� (��Ϊʣ��δ���T��)


	mov edi, [VDP_Current_Line]	;edi = ��ɨ����#
	mov eax, [VSRam + 2]		;��������׸�T��ʹ���׸�V����

%if %1 > 0
	shr eax, 1					; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax				;ɨ����# + �׸�V��ֵ, ΪVλ��
	mov eax, edi
	shr edi, 3					;V��(T)
	and edi, [V_Scroll_CMask]	;V��(T)ȡģ (�������T����ؾ�)
	and eax, byte 7				;V���
	mov [Data_Misc.Line_7], eax	;����V���

	jmp short %%First_Loop		;ת���� (V������ȷ, ��������V������)

	ALIGN32

	;(��Tѭ��)
	%%Loop

%if %2 > 0
		UPDATE_Y_OFFSET 0, %1	;��V2T�о�, ѭ��ʱҪ���Ƿ����V��
								;(���������T��#Ϊż, ��ȡ��һ��V����, 
								; ������edi�е�V��(T)��Data_Misc.Line_7��V���)
%endif

	%%First_Loop

		GET_PATTERN_INFO 0		;ax<==ȡ��ǰTI

		GET_PATTERN_DATA %1, 0	;ebx<==ȡ��ǰT�ڵ�, ��Ӧ��ɨ���е����е������� (����)
		
		test eax, 0x4000000		;H��ת? (V��ת��ȡ��������ʱ�Ѵ���)
		jz near %%No_H_Flip		;��ת

	;(H��ת)
	%%H_Flip

			test eax, 0x80000000		;��PRI? ��ת
			jnz near %%H_Flip_P1

	;(H��ת, ��PRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 0, %3	;���B��ĵ�PRI T���� (8��), X��ת
				jmp %%End_Loop

	ALIGN32

	;(H��ת, ��PRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 0, %3	;���B��ĸ�PRI T���� (8��), X��ת
				jmp %%End_Loop

	ALIGN32
	
	;(��H��ת)
	%%No_H_Flip

			test eax, 0x80000000			;��PRI? ��ת
			jnz near %%No_H_Flip_P1

	;(��H��ת, ��PRI)
	%%No_H_Flip_P0
				PUTLINE_P0 0, %3		;���B��ĵ�PRI T���� (8��)
				jmp %%End_Loop

	ALIGN32

	;(��H��ת, ��PRI)
	%%No_H_Flip_P1
				PUTLINE_P1 0, %3		;���B��ĸ�PRI T���� (8��)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;�������T��# ++
		inc esi							;esiԴ++, ��һTI
		and esi, [H_Scroll_CMask]		;ȡģ  (�������T����ؾ�)
		add ebp, byte 8					;���λ��+=8, ��һT���λ��
		dec byte [Data_Misc.X]			;temp��ʣ��T�� --
		jns near %%Loop					;�Ǹ���ѭ��
										;(ע���ǷǸ�, ���Ա�ʵ��T����1, ���ǵ��������)
		
%%End


%endmacro


;****************************************
; ���A��/Window ��ɨ����
; ����1 = 0=��ͨ  1=Interlace
; ����2 = 0=Vȫ�� 1=V2T��
; ����3 = 1=����/��Ӱ

%macro RENDER_LINE_SCROLL_A_WIN 3

	mov ebx, [H_Cell]					;ebx =��T��
	mov cl, [Win_ud]
	shr cl, 7							;cl = 0:��Window  1:��Window
	mov eax, [VDP_Current_Line]
	shr eax, 3							;eax =��ɨ��������T�� (����T��)
	cmp eax, [Win_Y_Pos]				;��� ��T��>= Window V�ֽ�λ��
	setae ch							;�� ch <== 1 
	xor cl, ch							;����� ��Window�� ��T��< Window V�ֽ�λ��
										;	  ����Window�� ��T��>= Window V�ֽ�λ��
	jz near %%Full_Win					;��ɨ����ȫ��Window, ת����

	;(��ɨ������Window V�ֽ�λ����, ��Window H�ֽ�λ�þ���Window����λ��)
	mov edx, [Win_X_Pos]				;edx =Window H�ֽ�λ��
	test byte [Win_lr], 0x80	;��Window? ��ת
	jz short %%Win_Left

;(��Window)
%%Win_Right
	sub ebx, edx
	mov [Data_Misc.Start_W], edx		;Window Hʼ = H�ֽ�λ��
	mov [Data_Misc.Lenght_W], ebx		;Window H�� = ��T�� -H�ֽ�λ��
	dec edx								;
	mov dword [Data_Misc.Start_A], 0	;A�� Hʼ = 0
	mov [Data_Misc.Lenght_A], edx		;A�� H�� = H�ֽ�λ��-1 (��ʵ����1)
	jns short %%Scroll_A				;��H�ֽ�λ�÷�0, ��϶���A��, ת�ȴ���A��
	jmp %%Window						;����ȫ��Window, ת����

	ALIGN4

;(��Window)
%%Win_Left
	sub ebx, edx
	mov dword [Data_Misc.Start_W], 0	;Window Hʼ = 0
	mov [Data_Misc.Lenght_W], edx		;Window H�� = H�ֽ�λ��
	dec ebx								;
	mov [Data_Misc.Start_A], edx		;A�� Hʼ = H�ֽ�λ��
	mov [Data_Misc.Lenght_A], ebx		;A�� H�� = ��T�� -H�ֽ�λ��-1 (��ʵ����1)
	jns short %%Scroll_A				;��A�� H��>=0, ��϶���A��, ת�ȴ���A��
										;(ע��A�� H��=0Ҳ��A��, ���ʵ����1)
	jmp %%Window						;����ȫ��Window, ת����

	ALIGN4

;(�϶���A��, �ȴ���, �ٴ���Window(����))
%%Scroll_A
	mov ebp, [esp]					;ebpָ��MD_Screen�ڱ�ɨ�������λ�� (ɨ����# *336)

	GET_X_OFFSET 1					;si<==ȡA��ı�ɨ����H��ֵ

	mov ebx, [Data_Misc.Start_A]	;ebx =A��ʼTλ�� (T)
	mov eax, esi					;
	xor esi, 0x3FF					;esi = ʵ��H��ֵ
	and eax, byte 7					;eax = H���
	shr esi, 3						;esi = H��T
	mov [Data_Misc.Mask], eax		;
	mov ecx, esi					;
	add esi, ebx					;esi = H��T +A��ʼTλ��, Ϊ���Ǿ����A��ʼTԴλ��
	and esi, [H_Scroll_CMask]		;ȡģ (�������T����ؾ�)
	lea eax, [eax + ebx * 8]		;
	add ebp, eax					;ebp += (��� +ʼTλ��*8), 
									;��H��������ָ��ʼT���λ��
	and ecx, byte 1
	sub ecx, byte 2					;�������T��#��ֵ = -1 (������)  -2(����ż)
	add ebx, ecx					;ʼTλ��+ �������T��#��ֵ, ��Ϊʵ�ʵ� �������T��#
	mov [Data_Misc.Cell], ebx		;����(ʵ�ʵ�) �������T��#
	mov edi, [VDP_Current_Line]		;edi = ��ɨ����#
	jns short %%Not_First_Cell		;���������T��#Ϊ��, ���������T�������ֱ���T��,

	mov eax, [VSRam + 0]			;��ʹ���׸�V����
	jmp short %%First_VScroll_OK

%%Not_First_Cell
	and ebx, [V_Scroll_MMask]		;������������T��#ȡģ
									;(V����ʱΪ0, ȡģ���ֻ��ȡV����0, 
									; V2T��ʱΪ7E, ȡģ��Ϊż�����޶���Χ)
	mov eax, [VSRam + ebx * 2]		;ȡ����ӦV����

;(��ȡ�����ʹ�õ�V����)
%%First_VScroll_OK

%if %1 > 0
	shr eax, 1						; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax					;ɨ����# + �׸�V��ֵ, ΪVλ��
	mov eax, edi
	shr edi, 3						;V��(T)
	and edi, [V_Scroll_CMask]		;V��(T)ȡģ (�������T����ؾ�)
	and eax, byte 7					;V���
	mov [Data_Misc.Line_7], eax		;����V���

	jmp short %%First_Loop_SCA		;ת���� (V������ȷ, ��������V������)

	ALIGN32

;(A���Tѭ��)
%%Loop_SCA

%if %2 > 0
		UPDATE_Y_OFFSET 1, %1		;��V2T�о�, ѭ��ʱҪ���Ƿ����V��
									;(���������T��#Ϊż, ��ȡ��һ��V����, 
									; ������edi�е�V��(T)��Data_Misc.Line_7��V���)
%endif

%%First_Loop_SCA
	;call _hook


		GET_PATTERN_INFO 1			;ax<==ȡ��ǰTI
		GET_PATTERN_DATA %1, 0		;ebx<==ȡ��ǰT�ڵ�, ��Ӧ��ɨ���е����е������� (����)
		
		test eax, 0x4000000			;H��ת? (V��ת��ȡ��������ʱ�Ѵ���)
		jz near %%No_H_Flip			;��ת

	;(H��ת)
	%%H_Flip
			test eax, 0x80000000	;��PRI? ��ת
			jnz near %%H_Flip_P1

	;(H��ת, ��PRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 1, %3	;���A��ĵ�PRI T���� (8��), X��ת
				jmp %%End_Loop

	ALIGN32

	;(H��ת, ��PRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 1, %3	;���A��ĸ�PRI T���� (8��), X��ת
				jmp %%End_Loop

	ALIGN32
	
	;(��H��ת)
	%%No_H_Flip
			test eax, 0x80000000		;��PRI? ��ת
			jnz near %%No_H_Flip_P1

	;(��H��ת, ��PRI)
	%%No_H_Flip_P0
				PUTLINE_P0 1, %3		;���A��ĵ�PRI T���� (8��)
				jmp %%End_Loop

	ALIGN32

	;(��H��ת, ��PRI)
	%%No_H_Flip_P1
				PUTLINE_P1 1, %3		;���A��ĸ�PRI T���� (8��)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;�������T��# --
		inc esi							;esiԴ++, ��һTI
		and esi, [H_Scroll_CMask]		;ȡģ  (�������T����ؾ�)
		add ebp, byte 8					;���λ��+8, ��һT���λ��
		dec byte [Data_Misc.Lenght_A]	;A��ʣ�೤��--
		jns near %%Loop_SCA				;�Ǹ���ѭ�� (��Ϊ�ǷǸ�, �����ٵ�1������)


;(�����ʱ��H������, A����������8��1��, Ҫ����)
;(����H���Ϊ0, �������A���׸�T����ȫ����(����ȫ��ǰ������), Ҫ��8��
; H���Ϊ1, �������A���׸�T������7��, Ҫ��7��
; ...H���Ϊ7, �������A���׸�T������1��, Ҫ��1��)
;(֮������������, ����Ϊ�������Ӧ A����� �ĵط����Ǻ������, ��������Window�������)
%%LC_SCA

%if %2 > 0
	UPDATE_Y_OFFSET 1, %1				;��V2T�о�, Ҫ���Ƿ����V��
%endif

	GET_PATTERN_INFO 1					;ax<==ȡ���Ҫ����TI
	GET_PATTERN_DATA %1, 0				;ebx<==��T�ڵ�, ��Ӧ��ɨ���е����е������� (����)

	mov ecx, [Data_Misc.Mask]			;ȡH���
	test eax, 0x4000000					;H��ת? (V��ת��ȡ��������ʱ�Ѵ���)
	jz near %%LC_SCA_No_H_Flip			;��ת

	;(H��ת)
	%%LC_SCA_H_Flip
		and ebx, [Mask_F + ecx * 4]		;ebx<==����H��㱣��Ҫ����, ������0 (0���Window�޺�)
		test eax, 0x80000000			;��PRI? ��ת
		jnz near %%LC_SCA_H_Flip_P1

	;(H��ת, ��PRI)
	%%LC_SCA_H_Flip_P0
			PUTLINE_FLIP_P0 1, %3		;���A��ĵ�PRI T���� (8��), X��ת
			jmp %%LC_SCA_End

	ALIGN32

	;(H��ת, ��PRI)
	%%LC_SCA_H_Flip_P1
			PUTLINE_FLIP_P1 1, %3		;���A��ĸ�PRI T���� (8��), X��ת
			jmp %%LC_SCA_End

	ALIGN32
	
	;(��H��ת)
	%%LC_SCA_No_H_Flip
		and ebx, [Mask_N + ecx * 4]		;ebx<==����H��㱣��Ҫ����, ������0 (0���Window�޺�)
		test eax, 0x80000000			;��PRI? ��ת
		jnz near %%LC_SCA_No_H_Flip_P1

	;(��H��ת, ��PRI)
	%%LC_SCA_No_H_Flip_P0
			PUTLINE_P0 1, %3			;���A��ĵ�PRI T���� (8��)
			jmp %%LC_SCA_End

	ALIGN32

	;(��H��ת, ��PRI)
	%%LC_SCA_No_H_Flip_P1
			PUTLINE_P1 1, %3			;���A��ĸ�PRI T���� (8��)
			jmp short %%LC_SCA_End

	ALIGN32

;(�������)
%%LC_SCA_End
	test byte [Data_Misc.Lenght_W], 0xFF	;��Window H��?
	jnz short %%Window						;��, תWindow����
	jmp %%End								;��, ����Window, ת����





	ALIGN4

;(��ɨ����ȫ��Windowʱ)
%%Full_Win
	xor esi, esi							;esi =Window Hʼ (T) =0
	mov edi, ebx							;edi =Window H�� (T) =��T��
	jmp short %%Window_Initialised			;ת����

	ALIGN4

;(��ɨ���в�����Windowʱ)
%%Window
	mov esi, [Data_Misc.Start_W]			;esi =Window Hʼ (T)
	mov edi, [Data_Misc.Lenght_W]			;edi =Window H�� (T)

%%Window_Initialised
	mov ebp, [esp]							;ebpָ��ɨ�������λ�� (ɨ����# *336)
	lea ebp, [ebp + esi * 8 + 8]			;ebpָ��Window��T���λ�� (+8���������)
	mov edx, [VDP_Current_Line]				;
	mov ebx, edx							;
	shr edx, 3								;edx = ��ɨ��������T��#
	mov cl, [H_Win_Mul]
	shl edx, cl								;edx = ��ɨ��������T��# * Window���ֱ���T��
											;�� ����T����Window���ֱ��ڵ�ƫ��(T)
	mov eax, Window
	lea eax, [eax + edx * 4]				;eax ָ��Window���ֱ�������T������
	mov [Data_Misc.Pattern_Adr], eax		;�ݴ�
	and ebx, byte 7							;ebx = ��ɨ���ж�Ӧ��V���
	mov [Data_Misc.Line_7], ebx				;�ݴ�
	jmp short %%Loop_Win					;תѭ��

	ALIGN32

%%Loop_Win
		mov ebx, [Data_Misc.Pattern_Adr]	;ȡ��ɨ��������T����Window���ֱ��ڵ�ƫ��(T)
		mov eax, [ebx + esi * 4]			; + ��ǰTλ��*4, ����ȡ����ǰTI

		GET_PATTERN_DATA %1, 1				;ȡ��ǰT�ڵ�, ��Ӧ��ɨ���е����е�������(����)

		test eax, 0x4000000					;H��ת?
		jz near %%W_No_H_Flip				;��ת

	;(H��ת)
	%%W_H_Flip
			test eax, 0x80000000			;��PRI? ��ת
			jnz near %%W_H_Flip_P1

	;(H��ת, ��PRI)
	%%W_H_Flip_P0
				PUTLINE_FLIP_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(H��ת, ��PRI)
	%%W_H_Flip_P1
				PUTLINE_FLIP_P1 2, %3
				jmp %%End_Loop_Win

	ALIGN32
	
	;(��H��ת)
	%%W_No_H_Flip
			test eax, 0x80000000				;��PRI? ��ת
			jnz near %%W_No_H_Flip_P1

	;(��H��ת, ��PRI)
	%%W_No_H_Flip_P0
				PUTLINE_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(��H��ת, ��PRI)
	%%W_No_H_Flip_P1
				PUTLINE_P1 2, %3
				jmp short %%End_Loop_Win

	ALIGN32

	%%End_Loop_Win
		inc esi						;esiԴ++, ��һWindow T
		add ebp, byte 8				;ebp +=8, ��һT���λ��
		dec edi						;ʣ��H�� --
		jnz near %%Loop_Win			;��0��ѭ��

%%End


%endmacro


;****************************************
; ������б�ɨ���пɼ�������Sprite�ĵ���
; ����1 = 0=��ͨ  1=Interlace
; ����2 = 1=����/��Ӱ

%macro RENDER_LINE_SPR 2

	UPDATE_MASK_SPRITE			;ɨ��Sprite_Struct�����, ����ɨ���к����ҿɼ���
								;��Sprite����ƫ�Ʊ��浽Sprite_Visible��, ������Sprite����
								;(ע��: edx =��ɨ����#)
	xor edi, edi				;ediΪSprite_Visible����ָ��
	mov dword [Data_Misc.X], edi;�ݴ�
	test esi, esi				;�籾ɨ������û�пɼ���Sprite
	jnz short %%First_Loop
	jmp %%End					;��ֱ�ӽ���

;(�пɼ���Sprite)
	ALIGN32

%%Sprite_Loop
		mov edx, [VDP_Current_Line]				;edx =��ɨ����#
%%First_Loop
		mov edi, [Sprite_Visible + edi]			;ȡ��ǰ�ɼ�Sprite��Sprite_Struct��ƫ��
		mov eax, [Sprite_Struct + edi + 24]		;eax =��TI
		mov esi, eax							;esi =��TI
		mov ebx, eax							;ebx =��TI
		shr bx, 9								;
		and ebx, 0x30							;ebx =ɫ��*016
		or ebx,[Sprite_Struct + edi + 28]
		mov [Data_Misc.Palette], ebx			;����
		and esi, 0x7FF							;esi = T#
		sub edx, [Sprite_Struct + edi + 4]		;edx = ��ɨ����# - SP Y��ʾ���� (Yƫ��)
		mov ecx, edx							;
		and edx, 0xF8							;edx = Yƫ��(T) *8
		and ecx, byte 7							;ecx = Y���
		mov ebx, [Sprite_Struct + edi + 12]		;ebx = Y�ߴ�-1
%if %1 > 0
		shl ebx, 6								;ebx = (Y�ߴ�-1) * 64
		lea edx, [edx * 8]						;edx = Yƫ��(T) * 64
		shl esi, 6								;esi = (VRAM�е�)��Tƫ��
%else
		shl ebx, 5								;ebx = (Y�ߴ�-1) * 32
		lea edx, [edx * 4]						;edx = Yƫ��(T) * 32
		shl esi, 5								;esi = (VRAM�е�)��Tƫ��
%endif

		test eax, 0x1000						;SP V��ת
		jz %%No_V_Flip							;��ת

	;(V��ת)
	%%V_Flip
		xor ecx, 7								;ecx = Y��� ��� 7 (0-7��Ϊ7-0)
		sub ebx, edx							;(V��תʱֻ�����esiԴָ��)
		add esi, ebx							;esi = VRAM�е���Tƫ�� +(Y�ߴ�-1) * 32(64)
												;	   - Yƫ��(T) * 32(64)
												;(�۲�Yƫ��(T) ��0-3ʱ, 
												; esiָ��YĩT, YĩT-1...YĩT-3�ĵ�����
												; ������ȷ)
%if %1 > 0
		lea ebx, [ebx + edx + 64]				;ebx�ָ�ԭֵ, �ټ�64, ��ebx =Y�ߴ�* 64
												;��ebxΪSP X����T֮������ݼ��
		lea esi, [esi + ecx * 8]				;esiָ��SP��T���еı�ɨ���ж�Ӧ��T�ڵ���
		jmp short %%Suite
%else
		lea ebx, [ebx + edx + 32]				;ebx�ָ�ԭֵ, �ټ�32, ��ebx =Y�ߴ�* 32
												;��ebxΪSP X����T֮������ݼ��
		lea esi, [esi + ecx * 4]				;esiָ��SP��T���еı�ɨ���ж�Ӧ��T�ڵ���
		jmp short %%Suite
%endif

	ALIGN4
	
	;(��V��ת)
	%%No_V_Flip
		add esi, edx							;esiָ��SP��T���еı�ɨ���ж�Ӧ��T
%if %1 > 0
		add ebx, byte 64						;ebx=Y�ߴ�*64, ��ΪSP X����T֮������ݼ��
		lea esi, [esi + ecx * 8]				;esiָ��SP��T���еı�ɨ���ж�Ӧ��T�ڵ���
%else			
		add ebx, byte 32						;ebx=Y�ߴ�*32, ��ΪSP X����T֮������ݼ��
		lea esi, [esi + ecx * 4]				;esiָ��SP��T���еı�ɨ���ж�Ӧ��T�ڵ���
%endif

	%%Suite
		mov [Data_Misc.Next_Cell], ebx			;����SP X����T֮������ݼ��
		mov edx, [Data_Misc.Palette]			;edx = ɫ��*016

		test eax, 0x800							;H��ת? ��ת
		jz near %%No_H_Flip

	;(H��ת)
	;(H��תʱ, esiԴ���ı�, ����ebp���λ�ü��������ı�
	; ebp��SP����T�����λ����, ���������T)
	%%H_Flip
		mov ebx, [Sprite_Struct + edi + 0]		;ebx =SP X��ʾ����
		mov ebp, [Sprite_Struct + edi + 16]		;ebp =SP �Ҽ���(��)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP X����T֮������ݼ��
		cmp ebx, -7								;(����SP ���λ�����Ҽ���)
		jg short %%Spr_X_Min_Norm
		mov ebx, -7								;��X��ʾ����<-7, ������ = -7
												;(���ǵ��������, ebpһ��<-7�Ϳ�ֹͣ���)
												;(֮����-7, ����Ϊ-7�������T���ܿ���1��
												; -7�����λ��, ���TҲ���ɼ�)
	%%Spr_X_Min_Norm
		mov [Data_Spr.H_Min], ebx				;�������� = X��ʾ���� (��)

	;(���λ������OK)
	%%Spr_X_Min_OK								;(SP ���λ���Ҽ���ֱ�����õ�ebp)
		sub ebp, byte 7							;ebp��ʼλ�� = ����T���λ�� (��esiԴ��Ӧ)
												;(��7ʵΪ��8, ��SP�Ҽ��ް�����SP��Χ��,
												; ��SP�Ҽ��� =X��ʾ���� +X�ߴ�*8 -1)
		jmp short %%Spr_Test_X_Max				;תebp����Ҽ��޺Ϸ��жϼ�����

	ALIGN4

	%%Spr_Test_X_Max_Loop
			sub ebp, byte 8						;ebp -=8, ��ǰһT���λ��
			add esi, edi						;esiԴ ָ��X����һT(����)����λ��

	%%Spr_Test_X_Max
			cmp ebp, [H_Pix]					;�� ebp>=�е���, ��Ƿ�, ת����ѭ��
												;(�������Ҳ������)
												;(���õ��ĵ�����ͷ, ��SP�϶��ɼ�)
			jge %%Spr_Test_X_Max_Loop
	;(ebp���λ�úϷ�)
		test eax, 0x8000						;��PRI? ��ת
		jnz near %%H_Flip_P1
		jmp short %%H_Flip_P0

	ALIGN32
	
	;(H��ת, ��PRI)
	%%H_Flip_P0
	%%H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SP��ǰT�еĵ�����
			PUTLINE_SPRITE_FLIP 0, %2				;���SP��ǰT�ĵ��� (8��), X��ת, ��PRI

			sub ebp, byte 8							;ebp���λ�� -=8, ��ǰһT���λ��
			add esi, edi							;esiԴ ָ��X����һT(����)����λ��
			cmp ebp, [Data_Spr.H_Min]				;ebp���λ���ѳ�Խ����?
			jge near %%H_Flip_P0_Loop				;��, ��ѭ�������һT(�ĵ���)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(H��ת, ��PRI)									;ͬ��, ���Ǹ�PRI
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
	
	;(��H��ת)
	;(��H��תʱ, ebp������T�����λ����, ˳�������T)
	%%No_H_Flip
		mov ebx, [Sprite_Struct + edi + 16]		;ebx =SP �Ҽ���(��)
		mov ecx, [H_Pix]
		mov ebp, [Sprite_Struct + edi + 0]		;ebp =SP X��ʾ���� (��Ϊ���λ��)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP X����T֮������ݼ��
												;(����SP ���λ�����Ҽ���)
		cmp ebx, ecx							;��SP �Ҽ���(��) >=�е���,
		jl %%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ecx				;������Ҽ��� =�е���
		jmp short %%Spr_Test_X_Min

	ALIGN4

	%%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ebx				;��������Ҽ��� =SP �Ҽ���(��)
												;(SP ���λ���Ҽ���OK)
												;(SP ���λ������ֱ�����õ�ebp)
		jmp short %%Spr_Test_X_Min				;תebp������޺Ϸ��жϼ�����

	ALIGN4

	%%Spr_Test_X_Min_Loop
			add ebp, byte 8						;ebp +=8, X����һT���λ��
			add esi, edi						;esiԴ ָ��X����һT(����)����λ��

	%%Spr_Test_X_Min
			cmp ebp, -7							;�� ebp<-7, ��Ƿ�, ת����ѭ��
			jl %%Spr_Test_X_Min_Loop

		test ax, 0x8000							;��PRI? ��ת
		jnz near %%No_H_Flip_P1
		jmp short %%No_H_Flip_P0

	ALIGN32
	
	;(��H��ת, ��PRI)
	%%No_H_Flip_P0
	%%No_H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SP��ǰT�еĵ�����
			PUTLINE_SPRITE 0, %2					;���SP��ǰT�ĵ��� (8��), ��PRI

			add ebp, byte 8							;ebp���λ�� +=8, ��һT���λ��
			add esi, edi							;esiԴ ָ��X����һT(����)����λ��
			cmp ebp, [Data_Spr.H_Max]				;ebp���λ���Դﵽ�Ҽ���?
			jl near %%No_H_Flip_P0_Loop				;��, ��ѭ�������һT(�ĵ���)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(��H��ת, ��PRI)								;ͬ��, ���Ǹ�PRI
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
	
	;(��ǰSP�������, ��һSP)
	%%End_Sprite_Loop
		mov edi, [Data_Misc.X]						;edi =Sprite_Visible����ָ��
		add edi, byte 4								;edi +=4, ��һSprite_Visible����
		mov [Data_Misc.X], edi						;����
		cmp edi, [Data_Misc.Borne]					;�Ѵ�Sprite_Visible��β?
		jb near %%Sprite_Loop						;��, ��ѭ�������һSP

%%End

%endmacro


;****************************************

; macro RENDER_LINE
; param :
; %1 = 1 pour mode entrelac� et 0 sinon
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
		test dword [Disp_state], 0x01		; on teste si le VDP est activ�
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
		test byte [CRam_Flag], 1		; CRam�ı�? (Ҫ����MD_Palette?)
		jz near .Palette_OK				; ��, �����账��, ����

		cmp dword [Crt_BPP], 32
		je near .Palette32
		test byte [STE_state], 8
		jnz near .Palette_HS

		UPDATE_PALETTE 0				;��Genesis��CRamת��ΪPC��ʽ, ������
		jmp .Palette_OK

	ALIGN4
	.Palette_HS
		UPDATE_PALETTE 1				;��Genesis��CRamת��ΪPC��ʽ, ������
		jmp .Palette_OK

	ALIGN4
	.Palette32
		test byte [STE_state], 8
		jnz near .Palette32_HS
		UPDATE_PALETTE32 0				;��Genesis��CRamת��ΪPC��ʽ, ������
		jmp .Palette_OK
	.Palette32_HS
		UPDATE_PALETTE32 1				;��Genesis��CRamת��ΪPC��ʽ, ������

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
