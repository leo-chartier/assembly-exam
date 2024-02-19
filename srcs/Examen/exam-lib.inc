; =============================================================================
; ALGOSUP assembly exam - Test library.
; =============================================================================

%if (LINE_IMPLEMENTATION_LEVEL < 1) || (7 < LINE_IMPLEMENTATION_LEVEL)
%fatal "ERROR: LINE_IMPLEMENTATION_LEVEL is out of range ! [1..7]"
%endif

org 100h
section .text
    jmp examTestStart        ;; Jump to program entry point.

; =============================================================================
section .text

; -------------------------------------
; Entry point:
examTestStart:
    call examTestInit
    call examTestRun
    jmp examTestShut

; =============================================================================
; Test initialization:
examTestInit:
    call heap_init          ; - Initialize heap memory.
    call nsGfxInitEngine    ; - Initialize graphic engine.
    call gfxSetGraphicMode
    ret

; =============================================================================
; Test shutdown:
examTestShut:
    call gfxSetTextMode
    mov ah, 4ch     ; AH=4Ch means "exit" function
    xor al, al      ; Set AL to 0 (return code)
    int 21h         ; Call the DOS interrupt 21h to exit the program
    ; we are out.

; =============================================================================
examTestRun:
    ; Load frame buffer segment:
    mov ax ,[nsGfxFramebufferSeg]
    mov [line_frameBufferSeg] ,ax

    call nsGfxClearFrame

    ; Bind to implementation level data set:
    mov si ,lineData_ %+ LINE_IMPLEMENTATION_LEVEL
    lodsw       ; load line count.
    mov cx ,ax
.eachLine:
    lodsb       ; load color index
    mov [line_colorIndex] ,al
    lodsw       ; load p0
    mov [line_x0] ,ax
    lodsw
    mov [line_y0] ,ax
    lodsw       ; load p1
    mov [line_x1] ,ax
    lodsw
    mov [line_y1] ,ax
    ; Invoke line drawing
    push ds
    push si
    push cx
    call drawLine
    pop cx
    pop si
    pop ds
    loop .eachLine
    ; Present framebuffer:
    call nsGfxPresentPixels
    ; Wait for ESCape pressed.
.waitEsc:
    call keybReadKey
    cmp al ,27
    jne .waitEsc
    ret

; =============================================================================
; Gfx features:
; =============================================================================

%define VGA_320_200_MEMADDR 0a000h

; =====================================
section .bss
    nsGfxPaletteSeg resw 1
    nsGfxFramebufferSeg resw 1
    nsGfxNextFreeColor resb 1

; =====================================
section .text
; -----------------------------------------------
nsGfxInitEngine:
    ; Allocate working palette memory:
    mov ax ,((768+15) / 16)
	call heap_allocSegs
    mov [nsGfxPaletteSeg] ,ax
    mov byte [nsGfxNextFreeColor] ,0

    ; Clear palette:
    mov es ,ax
    xor di ,di
    xor ax ,ax
    mov cx ,(768 / 2)
    cld
    rep stosw

    ; Allocate working framebuffer memory:
    mov ax ,((65535) / 16)
	call heap_allocSegs
    mov [nsGfxFramebufferSeg] ,ax
    ret

; -----------------------------------------------
nsGfxPresentPixels:
    push ds
    xor di ,di
    xor si ,si
    mov ax ,[nsGfxFramebufferSeg]
    mov bx ,VGA_320_200_MEMADDR
    mov ds ,ax
    mov es ,bx
    mov cx ,(64000 / 4)
    rep movsd
    pop ds
    ret

; -----------------------------------------------
nsGfxClearFrame:
    mov ax ,cs:[nsGfxFramebufferSeg]
    mov es ,ax
    xor di ,di
    xor eax, eax
    mov cx ,(320 * 200) / 4
    rep stosd
    ret

; -----------------------------------------------
; Set graphic mode: 320x200 pixels 256 colours.
gfxSetGraphicMode:
    mov ax, 13h
    int 10h
    ret

; -----------------------------------------------
; Set text mode: 80x25 chars.
gfxSetTextMode:
    mov ax, 07h
    int 10h
    ret

; =============================================================================
; String features:
; =============================================================================

; =====================================
section .data
    dosEOL db `\r\n`, 0
    carriageReturn db `\r` ,0

; =====================================
section .text

; -----------------------------------------------
;   ds:si = Source string.
printAsciiZ:
    lodsb
    cmp al ,0
    jz .endPrint
    mov dl ,al
    mov ax ,0600h
    int 21h
    jmp printAsciiZ
.endPrint:
    ret

; -----------------------------------------------
printSpace:
    mov dl, ' '
    mov ax ,0600h
    int 21h
    ret

; -----------------------------------------------
printNextLine:
    mov si ,dosEOL
    jmp printAsciiZ

; -----------------------------------------------
printCarriageReturn:
    mov si ,carriageReturn
    jmp printAsciiZ

; -----------------------------------------------
; Generate an hexa string from unsigned byte:
;   al = number to convert
;   es:di = target string
stringUByteToHexa:
    mov cx, 2
    jmp stringUnsignedToHexa

