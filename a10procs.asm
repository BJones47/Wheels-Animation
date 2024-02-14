; *****************************************************************
;  Name: Braxton Jones
;  Description:  This program will draw and animate a circle using OpenGL.

; -----
;  Function: getParams
;	Gets, checks, converts, and returns command line arguments.

;  Function drawWheels()
;	Plots functions

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

SPD_MIN		equ	1
SPD_MAX		equ	50			; 101(7) = 50

CLR_MIN		equ	0
CLR_MAX		equ	0xFFFFFF		; 0xFFFFFF = 262414110(7)

SIZ_MIN		equ	100			; 202(7) = 100
SIZ_MAX		equ	2000			; 5555(7) = 2000

; -----
;  Local variables for getParams functions.

STR_LENGTH	equ	12

errUsage	db	"Usage: ./wheels -sp <septNumber> -cl <septNumber> "
		db	"-sz <septNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSpdSpec	db	"Error, speed specifier incorrect."
		db	LF, NULL
errSpdValue	db	"Error, speed value must be between 1 and 101(7)."
		db	LF, NULL

errClrSpec	db	"Error, color specifier incorrect."
		db	LF, NULL
errClrValue	db	"Error, color value must be between 0 and 262414110(7)."
		db	LF, NULL

errSizSpec	db	"Error, size specifier incorrect."
		db	LF, NULL
errSizValue	db	"Error, size value must be between 202(7) and 5555(7)."
		db	LF, NULL

; -----
;  Local variables for drawWheels routine.

t		dq	0.0			; loop variable
s		dq	0.0
tStep		dq	0.001			; t step
sStep		dq	0.0
x		dq	0			; current x
y		dq	0			; current y
scale		dq	7500.0			; speed scale

fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0
fltThree	dq	3.0
fltFour		dq	4.0
fltSix		dq	6.0
fltTwoPiS	dq	0.0

pi		dq	3.14159265358

fltTmp1		dq	0.0
fltTmp2		dq	0.0
fltTmp3     dq  0.0
fltTmp4     dq  0.0

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cos, sin


; ******************************************************************
;  Function getParams()
;	Gets draw speed, draw color, and screen size
;	from the command line arguments.

;	Performs error checking, converts ASCII/septenary to integer.
;	Command line format (fixed order):
;	  "-sp <septNumber> -cl <septNumber> -sz <septyNumber>"

; -----
;  Arguments:
;	ARGC, double-word, value
;	ARGV, double-word, address
;	speed, double-word, address
;	color, double-word, address
;	size, double-word, address

; Returns:
;	speed, color, and size via reference (of all valid)
;	TRUE or FALSE


global getParams
getParams:
;	YOUR CODE GOES HERE
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r12, rsi
	mov r13, rdx
	mov r14, rcx
	mov r15, r8
; compare argc to 1 and 7
	cmp rdi, 1 
	je usageErr
	cmp rdi, 7
	jne errorCL

; check argv[1] for -sp
	mov rbx, qword[rsi+8] ; check -
	mov al, byte[rbx]
	cmp al, "-"
	jne errSpSpec

	mov al, byte[rbx+1]   ; check s
	cmp al, "s"
	jne errSpSpec

	mov al, byte[rbx+2]   ; check p
	cmp al, "p"
	jne errSpSpec

	mov al, byte[rbx+3]
	cmp al, NULL
	jne errSpSpec
	
	; is good

	; check argv[2] convert ascii/base7 
	
	mov rdi, qword[r12+16]
	call sept2int
	cmp eax, 0          ; check binary number to 0 error check.
	je errSpValue
	cmp eax, SPD_MIN    ; check if binary num is above min and below max.
	jb errSpValue
	cmp eax, SPD_MAX
	ja errSpValue
	
	mov dword[r13], eax ; return speed
	; is good
	; check argv[3] for -cl
	mov rbx, qword[r12+24] ; check -
	mov al, byte[rbx]
	cmp al, "-"
	jne errClSpec

	mov al, byte[rbx+1]   ; check c
	cmp al, "c"
	jne errClSpec

	mov al, byte[rbx+2]   ; check l
	cmp al, "l"
	jne errClSpec

	mov al, byte[rbx+3]   ; check NULL
	cmp al, NULL
	jne errSpSpec
	
	; is good
	; check the color identifier and error check the sept to binary num
	mov rdi, qword[r12+32]
	call sept2int
	cmp eax, 0          ; check binary number to 0 error check.
	je errCLValue
	cmp eax, CLR_MIN    ; check if binary num is above min and below max.
	jb errCLValue
	cmp eax, CLR_MAX
	ja errCLValue

	mov dword[r14], eax ; return color
	; is good
	; check argv[5] for -sz
	mov rbx, qword[r12+40] ; check -
	mov al, byte[rbx]
	cmp al, "-"
	jne errSzSpec

	mov al, byte[rbx+1]   ; check s
	cmp al, "s"
	jne errSzSpec

	mov al, byte[rbx+2]   ; check z
	cmp al, "z"
	jne errSzSpec

	mov al, byte[rbx+3]   ; check NULL
	cmp al, NULL
	jne errSzSpec

	; is good
	; check the size sept to int is valid and within min and max
	mov rdi, qword[r12+48]
	call sept2int
	cmp eax, 0          ; check binary number to 0 error check.
	je errSZValue
	cmp eax, SIZ_MIN    ; check if binary num is above min and below max.
	jb errSZValue
	cmp eax, SIZ_MAX
	ja errSZValue

	mov dword[r15], eax ; return size

	mov rax, TRUE       ; if successful return TRUE.


	jmp good

