TITLE MASM 16bEncode						(main.asm)

INCLUDE Irvine32.inc
.data
maxX BYTE ?
maxY BYTE ?
xPos BYTE ?
yPos BYTE ?
level BYTE 2
levels BYTE '1',0,'2',0,'3',0,'z'
fileHandle DWORD ?
map BYTE 440 DUP(?)
sockets BYTE 40 DUP(?)
socketSize BYTE	?
buffer BYTE 100 DUP(?)

.code
main PROC
dec level
LMain0:
inc level
movzx eax, level
cmp levels[eax*2],'z'
je LMain3
LMainRestart:
call GetMapFile
LMain1:
	call DrawMap	; Draw map... duh.
	call DrawSockets
	mov dl, xPos	; Display guy
	mov dh, yPos
	call Gotoxy
	mov eax, lightCyan
	call SetTextColor
	mov al, 1
	call WriteChar
	call CheckForWin
	jz LMain0
	mov dl, xPos	; Store old x and y pos
	mov dh, yPos
	call GetMov		; Get the move direction
	cmp ax, 1372h	; Check for restart
	je LMainRestart
	call CheckMapLoc ; Is it valid?
	cmp map[ebx], '#'
	je LMain1
	cmp map[ebx], 'o'
	jne LMain2
	call MoveRock
	jmp LMain1
LMain2:
	mov xPos, dl	; If so, move the guy
	mov yPos, dh
	jmp LMain1
LMain3:
	mov dl, 0
	mov dh, maxY
	call Gotoxy
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
	cmp dl, maxX
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
	cmp dh, maxY
	jae N4
	inc dh
	N4:
	ret
GetMov endp

DrawMap proc USES EAX ECX EDX
	mov eax, lightRed
	call SetTextColor
	mov edx, 0
	call Gotoxy
	mov eax, 0
	mov ecx, 11
	LDrawMap1:
		mov edx, OFFSET map
		add edx, eax
		call WriteString
		call Crlf
		add al, maxX
		loop LDrawMap1
	ret
DrawMap endp

DrawSockets proc USES EAX EBX ECX EDX
	mov ecx, 0
LDrawSockets1:
		mov eax, magenta
		call SetTextColor
		mov dl, sockets[ecx]
		mov dh, sockets[ecx+1]
		call Gotoxy
		mov al, '.'
		call CheckMapLoc
		cmp map[ebx], 'o'
		jne LDrawSockets2
		mov eax, lightGreen
		call SetTextColor
		mov al, '*'
	LDrawSockets2:
		call WriteChar
		add ecx, 2
		cmp cl, socketSize
		jne LDrawSockets1
	ret
DrawSockets endp

CheckMapLoc proc USES EAX ECX
; dl = x dh = y
; returns ebx, the location of player in map array
	mov ebx, 0
	movzx ecx, dh
	inc ecx
	sub bl, maxX
	LCheckMapLoc1:
		add bl, maxX
		loop LCheckMapLoc1
	movzx eax, dl
	add ebx, eax
	ret
CheckMapLoc endp

MoveRock proc USES EAX EDX
; dl = x being moved to dh = y
	push edx
	push edx
	sub dl, xPos
	sub dh, yPos
	mov eax, edx
	pop edx
	add dl, al
	add dh, ah
	call CheckMapLoc
	cmp map[ebx], '#'
	je LMoveRock1
	cmp map[ebx], 'o'
	je LMoveRock1
	mov map[ebx], 'o'
	pop edx
	call CheckMapLoc
	mov map[ebx], ' '
	mov xPos, dl	; move the guy into good pos
	mov yPos, dh
	push edx
LMoveRock1:
	pop edx
	ret
MoveRock endp

CheckForWin proc USES EAX EBX ECX EDX
; sets zero flag if win
	mov ecx, 0
	mov eax, 0
LCheckForWin1:
		mov dl, sockets[ecx]
		mov dh, sockets[ecx+1]
		call CheckMapLoc
		cmp map[ebx], 'o'
		jne LCheckForWin2
		add ecx, 2
		cmp cl, socketSize
		jne LCheckForWin1
	mov eax, 1
LCheckForWin2:
	sub eax, 1
	ret
CheckForWin endp

GetMapFile proc USES EAX EBX ECX EDX
	mov edx, OFFSET levels
	movzx eax, level
	add edx, eax
	add edx, eax
	call OpenInputFile	
	mov fileHandle,eax	
	
	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, 4
	call ReadFromFile
	mov edx, OFFSET buffer
	mov ecx, 2
	call ParseDecimal32
	mov maxX,al
	
	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, 4
	call ReadFromFile
	mov edx, OFFSET buffer
	mov ecx, 2
	call ParseDecimal32
	mov maxY,al
	
	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, 4
	call ReadFromFile
	mov edx, OFFSET buffer
	mov ecx, 2
	call ParseDecimal32
	mov xPos,al
	
	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, 4
	call ReadFromFile
	mov edx, OFFSET buffer
	mov ecx, 2
	call ParseDecimal32
	mov yPos,al
	
	movzx ecx, maxY
	mov eax, ecx
	mov edx, OFFSET map
	mov ebx, 0
	LGetMapFile1:
		push ecx
		movzx ecx, maxX
		inc ecx
		push edx
		mov eax, fileHandle
		call ReadFromFile
		pop edx
		movzx ecx, maxX
		add edx, ecx
		add ebx, ecx
		mov map[ebx], 0
		mov map[ebx-1],0
		pop ecx
		loop LGetMapFile1
	
	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, 4
	call ReadFromFile
	mov edx, OFFSET buffer
	mov ecx, 2
	call ParseDecimal32
	mov socketSize,al
	
	mov ebx, 0
	movzx ecx,socketSize
	
	LGetMapFile2:
		push ecx
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, 3
		call ReadFromFile
		jc LGetMapFile3 ; if eof jmp
		mov edx, OFFSET buffer
		mov ecx, 2
		call ParseDecimal32
		mov sockets[ebx],al
		
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, 4
		call ReadFromFile
		mov edx, OFFSET buffer
		mov ecx, 2
		call ParseDecimal32
		mov sockets[ebx+1],al
		add ebx, 2
		inc socketSize
		pop ecx
		loop LGetMapFile2
	LGetMapFile3:
	
	mov eax, fileHandle
	call CloseFile
	ret
GetMapFile endp

END main
