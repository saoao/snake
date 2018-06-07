#define DIRECTINPUT_VERSION 0x0500  // for joystick support
#include <dinput.h>
#include <stdio.h>  
#include "globals.h"

#define KEYDOWN(key) (Keys[key] & 0x80) 
#define MAX_JOYS 8

static LPDIRECTINPUT lpDI;
static LPDIRECTINPUTDEVICE lpDIDKeyboard;
static LPDIRECTINPUTDEVICE lpDIDMouse;
char Phrase[1024];
int Nb_Joys = 0;
static IDirectInputDevice2 *Joy_ID[MAX_JOYS] = {NULL};
static DIJOYSTATE Joy_State[MAX_JOYS] = {{0}};
long MouseX, MouseY;
unsigned char Keys[256];

int P1_Keys;
int P1_Triggers;

//(最多)8个用户的手柄记键定义数组
//(前2个即1P,2P有默任定义)
struct K_Def Keys_Def[8] = {
	/*
	{4120, 4121,
	4119, 4114, 4115,
	4118, 4113, 4112,
	4124, 4126, 4125, 4127},
	*/
	{DIK_RETURN, DIK_RSHIFT,
	DIK_A, DIK_S, DIK_D,
	DIK_Z, DIK_X, DIK_C,
	DIK_UP, DIK_DOWN, DIK_LEFT, DIK_RIGHT},
	{DIK_RETURN, DIK_RSHIFT,
	DIK_A, DIK_S, DIK_D,
	DIK_Z, DIK_X, DIK_C,
	DIK_UP, DIK_DOWN, DIK_LEFT, DIK_RIGHT}
};


//释放键盘及各手柄设备对象, 及DirectInput对象本身
//
void End_Input(){
	int i;
	
	if (lpDI){
		if(lpDIDMouse){
			lpDIDMouse->Release();
			lpDIDMouse = NULL;
		}

		if(lpDIDKeyboard){
			lpDIDKeyboard->Release();
			lpDIDKeyboard = NULL;
		}

		for(i = 0; i < MAX_JOYS; i++){
			if (Joy_ID[i]){
				Joy_ID[i]->Unacquire();
				Joy_ID[i]->Release();
			}
		}

		Nb_Joys = 0;
		lpDI->Release();
		lpDI = NULL;
	}
}

//手柄枚举回调
//创建本次找到的手柄设备, 设置其数据格式, 协作等级, XY范围, 并加入手柄设备数组
BOOL CALLBACK InitJoystick(LPCDIDEVICEINSTANCE lpDIIJoy, LPVOID pvRef){
	HRESULT rval;
	LPDIRECTINPUTDEVICE	lpDIJoy;
	DIPROPRANGE diprg;
	int i;
 
	if (Nb_Joys >= MAX_JOYS) return(DIENUM_STOP);
		
	Joy_ID[Nb_Joys] = NULL;

	rval = lpDI->CreateDevice(lpDIIJoy->guidInstance, &lpDIJoy, NULL);
	if (rval != DI_OK){
		MessageBox(NULL, "IDirectInput::CreateDevice FAILED", "erreur joystick", MB_OK);
		return(DIENUM_CONTINUE);
	}

	rval = lpDIJoy->QueryInterface(IID_IDirectInputDevice2, (void **)&Joy_ID[Nb_Joys]);
	lpDIJoy->Release();
	if (rval != DI_OK){
		MessageBox(NULL, "IDirectInputDevice2::QueryInterface FAILED", "erreur joystick", MB_OK);
	    Joy_ID[Nb_Joys] = NULL;
	    return(DIENUM_CONTINUE);
	}

	rval = Joy_ID[Nb_Joys]->SetDataFormat(&c_dfDIJoystick);
	if (rval != DI_OK){
		MessageBox(NULL, "IDirectInputDevice::SetDataFormat FAILED", "erreur joystick", MB_OK);
		Joy_ID[Nb_Joys]->Release();
		Joy_ID[Nb_Joys] = NULL;
		return(DIENUM_CONTINUE);
	}

	rval = Joy_ID[Nb_Joys]->SetCooperativeLevel((HWND)pvRef, DISCL_NONEXCLUSIVE | DISCL_FOREGROUND);

	if (rval != DI_OK){ 
		MessageBox(NULL, "IDirectInputDevice::SetCooperativeLevel FAILED", "erreur joystick", MB_OK);
		Joy_ID[Nb_Joys]->Release();
		Joy_ID[Nb_Joys] = NULL;
		return(DIENUM_CONTINUE);
	}
 
	diprg.diph.dwSize = sizeof(diprg); 
	diprg.diph.dwHeaderSize = sizeof(diprg.diph); 
	diprg.diph.dwObj = DIJOFS_X;
	diprg.diph.dwHow = DIPH_BYOFFSET;
	diprg.lMin = -1000; 
	diprg.lMax = +1000;
 
	rval = Joy_ID[Nb_Joys]->SetProperty(DIPROP_RANGE, &diprg.diph);
	if ((rval != DI_OK) && (rval != DI_PROPNOEFFECT)) 
		MessageBox(NULL, "IDirectInputDevice::SetProperty() (X-Axis) FAILED", "erreur joystick", MB_OK);

	diprg.diph.dwSize = sizeof(diprg); 
	diprg.diph.dwHeaderSize = sizeof(diprg.diph); 
	diprg.diph.dwObj = DIJOFS_Y;
	diprg.diph.dwHow = DIPH_BYOFFSET;
	diprg.lMin = -1000; 
	diprg.lMax = +1000;
 
	rval = Joy_ID[Nb_Joys]->SetProperty(DIPROP_RANGE, &diprg.diph);
	if ((rval != DI_OK) && (rval != DI_PROPNOEFFECT)) 
		MessageBox(NULL, "IDirectInputDevice::SetProperty() (Y-Axis) FAILED", "erreur joystick", MB_OK);

	for(i = 0; i < 10; i++){
		rval = Joy_ID[Nb_Joys]->Acquire();
		if (rval == DI_OK) break;
		Sleep(10);
	}

	Nb_Joys++;

	return(DIENUM_CONTINUE);
}

