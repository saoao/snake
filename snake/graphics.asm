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

	DECL SP_colide					;B5：1=有任何2个sprite的非透明点碰撞
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
; 取A/B面的本扫描行H卷动值
; 参数1: 0=B面  1=A面
; 出口: si=卷动值

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
; 如现输出的T列#为偶, 则取下一个V卷动量, 
; 并更新edi中的V行(T)及Data_Misc.Line_7的V余点
; 参数1: 0=B面  1=A面
; 参数2: 0=普通  1=Interlace
; 出口:
; edi =(原先的或更新的) V行(T),   Data_Misc.Line_7=(原先的或更新的) V余点

%macro UPDATE_Y_OFFSET 2

	mov eax, [Data_Misc.Cell]				;取现输出的T列#
	test eax, 0xFF81						;如为负或奇, 
	jnz short %%End							;则仍使用现V卷动量, 转返
	mov edi, [VDP_Current_Line]				;edi = 本扫描行#

%if %1 > 0
	mov eax, [VSRam + eax * 2 + 0]			;取A面/B面的下一个V卷动量
%else										;(注意T列#*2, 因T列#为偶时才乘2, 实为*4)
	mov ax, [VSRam + eax * 2 + 2]
%endif

%if %2 > 0
	shr eax, 1								; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax							;edi<==本扫描行# +V卷动量, 即卷动后的实际点行#
	mov eax, edi							;
	shr edi, 3								;edi<==实际点行化为V行(T)
	and eax, byte 7							;取模
	and edi, [V_Scroll_CMask]				;
	mov [Data_Misc.Line_7], eax				;V余点

%%End

%endmacro


;****************************************
; 取当前TI
; 入口:
; edi = V行(T)
; esi = H列(T)
; 参数1: 0=B面  1=A面
; 出口 :
; ax = TI (Tile Info)

%macro GET_PATTERN_INFO 1

	mov cl, [H_Scroll_CMul]						;行T指数
	mov eax, edi								;
	shl eax, cl									;eax = V行(T) * (2的行T指数次方)
												;(即V卷动后对应的V行(T)在名字表中的偏移)
	mov edx, esi								;edx = H列(T)
	add edx, eax								;edx = V行(T)偏移 +H列(T)
												;(即要取的TI的偏移, !!是TI偏移, 非字节偏移)

%if %1 > 0
	mov ebx, ScreenA							;根据参数1, 取A面/B面的
%else
	mov ebx, ScreenB
%endif

	mov eax, [ebx + edx * 4]						; eax = TI  (*4即T偏移化为字节偏移)

%endmacro


;****************************************
; 取当前T内的, 对应本扫描行的那行点阵数据 (长字)
; 入口:
; eax = TI
; 参数1 = 0=普通  1=Interlace
; 参数2 = 无效
; 出口:
; ebx = 点阵长字 (含8点)
; edx = 色组*016

%macro GET_PATTERN_DATA 2

	mov ebx, [Data_Misc.Line_7]					;ebx = V余点, 即T内点行#
	mov edx, eax								;edx = TI
	mov ecx, eax								;ecx = TI
	shr edx, 24
	and edx, byte 0x70							;edx = 色组*016  (色组0-7)
	and ecx, 0x3FFFFFF							;ecx = T# (26位)

%if %1 > 0
	shl ecx, 6									;ecx = T#*064, 得T的点阵数据偏移
												;(1个Tile有064个字节) 
%else
	shl ecx, 5									;ecx = T#*032, 得T的点阵数据偏移
												;(1个Tile有032个字节) 
%endif

	test eax, 0x8000000							; 如指定V翻转, 则T内点行# 异或 7
	jz %%No_V_Flip								; (0-7 变为 7-0)

	xor ebx, byte 7

%%No_V_Flip

%if %1 > 0
	mov ebx, [VRam + ecx + ebx * 8]				;(乘8是因每2点行输出1点行, 次点行4字节不用)
%else
	mov ebx, [VRam + ecx + ebx * 4]				;点阵数据 在VRAM内的 (T的点阵数据偏移)+
%endif											;T内点行#*4处 (乘4是因每点行点阵数据4字节)

%endmacro


;****************************************
;根据Sprite属性区重设Sprite_Struct表
; 参数1 = 0=普通  1=Interlace


%macro MAKE_SPRITE_STRUCT 1

	mov ebp, Sprite							;esi=ebp指向(VRAM的)Sprite属性区
	mov esi, ebp							;
	xor edi, edi							;edi = 0, 从Sprite_Struct首项起写入
	jmp short %%Loop

	ALIGN32
	
%%Loop
		mov ax, [ebp + 0]						;ax = Pos Y
		mov cx, [ebp + 6]						;cx = Pos X
		mov edx,0
		mov [Sprite_Struct + edi + 28], edx
		mov dl, [ebp + (2 ^ 1)]					;dl = Sprite尺寸 (^1是因为VRAM颠倒, 下同)
		test dl, 0x80
		jz %%cg0_3
		or byte [Sprite_Struct + edi + 28],0x40	;如果游戏不用Sprite尺寸的高4位, 则可使用本句, 来增加SPRITE可用色组
%%cg0_3
	%if %1 > 0
		shr eax, 1								; si entrelac�, la position est divis� par 2
	%endif
		mov dh, dl								;dh =dl =Sprite尺寸
		and eax, 0x1FF							;Pos Y,X规范
		and ecx, 0x1FF
		and edx, 0x0C03							;dh =(X尺寸-1)*4, dl =(Y尺寸-1)
		sub eax, 0x80							;eax = Y显示坐标 (注意可为负)
		sub ecx, 0x80							;ecx = X显示坐标 (注意可为负)
		mov [Sprite_Struct + edi + 4], eax		;Y显示坐标 存入Sprite_Struct
		mov [Sprite_Struct + edi + 0], ecx		;X显示坐标 存入Sprite_Struct
		shr dh, 2								;dh = X尺寸-1
		inc dh									;dh = X尺寸
		mov [Sprite_Struct + edi + 8], dh		;X尺寸 存入Sprite_Struct
		mov bl, dh								;bl = X尺寸
		and ebx, byte 7							;ebx = X尺寸
		mov [Sprite_Struct + edi + 12], dl		;Y尺寸-1 存入Sprite_Struct
		and edx, byte 3							;edx = Y尺寸-1
		lea ecx, [ecx + ebx * 8 - 1]			;ecx = 右极限
		lea eax, [eax + edx * 8 + 7]			;eax = 下极限 (+7=+8-1, +8因Y尺寸-1)
		mov [Sprite_Struct + edi + 16], ecx		;右极限 存入Sprite_Struct
		mov [Sprite_Struct + edi + 20], eax		;下极限 存入Sprite_Struct
		mov bl, [ebp + (3 ^ 1)]					;bl = 下一SP#
		mov dx, [ebp + 4]						;dx = 首TI
		add edi, byte (8 * 4)					;edi指向下一Sprite_Struct项
		and ebx, byte 0x7F						;ebx = 下一SP#
		mov [Sprite_Struct + edi - 32 + 24], dx	;首TI 存入Sprite_Struct (-32是因刚+32)
		jz short %%End							;如下一SP#为0, 则再无SP, 转跳出循环
		lea ebp, [esi + ebx * 8]				;ebp指向下一SP属性
		cmp edi, (8 * 4 * 80)					;如未超越Sprite属性区, 则转循环
		jb near %%Loop

%%End
	sub edi, 8 * 4							;
	mov [Data_Misc.Spr_End], edi			;保存Sprite_Struct表最后一项的偏移

%endmacro


;****************************************
;扫描Sprite_Struct表各项, 将本扫描行含有且可见的各Sprite的项偏移保存到Sprite_Visible区,
;并处理Sprite屏蔽
;出口:
; edx =本扫描行#

%macro UPDATE_MASK_SPRITE 0

	xor edi, edi					;从Sprite_Struct表第0项起查找
	xor ax, ax
	mov ebx, [H_Pix]				;ebx=显示点数
	xor esi, esi					;Sprite_Visible的保存指针
	mov edx, [VDP_Current_Line]		;edx=本扫描行#
	jmp short %%Loop_1

	ALIGN4
	;(Loop_1循环用来查找首个本扫描行含有的Sprite)
%%Loop_1
		cmp [Sprite_Struct + edi + 4], edx			;Y显示坐标>本扫描行#? 是转下一项
		jg short %%Out_Line_1
		cmp [Sprite_Struct + edi + 20], edx			;下极限<本扫描行#? 是转下一项
		jl short %%Out_Line_1

		;(找到首个本扫描行含有的Sprite, 判其是否可见)
		cmp [Sprite_Struct + edi + 0], ebx			;X显示坐标 >显示点数?
		jge short %%Out_Line_1_2					;是, 转下一项并进入Loop_2
		cmp dword [Sprite_Struct + edi + 16], 0		;右极限<0?
		jl short %%Out_Line_1_2						;是, 转下一项并进入Loop_2

		mov [Sprite_Visible + esi], edi				;找到本扫描行可见的Sprite, 保存其偏移
		add esi, byte 4								;保存指针+=4, 下一保存位置

		;(进入这儿时, 已找到首个本扫描行含有的Sprite (可见或不可见))
%%Out_Line_1_2
		add edi, byte (8 * 4)						;下一Sprite_Struct项
		cmp edi, [Data_Misc.Spr_End]				;已超越Sprite_Struct所有项?
		jle short %%Loop_2							;否, 则转Loop_2循环

		jmp %%End									;是, 则转结束

	ALIGN4

		;(进入这儿时, 仍然未找到首个本扫描行含有的Sprite)
%%Out_Line_1
		add edi, byte (8 * 4)						;下一Sprite_Struct项
		cmp edi, [Data_Misc.Spr_End]				
		jle short %%Loop_1							;已超越Sprite_Struct所有项?
													;否, 则转Loop_1循环, 继续查首个
		jmp %%End									;是, 则转结束

	ALIGN4

	;(Loop_2循环用来查找次个起的本扫描行含有的Sprite)
%%Loop_2
		cmp [Sprite_Struct + edi + 4], edx			;Y显示坐标>本扫描行#? 是转下一项
		jg short %%Out_Line_2
		cmp [Sprite_Struct + edi + 20], edx			;下极限<本扫描行#? 是转下一项
		jl short %%Out_Line_2

		cmp dword [Sprite_Struct + edi + 0], -128	;如X显示坐标为-80 (说明X位置为0)
		je short %%End								;则直接转结束 (其它Sprite被屏蔽
													; 因它们优先级肯定更低)

		cmp [Sprite_Struct + edi + 0], ebx			;X显示坐标 >显示点数? 是转下一项
		jge short %%Out_Line_2
		cmp dword [Sprite_Struct + edi + 16], 0		;右极限<0? 是转下一项
		jl short %%Out_Line_2

		mov [Sprite_Visible + esi], edi				;找到本扫描行可见的Sprite, 保存其偏移
		add esi, byte 4								;保存指针+=4, 下一保存位置

%%Out_Line_2
		add edi, byte (8 * 4)
		cmp edi, [Data_Misc.Spr_End]
		jle short %%Loop_2
		jmp short %%End

	ALIGN4

%%End
	mov [Data_Misc.Borne], esi						;保存Sprite_Visible区尾(不含)


%endmacro


;****************************************
; 输出A/B面的低PRI点
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
;  edx = 色组*016
; 参数1 = ebx点阵长字(8点)的点#
; 参数2 = 取出该点值的MASK
; 参数3 = 该点值的右移位数
; 参数4 = 0=B面  1=其它
; 参数5 = 1=高亮/阴影

%macro PUTPIXEL_P0 5

	mov eax, ebx			;如该点为0000则是透明,
	and eax, %2
	jnz short %%no_trans1	;不画, 直接返
	jmp short %%Trans

;(非0000点)
;(下面要检测是否A面, 如是, 要判本点输出处是否已有B面高Pri点, 是则不能覆盖, 转返
; 注意B面不用检测直接画, 因B面是最先处理的, 其下只有1个级别更低的Backdrop, 所以直接画)
%%no_trans1
%if %4 > 0														;是A面?
	%if %5 > 0													;高亮/阴影模式?
		mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 1]			;是, 则取该输出点高字节
		test cl, PRIO_B											;该点已有B面高Pri点?
		jz short %%no_trans2									;是则不画, 返
																;(低Pri的A不能覆盖它)
	%else
																;不是高亮/阴影模式
		test byte [MD_Screen + ebp * 2 + (%1 * 2) + 1], PRIO_B	;取点高字节
		jz short %%no_trans2									;如已有B面高Pri点, 则返
	%endif
	jmp short %%Trans
