;rg@z
;jmp short deXor
jmp short xorData

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;decrease delay to increase speed
Delay db        0fah
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keyboard Settings
;          key scan code
lftA  db        2ch
rgtA  db        2dh

lftB  db        34h
rgtB  db        35h

start db        39h ;spaceBar keyScanCode
quit  db        01h ;esc keyScanCode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start Positions & Directions
xAinit  equ 210;320
yAinit  equ 239

VxAinit equ +1;-1
VyAinit equ 0;1

xBinit  equ 419;319
yBinit  equ 239

VxBinit equ -1;+1
VyBinit equ 0;1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Color Settings
colorA      equ   0eh;09h;0eh;03 ;0eh
colorB      equ   0ah;02 ;0ah

colorWall         equ   0ch
initMsgColor      equ   09h 
gameStartMsgColor equ   03h;0ah
gameDrawMsgColor  equ   07h;0eh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Boundary Limits
wallL equ       5
wallT equ       5
wallB equ       440
wallR equ       634
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

deXor:
  mov   cx, 200h;0139h  ; b9NNMM ;MMNN=No of bytes/2
  lea   si, xorData-2     ;be1801
deXorNext:
  inc   si          ;46
  inc   si          ;46
  xor word ptr [si], 05857h;05958h  ;8134XXYY ;XXYY=XorCode 5958 ; 5859 in zXor
  loop  deXorNext ;e2f8
xorData:
  not Delay ;conversion from speed to time-delay
  mov   ax, 12h
  int   10h   ;change to mode 12h
  
;;;;;;;display initial message
  mov   ax, 1300h
  mov   bx, initMsgColor
  mov   cx, initMsgLen
  mov   dx, initMsgCoOrd
  lea   bp, initMsg
  int   10h

;;;;;;;display start/exit message
NewGame:
  mov   ax, 1300h
  mov   bx, gameStartMsgColor
  mov   cx, gameStartMsgLen
  mov   dx, gameStartMsgCoOrd
  lea   bp, gameStartMsg
  int   10h
;;;;;;;check for start/exit keys
 ng_lp1:
  mov   ah, 10h
  int   16h
  cmp   ah, start
  je    start_game
  cmp   ah, quit
  jne   ng_lp1
exit:
  mov   ax, 4c00h
  int   21h

start_game:
  mov   ax, 12h
  int   10h   ;clrscr (change to mode 12h)

  call  displayScores

  mov   ah, 0ch
  mov   al, colorWall
  xor   bx, bx
  
  mov   cx, wallL
  mov   dx, wallT
w1:
  int   10h
  inc   dx
  cmp   dx, wallB
  jle   w1
  mov   dx, wallB
w2:
  int   10h
  inc   cx
  cmp   cx, wallR
  jle   w2

  mov   cx, wallR
w3:
  int   10h
  dec   dx
  cmp   dx, wallT
  jge   w3

  mov   dx, wallT
w4:
  int   10h
  dec   cx
  cmp   cx, wallL
  jge   w4

  mov   W xA, xAinit
  mov   W yA, yAinit

  mov   W xB, xBinit
  mov   W yB, yBinit

  mov   W uA, VxAinit
  mov   W vA, VyAinit
  mov   W uB, VxBinit
  mov   W vB, VyBinit


mov B initMsg, 0

Refresh:
ChkForKey:  
  mov   ah, 11h
  int   16h
  jz    NoKeyPressed

GetKey:
  mov   ah, 10h
  int   16h
chkQuit:
  cmp   ah, quit
  jne   chkLftA
  jmp   exit
  
chkLftA:
  cmp   ah, lftA
  jne   chkRgtA
  
  mov   ax, uA
  neg   ax
  mov   bx, vA
  mov   uA, bx
  mov   vA, ax
  jmp   NoKeyPressed

chkRgtA:
  cmp   ah, rgtA
  jne   chkLftB
  
  mov   ax, vA
  neg   ax
  mov   bx, uA
  mov   vA, bx
  mov   uA, ax
  jmp   NoKeyPressed

chkLftB:
  cmp   ah, lftB
  jne   chkRgtB
  
  mov   ax, uB
  neg   ax
  mov   bx, vB
  mov   uB, bx
  mov   vB, ax
  jmp   NoKeyPressed

chkRgtB:
  cmp   ah, rgtB
  jne   NoKeyPressed
  
  mov   ax, vB
  neg   ax
  mov   bx, uB
  mov   vB, bx
  mov   uB, ax

NoKeyPressed:

UpdateValues:
  mov   ax, xA
  add   ax, uA
  mov   xA, ax

  mov   ax, yA
  add   ax, vA
  mov   yA, ax

  mov   ax, xB
  add   ax, uB
  mov   xB, ax

  mov   ax, yB
  add   ax, vB
  mov   yB, ax

  ;jmp putPixels  ; to bypass ChkForCollisions

ChkForCollisions:

getPixelA:
  mov   ah, 0dh
  xor   bx, bx
  mov   cx, xA
  mov   dx, yA
  int   10h
  test  al, al
  jz    chk1
  xor B initMsg, 2
getPixelB:
chk1:
  ;; mov ah, 0dh
  ;; xor bx, bx
  mov   cx, xB
  mov   dx, yB
  int   10h
  test  al, al
  jz    chk2
  inc   initMsg
chk2:
  cmp   initMsg, 0
  jnz   gameOver

cmpAandB:
  mov   ax, xA
  cmp   ax, xB
  jne   putPixels
  mov   ax, yA
  cmp   ax, yB
  jne   putPixels
  or    initMsg, 3
  jmp   gameOver

putPixels:
  mov   ah, 0ch
  xor   bx, bx
  mov   al, colorA
  mov   cx, xA
  mov   dx, yA
  int   10h
  mov   al, colorB
  mov   cx, xB
  mov   dx, yB
  int   10h

someDelay:
  mov   dl, Delay
  xor   cx, cx
OuterDelayLoop:
  not   cx
DelayLoop:
  loop DelayLoop
  dec   dl
  jnz   OuterDelayLoop
  
  jmp Refresh


gameOver:
  mov   ah, initMsg
  cmp   ah, 3
  jnz   chkA
  lea   bp, msgDraw
  mov   bx, gameDrawMsgColor
  jmp   gameOverMsg
chkA:
  and   ah, 1
  jz chkB
  lea   bp, msgAwon
  mov   bx, colorA
  inc W scoreA
  jmp   gameOverMsg
chkB:
  lea   bp, msgBwon
  mov   bx, colorB
  inc W scoreB
gameOverMsg:
  mov   ax, 1300h
  mov   cx, gameOverMsgLen
  mov   dx, gameOverMsgCoOrd
  int   10h
  call  displayScores
pc_spkr_beep:
  mov   ah, 2
  mov   dl, 7
  int   21h   ;beep

  jmp   NewGame


displayScores:
  mov   ax, W scoreA
  call  i2a         ; returns length of num in cx
  mov   dx, scACoOrd
  mov   bx, colorA
  int   10h
  mov   ax, W scoreB
  call  i2a         ; returns length of num in cx
  mov   dx, scBCoOrd
  mov   bx, colorB
  int   10h
  ret

i2a: ;;; convert word in ax to string in initMsg
         ;;; remove ;;;** to disable 3 digit display
  lea   si, initMsg
  mov   bx, 100;00
  xor   dx, dx
  mov   di, 10
  mov   cx, 3;5     ;;;**
  ;xor cx, cx       ;;;**
i2a_loop:
  div   bx          ;ax=q;dx=r;
  test  ax, ax
  ;jz   i2a_l1      ;;;**
  add   al, 30h
  mov   [si], al
  inc   si
  ;inc  cx          ;;;**
i2a_l1: mov ax, dx

  xor   dx, dx      ;bx/=10
  xchg  ax, bx
  div   di          ;W ten;000ah; ;dx=0
  xchg  ax, bx
  test  bx, bx
  jnz   i2a_loop
  ;test cx, cx      ;;;**
  ;jnz  i2a_l2      ;;;**
  ;inc  cx          ;;;**
  ;mov  B [si], 30h ;;;**
i2a_l2: 
  mov ax, 1300h
  lea bp, initMsg
  ret


xA  dw  xAinit
xB  dw  xBinit
yA  dw  yAinit
yB  dw  yBinit

uA  dw  VxAinit
uB  dw  VxBinit
vA  dw  VyAinit
vB  dw  VyBinit

scoreA  dw  0
scoreB  dw  0

scACoOrd          equ 1c05h
scBCoOrd          equ 1c48h


initMsg           db  'a s m T r o n   b y   _z y x w a r e_'
initMsgLen        equ 37
initMsgCoOrd      equ 0f16h

gameStartMsg      db  '[space] / [escape]'
gameStartMsgLen   equ 18
gameStartMsgCoOrd equ 1d1eh

msgAwon           db  'player A won !'
msgBwon           db  'player B won !'
msgDraw           db  'game drawn !!?'
gameOverMsgLen    equ 14
gameOverMsgCoOrd  equ 1c20h