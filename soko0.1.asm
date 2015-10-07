TITLE MASM 16bEncode						(main.asm)

INCLUDE Irvine32.inc
.data
MAX_X = 24
MAX_Y = 20
xPos BYTE 5
yPos BYTE 1
map BYTE "    #####              ",0h,
		 "    #   #              ",0h,
		 "    #   #              ",0h,
		 "  ###   ##             ",0h,
		 "  #      #             ",0h,
		 "### # ## #   ######    ",0h,
		 "#   # ## #####    #    ",0h,
		 "#                 #    ",0h,
		 "##### ### # ##    #    ",0h,
		 "    #     #########    ",0h,
		 "    #######            ",0h
.code
main PROC
L2:
	call DrawMap	; Draw map... duh.
	mov dl, xPos	; Display guy
	mov dh, yPos
	call Gotoxy
	mov al, 1
	call WriteChar
	mov dl, xPos	; Store old x and y pos
	mov dh, yPos
	call GetMov		; Get the move direction
	;call CheckMapLoc ; Is it valid?
	;jne L2
	mov xPos, dl
	mov yPos, dh
	jmp L2
	exit
main ENDP

GetMov proc
; Moves the character based on arrow keys
	LGetMov1:
		mov eax, 10
		call Delay
		call ReadKey
		jz LGetMov1
	mov dl, xPos
	mov dh, yPos
	cmp ax, 4B00h
	jne N1
	cmp dl, 0
	jbe N1
	dec dl
	N1:
	cmp ax, 4D00h
	jne N2
	cmp dl, MAX_X
	jae N2
	inc dl
	N2:
	cmp ax, 4800h
	jne N3
	cmp dh, 0
	jbe N3
	dec dh
	N3:
	cmp ax, 5000h
	jne N4
	cmp dh, MAX_Y
	jae N4
	inc dh
	N4:
	ret
GetMov endp

DrawMap proc USES EAX ECX EDX
	mov edx, 0
	call Gotoxy
	mov eax, 0
	mov ecx, 11
	LDrawMap1:
		mov edx, OFFSET map
		add edx, eax
		call WriteString
		call Crlf
		add eax, MAX_X
		loop LDrawMap1
	ret
DrawMap endp

CheckMapLoc proc USES EAX EBX ECX
; dl = x dh = y
	mov ebx, OFFSET map
	movzx eax, dh
	mov ecx, MAX_X
	mul ecx
	add ebx, ebx
	movzx eax, dl
	add ebx, eax
	cmp map[eax], ' '
	ret
CheckMapLoc endp

END main