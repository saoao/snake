#include <windows.h>
#include <stdio.h>  
#include <ddraw.h>
#include "graphics.h"
#include "globals.h"

static LPDIRECTDRAW lpDD_Init;
static LPDIRECTDRAW4 lpDD;
static LPDIRECTDRAWSURFACE4 lpDDS_Primary;
static LPDIRECTDRAWSURFACE4 lpDDS_Flip;
static LPDIRECTDRAWSURFACE4 lpDDS_Back;
static LPDIRECTDRAWCLIPPER lpDDC_Clipper;

int Flag_Clr_Scr = 0;

HRESULT RestoreGraphics();
int Clear_Primary_Screen(HWND hWnd);
int Clear_Back_Screen(HWND hWnd);

//�ͷ�DD����, DD��ҳ�漰��ҳ��(ȫ��VSync), �ü���(����ʱ), ������ҳ��
void End_DDraw(){
	if (lpDDC_Clipper){
		lpDDC_Clipper->Release();
		lpDDC_Clipper = NULL;
	}

	if (lpDDS_Back){
		lpDDS_Back->Release();
		lpDDS_Back = NULL;
	}

	if (lpDDS_Flip)
	{
		lpDDS_Flip->Release();
		lpDDS_Flip = NULL;
	}

	if (lpDDS_Primary){
		lpDDS_Primary->Release();
		lpDDS_Primary = NULL;
	}

	if (lpDD){
		lpDD->SetCooperativeLevel(g_hwnd, DDSCL_NORMAL);
		lpDD->Release();
		lpDD = NULL;
	}
}

//DD��ʼ��
//(����DD����, DD��ҳ�漰��ҳ��(ȫ��VSync), �ü���(����ʱ), ������ҳ��)
//����: 0=ʧ��  ��0=�ɹ�
int Init_DDraw(HWND hWnd){
	HRESULT rval;
	DDSURFACEDESC2 ddsd;

	End_DDraw();
	
	//������ʱDD����
	if (DirectDrawCreate(NULL, &lpDD_Init, NULL) != DD_OK)
		return 0;

	//DD����ʹ��DirectDraw4
	if (lpDD_Init->QueryInterface(IID_IDirectDraw4, (LPVOID *) &lpDD) != DD_OK)
		return 0;

	//��ʱDD�����ͷ�
	lpDD_Init->Release();
	lpDD_Init = NULL;

	rval = lpDD->SetCooperativeLevel(hWnd, DDSCL_NORMAL);

	if (rval != DD_OK)
		return 0;

	//����DD��ҳ��
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);

	ddsd.dwFlags = DDSD_CAPS;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

	if (lpDD->CreateSurface(&ddsd, &lpDDS_Primary, NULL ) != DD_OK)
		return 0;

	//�轨���ü���lpDDC_Clipper, �����õ���ҳ��
	if (lpDD->CreateClipper(0, &lpDDC_Clipper, NULL ) != DD_OK)
		return 0;

	if (lpDDC_Clipper->SetHWnd(0, hWnd) != DD_OK)
		return 0;

	if (lpDDS_Primary->SetClipper(lpDDC_Clipper) != DD_OK)
		return 0;

	//��������ҳ��lpDDS_Back
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH;

	ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_SYSTEMMEMORY;
	ddsd.dwWidth = 336;
	ddsd.dwHeight = 240;

	if (lpDD->CreateSurface(&ddsd, &lpDDS_Back, NULL) != DD_OK)
		return 0;

	//����ҳ���������
	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);

	if (lpDDS_Back->GetSurfaceDesc(&ddsd) != DD_OK)
		return 0;

	ddsd.dwFlags = DDSD_WIDTH | DDSD_HEIGHT | DDSD_PITCH | DDSD_LPSURFACE;
	ddsd.dwWidth = 336;
	ddsd.dwHeight = 240;
	if (Crt_BPP==16){
		ddsd.lPitch = 336 * 2;
		ddsd.lpSurface = &MD_Screen[0];
	}else{
		ddsd.lPitch = 336 * 4;
		ddsd.lpSurface = &MD_Screen32[0];
	}

	if (lpDDS_Back->SetSurfaceDesc(&ddsd, 0) != DD_OK)
		return 0;

	return 1;
}