%endif

%%no_trans2
%if %3 > 0
	shr eax, %3									;将点右移, 得点值 (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3

;(A,B面分别处理)
%if %4 > 0
	;(A面)
	%if %5 > 0
		;(A面有无阴影随B面而定)
		;(高亮/阴影时, 低PRI的B面,Backdrop都是阴影, 虽然高PRI的B无阴影 (含Backdrop), 
		; 但低PRI的A无法覆盖高PRI的B, 貌似这儿可用or al, SHAD_B, 
		; 但高PRI的 B中仍有0000点, 此时低PRI的A能覆盖这些0000点, 且无阴影, 所以要用and)
		and cl, SHAD_B							;高亮/阴影时的色彩# =0x40(如果原先有阴影)
		add al, dl								; +色组*16
		add al, cl								; +点值 (0-F)
	%else
		add al, dl								;普通时的色彩# =色组*16 +点值 (0-F)
	%endif
%else
	;(B面)
	%if %5 > 0
		lea eax, [eax + edx + SHAD_W]			;高亮/阴影时的色彩# =0x40 (注意只能是阴影)
												; +色组*16 +点值 (0-F)
	%else
		add al, dl								;普通时的色彩# =色组*16 +点值 (0-F)
	%endif
%endif

%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], al	;写入色彩#值

%%Trans

%endmacro


;****************************************
; 输出A/B面的高PRI点
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
;  edx = 色组*016
; 参数1 = ebx点阵长字(8点)的点#
; 参数2 = 取出该点值的MASK
; 参数3 = 该点值的右移位数
; 参数4 = 1=高亮/阴影  (无效)

%macro PUTPIXEL_P1 4

	mov eax, ebx			;如该点为0000则是透明,
	and eax, %2
	jnz short %%no_trans
	jmp short %%Trans		;不画, 直接返 (注意, 尽管T是高PRI, 但其透明点未处理, 其高字节
							; PRI位仍为0)
