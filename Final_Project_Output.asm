; Author: Michael Ruddy, Michael Sherrick, Esai Ulloa
; Class: CIS123 Assembly Language
; File Name: Final_Project_Output.asm
; Creation Date: 5/9/2020
; Program Description: This is the output phase of the application where the game recap is built from
;                       memory with the data gathered during the input phase.

INCLUDE Final_Project_Include.inc
.data
	currentP BYTE 0
	missedPrompt BYTE " missed his shot",0
	scratchedPrompt BYTE " sunk the white ball like a battleship",0
	sunk8L BYTE " sunk the 8 ball early, giving the victory to ",0
	sunk8W BYTE " sunk the 8 ball for a victory",0
	wrongBall BYTE " sunk the opponents ",0
	pastIndex DWORD 0FFFFFFFFh
.code
;----------------------------------------
Output PROC,
    player1: PTR BYTE,
    player2: PTR BYTE,
    totalBalls: PTR SBYTE,
    pSolids: BYTE                   ; Player solids status.

;------------------------------------------
    mov bl, 81                      ; Establish single byte comparators.
    mov bh, 69
    mov cl, 8
    mov ch, 88
    mov eax,0
    call WaitMsg                    ; Wait for the user to see the winner.
    call ClrScr                     ; Clear the screen.
    mov edx, OFFSET sunk8W          ; Load the message for a successful 8 ball win.
    call WriteString                ; Display the message.
    call Crlf                       ; Move to the next line.

    mov esi, totalBalls             ; Initialize esi with the pointer to totalBalls.

gameloop:
    mov ah, [esi]                   ; Load the current ball status.
    mov al, ah
    neg al                          ; Use this to switch players

    ; OR 
    .IF [esi] < al
        mov edx, player1            ; Set edx to player1 if it's their turn.
        mov pTurn, 0                ; Set pTurn to 0 to indicate player1's turn.
    .ELSE
        mov edx, player2            ; Set edx to player2 if it's their turn.
        mov pTurn, 1                ; Set pTurn to 1 to indicate player2's turn.
    .ENDIF

    call WriteString                ; Display the current player's name.

    ; Check various conditions based on the current ball status.
    .IF al == cl || ah == cl        ; If the current player sunk the 8 ball at the right time.
        mov edx, OFFSET sunk8W
        call WriteString            ; Display the message for a successful 8 ball win.
        call Crlf
        jmp GameOver                ; Jump to the GameOver section.
    .ELSEIF [esi] == ch || ah == ch ; If the current player sunk the 8 ball early.
        mov edx, OFFSET sunk8L
        call WriteString            ; Display the message for early 8 ball loss.
        call Crlf
        jmp GameOver                ; Jump to the GameOver section.
    .ELSEIF (ah > cl && pSolids != 0 && pTurn == 0) || (pSolids == 0 && al > cl && pTurn == 1) ; If the current player sunk their ball.
        jmp ballMade
    .ELSEIF (pSolids == 0 && ah < cl && pTurn == 0) || (pSolids != 0 && al < cl && pTurn == 1) ; If the current player sunk their ball.
        jmp ballMade
    .ELSEIF (ah > cl && pSolids != 0 && pTurn == 1) || (pSolids == 0 && al > cl && pTurn == 0) ; If the player sunk the opponent's ball.
        jmp wrong
    .ELSEIF (pSolids == 0 && pTurn == 1 && ah < cl) || (pSolids != 0 && pTurn == 0 && al < cl) ; If the player scratched.
        jmp wrong
    .ELSEIF [esi] == bh || ah == bh ; If the current player scratched.
        mov edx, OFFSET scratchedPrompt
        call WriteString            ; Display the message for scratching.
        call Crlf
        inc esi
    .ELSEIF [esi] == bl || ah == bl ; If the current player missed.
        mov edx, OFFSET missedPrompt
        call WriteString            ; Display the message for a missed shot.
        call Crlf
        jmp gameloop
        inc esi
    .ENDIF                          ; Write details of the turn to the output file.

ballMade:
    push edx                        ; Preserve edx register.
    mov edx, OFFSET ballMadePrompt  ; Load the message for a successful ball sink.
    call WriteString                ; Display the message.
    pop edx                         ; Restore edx.

    ; Check if the current player is player2.
    .IF edx == player2
        jmp skl                     
    .ENDIF

    neg al                         

skl:                                ; skl - sunk legal ball
    mov ah, 0                       ; Clear ah register.
    call WriteInt                   ; Write Ball #
    call Crlf                       ; Move to the next line.
    inc esi                         ; Move to the next ball.
    jmp gameLoop                    ; Continue the game loop.

wrong:
    push edx                        ; Preserve edx register.
    mov edx, OFFSET wrongBall       ; Load the message for a wrong ball sink.
    call WriteString                ; Display the message.
    pop edx                         ; Restore edx.

    ; Check if the current player is player2.
    .IF edx == player2
        jmp ski                     
    .ENDIF

    neg al                          

ski:                                ; ski - sunk illegal ball
    mov ah, 0                       ; Clear ah register.
    call WriteInt                   ; Write ball #
    call Crlf                       ; Move to the next line.
    inc esi                         ; Move to the next ball.
    jmp gameLoop                    ; Continue the game loop.