; error print
usageErr:
	mov rdi, errUsage
	jmp printIt
errorCL:
	mov rdi, errBadCL
	jmp printIt
errSpSpec:
	mov rdi, errSpdSpec
	jmp printIt
errSpValue:
	mov rdi, errSpdValue
	jmp printIt
errClSpec:
	mov rdi, errClrSpec
	jmp printIt
errCLValue:
	mov rdi, errClrValue
	jmp printIt
errSzSpec:
	mov rdi, errSizSpec
	jmp printIt
errSZValue:
	mov rdi, errSizValue
	jmp printIt
printIt:
	call printString
	mov rax, FALSE
good:
	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

; ******************************************************************
;  Draw wheels function.
;	Plot the provided functions (see PDF).

; -----
;  Arguments:
;	none -> accesses global variables.
;	nothing -> is void

; -----
;  Gloabl variables Accessed:

common	speed		1:4			; draw speed, dword, integer value
common	color		1:4			; draw color, dword, integer value
common	size		1:4			; screen size, dword, integer value

global drawWheels
drawWheels:
	push	rbp

; do NOT push any additional registers.
; If needed, save regitser to quad variable...

; -----
;  Set draw speed step
;	sStep = speed / scale

;	YOUR CODE GOES HERE
	cvtsi2sd xmm0, dword[speed]
	divsd    xmm0, qword[scale]
	movsd    qword[sStep], xmm0


; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Set draw color(r,g,b)
;	uses glColor3ub(r,g,b)

;	YOUR CODE GOES HERE
	mov rax, 0
	mov r9, 0
	mov r10, 0
	mov r11, 0

	; mov color into r9 each 8 bits represents rgb

	mov rax, qword[color]
	mov r9b, al
	shr eax, 8
	mov r10b, al
	shr eax, 8
	mov r11b, al
	
	
	mov rdi, r11
	mov rsi, r10
	mov rdx, r9
	call glColor3ub
; -----
;  main plot loop
;	iterate t from 0.0 to 2*pi by tStep
;	uses glVertex2d(x,y) for each formula


;	YOUR CODE GOES HERE
;   find interations for the circle loop	
	