//初始化DI输入
//创建DI对象, 各手柄枚举及初始化, 创建键盘设备, 设置其数据格式, 协作等级等
int Init_Input(HINSTANCE hInst, HWND hWnd){
	int i;
	HRESULT rval;

	End_Input();
	
	rval = DirectInputCreate(hInst, DIRECTINPUT_VERSION, &lpDI, NULL);
	if (rval != DI_OK){
		MessageBox(hWnd, "DirectInput failed ...You must have DirectX 5", "Error", MB_OK);
		return 0;
	}
	
	Nb_Joys = 0;

	for(i = 0; i < MAX_JOYS; i++) Joy_ID[i] = NULL;

	rval = lpDI->EnumDevices(DIDEVTYPE_JOYSTICK, &InitJoystick, hWnd, DIEDFL_ATTACHEDONLY);
	if (rval != DI_OK) return 0;

	rval = lpDI->CreateDevice(GUID_SysKeyboard, &lpDIDKeyboard, NULL);
	if (rval != DI_OK) return 0;

	rval = lpDIDKeyboard->SetCooperativeLevel(hWnd, DISCL_NONEXCLUSIVE | DISCL_FOREGROUND);
	if (rval != DI_OK) return 0;

	rval = lpDIDKeyboard->SetDataFormat(&c_dfDIKeyboard);
	if (rval != DI_OK) return 0;

	for(i = 0; i < 10; i++){
		rval = lpDIDKeyboard->Acquire();
		if (rval == DI_OK) break;
		Sleep(10);
	}

	return 1;
}


//键盘设备获得焦点
void Restore_Input()
{
//	lpDIDMouse->Acquire();
	lpDIDKeyboard->Acquire();
}

//读取键盘及各手柄的现状态
void Update_Input(){
	HRESULT rval;
	int i;

	rval = lpDIDKeyboard->GetDeviceState(256, &Keys);

	if ((rval == DIERR_INPUTLOST) | (rval == DIERR_NOTACQUIRED))
		Restore_Input();

	for (i = 0; i < Nb_Joys; i++)
	{
		if (Joy_ID[i])
		{
			Joy_ID[i]->Poll();
			rval = Joy_ID[i]->GetDeviceState(sizeof(Joy_State[i]), &Joy_State[i]);
			if (rval != DI_OK) Joy_ID[i]->Acquire();
		}
	}
}