%%no_trans
%if %3 > 0
	shr eax, %3				;将点右移, 得点值 (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


;(直接写入: 因为如是B面的点, 当然直接写入, 
; 如是A面的点, 因其是高PRI, 总是覆盖B面的点, 而不管B面PRI是高是低
; 也不用考虑阴影, A,B面T只要有一是高PRI, 就没有阴影 (即使原先有, 也已在PUTLINE_P1中去除))
	lea eax, [eax + edx + PRIO_W]				;色彩# =色组*16 +点值 (0-F), 高字节表明
												; 本点已由(A/B面的)高Pri点输出
%%write_p
	mov [MD_Screen + ebp * 2 + (%1 * 2)], ax	;写入色彩#值 (含高字节)

%%Trans

%endmacro


;****************************************
; 输出Sprite点
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
;  edx = 色组*016
; 参数1 = ebx点阵长字(8点)的点#
; 参数2 = 取出该点值的MASK
; 参数3 = 该点值的右移位数
; 参数4 = PRI
; 参数5 = 1=高亮/阴影

%macro PUTPIXEL_SPRITE 5

	mov eax, ebx			;如该点为0000则是透明,
	and eax, %2
	jz near %%Trans			;不画, 直接返 (注意, 透明点的高字节无 已由其它Sprite输出标志,
							; 其后Sprite可覆盖它)

	;(非0000点)
	mov cl, [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1]	;取该输出点高字节
													;(16=2*8, 跳过前8点, 因Sprite不用调整)
	test cl, (PRIO_B + SPR_B - %4)		;如 已由其它Sprite输出, 或是已由(A/B面的)高Pri点
										;输出而本Sprite点是低PRI, 则不输出本点
	jz short %%Affich					;否则转输出本点

;(不输出本点)
%%Prio
	or ch, cl			;ch跟踪不输出各点时, 其相应原输出点是否含 已由其它Sprite输出标志,
						;如有, 则说明某Sprite的非0点与之前画的某Sprite有冲突, 可用来设置
						;SP_colide (有任何2个sprite的非透明点碰撞)

%if %4 < 1				;如是低PRI的Sprite点不输出, 有可能是被 AB面的高PRI点阻断, 为免被
						;之后的低级别(但高PRI) Sprite覆盖, 
	or byte [MD_Screen + ebp * 2 + (%1 * 2) + 16 + 1], SPR_B	;置 本点已由其它Sprite输出
%endif
	jmp %%Trans			;转返

;(输出本点)

ALIGN4

%%Affich

%if %3 > 0
	shr eax, %3						;将点右移, 得点值 (0-F)
%endif

	cmp dl,0x40
	jb %%cg0_3
	add al,0x80
%%cg0_3


	;(非高亮/阴影时)
	lea eax, [eax + edx + SPR_W]	;色彩# =色组*16 +点值 (0-F), 
									;高字节置 本点已由其它Sprite输出

%if %5 > 0
;(高亮/阴影时)
	;先计算 非特殊色彩# (3E, 3F)的Sprite点覆盖AB面点时, 其高亮/阴影/普通状态
	%if %4 < 1
		and cl, SHAD_B | HIGH_B		;低PRI的Sprite点随AB面的高亮/阴影/普通变化
	%else
		and cl, HIGH_B				;高PRI的Sprite点随AB面的高亮/普通变化 (阴影也算普通)
	%endif

	cmp eax, (0x3E + SPR_W)
	jb short %%Normal
	ja short %%Shadow

;(特殊色彩#3E, 使AB面点高亮, 但本身不显示, 点的高字节也无 已由其它Sprite输出)
%%Highlight
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], HIGH_W
	jmp short %%Trans			;转返
	
;(特殊色彩#3F, 使AB面点阴影, 但本身不显示, 点的高字节也无 已由其它Sprite输出)
%%Shadow
	or word [MD_Screen + ebp * 2 + (%1 * 2) + 16], SHAD_W
	jmp short %%Trans			;转返
;(非特殊色彩#)
%%Normal
	add al, cl						;色组*16 +点值 (0-F), 加上上面计算的高亮/阴影/普通状态

%endif

	mov [MD_Screen + ebp * 2 + (%1 * 2) + 16], ax	;写入色彩# (含高字节)

%%Trans

%endmacro


;****************************************
; 输出A/B面的低PRI T点行 (8点)
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
; 参数1 = 0=B面  1=其它
; 参数2 = 1=高亮/阴影

%macro PUTLINE_P0 2

;是输出B面 T? (只有B面可直接设置Backdrop, A面不可)
%if %1 < 1
;设置本点行(8点)的Backdrop (共8*2=016字节)
	%if %2 > 0
	;阴影时Backdrop (40是阴影的色组0色0) (注意连高字节也一并设置)
		mov dword [MD_Screen + ebp * 2 +  0], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  4], SHAD_D
		mov dword [MD_Screen + ebp * 2 +  8], SHAD_D
		mov dword [MD_Screen + ebp * 2 + 12], SHAD_D
		mov dword [Backdrop_p0], SHAD_D
	%else
	;无阴影时Backdrop (0是色组0色0) (注意连高字节也一并设置)
		mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
		mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
		mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
		mov dword [Backdrop_p0], 0x00000000
	%endif
%endif

	test ebx, ebx			;如本点行均为0000点, 则不用画, 直接返
	jz near %%Full_Trans
	;8个画点操作 (注意ebx读的是长字)
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
; 输出A/B面的低PRI T点行 (8点), X翻转
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
; 参数1 = 0=B面  1=其它
; 参数2 = 1=高亮/阴影

;(同上, 仅8个画点操作有异)

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
	;8个画点操作 (与上相比可见X翻转效果)
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
; 输出A/B面的高PRI T点行 (8点)
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
; 参数1 = 0=B面  1=其它
; 参数2 = 1=高亮/阴影

%macro PUTLINE_P1 2

;(高PRI点无阴影, 所以先进行无阴影或去除阴影处理)

%if %1 < 1
	;B面时, 直接设Backdrop (0是色组0色0) (注意连高字节也一并设置)
	;(是否高亮/阴影在这儿被忽视)
	mov dword [MD_Screen + ebp * 2 +  0], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  4], 0x00000000
	mov dword [MD_Screen + ebp * 2 +  8], 0x00000000
	mov dword [MD_Screen + ebp * 2 + 12], 0x00000000
%else
	%if %2 > 0
	;(A面且高亮/阴影时)
	;(低PRI的B面应该是阴影, 但本A面T是高PRI, 所以相应位置的B面点要先去除阴影)
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

	test ebx, ebx			;如本点行均为0000点, 则不用画, 直接返
	jz near %%Full_Trans
	;8个画点操作 (注意ebx读的是长字)
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
; 输出A/B面的高PRI T点行 (8点), X翻转
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置
; 参数1 = 0=B面  1=其它
; 参数2 = 1=高亮/阴影

;(同上, 仅8个画点操作有异)

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
	;8个画点操作 (与上相比可见X翻转效果)
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
;输出Sprite当前T的点行 (8点)
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置 (纯偏移, 不含扫描行首自身偏移)
; 出口 :
;  ch  = 20 (如有Sprite非0000点冲突)
; 参数1  = PRI
; 参数2 = 1=高亮/阴影

%macro PUTLINE_SPRITE 2

	xor ecx, ecx
	add ebp, [esp]		;ebp +=扫描行首自身偏移 (扫描行# *0336)

	;8个画点操作
	PUTPIXEL_SPRITE 0, 0x000000f0,  4, %1, %2
	PUTPIXEL_SPRITE 1, 0x0000000f,  0, %1, %2
	PUTPIXEL_SPRITE 2, 0x0000f000, 12, %1, %2
	PUTPIXEL_SPRITE 3, 0x00000f00,  8, %1, %2
	PUTPIXEL_SPRITE 4, 0x00f00000, 20, %1, %2
	PUTPIXEL_SPRITE 5, 0x000f0000, 16, %1, %2
	PUTPIXEL_SPRITE 6, 0xf0000000, 28, %1, %2
	PUTPIXEL_SPRITE 7, 0x0f000000, 24, %1, %2

	sub ebp, [esp]		;ebp恢复为纯偏移
	and ch, 0x20				;如有Sprite非0000点冲突,
	or byte [SP_colide], ch	;置SP_colide的 有任何2个sprite的非透明点碰撞

%endmacro


;****************************************
;输出Sprite当前T的点行 (8点), X翻转
; 入口 :
;  ebx = 点阵长字
;  ebp = 当前T输出位置 (纯偏移, 不含扫描行首自身偏移)
; 出口 :
;  ch  = 20 (如有Sprite非0000点冲突)
; 参数1  = PRI
; 参数2 = 1=高亮/阴影

;(同上, 仅8个画点操作有异)

%macro PUTLINE_SPRITE_FLIP 2

	xor ecx, ecx
	add ebp, [esp]

	;8个画点操作 (与上相比可见X翻转效果)
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
;将Genesis的CRam转化为PC格式MD_Palette
; 参数1: 1=高亮/阴影

%macro UPDATE_PALETTE 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; 已处理, 所以清CRam改变标志
	mov cx, 0x7BEF								; 0111 1011 1110 1111 (r4g5b4)
	xor edx, edx								; 每个色彩右移1位, 再与此相"与", 可使每个色彩bgr分量减半(暗)
	mov ebx, (128 / 2) - 1						; ebx = 色彩循环数, 128是色彩总数(8色组)
	jmp short %%Loop							; (除2因每次处理2个色彩)
	
	ALIGN32

	%%Loop										;循环
		mov ax, [CRam + ebx * 4 + 0]					; ax = 当前色彩1
		mov dx, [CRam + ebx * 4 + 2]					; dx = 当前色彩2
		cmp ebx, 0x20
		jb %%cg0_3
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 0], ax	; 色组4-7直接存入目标
		mov [MD_Palette + ebx * 4-0x20*4 + 192 * 2 + 2], dx	; 
		jmp short %%Next_c
	%%cg0_3
		and ax, 0x0FFF									; 色彩字bbb0 ggg0 rrr0
		and dx, 0x0FFF									; 只有12位
		
		mov ax, [Palette + eax * 2]						; 色彩1,2化为PC格式
		mov dx, [Palette + edx * 2]
		mov [MD_Palette + ebx * 4 + 0], ax				; 存入目标
		mov [MD_Palette + ebx * 4 + 2], dx				; 

%if %1 > 0												;如指定Highlight/Shadow
		shr ax, 1
		shr dx, 1
		and ax, cx										; PC色彩1,2化为暗色
		and dx, cx										; 
		mov [MD_Palette + ebx * 4 + 64 * 2 + 0], ax		; 64-127保存暗色
		mov [MD_Palette + ebx * 4 + 64 * 2 + 2], dx		; 
		add ax, cx										; PC暗色彩1,2化为亮色
		add dx, cx
		mov [MD_Palette + ebx * 4 + 128 * 2 + 0], ax	; 128-191保存亮色
		mov [MD_Palette + ebx * 4 + 128 * 2 + 2], dx	; 
%endif

	%%Next_c
		dec ebx										; 循环处理所有64个色彩
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;色组0色0改为背景色寄存器指定色
		and ebx, byte 0x3F					;(即AB面中所有色组0tile的0000点都
		mov ax, [MD_Palette + ebx * 2]		; 显示为此背景色)
		mov [MD_Palette + 0 * 2], ax

%if %1 > 0										;如指定Highlight/Shadow
		shr ax, 1								;改为背景色寄存器指定色的暗, 亮版本
		and ax, cx
		mov [MD_Palette + 0 * 2 + 64 * 2], ax
		add ax, cx
		mov [MD_Palette + 0 * 2 + 128 * 2], ax
%endif

%endmacro

;****************************************
;将Genesis的CRam转化为PC32格式MD_Palette32
; 参数1: 1=高亮/阴影

%macro UPDATE_PALETTE32 1

	xor eax, eax
	mov byte [CRam_Flag], 0						; 已处理, 所以清CRam改变标志
	mov ecx, 0x7f7f7f							; (r7g7b7)
	xor edx, edx								; 每个色彩右移1位, 再与此相"与",可使每个色彩bgr分量减半(暗)
	mov ebx, (128 / 2) - 1						; ebx = 色彩循环数, 128是色彩总数(8色组)(除2因每次处理2个色彩)
	jmp short %%Loop

	ALIGN32

	%%Loop												;循环
		mov ax, [CRam + ebx * 4 + 0]					; ax = 当前色彩1
		mov dx, [CRam + ebx * 4 + 2]					; dx = 当前色彩2
		cmp ebx, 0x20
		jb %%cg0_3
		mov esi, eax									; eax=化为32位格式
		mov edi, eax
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and eax, 0x1F
		shl eax, 3
		or  eax, esi
		or  eax, edi
		mov esi, edx									; edx=化为32位格式
		mov edi, edx
		and esi, 0xf800
		shl esi, 8
		and edi, 0x7e0
		shl edi, 5
		and edx, 0x1F
		shl edx, 3
		or  edx, esi
		or  edx, edi
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 0], eax	; 色组4-7直接存入目标
		mov [MD_Palette32 + ebx * 8-0x20*8 + 192 * 4 + 4], edx	; 
		jmp short %%Next_c
	%%cg0_3
		and eax, 0x0FFF									; 色彩字bbb0 ggg0 rrr0
		and edx, 0x0FFF									; 只有12位
		
		mov eax, [Palette32 + eax * 4]						; 色彩1,2化为PC格式
		mov edx, [Palette32 + edx * 4]
		mov [MD_Palette32 + ebx * 8 + 0], eax				; 存入目标
		mov [MD_Palette32 + ebx * 8 + 4], edx				; 