//DDȫ����ʼ��
//����: 0=ʧ��  ��0=�ɹ�
int Init_DDraw_FS(HWND hWnd){
	HRESULT rval;
	DDSURFACEDESC2 ddsd;

	End_DDraw();
	
	//������ʱDD����
	if (DirectDrawCreate(NULL, &lpDD_Init, NULL) != DD_OK)
		return 0;

	//DD����ʹ��DirectDraw4
	if (lpDD_Init->QueryInterface(IID_IDirectDraw4, (LPVOID *) &lpDD) != DD_OK)
		return 0;

	//��ʱDD�����ͷ�
	lpDD_Init->Release();
	lpDD_Init = NULL;

	rval = lpDD->SetCooperativeLevel(hWnd, DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
	if (rval != DD_OK)
		return 0;

	if (lpDD->SetDisplayMode(640, 480, 16, 0, 0) != DD_OK)
		return 0;

	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
	ddsd.dwBackBufferCount = 2;
	if (lpDD->CreateSurface(&ddsd, &lpDDS_Primary, NULL ) != DD_OK)
		return 0;

	ddsd.ddsCaps.dwCaps = DDSCAPS_BACKBUFFER;
	if (lpDDS_Primary->GetAttachedSurface(&ddsd.ddsCaps, &lpDDS_Flip) != DD_OK)
		return 0;

	memset(&ddsd, 0, sizeof(ddsd));
	ddsd.dwSize = sizeof(ddsd);
	ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH;
	if(!use_sai){
		ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_SYSTEMMEMORY;
		ddsd.dwWidth = 336;
		ddsd.dwHeight = 240;
	}else{
		ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_VIDEOMEMORY;
		ddsd.dwWidth = 640;
		ddsd.dwHeight = 480;
	}
	if (lpDD->CreateSurface(&ddsd, &lpDDS_Back, NULL) != DD_OK)
		return 0;
	if (!use_sai){
		memset(&ddsd, 0, sizeof(ddsd));
		ddsd.dwSize = sizeof(ddsd);
		if (lpDDS_Back->GetSurfaceDesc(&ddsd) != DD_OK)
			return 0;
		ddsd.dwFlags = DDSD_WIDTH | DDSD_HEIGHT | DDSD_PITCH | DDSD_LPSURFACE;
		ddsd.dwWidth = 336;
		ddsd.dwHeight = 240;
		ddsd.lPitch = 336 * 2;
		ddsd.lpSurface = &MD_Screen[0];
		if (lpDDS_Back->SetSurfaceDesc(&ddsd, 0) != DD_OK)
			return 0;
	}

	return 1;
}

//�ָ�DD��ҳ�漰����ҳ��
HRESULT RestoreGraphics(){
	HRESULT rval;

	rval = lpDDS_Primary->Restore();
	rval = lpDDS_Back->Restore();
	//Clear_Primary_Screen(g_hwnd);
	//Clear_Back_Screen(g_hwnd);

	return rval;
}

//���� (����ҳ��(��2����ҳ��))
int Clear_Primary_Screen(HWND hWnd){
	DDBLTFX ddbltfx;	//����blt
	RECT RD;
	POINT p;

	memset(&ddbltfx, 0, sizeof(ddbltfx));
	ddbltfx.dwSize = sizeof(ddbltfx);
	ddbltfx.dwFillColor = 0; //���ɫ=��

	if (fullscreen){
		lpDDS_Flip->Blt(NULL, NULL, NULL, DDBLT_WAIT | DDBLT_COLORFILL, &ddbltfx);
		lpDDS_Primary->Flip(NULL, DDFLIP_WAIT);

		lpDDS_Flip->Blt(NULL, NULL, NULL, DDBLT_WAIT | DDBLT_COLORFILL, &ddbltfx);
		lpDDS_Primary->Flip(NULL, DDFLIP_WAIT);

		lpDDS_Flip->Blt(NULL, NULL, NULL, DDBLT_WAIT | DDBLT_COLORFILL, &ddbltfx);
		lpDDS_Primary->Flip(NULL, DDFLIP_WAIT);
	}else{
		//����䷽ʽ��bltʵ������
		p.x = p.y = 0;
		GetClientRect(hWnd, &RD);
		ClientToScreen(hWnd, &p);

		RD.left = p.x;
		RD.top = p.y;
		RD.right += p.x;
		RD.bottom += p.y;

		if (RD.top < RD.bottom)
			lpDDS_Primary->Blt(&RD, NULL, NULL, DDBLT_WAIT | DDBLT_COLORFILL, &ddbltfx);
	}

	return 1;
}

//������ҳ��
int Clear_Back_Screen(HWND hWnd){
	DDBLTFX ddbltfx;

	memset(&ddbltfx, 0, sizeof(ddbltfx));
	ddbltfx.dwSize = sizeof(ddbltfx);
	ddbltfx.dwFillColor = 0;

	lpDDS_Back->Blt(NULL, NULL, NULL, DDBLT_WAIT | DDBLT_COLORFILL, &ddbltfx);

	return 1;
}

int Flip(HWND hWnd){
	HRESULT rval;
	RECT RectDest, RectSrc;
	POINT p;
	int Dep;
	DDSURFACEDESC2 ddsd;

	ddsd.dwSize = sizeof(ddsd);

	if (fullscreen){
		if (H_Cell==40){
			if (Flag_Clr_Scr != 40){
				Clear_Primary_Screen(hWnd);
				Clear_Back_Screen(hWnd);
				Flag_Clr_Scr = 40;
			}

			Dep = 0;
			RectSrc.left = 0 + 8;
			RectSrc.right = 320 + 8;
			RectDest.left = 0;
			RectDest.right = 640;
		}else{
			if (Flag_Clr_Scr != 32){
				Clear_Primary_Screen(hWnd);
				Clear_Back_Screen(hWnd);
				Flag_Clr_Scr = 32;
			}

			Dep = 64;
			RectSrc.left = 0 + 8;
			RectSrc.right = 256 + 8;
			RectDest.left = 64;
			RectDest.right = 576;
		}

		RectSrc.top = 0;
		RectSrc.bottom = SCREEN_H;

		if (SCREEN_H == 224)
		{
			RectDest.top = 16;
			RectDest.bottom = 464;
		}
		else
		{
			RectDest.top = 0;
			RectDest.bottom = 480;
		}

		if (!use_sai){
			rval=lpDDS_Flip->Blt(&RectDest, lpDDS_Back, &RectSrc, DDBLT_WAIT | DDBLT_ASYNC, NULL);
			if (rval == DDERR_SURFACELOST) rval = RestoreGraphics();
			lpDDS_Primary->Flip(NULL, DDFLIP_WAIT);
		}else{
			rval = lpDDS_Flip->Lock(NULL, &ddsd, DDLOCK_WAIT, NULL);

			if (rval != DD_OK){
				return 1;
			}

			Blit_2xSAI_MMX((unsigned char *) ddsd.lpSurface + ((ddsd.lPitch * ((240 - SCREEN_H) >> 1) + Dep) << 1), ddsd.lPitch, 320 - Dep, SCREEN_H, 32 + Dep * 2);

			lpDDS_Flip->Unlock(NULL);

			lpDDS_Primary->Flip(NULL, DDFLIP_WAIT);
		}
	}//if (fullscreen)
	else{
		p.x = p.y = 0;
		GetClientRect(hWnd, &RectDest);
		ClientToScreen(hWnd, &p);

		RectDest.left = p.x;
		RectDest.top = p.y;
		RectDest.right += p.x;
		RectDest.bottom += p.y;

		RectSrc.top = 0;
		RectSrc.bottom = SCREEN_H;

		if (SCREEN_H == 224){
			RectDest.top += 8;
			RectDest.bottom -= 8;
		}

		if (H_Cell==40){
			if (Flag_Clr_Scr != 40)
			{
				Clear_Primary_Screen(hWnd);
				Clear_Back_Screen(hWnd);
				Flag_Clr_Scr = 40;
			}

			RectSrc.left = 8 + 0 ;
			RectSrc.right = 8 + 320;
		}
		else{
			RectDest.left += 32;
			RectDest.right -= 32;

			if (Flag_Clr_Scr != 32)
			{
				Flag_Clr_Scr = 32;
				Clear_Primary_Screen(hWnd);
				Clear_Back_Screen(hWnd);
			}

			RectSrc.left = 8 + 0;
			RectSrc.right = 8 + 256;
		}

		int vb;
		lpDD->GetVerticalBlankStatus(&vb);
		if (!vb) lpDD->WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);

		rval = lpDDS_Primary->Blt(&RectDest, lpDDS_Back, &RectSrc, DDBLT_WAIT | DDBLT_ASYNC, NULL);
		if (rval == DDERR_SURFACELOST) rval = RestoreGraphics();
	}


	return 1;
}