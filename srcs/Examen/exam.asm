[map symbols exam.map]
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
%define LINE_IMPLEMENTATION_LEVEL 5

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
    movedX   resw 1
    movedY   resw 1

section .text

; Defining the screen size
%define SCREEN_W 320
%define SCREEN_H 200

; -------------------------------------
; Draw a line:
drawLine:
    ; TODO
    ; Idea: Add padding to the implementations and use a relative jump instead
    ; => "jump by" LINE_IMPLEMENTATION_LEVEL * size_of_implementation + offset
    ; Idea 2 (simpler): Use the preprocessing by concatenating "implementation"
    ; with the actual number
    ; => jmp implementation(LINE_IMPLEMENTATION_LEVEL)
    %if (LINE_IMPLEMENTATION_LEVEL == 1)
    jmp implementation1
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 2)
    jmp implementation2
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 3)
    jmp implementation3
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 4)
    jmp implementation4
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 5)
    jmp implementation5
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 6)
    jmp implementation6
    %endif
    %if (LINE_IMPLEMENTATION_LEVEL == 7)
    jmp implementation7
    %endif
    ; Value out of bounds
    ret

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
    ; al: Pixel color
    ; bx: Index of the pixel in memory
    ; cx: Pixel's X position

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
    ; al: Pixel color
    ; bx: Index of the pixel in memory
    ; cx: Pixel counter

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
    ; al: Pixel color
    ; bx: Index of the pixel in memory
    ; cx: Pixel's Y position

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
    ; Note to self: Review Bresenham without floating points
    ; Note to self: Learn how to use the FPU

    ; al: Pixel color and temporary variable
    ; bx: Index of the pixel in memory
    ; cx: Pixel's X position

    ; TODO: Current program assumes x1 - x0 > y1 - y0
    ; Needs to be able to switch which variable is incremented

    ; Calculate the slope
    mov ax, [line_x1]
    sub ax, [line_x0]
    mov [deltaX], ax
    mov word [movedX], 0
    mov ax, [line_y1]
    sub ax, [line_y0]
    mov [deltaY], ax
    mov word [movedY], 0
    ; Load the segment address
    mov ax, [line_frameBufferSeg]
    mov es, ax
    ; Select the starting position
    mov ax, [line_y0]
    mov bx, SCREEN_W
    mul bx
    mov bx, ax
    add bx, [line_x0]
    ; Loop through the whole line
    mov cx, [line_x0]
    mov dx, 0
    .loop:
    mov di, bx
    ; Draw the pixel
    mov al, [line_colorIndex]
    stosb
    ; Increment the positions
    inc cx
    inc word [movedX]
    inc bx
    ; Calculate our position to the slope
    push cx
    push dx
    mov ax, [deltaY]
    mov cx, [movedX]
    mul cx
    push ax
    mov ax, [deltaX]
    mov cx, [movedY]
    mul cx
    pop cx
    sub ax, cx ; ax = (dY*mX - dX*mY) => Positive if above slope
    pop dx
    pop cx
    cmp ax, 0
    ; Increment if necessary
    jge .noYoffset
    add bx, SCREEN_W
    inc word [movedY]
    .noYoffset:
    ; Loop
    cmp cx, [line_x1]
    jbe .loop
    ret

implementation6:
    ; TODO
    ret

implementation7:
    ; TODO
    ret