//检查指定的键是否按下, 是则返1, 否则返0
int Check_Key_Pressed(unsigned int key){
	int Num_Joy;

	if (key < 0x100){
		if KEYDOWN(key) return(1);
	}
	else{
		Num_Joy = ((key >> 8) & 0xF);

		if (Joy_ID[Num_Joy]){
			if (key & 0x80){			// Test POV Joys
				switch(key & 0xF){
					case 1:
						if (Joy_State[Num_Joy].rgdwPOV[(key >> 4) & 3] == 0) return(1); break;

					case 2:
						if (Joy_State[Num_Joy].rgdwPOV[(key >> 4) & 3] == 9000) return(1); break;

					case 3:
						if (Joy_State[Num_Joy].rgdwPOV[(key >> 4) & 3] == 18000) return(1); break;

					case 4:
						if (Joy_State[Num_Joy].rgdwPOV[(key >> 4) & 3] == 27000) return(1); break;
				}

			}
			else if (key & 0x70){		// Test Button Joys
				if (Joy_State[Num_Joy].rgbButtons[(key & 0xFF) - 0x10]) return(1);
			}
			else{
				switch(key & 0xF){
					case 1:
						if (Joy_State[Num_Joy].lY < -500) return(1); break;

					case 2:
						if (Joy_State[Num_Joy].lY > +500) return(1); break;

					case 3:
						if (Joy_State[Num_Joy].lX < -500) return(1); break;

					case 4:
						if (Joy_State[Num_Joy].lX > +500) return(1); break;
				}
			}
		}//if (Joy_ID[Num_Joy])
	}//else (key < 0x100)

	return 0;
}


//更新各手柄(最多8个)的各键状态
void Update_Controllers(){
	int t_keys=0;

	Update_Input();

	if (Check_Key_Pressed(Keys_Def[0].Up))
		t_keys |= 1;
	else
		if (Check_Key_Pressed(Keys_Def[0].Down))
			t_keys |= 2;
	
	if (Check_Key_Pressed(Keys_Def[0].Left))
		t_keys |= 4;
	else{
		if (Check_Key_Pressed(Keys_Def[0].Right))
			t_keys |=8;
	}

	if (Check_Key_Pressed(Keys_Def[0].Start))
		t_keys |= 0x80;

	if (Check_Key_Pressed(Keys_Def[0].A))
		t_keys |= 0x40;

	if (Check_Key_Pressed(Keys_Def[0].B))
		t_keys |= 0x10;

	if (Check_Key_Pressed(Keys_Def[0].C))
		t_keys |= 0x20;

	P1_Triggers =(P1_Keys ^ t_keys) & t_keys;
	P1_Keys =t_keys;
	/*
	if (Controller_1_Type & 1){
		if (Check_Key_Pressed(Keys_Def[0].Mode)) Controller_1_Mode = 0;
		else Controller_1_Mode = 1;

		if (Check_Key_Pressed(Keys_Def[0].X)) Controller_1_X = 0;
		else Controller_1_X = 1;

		if (Check_Key_Pressed(Keys_Def[0].Y)) Controller_1_Y = 0;
		else Controller_1_Y = 1;

		if (Check_Key_Pressed(Keys_Def[0].Z)) Controller_1_Z = 0;
		else Controller_1_Z = 1;
	}

	if (Check_Key_Pressed(Keys_Def[1].Up)){
		Controller_2_Up = 0;
		Controller_2_Down = 1;
	}
	else{
		Controller_2_Up = 1;
		if (Check_Key_Pressed(Keys_Def[1].Down)) Controller_2_Down = 0;
		else Controller_2_Down = 1;
	}

	
	if (Check_Key_Pressed(Keys_Def[1].Left)){
		Controller_2_Left = 0;
		Controller_2_Right = 1;
	}
	else{
		Controller_2_Left = 1;
		if (Check_Key_Pressed(Keys_Def[1].Right)) Controller_2_Right = 0;
		else Controller_2_Right = 1;
	}

	if (Check_Key_Pressed(Keys_Def[1].Start)) Controller_2_Start = 0;
	else Controller_2_Start = 1;

	if (Check_Key_Pressed(Keys_Def[1].A)) Controller_2_A = 0;
	else Controller_2_A = 1;

	if (Check_Key_Pressed(Keys_Def[1].B)) Controller_2_B = 0;
	else Controller_2_B = 1;

	if (Check_Key_Pressed(Keys_Def[1].C)) Controller_2_C = 0;
	else Controller_2_C = 1;

	if (Controller_2_Type & 1){
		if (Check_Key_Pressed(Keys_Def[1].Mode)) Controller_2_Mode = 0;
		else Controller_2_Mode = 1;

		if (Check_Key_Pressed(Keys_Def[1].X)) Controller_2_X = 0;
		else Controller_2_X = 1;

		if (Check_Key_Pressed(Keys_Def[1].Y)) Controller_2_Y = 0;
		else Controller_2_Y = 1;

		if (Check_Key_Pressed(Keys_Def[1].Z)) Controller_2_Z = 0;
		else Controller_2_Z = 1;
	}
	*/
}