plotLoop:
	movsd xmm0, qword[fltZero]
	movsd xmm0, qword[fltTwo]
	mulsd xmm0, qword[pi]
	ucomisd xmm0, qword[t]       ; compare 2pi to t
	jbe plotLoopDone
	
	; x1 and y1
	movsd xmm0, qword[t]
	call cos
	movsd qword[x], xmm0 ; x1

	movsd xmm0, qword[t]
	call sin
	movsd qword[y], xmm0 ; y1

	; plot points 
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	; x2 and y2
	movsd xmm0, qword[t] ; x2
	call cos
	divsd xmm0, qword[fltThree]
	movsd qword[fltTmp1], xmm0 ; save cost/3.0 for later
	movsd xmm0, qword[fltTwo]
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	
	movsd qword[fltTmp2], xmm0 ;2pis
	call cos
	mulsd xmm0, qword[fltTwo]
	divsd xmm0, qword[fltThree]
	movsd qword[fltTmp3], xmm0 ; 2cos2pis/3
	addsd xmm0, qword[fltTmp1]
	movsd qword[x], xmm0

	movsd xmm0, qword[t] ; y2
	call sin
	divsd xmm0, qword[fltThree]
	movsd qword[fltTmp1], xmm0 ; save sint/3.0 for later
	movsd xmm0, qword[fltTwo]
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	
	movsd qword[fltTmp2], xmm0 ; 2pis
	call sin
	mulsd xmm0, qword[fltTwo]
	divsd xmm0, qword[fltThree]
	movsd qword[fltTmp4], xmm0 ; 2sin2pis/3
	addsd xmm0, qword[fltTmp1]
	movsd qword[y], xmm0
	; plot points 
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	; x3 and y3
	
	movsd xmm0, qword[fltFour] ; x3
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	call cos
	mulsd xmm0, qword[t]      ;tcos4pis
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	addsd xmm0, qword[fltTmp3] ; add 2cos2pis/3 + tcos4pis/6n
	movsd qword[x], xmm0

	movsd xmm0, qword[fltFour] ; y3 
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	call sin
	mulsd xmm0, qword[t]      ;tsin4pis
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	movsd xmm2, qword[fltTmp4]  ; sub 2sin2pis/3 - tsin4pis/6n
	subsd xmm2, xmm0
	movsd qword[y], xmm2
	; plot points 
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	; x4 and y4
	movsd xmm0, qword[fltFour] 
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	movsd xmm1, qword[fltTwo]
	mulsd xmm1, qword[pi]
	divsd xmm1, qword[fltThree] ; 2pi/3
	addsd xmm0, xmm1            ; 4pis+2pi/3
	call cos
	mulsd xmm0, qword[t]      ;tcos4pis+2pi/3
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	addsd xmm0, qword[fltTmp3] ; add 2cos2pis/3 + tcos4pis(+2pi/3)/6n
	movsd qword[x], xmm0       ; x4

	movsd xmm0, qword[fltFour] 
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	movsd xmm1, qword[fltTwo] 
	mulsd xmm1, qword[pi]
	divsd xmm1, qword[fltThree] ; 2pi/3
	addsd xmm0, xmm1
	call sin
	mulsd xmm0, qword[t]      ;tsin4pis+2pi/3
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	movsd xmm2, qword[fltTmp4]  ; sub 2sin2pis/3 - tsin4pis+(2pi/3)/6n
	subsd xmm2, xmm0
	movsd qword[y], xmm2 ; y4
	; plot points
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	; x5 and y5
	movsd xmm0, qword[fltFour] 
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	movsd xmm1, qword[fltTwo]
	mulsd xmm1, qword[pi]
	divsd xmm1, qword[fltThree] ; 2pi/3
	subsd xmm0, xmm1            ; 4pis-2pi/3
	call cos
	mulsd xmm0, qword[t]      ;tcos4pis-2pi/3
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	addsd xmm0, qword[fltTmp3] ; add 2cos2pis/3 + tcos4pis(+2pi/3)/6n
	movsd qword[x], xmm0       ; x5

	movsd xmm0, qword[fltFour] 
	mulsd xmm0, qword[pi]
	mulsd xmm0, qword[s]
	movsd xmm1, qword[fltTwo] 
	mulsd xmm1, qword[pi]
	divsd xmm1, qword[fltThree] ; 2pi/3
	subsd xmm0, xmm1
	call sin
	mulsd xmm0, qword[t]      ;tsin4pis-2pi/3
	movsd xmm1, qword[fltSix]
	mulsd xmm1, qword[pi]     ; 6pi
	divsd xmm0, xmm1
	movsd xmm2, qword[fltTmp4]  ; sub 2sin2pis/3 - tsin4pis+(2pi/3)/6n
	subsd xmm2, xmm0
	movsd qword[y], xmm2 ; y5
	; plot points
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	; t += tStep
	movsd	xmm0, qword [t]			; t+= tStep
	addsd	xmm0, qword [tStep]
	movsd	qword [t], xmm0
	jmp plotLoop

plotLoopDone:
	movsd	xmm0, qword [fltZero]
	movsd	qword [t], xmm0
; -----
;  Display image

	call	glEnd
	call	glFlush

; -----
;  Update s, s += sStep;
;  if (s > 1.0)
;	s = 0.0;

	movsd	xmm0, qword [s]			; s+= sStep
	addsd	xmm0, qword [sStep]
	movsd	qword [s], xmm0

	movsd	xmm0, qword [s]
	movsd	xmm1, qword [fltOne]
	ucomisd	xmm0, xmm1			; if (s > 1.0)
	jbe	resetDone

	movsd	xmm0, qword [fltZero]
	movsd	qword [sStep], xmm0
resetDone:

	call	glutPostRedisplay

; -----

	pop	rbp
	ret

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; Function to convert a septenary ascii string to an integer
; checks min and max rsum.
; arguments
; rdi = address of string

global sept2int
sept2int:

    mov r8, rdi
	mov r9, 0
	mov eax, 0

nextChr:
	; get char, chr = str[i]
	mov ecx, 0
	mov cl, byte[r8+r9]

	; if char == NULL jump to chrLpDone
	cmp cl, NULL
	je chrLpDone
    ; if char is between 0 - 6 continue
    cmp cl, "0"
    jb inval 
    cmp cl, "6"
    ja inval

	; convert char to int
	sub cl, 0x30
	; rsum = (rsum*7)+int
	mov r11d, 7
	mul r11d
	add eax, ecx
	; inc i
	inc r9
	jmp nextChr
chrLpDone:
	jmp loopDone
inval:
	mov eax, 0
	jmp loopDone
loopDone:

ret


; ******************************************************************