%if %1 > 0												;如指定Highlight/Shadow
		shr eax, 1
		shr edx, 1
		and eax, ecx										; PC色彩1,2化为暗色
		and edx, ecx										; 
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 0], eax		; 64-127保存暗色
		mov [MD_Palette32 + ebx * 8 + 64 * 4 + 4], edx		; 
		add eax, ecx										; PC暗色彩1,2化为亮色
		add edx, ecx
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 0], eax	; 128-191保存亮色
		mov [MD_Palette32 + ebx * 8 + 128 * 4 + 4], edx	; 
%endif

	%%Next_c
		dec ebx										; 循环处理所有64个色彩
		jns %%Loop							; alors on continue

		mov ebx, [BG_Color]					;色组0色0改为背景色寄存器指定色
		and ebx, byte 0x3F					;(即AB面中所有色组0tile的0000点都
		mov eax, [MD_Palette32 + ebx * 4]		; 显示为此背景色)
		mov [MD_Palette32 + 0 * 4], eax

%if %1 > 0										;如指定Highlight/Shadow
		shr eax, 1								;改为背景色寄存器指定色的暗, 亮版本
		and eax, ecx
		mov [MD_Palette32 + 0 * 4 + 64 * 4], eax
		add eax, ecx
		mov [MD_Palette32 + 0 * 4 + 128 * 4], eax
