; Author: Michael Ruddy, Michael Sherrick, Esai Ulloa
; Class: CIS123 Assembly Language
; File Name: Final_Project_WinLose.asm
; Creation Date: 5/9/2020
; Program Description: This is the input phase of the application. It prompts user for player names then runs 
;                       a simulated 8 ball pool game prompting
;                      the user to enter if a player successfully sunk a ball, missed, or scratched. The program
;                      switches turns when appropriate and determines when the game is over. Balls that have
;                      already been sunk are not accepted. 

Include Final_Project_Include.inc

.data
    winnerPrompt BYTE " is the 8 ball pool grand champion of the world!",0  ; Message for the winner.

.code
;-----------------------------------
WinLose PROC,
    player1: PTR BYTE,
    player2: PTR BYTE,
    totalBalls: PTR SBYTE,     ; Pointer to the total number of balls.
    p1Balls: PTR BYTE,         ; Pointer to balls sunk by player 1.
    p2Balls: PTR BYTE,         ; Pointer to balls sunk by player 2.
    p1Counter: DWORD,          ; Counter for player 1.
    p2Counter: DWORD,          ; Counter for player 2.
    pTurn: BYTE                ; Player turn indicator (0 for player 1, 1 for player 2).

;-----------------------------------
    pushad                      ; Save registers.

    ; Determine whose turn it is.
    .IF pTurn == 0
        mov ebx, p1Balls        ; Player 1's balls.
        mov ecx, p1Counter      ; Player 1's counter.
    .ELSE 
        mov ebx, p2Balls        ; Player 2's balls.
        mov ecx, p2Counter      ; Player 2's counter.
    .ENDIF

    mov edx, 0

Winner:
    mov eax, 0
    mov ah, 69                   
    
    ; Check if the ball has not been sunk or scratched.
    .IF [ebx] != al && [ebx] != ah
        inc edx                  ; Increment the count of unsunk balls.
    .ENDIF

    inc ebx                      ; Move to the next ball.
    loop Winner

    ; Determine the winner and update the ball count.
    .IF edx == 7 && pTurn == 0
        mov edx, player1         ; Player 1 wins.
        mov al, 8                
        mov [ebx], al            ; Update the ball status.
        INVOKE AddToTotal,
            totalBalls,
            p1Counter,
            p2Counter
    .ELSEIF edx == 7 && pTurn != 0
        mov edx, player2         ; Player 2 wins.
        mov al, 8                
        mov [ebx], al            ; Update the ball status.
        INVOKE AddToTotal,
            totalBalls,
            p1Counter,
            p2Counter
    .ELSEIF edx != 7 && pTurn == 0
        mov edx, player2         ; Player 2 wins.
        mov al, 88               
        mov [ebx], al            ; Update the ball status.
        INVOKE AddToTotal,
            totalBalls,
            p1Counter,
            p2Counter
    .ELSEIF edx != 7 && pTurn != 0
        mov edx, player1         ; Player 1 wins.
        mov al, 88               
        mov [ebx], al            ; Update the ball status.
        INVOKE AddToTotal,
            totalBalls,
            p1Counter,
            p2Counter
    .ENDIF

    call WriteString             ; Display the winner's name.
    mov edx, OFFSET winnerPrompt ; Load the winner's message.
    call WriteString             ; Display the message.

    popad                        ; Restore registers.
    ret

WinLose ENDP
END

