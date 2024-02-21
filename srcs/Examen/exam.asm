[map symbols exam.map]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                          ;;
;;   THIS VERSION WAS MADE AFTER THE EXAM   ;;
;;   AND SHOULD NOT BE TAKEN INTO ACCOUNT   ;;
;;                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; -------------------------------------
; ALGOSUP assembly exam.
; -------------------------------------
; You must implement a line drawing algorithm in pure assembly.
;
; Parameters will be filled by the test bed for you.
;
; There are 7 levels of implementation:
;   1 - Draw an horizontal line filling the width of the screen (use only line_colorIndex and line_y0).
;   2 - Draw an horizontal segment between the specified X coordinates (use only line_colorIndex, line_y0, and line_x0 to line_x1).
;   3 - Draw an vertical line filling the height of the screen (use only line_colorIndex and line_x0).
;   4 - Draw an vertical segment between the specified Y coordinates (use only line_colorIndex, line_x0, and line_y0 to line_y1).
;   5 - Draw an arbitrary segment between (x0,y0) and (x1,y1). (x0 <= x1 and y0 <= y1, both points in screen)
;   6 - Draw an arbitrary segment between (x0,y0) and (x1,y1). (unsorted x's and y's both points in screen)
;   7 - Draw an arbitrary segment between (x0,y0) and (x1,y1) and clip it. (p0 and p1 can be outside the screen)
; -------------------------------------
; You can proceed iteratively and raise the reached level on each step, or, if you feel inspired,
; you can start to implement directly your targeted level.
; -------------------------------------
; Specify the implementation level through the macro value:
;   %define LINE_IMPLEMENTATION_LEVEL 1
;   or
;   %define LINE_IMPLEMENTATION_LEVEL 7
;   and so on...
; -------------------------------------
; Good luck !
; -------------------------------------

; Choose the feature level here:
%define LINE_IMPLEMENTATION_LEVEL 7

; This is the test bed code (don't add anything before this):
%include "exam-lib.inc"

section .bss

; -------------------------------------
; Line drawing parameters (given by the test host):
    line_frameBufferSeg resw 1      ; Base segment where to display (it can be somewhere else that video memory)
    line_colorIndex     resb 1      ; The color to use to draw the line.
    line_x0  resw 1     ; p0
    line_y0  resw 1
    line_x1  resw 1     ; p1
    line_y1  resw 1
    deltaX   resw 1
    deltaY   resw 1
    sx       resw 1
    sy       resw 1
    error_   resw 1

section .text

; Defining the screen size
%define SCREEN_W 320
%define SCREEN_H 200

; -------------------------------------
; Draw a line:
drawLine:
    jmp implementation %+ LINE_IMPLEMENTATION_LEVEL

implementation1:
    ; al: Pixel color
    ; bx: Index of the pixel in memory
    ; cx: Pixel counter

    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax
    ; Select the starting position
    mov ax, [line_y0]
    mov bx, SCREEN_W
    mul bx
    mov bx, ax
    ; Select the color
    mov al, [line_colorIndex]
    ; Loop through the whole line
    mov cx, 0
    .loop:
    mov di, bx
    ; Draw the pixel
    stosb
    ; Increment and repeat
    inc cx
    inc bx
    cmp cx, SCREEN_W
    jne .loop
    ret

implementation2:
    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax
    ; Select the starting position
    mov ax, [line_y0]
    mov bx, SCREEN_W
    mul bx
    mov bx, ax
    mov cx, [line_x0]
    add bx, cx
    ; Select the color
    mov al, [line_colorIndex]
    ; Loop through the whole line
    .loop:
    mov di, bx
    ; Draw the pixel
    stosb
    ; Increment and repeat
    inc cx
    inc bx
    cmp cx, [line_x1]
    jbe .loop
    ret

implementation3:
    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax
    ; Select the starting position
    mov bx, [line_x0]
    ; Select the color
    mov al, [line_colorIndex]
    ; Loop through the whole line
    mov cx, 0
    .loop:
    mov di, bx
    ; Draw the pixel
    stosb
    ; Increment and repeat
    inc cx
    add bx, SCREEN_W
    cmp cx, SCREEN_H
    jne .loop
    ret

implementation4:
    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax
    ; Select the starting position
    mov ax, [line_y0]
    mov bx, SCREEN_W
    mul bx
    mov bx, ax
    add bx, [line_x0]
    ; Select the color
    mov al, [line_colorIndex]
    ; Loop through the whole line
    mov cx, [line_y0]
    .loop:
    mov di, bx
    ; Draw the pixel
    stosb
    ; Increment and repeat
    inc cx
    add bx, SCREEN_W
    cmp cx, [line_y1]
    jbe .loop
    ret

implementation5:
    call bresenham
    ret

implementation6:
    call bresenham
    ret

implementation7:
    call bresenham
    ret

bresenham:
    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax

    ; Adapted from
    ; https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm#All_cases

    ; dx = abs(x1 - x0)
    mov ax, [line_x1]
    sub ax, [line_x0]
    mov dx, ax
    sar dx, 15
    xor ax, dx
    sub ax, dx
    mov [deltaX], ax
    ; sx = x0 < x1 ? 1 : -1
    or dx, 1
    mov [sx], dx
    ; dy = -abs(y1 - y0)
    mov ax, [line_y1]
    sub ax, [line_y0]
    mov dx, ax
    sar dx, 15
    xor ax, dx
    sub ax, dx
    neg ax
    mov [deltaY], ax
    ; sy = y0 < y1 ? 1 : -1
    or dx, 1
    mov [sy], dx
    ; error = dx + dy
    mov ax, [deltaX]
    add ax, [deltaY]
    mov [error_], ax
    
    ; while true
    .while:
    ;     plot(x0, y0)
    call plot
    ;     if x0 == x1 && y0 == y1 break
    mov ax, [line_x0]
    cmp ax, [line_x1]
    jne .notBreak
    mov ax, [line_y0]
    cmp ax, [line_y1]
    je .endWhile
    .notBreak:
    ;     e2 = 2 * error
    mov dx, [error_]
    shl dx, 1
    ;     if e2 >= dy
    cmp dx, [deltaY]
    jl .lowerDy
    ;         if x0 == x1 break
    mov ax, [line_x0]
    cmp ax, [line_x1]
    je .endWhile
    ;         error = error + dy
    mov ax, [deltaY]
    add [error_], ax
    ;         x0 = x0 + sx
    mov ax, [sx]
    add [line_x0], ax
    ;     end if
    .lowerDy:
    ;     if e2 <= dx
    cmp dx, [deltaX]
    jg .greaterDx
    ;         if y0 == y1 break
    mov ax, [line_y0]
    cmp ax, [line_y1]
    je .endWhile
    ;         error = error + dx
    mov ax, [deltaX]
    add [error_], ax
    ;         y0 = y0 + sy
    mov ax, [sy]
    add [line_y0], ax
    ;     end if
    .greaterDx:
    ; end while
    jmp .while
    .endWhile:

    ret

plot:
    ; Check for out of bounds
    cmp word [line_x0], 0
    jl .outOfBounds
    cmp word [line_x0], SCREEN_W
    jge .outOfBounds
    cmp word [line_y0], 0
    jl .outOfBounds
    cmp word [line_y0], SCREEN_H
    jge .outOfBounds

    ; Display
    mov ax, [line_y0]
    mov bx, SCREEN_W
    mul bx
    add ax, [line_x0]
    mov di, ax
    mov al, [line_colorIndex]
    stosb

    .outOfBounds:
    ret
