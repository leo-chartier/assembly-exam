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
%define LINE_IMPLEMENTATION_LEVEL 1

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

section .text

; Defining the screen size
%define SCREEN_W 320
%define SCREEN_H 200

; -------------------------------------
; Draw a line:
drawLine:
    ; ! Insert your line drawing code here !

    ; Here is just a tiny snippet to draw a pixel (you should expand/replace it, obviously)
    ; Draws a pixel at 160x100
    mov ax, [line_frameBufferSeg]
    mov es, ax
    mov ax, 100     ; load y
    mov bx, SCREEN_W
    mul bx
    add ax, 160     ; load x
    mov di, ax
    mov al, 0fh     ; set arbitrary color index.
    stosb
    ret