; -----------------------------------------------
; Generate an hexa string from unsigned word:
;   ax = number to convert
;   es:di = target string
stringUWordToHexa:
    mov cx, 4
    jmp stringUnsignedToHexa

; -----------------------------------------------
; Generate an hexa string from unsigned byte:
;   eax = number to convert
;   cx = number of hexadigit (lowest).
;   es:di = target string
stringUnsignedToHexa:
    mov ebx ,eax
    shl cx ,2
.hexaDigitLoop:
    sub cx ,4
    shr eax, cl
    and al, 15
    cmp al, 10
    jae .hexaLetter
    add al, '0'
    jmp .hexaFlush
.hexaLetter:
    add al, ('a' - 10)
.hexaFlush:
    stosb
    cmp cx ,0
    je .hexaEnd
    mov eax ,ebx
    jmp .hexaDigitLoop
.hexaEnd:
    xor al ,al
    stosb
    ret

; -----------------------------------------------
; Generate a decimal string from unsigned word
;   ax = number to convert
;   es:di = target string
stringUWordToDecimal:
    and eax ,0ffffh
    jmp stringUDWordToDecimal

; -----------------------------------------------
; Generate a decimal string from unsigned double word
;   eax = number to convert
;   es:di = target string
stringUDWordToDecimal:
    cmp eax, 0               ; Zero value is just... zero.
    jz .zeroValue
    mov ebx ,1000000000      ; Start with bilions
.decLead:
    xor edx ,edx
    div ebx                 ; Check this digit.
    cmp eax ,0              ; Zero lead ?
    jnz .digitLoop          ; Nope -> go to digit writing loop.
    mov ecx ,edx            ; Keep input value (was in remainder)
    mov eax ,ebx            ; Divide by 10
    xor edx ,edx
    div dword [.tenConst]
    mov ebx ,eax
    mov eax, ecx            ; Next (leading) digit.
    jmp .decLead

.digitLoop:                 ; => eax = quot / edx = remainder
    add al, '0'             ; Emit digit
    stosb
    mov ecx ,edx              ; Next digit -> keep remainder.
    mov eax ,ebx              ; Divide by 10
    xor edx ,edx
    div dword [.tenConst]
    cmp eax, 0
    jz .endDecimal
    mov ebx ,eax
    mov eax ,ecx              ; Divide remainder.
    xor edx ,edx
    div ebx
    jmp .digitLoop

.zeroValue:
    mov al ,'0'
    stosb

.endDecimal:
    xor al ,al              ; Close string
    stosb
    ret

.tenConst dd 10

; =============================================================================
; Keyboard
; =============================================================================

; =====================================
section .text

; -----------------------------------------------
; Read a key from keyboard input buffer.
;   ah = scan code
;   al = character
keybReadKey:
    xor ax, ax
    int 16h
    ret

; =============================================================================
; Heap features:
; =============================================================================

; =====================================
section .bss
    heapParagraphCount resw 1
    heapBase resw 1
    heapNext resw 1

; =====================================
section .text

; -----------------------------------------------
; Initialize memory for the program.
heap_init:
    ; Heap startes after the "base segment"
    mov ax ,cs              ; Load code segment (=this segment).
    add ax ,01000h          ; Jump after this segment.
    mov bx ,0a000h          ; Top memory.
    sub bx ,ax              ; Heap size.
    mov [heapBase] ,ax
    mov [heapNext] ,ax
    mov [heapParagraphCount] ,bx
    call memDumpInfo
    ret

; -----------------------------------------------
;   ax = paragraph count
; Returns:
;   ax = allocated seg
heap_allocSegs:
    mov bx ,cs:[heapNext]
    add ax ,bx
    mov cs:[heapNext] ,ax
    xchg ax ,bx
    ret

; =====================================
;   Heap dump infos:
section .data
    memDumpHeader    db `** Heap informations: **\r\n` ,0
    memDumpHeapBase  db ` - Heap Base: ` ,0
    memDumpHeapSize  db ` - Heap Size: ` ,0
    memDumpKilobytes db `Kbytes` ,0

section .bss
    memDumpNumString resb 16

section .text
memDumpInfo:
    mov si ,memDumpHeader
    call printAsciiZ

    ; - Heap base:
    mov si ,memDumpHeapBase
    call printAsciiZ
    mov ax ,[heapBase]
    mov di ,memDumpNumString
    call stringUWordToHexa
    ;call stringUWordToDecimal
    mov si ,memDumpNumString
    call printAsciiZ
    call printNextLine

    ; - Heap size
    mov si ,memDumpHeapSize
    call printAsciiZ
    mov ax ,word [heapParagraphCount]
    shr ax ,6
    mov di ,memDumpNumString
    call stringUWordToDecimal
    mov si ,memDumpNumString
    call printAsciiZ
    call printSpace
    mov si ,memDumpKilobytes
    call printAsciiZ
    call printNextLine
    ret

; =============================================================================
;   Test data:
; =============================================================================

struc LineParameters
    .color: resb 1
    .x0     resw 1     ; p0
    .y0     resw 1
    .x1     resw 1     ; p1
    .y1     resw 1
endstruc

section .data
%include "linedata.inc"
