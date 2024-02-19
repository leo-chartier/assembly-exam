[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/FntXziri)
# ALGOSUP 2023-2024 x86 assembly exam.

This is the repository for the x86 assembly exam.

## Setup

### Windows:

For Windows developers, you will need to have **DOSBox** installed in the default location.
[DOSBox link](https://www.dosbox.com/download.php?main=1)

**Nasm** binary (for Windows) is already baked inside the repository.

### MacOS:

You need to install **DOSBox** and **nasm** through _brew_.

    $ brew install dosbox
    [...]
    $ brew install nasm

## Overview

The goal of this exam is to implement a line drawing function in full _x86_ assembly.

We provide you the testbed, and you'll have just to implement the function, and specify which _level_ you have implemented.

Parameters will be filled by the test bed for you.

There are 7 levels of implementation:

1. Draw an horizontal line filling the width of the screen _(use only line\_colorIndex and line\_y0)_.
2. Draw an horizontal segment between the specified X coordinates _(use only line\_colorIndex, line\_y0, and line\_x0 to line\_x1)_.
3. Draw an vertical line filling the height of the screen _(use only line\_colorIndex and line\_x0)_.
4. Draw an vertical segment between the specified Y coordinates _(use only line\_colorIndex, line\_x0, and line\_y0 to line\_y1)_.
5. Draw an arbitrary segment between (x0,y0) and (x1,y1). _(**x0 \<= x1** and **y0 \<= y1**, both points in screen)_
6. Draw an arbitrary segment between (x0,y0) and (x1,y1). _(unsorted x's and y's both points in screen)_
7. Draw an arbitrary segment between (x0,y0) and (x1,y1) and clip it. _(p0 and p1 can be outside the screen)_

You can proceed iteratively and raise the reached level on each step, or, if you feel inspired,
you can start to implement directly your targeted level.

Reminder:
* Framebuffer resolution is 320x200 pixels.
* Color type is one byte per pixel (a pixel palette index)
* Origin for the coordinates will be on the top left corner, x's growing to the right, y's growing downward.

## Project layout

There are two scripts (for each system) for your test:

* _srcs/Examen/build-exam.cmd_ (Windows) and _srcs\Examen\build-exam.bash_ (Mac) to build the test program.
* _launch-dosbox.cmd_ (Windows) and _launch-dosbox.bash_ (Mac) to run **DOSBox** and execute the test bed.

**Note:** On _Windows_, you can double click on the _*.cmd_ file to launch it. On Mac, you have to run the _*.bash_ files from the
terminal (<code>$ bash build-exam.bash</code>).

And there's the main file where you'll implement your algorithm: _srcs/Examen/exam.asm_

You'll specify the line implementation "level" (see above), modifying the value here:

    %define LINE_IMPLEMENTATION_LEVEL 1

And you just implement the function named _drawLine_, just below:

    drawLine:
        ; Insert your line drawing code here:

        ; <There's a dummy pixel writer here for your convenience>

        ret

The test bed will feed the line parameters with data set for each level test.

    line_frameBufferSeg resw 1      ; Base segment where to display (it can be somewhere else than video memory)
    line_colorIndex     resb 1      ; The color to use to draw the line.
    line_x0  resw 1     ; p0
    line_y0  resw 1
    line_x1  resw 1     ; p1
    line_y1  resw 1

**Note** that the framebuffer memory segment you need to write into is provided to you through _line\_frameBufferSeg_ (instead of 0xa000).

### MacOS users:

Reminder, you can make both scripts executable with:

    $ chmod +x srcs/Examen/build-exam.bash
    $ chmod +x launch-dosbox.bash


## Test bed flow

The program will follow this flow:

1. Initialize memory and graphic mode.
2. Call your _drawLine_ multiple times, feeding the parameters with level data set values.
3. Present back buffer to video memory.
4. Wait for **ESC** key to be pressed.
5. Returns to prompt.

## Some advices

You will have your own repository for the exam (see _github classroom_).

Remember to commit **often** to your repository clone, more over when you have a
working version of your line drawing function (implementing iteratively each level).

Also you have **nasm** and the intel 486 programming references in the _\\docs_ directory.

[NASM HTML](docs/nasmdoc-html/nasmdoc0.html)

[NASM PDF](docs/nasmdoc.pdf)

[i486 Programmer Reference](docs/i486_Processor_Programmers_Reference_Manual_1990.pdf)

You also have access to _Turbo Debugger_ inside _/bin_ (Or your **C:\\\>** disk within DOSBox).

## Final words

Good luck !