%endif

%endmacro

;****************************************
; 输出B面 本扫描行
; 参数1 = 0=普通  1=Interlace
; 参数2 = 0=V全屏 1=V2T列
; 参数3 = 1=高亮/阴影

%macro RENDER_LINE_SCROLL_B 3

	mov ebp, [esp]				;ebp指向MD_Screen内本扫描行输出位置 (扫描行# *336)

	GET_X_OFFSET 0				;si<==取B面的本扫描行H卷动值

	mov eax, esi
	xor esi, 0x3FF				;esi =实际H卷动值
	shr esi, 3					;esi = H列(T)
	and eax, byte 7				;eax = H余点
	add ebp, eax				;ebp +=H余点, 通过输出位置调整实现H卷动 (详见MD_Screen)
	mov ebx, esi
	and esi, [H_Scroll_CMask]	;esi 的H列(T) 取模 (超过最大T数则回卷)
	and ebx, byte 1				;ebx =首列奇偶 (1=奇)
								;(注意, 首列位于行输出调整区, 根据卷动值, 8点最多7点可见)
	sub ebx, byte 2				;
	mov [Data_Misc.Cell], ebx	;现输出的T列#初值 = -1 (首列奇)  -2(首列偶)
								;(注意! 当现输出的T列#为负时, 使用首个V卷动量, 
								; 而当现输出的T列#为0时, 也使用首个V卷动量,
								; 最严重时 (首列偶, H余点=7)会有近4个T列都使用首个V卷动量,
								; 所以V2T列卷动不应与H卷动同时使用
								; 这是硬件本身的问题, 已测试Fusion也是这样模拟的)
	mov eax, [H_Cell]
	mov [Data_Misc.X], eax		;temp=行T数 (作为剩余未输出T数)


	mov edi, [VDP_Current_Line]	;edi = 本扫描行#
	mov eax, [VSRam + 2]		;现输出的首个T列使用首个V卷动量

%if %1 > 0
	shr eax, 1					; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax				;扫描行# + 首个V卷动值, 为V位置
	mov eax, edi
	shr edi, 3					;V行(T)
	and edi, [V_Scroll_CMask]	;V行(T)取模 (超过最大T数则回卷)
	and eax, byte 7				;V余点
	mov [Data_Misc.Line_7], eax	;保存V余点

	jmp short %%First_Loop		;转继续 (V卷动已正确, 所以跳过V卷动更新)

	ALIGN32

	;(各T循环)
	%%Loop

%if %2 > 0
		UPDATE_Y_OFFSET 0, %1	;如V2T列卷动, 循环时要判是否更新V卷动
								;(如现输出的T列#为偶, 则取下一个V卷动量, 
								; 并更新edi中的V行(T)及Data_Misc.Line_7的V余点)
%endif

	%%First_Loop

		GET_PATTERN_INFO 0		;ax<==取当前TI

		GET_PATTERN_DATA %1, 0	;ebx<==取当前T内的, 对应本扫描行的那行点阵数据 (长字)
		
		test eax, 0x4000000		;H翻转? (V翻转在取点阵数据时已处理)
		jz near %%No_H_Flip		;非转

	;(H翻转)
	%%H_Flip

			test eax, 0x80000000		;高PRI? 是转
			jnz near %%H_Flip_P1

	;(H翻转, 低PRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 0, %3	;输出B面的低PRI T点行 (8点), X翻转
				jmp %%End_Loop

	ALIGN32

	;(H翻转, 高PRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 0, %3	;输出B面的高PRI T点行 (8点), X翻转
				jmp %%End_Loop

	ALIGN32
	
	;(非H翻转)
	%%No_H_Flip

			test eax, 0x80000000			;高PRI? 是转
			jnz near %%No_H_Flip_P1

	;(非H翻转, 低PRI)
	%%No_H_Flip_P0
				PUTLINE_P0 0, %3		;输出B面的低PRI T点行 (8点)
				jmp %%End_Loop

	ALIGN32

	;(非H翻转, 高PRI)
	%%No_H_Flip_P1
				PUTLINE_P1 0, %3		;输出B面的高PRI T点行 (8点)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;现输出的T列# ++
		inc esi							;esi源++, 下一TI
		and esi, [H_Scroll_CMask]		;取模  (超过最大T数则回卷)
		add ebp, byte 8					;输出位置+=8, 下一T输出位置
		dec byte [Data_Misc.X]			;temp的剩余T数 --
		jns near %%Loop					;非负则循环
										;(注意是非负, 所以比实际T数多1, 这是调整所需的)
		
%%End


%endmacro


;****************************************
; 输出A面/Window 本扫描行
; 参数1 = 0=普通  1=Interlace
; 参数2 = 0=V全屏 1=V2T列
; 参数3 = 1=高亮/阴影

%macro RENDER_LINE_SCROLL_A_WIN 3

	mov ebx, [H_Cell]					;ebx =行T数
	mov cl, [Win_ud]
	shr cl, 7							;cl = 0:上Window  1:下Window
	mov eax, [VDP_Current_Line]
	shr eax, 3							;eax =本扫描行所在T行 (即现T行)
	cmp eax, [Win_Y_Pos]				;如果 现T行>= Window V分界位置
	setae ch							;则 ch <== 1 
	xor cl, ch							;如果是 上Window且 现T行< Window V分界位置
										;	  或下Window且 现T行>= Window V分界位置
	jz near %%Full_Win					;则本扫描行全是Window, 转处理

	;(本扫描行在Window V分界位置外, 由Window H分界位置决定Window横向位置)
	mov edx, [Win_X_Pos]				;edx =Window H分界位置
	test byte [Win_lr], 0x80	;左Window? 是转
	jz short %%Win_Left

;(右Window)
%%Win_Right
	sub ebx, edx
	mov [Data_Misc.Start_W], edx		;Window H始 = H分界位置
	mov [Data_Misc.Lenght_W], ebx		;Window H长 = 行T数 -H分界位置
	dec edx								;
	mov dword [Data_Misc.Start_A], 0	;A面 H始 = 0
	mov [Data_Misc.Lenght_A], edx		;A面 H长 = H分界位置-1 (比实际少1)
	jns short %%Scroll_A				;如H分界位置非0, 则肯定有A面, 转先处理A面
	jmp %%Window						;否则全是Window, 转处理

	ALIGN4

;(左Window)
%%Win_Left
	sub ebx, edx
	mov dword [Data_Misc.Start_W], 0	;Window H始 = 0
	mov [Data_Misc.Lenght_W], edx		;Window H长 = H分界位置
	dec ebx								;
	mov [Data_Misc.Start_A], edx		;A面 H始 = H分界位置
	mov [Data_Misc.Lenght_A], ebx		;A面 H长 = 行T数 -H分界位置-1 (比实际少1)
	jns short %%Scroll_A				;如A面 H长>=0, 则肯定有A面, 转先处理A面
										;(注意A面 H长=0也有A面, 因比实际少1)
	jmp %%Window						;否则全是Window, 转处理

	ALIGN4

;(肯定有A面, 先处理, 再处理Window(如有))
%%Scroll_A
	mov ebp, [esp]					;ebp指向MD_Screen内本扫描行输出位置 (扫描行# *336)

	GET_X_OFFSET 1					;si<==取A面的本扫描行H卷动值

	mov ebx, [Data_Misc.Start_A]	;ebx =A面始T位置 (T)
	mov eax, esi					;
	xor esi, 0x3FF					;esi = 实际H卷动值
	and eax, byte 7					;eax = H余点
	shr esi, 3						;esi = H列T
	mov [Data_Misc.Mask], eax		;
	mov ecx, esi					;
	add esi, ebx					;esi = H列T +A面始T位置, 为考虑卷动后的A面始T源位置
	and esi, [H_Scroll_CMask]		;取模 (超过最大T数则回卷)
	lea eax, [eax + ebx * 8]		;
	add ebp, eax					;ebp += (余点 +始T位置*8), 
									;即H卷动调整后指向始T输出位置
	and ecx, byte 1
	sub ecx, byte 2					;现输出的T列#初值 = -1 (首列奇)  -2(首列偶)
	add ebx, ecx					;始T位置+ 现输出的T列#初值, 作为实际的 现输出的T列#
	mov [Data_Misc.Cell], ebx		;保存(实际的) 现输出的T列#
	mov edi, [VDP_Current_Line]		;edi = 本扫描行#
	jns short %%Not_First_Cell		;如现输出的T列#为负, 则现输出的T属于名字表首T列,

	mov eax, [VSRam + 0]			;则使用首个V卷动量
	jmp short %%First_VScroll_OK

%%Not_First_Cell
	and ebx, [V_Scroll_MMask]		;否则对现输出的T列#取模
									;(V整体时为0, 取模后就只会取V卷动量0, 
									; V2T列时为7E, 取模后为偶数且限定范围)
	mov eax, [VSRam + ebx * 2]		;取得相应V卷动量

;(已取得最初使用的V卷动量)
%%First_VScroll_OK

%if %1 > 0
	shr eax, 1						; on divise le Y scroll par 2 si on est en entrelac�
%endif

	add edi, eax					;扫描行# + 首个V卷动值, 为V位置
	mov eax, edi
	shr edi, 3						;V行(T)
	and edi, [V_Scroll_CMask]		;V行(T)取模 (超过最大T数则回卷)
	and eax, byte 7					;V余点
	mov [Data_Misc.Line_7], eax		;保存V余点

	jmp short %%First_Loop_SCA		;转继续 (V卷动已正确, 所以跳过V卷动更新)

	ALIGN32

;(A面各T循环)
%%Loop_SCA

%if %2 > 0
		UPDATE_Y_OFFSET 1, %1		;如V2T列卷动, 循环时要判是否更新V卷动
									;(如现输出的T列#为偶, 则取下一个V卷动量, 
									; 并更新edi中的V行(T)及Data_Misc.Line_7的V余点)
%endif

%%First_Loop_SCA
	;call _hook


		GET_PATTERN_INFO 1			;ax<==取当前TI
		GET_PATTERN_DATA %1, 0		;ebx<==取当前T内的, 对应本扫描行的那行点阵数据 (长字)
		
		test eax, 0x4000000			;H翻转? (V翻转在取点阵数据时已处理)
		jz near %%No_H_Flip			;非转

	;(H翻转)
	%%H_Flip
			test eax, 0x80000000	;高PRI? 是转
			jnz near %%H_Flip_P1

	;(H翻转, 低PRI)
	%%H_Flip_P0
				PUTLINE_FLIP_P0 1, %3	;输出A面的低PRI T点行 (8点), X翻转
				jmp %%End_Loop

	ALIGN32

	;(H翻转, 高PRI)
	%%H_Flip_P1
				PUTLINE_FLIP_P1 1, %3	;输出A面的高PRI T点行 (8点), X翻转
				jmp %%End_Loop

	ALIGN32
	
	;(非H翻转)
	%%No_H_Flip
			test eax, 0x80000000		;高PRI? 是转
			jnz near %%No_H_Flip_P1

	;(非H翻转, 低PRI)
	%%No_H_Flip_P0
				PUTLINE_P0 1, %3		;输出A面的低PRI T点行 (8点)
				jmp %%End_Loop

	ALIGN32

	;(非H翻转, 高PRI)
	%%No_H_Flip_P1
				PUTLINE_P1 1, %3		;输出A面的高PRI T点行 (8点)
				jmp short %%End_Loop

	ALIGN32

	%%End_Loop
		inc dword [Data_Misc.Cell]		;现输出的T列# --
		inc esi							;esi源++, 下一TI
		and esi, [H_Scroll_CMask]		;取模  (超过最大T数则回卷)
		add ebp, byte 8					;输出位置+8, 下一T输出位置
		dec byte [Data_Misc.Lenght_A]	;A面剩余长度--
		jns near %%Loop_SCA				;非负则循环 (因为是非负, 所以少的1被补上)


;(因输出时的H卷动调整, A面最后可能少8至1点, 要补上)
;(比如H余点为0, 则输出的A面首个T被完全跳过(因完全在前调整区), 要补8点
; H余点为1, 则输出的A面首个T被跳过7点, 要补7点
; ...H余点为7, 则输出的A面首个T被跳过1点, 要补1点)
;(之所以这样处理, 是因为输出区对应 A面最后 的地方不是后调整区, 而可能是Window输出部分)
%%LC_SCA

%if %2 > 0
	UPDATE_Y_OFFSET 1, %1				;如V2T列卷动, 要判是否更新V卷动
%endif

	GET_PATTERN_INFO 1					;ax<==取最后要补的TI
	GET_PATTERN_DATA %1, 0				;ebx<==该T内的, 对应本扫描行的那行点阵数据 (长字)

	mov ecx, [Data_Misc.Mask]			;取H余点
	test eax, 0x4000000					;H翻转? (V翻转在取点阵数据时已处理)
	jz near %%LC_SCA_No_H_Flip			;非转

	;(H翻转)
	%%LC_SCA_H_Flip
		and ebx, [Mask_F + ecx * 4]		;ebx<==根据H余点保留要补点, 其余清0 (0点对Window无害)
		test eax, 0x80000000			;高PRI? 是转
		jnz near %%LC_SCA_H_Flip_P1

	;(H翻转, 低PRI)
	%%LC_SCA_H_Flip_P0
			PUTLINE_FLIP_P0 1, %3		;输出A面的低PRI T点行 (8点), X翻转
			jmp %%LC_SCA_End

	ALIGN32

	;(H翻转, 高PRI)
	%%LC_SCA_H_Flip_P1
			PUTLINE_FLIP_P1 1, %3		;输出A面的高PRI T点行 (8点), X翻转
			jmp %%LC_SCA_End

	ALIGN32
	
	;(非H翻转)
	%%LC_SCA_No_H_Flip
		and ebx, [Mask_N + ecx * 4]		;ebx<==根据H余点保留要补点, 其余清0 (0点对Window无害)
		test eax, 0x80000000			;高PRI? 是转
		jnz near %%LC_SCA_No_H_Flip_P1

	;(非H翻转, 低PRI)
	%%LC_SCA_No_H_Flip_P0
			PUTLINE_P0 1, %3			;输出A面的低PRI T点行 (8点)
			jmp %%LC_SCA_End

	ALIGN32

	;(非H翻转, 高PRI)
	%%LC_SCA_No_H_Flip_P1
			PUTLINE_P1 1, %3			;输出A面的高PRI T点行 (8点)
			jmp short %%LC_SCA_End

	ALIGN32

;(补点结束)
%%LC_SCA_End
	test byte [Data_Misc.Lenght_W], 0xFF	;有Window H长?
	jnz short %%Window						;是, 转Window处理
	jmp %%End								;否, 则无Window, 转结束





	ALIGN4

;(本扫描行全是Window时)
%%Full_Win
	xor esi, esi							;esi =Window H始 (T) =0
	mov edi, ebx							;edi =Window H长 (T) =行T数
	jmp short %%Window_Initialised			;转继续

	ALIGN4

;(本扫描行部分是Window时)
%%Window
	mov esi, [Data_Misc.Start_W]			;esi =Window H始 (T)
	mov edi, [Data_Misc.Lenght_W]			;edi =Window H长 (T)

%%Window_Initialised
	mov ebp, [esp]							;ebp指向本扫描行输出位置 (扫描行# *336)
	lea ebp, [ebp + esi * 8 + 8]			;ebp指向Window首T输出位置 (+8因无需调整)
	mov edx, [VDP_Current_Line]				;
	mov ebx, edx							;
	shr edx, 3								;edx = 本扫描行所在T行#
	mov cl, [H_Win_Mul]
	shl edx, cl								;edx = 本扫描行所在T行# * Window名字表行T数
											;即 所在T行在Window名字表内的偏移(T)
	mov eax, Window
	lea eax, [eax + edx * 4]				;eax 指向Window名字表内所在T行行首
	mov [Data_Misc.Pattern_Adr], eax		;暂存
	and ebx, byte 7							;ebx = 本扫描行对应的V余点
	mov [Data_Misc.Line_7], ebx				;暂存
	jmp short %%Loop_Win					;转循环

	ALIGN32

%%Loop_Win
		mov ebx, [Data_Misc.Pattern_Adr]	;取本扫描行所在T行在Window名字表内的偏移(T)
		mov eax, [ebx + esi * 4]			; + 当前T位置*4, 就能取出当前TI

		GET_PATTERN_DATA %1, 1				;取当前T内的, 对应本扫描行的那行点阵数据(长字)

		test eax, 0x4000000					;H翻转?
		jz near %%W_No_H_Flip				;非转

	;(H翻转)
	%%W_H_Flip
			test eax, 0x80000000			;高PRI? 是转
			jnz near %%W_H_Flip_P1

	;(H翻转, 低PRI)
	%%W_H_Flip_P0
				PUTLINE_FLIP_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(H翻转, 高PRI)
	%%W_H_Flip_P1
				PUTLINE_FLIP_P1 2, %3
				jmp %%End_Loop_Win

	ALIGN32
	
	;(非H翻转)
	%%W_No_H_Flip
			test eax, 0x80000000				;高PRI? 是转
			jnz near %%W_No_H_Flip_P1

	;(非H翻转, 低PRI)
	%%W_No_H_Flip_P0
				PUTLINE_P0 2, %3
				jmp %%End_Loop_Win

	ALIGN32

	;(非H翻转, 高PRI)
	%%W_No_H_Flip_P1
				PUTLINE_P1 2, %3
				jmp short %%End_Loop_Win

	ALIGN32

	%%End_Loop_Win
		inc esi						;esi源++, 下一Window T
		add ebp, byte 8				;ebp +=8, 下一T输出位置
		dec edi						;剩余H长 --
		jnz near %%Loop_Win			;非0则循环

%%End


%endmacro


;****************************************
; 输出所有本扫描行可见的所有Sprite的点行
; 参数1 = 0=普通  1=Interlace
; 参数2 = 1=高亮/阴影

%macro RENDER_LINE_SPR 2

	UPDATE_MASK_SPRITE			;扫描Sprite_Struct表各项, 将本扫描行含有且可见的
								;各Sprite的项偏移保存到Sprite_Visible区, 并处理Sprite屏蔽
								;(注意: edx =本扫描行#)
	xor edi, edi				;edi为Sprite_Visible区读指针
	mov dword [Data_Misc.X], edi;暂存
	test esi, esi				;如本扫描行上没有可见的Sprite
	jnz short %%First_Loop
	jmp %%End					;则直接结束

;(有可见的Sprite)
	ALIGN32

%%Sprite_Loop
		mov edx, [VDP_Current_Line]				;edx =本扫描行#
%%First_Loop
		mov edi, [Sprite_Visible + edi]			;取当前可见Sprite的Sprite_Struct项偏移
		mov eax, [Sprite_Struct + edi + 24]		;eax =首TI
		mov esi, eax							;esi =首TI
		mov ebx, eax							;ebx =首TI
		shr bx, 9								;
		and ebx, 0x30							;ebx =色组*016
		or ebx,[Sprite_Struct + edi + 28]
		mov [Data_Misc.Palette], ebx			;保存
		and esi, 0x7FF							;esi = T#
		sub edx, [Sprite_Struct + edi + 4]		;edx = 本扫描行# - SP Y显示坐标 (Y偏移)
		mov ecx, edx							;
		and edx, 0xF8							;edx = Y偏移(T) *8
		and ecx, byte 7							;ecx = Y余点
		mov ebx, [Sprite_Struct + edi + 12]		;ebx = Y尺寸-1
%if %1 > 0
		shl ebx, 6								;ebx = (Y尺寸-1) * 64
		lea edx, [edx * 8]						;edx = Y偏移(T) * 64
		shl esi, 6								;esi = (VRAM中的)首T偏移
%else
		shl ebx, 5								;ebx = (Y尺寸-1) * 32
		lea edx, [edx * 4]						;edx = Y偏移(T) * 32
		shl esi, 5								;esi = (VRAM中的)首T偏移
%endif

		test eax, 0x1000						;SP V翻转
		jz %%No_V_Flip							;非转

	;(V翻转)
	%%V_Flip
		xor ecx, 7								;ecx = Y余点 异或 7 (0-7变为7-0)
		sub ebx, edx							;(V翻转时只需调整esi源指针)
		add esi, ebx							;esi = VRAM中的首T偏移 +(Y尺寸-1) * 32(64)
												;	   - Y偏移(T) * 32(64)
												;(观察Y偏移(T) 从0-3时, 
												; esi指向Y末T, Y末T-1...Y末T-3的点阵首
												; 所以正确)
%if %1 > 0
		lea ebx, [ebx + edx + 64]				;ebx恢复原值, 再加64, 即ebx =Y尺寸* 64
												;即ebx为SP X相邻T之间的数据间距
		lea esi, [esi + ecx * 8]				;esi指向SP首T列中的本扫描行对应的T内点行
		jmp short %%Suite
%else
		lea ebx, [ebx + edx + 32]				;ebx恢复原值, 再加32, 即ebx =Y尺寸* 32
												;即ebx为SP X相邻T之间的数据间距
		lea esi, [esi + ecx * 4]				;esi指向SP首T列中的本扫描行对应的T内点行
		jmp short %%Suite
%endif

	ALIGN4
	
	;(非V翻转)
	%%No_V_Flip
		add esi, edx							;esi指向SP首T列中的本扫描行对应的T
%if %1 > 0
		add ebx, byte 64						;ebx=Y尺寸*64, 即为SP X相邻T之间的数据间距
		lea esi, [esi + ecx * 8]				;esi指向SP首T列中的本扫描行对应的T内点行
%else			
		add ebx, byte 32						;ebx=Y尺寸*32, 即为SP X相邻T之间的数据间距
		lea esi, [esi + ecx * 4]				;esi指向SP首T列中的本扫描行对应的T内点行
%endif

	%%Suite
		mov [Data_Misc.Next_Cell], ebx			;保存SP X相邻T之间的数据间距
		mov edx, [Data_Misc.Palette]			;edx = 色组*016

		test eax, 0x800							;H翻转? 非转
		jz near %%No_H_Flip

	;(H翻转)
	;(H翻转时, esi源不改变, 而将ebp输出位置及输出次序改变
	; ebp从SP最右T的输出位置起, 倒序输出各T)
	%%H_Flip
		mov ebx, [Sprite_Struct + edi + 0]		;ebx =SP X显示坐标
		mov ebp, [Sprite_Struct + edi + 16]		;ebp =SP 右极限(含)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP X相邻T之间的数据间距
		cmp ebx, -7								;(设置SP 输出位置左右极限)
		jg short %%Spr_X_Min_Norm
		mov ebx, -7								;如X显示坐标<-7, 则左极限 = -7
												;(因是倒次序输出, ebp一旦<-7就可停止输出)
												;(之所以-7, 是因为-7处输出的T仍能看到1点
												; -7以左的位置, 输出T也不可见)
	%%Spr_X_Min_Norm
		mov [Data_Spr.H_Min], ebx				;否则左极限 = X显示坐标 (含)

	;(输出位置左极限OK)
	%%Spr_X_Min_OK								;(SP 输出位置右极限直接设置到ebp)
		sub ebp, byte 7							;ebp初始位置 = 最右T输出位置 (与esi源对应)
												;(减7实为减8, 因SP右极限包含在SP范围内,
												; 即SP右极限 =X显示坐标 +X尺寸*8 -1)
		jmp short %%Spr_Test_X_Max				;转ebp输出右极限合法判断及调整

	ALIGN4

	%%Spr_Test_X_Max_Loop
			sub ebp, byte 8						;ebp -=8, 左前一T输出位置
			add esi, edi						;esi源 指向X向下一T(点行)数据位置

	%%Spr_Test_X_Max
			cmp ebp, [H_Pix]					;如 ebp>=行点数, 则非法, 转调整循环
												;(因输出了也看不见)
												;(不用担心调整过头, 因本SP肯定可见)
			jge %%Spr_Test_X_Max_Loop
	;(ebp输出位置合法)
		test eax, 0x8000						;高PRI? 是转
		jnz near %%H_Flip_P1
		jmp short %%H_Flip_P0

	ALIGN32
	
	;(H翻转, 低PRI)
	%%H_Flip_P0
	%%H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SP当前T列的点阵长字
			PUTLINE_SPRITE_FLIP 0, %2				;输出SP当前T的点行 (8点), X翻转, 低PRI

			sub ebp, byte 8							;ebp输出位置 -=8, 左前一T输出位置
			add esi, edi							;esi源 指向X向下一T(点行)数据位置
			cmp ebp, [Data_Spr.H_Min]				;ebp输出位置已超越左极限?
			jge near %%H_Flip_P0_Loop				;否, 则循环输出下一T(的点行)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(H翻转, 高PRI)									;同上, 但是高PRI
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
	
	;(非H翻转)
	;(非H翻转时, ebp从最左T的输出位置起, 顺序输出各T)
	%%No_H_Flip
		mov ebx, [Sprite_Struct + edi + 16]		;ebx =SP 右极限(含)
		mov ecx, [H_Pix]
		mov ebp, [Sprite_Struct + edi + 0]		;ebp =SP X显示坐标 (作为输出位置)
		mov edi, [Data_Misc.Next_Cell]			;edi =SP X相邻T之间的数据间距
												;(设置SP 输出位置左右极限)
		cmp ebx, ecx							;如SP 右极限(含) >=行点数,
		jl %%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ecx				;则输出右极限 =行点数
		jmp short %%Spr_Test_X_Min

	ALIGN4

	%%Spr_X_Max_Norm
		mov [Data_Spr.H_Max], ebx				;否则输出右极限 =SP 右极限(含)
												;(SP 输出位置右极限OK)
												;(SP 输出位置左极限直接设置到ebp)
		jmp short %%Spr_Test_X_Min				;转ebp输出左极限合法判断及调整

	ALIGN4

	%%Spr_Test_X_Min_Loop
			add ebp, byte 8						;ebp +=8, X向下一T输出位置
			add esi, edi						;esi源 指向X向下一T(点行)数据位置

	%%Spr_Test_X_Min
			cmp ebp, -7							;如 ebp<-7, 则非法, 转调整循环
			jl %%Spr_Test_X_Min_Loop

		test ax, 0x8000							;高PRI? 是转
		jnz near %%No_H_Flip_P1
		jmp short %%No_H_Flip_P0

	ALIGN32
	
	;(非H翻转, 低PRI)
	%%No_H_Flip_P0
	%%No_H_Flip_P0_Loop
			mov ebx, [VRam + esi]					;ebx = SP当前T列的点阵长字
			PUTLINE_SPRITE 0, %2					;输出SP当前T的点行 (8点), 低PRI

			add ebp, byte 8							;ebp输出位置 +=8, 下一T输出位置
			add esi, edi							;esi源 指向X向下一T(点行)数据位置
			cmp ebp, [Data_Spr.H_Max]				;ebp输出位置以达到右极限?
			jl near %%No_H_Flip_P0_Loop				;否, 则循环输出下一T(的点行)
		jmp %%End_Sprite_Loop

	ALIGN32
	
	;(非H翻转, 高PRI)								;同上, 但是高PRI
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
	
	;(当前SP输出结束, 下一SP)
	%%End_Sprite_Loop
		mov edi, [Data_Misc.X]						;edi =Sprite_Visible区读指针
		add edi, byte 4								;edi +=4, 下一Sprite_Visible区项
		mov [Data_Misc.X], edi						;更新
		cmp edi, [Data_Misc.Borne]					;已达Sprite_Visible区尾?
		jb near %%Sprite_Loop						;否, 则循环输出下一SP

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
		test byte [CRam_Flag], 1		; CRam改变? (要更新MD_Palette?)
		jz near .Palette_OK				; 否, 则无需处理, 跳过

		cmp dword [Crt_BPP], 32
		je near .Palette32
		test byte [STE_state], 8
		jnz near .Palette_HS

		UPDATE_PALETTE 0				;将Genesis的CRam转化为PC格式, 无亮暗
		jmp .Palette_OK

	ALIGN4
	.Palette_HS
		UPDATE_PALETTE 1				;将Genesis的CRam转化为PC格式, 有亮暗
		jmp .Palette_OK

	ALIGN4
	.Palette32
		test byte [STE_state], 8
		jnz near .Palette32_HS
		UPDATE_PALETTE32 0				;将Genesis的CRam转化为PC格式, 无亮暗
		jmp .Palette_OK
	.Palette32_HS
		UPDATE_PALETTE32 1				;将Genesis的CRam转化为PC格式, 有亮暗

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
