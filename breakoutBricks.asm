define random                                $fe
define keyboard                              $ff

define leftKey                               $61
define rightKey                              $64
define upKey                                 $77
define downKey                               $73

define appleL                                $00
define appleH                                $01
define paddleDirection                       $03
define paddleLength                          $04
define paddleStartL                          $05
define paddleStartH                          $06
define check                                 $07

define ballLocationL                         $08
define ballLocationH                         $09
define ballDirectionX                        $0a
define ballDirectionY                        $0b

define calculatedPositionL                   $0c
define calculatedPositionH                   $0d

define calculatedCollisionPositionL          $0e
define calculatedCollisionPositionH          $0f

define calculatedBrickCollisionPositionL     $10
define calculatedBrickCollisionPositionH     $11

define xShouldToggle                         $12
define yShouldToggle                         $13

define playerPoints                          $14


define paddleLeft                            1
define paddleRight                           2
define standStill                            4

define ballRight                             1
define ballLeft                              0
define ballUp                                1
define ballDown                              0

define true                                  1
define false                                 0
define black                                 0
define paddleColor                           $f
define ballColor                             $e
define brickStartColor                       $d

JSR init
JSR main

init:
  JSR initPaddle
  JSR initBall
  JSR initBricks
  RTS

initPaddle: 
  LDA #paddleRight
  STA paddleDirection
  LDA #$06
  STA paddleLength
  LDA #$a9
  STA paddleStartL
  LDA #$05
  STA paddleStartH
  RTS

initBall:
  LDA #$04
  STA ballLocationH
  STA calculatedPositionH
  STA calculatedCollisionPositionH
  LDA #$34
  STA ballLocationL
  STA calculatedPositionL
  STA calculatedCollisionPositionL
  LDA #ballRight
  STA ballDirectionX
  LDA #ballUp
  STA ballDirectionY
  RTS

initBricks:
  LDA #brickStartColor
  STA $0285
  STA $0287
  STA $0289
  STA $028b
  STA $028d
  STA $028f
  STA $0291
  STA $0293
  STA $0295
  STA $0297
  STA $0299

  STA $0305
  STA $0307
  STA $0309
  STA $030b
  STA $030d
  STA $030f
  STA $0311
  STA $0313
  STA $0315
  STA $0317
  STA $0319

  STA $0385
  STA $0387
  STA $0389
  STA $038b
  STA $038d
  STA $038f
  STA $0391
  STA $0393
  STA $0395
  STA $0397
  STA $0399
  RTS

main: 
  JSR getInput
  JSR updatePaddle
  JSR drawPaddle
  JSR updateBall
  JSR drawBall
  JSR spinWheels
  JMP main

getInput: 
  LDA keyboard
  CMP #leftKey
  BEQ setPaddleDirectionLeft
  CMP #rightKey
  BEQ setPaddleDirectionRight
  CMP #upKey
  BEQ setPaddleDirectionStill
  CMP #downKey
  BEQ setPaddleDirectionStill
  RTS

setPaddleDirectionLeft:
  LDX #paddleLeft
  STX paddleDirection
  RTS
setPaddleDirectionRight:
  LDX #paddleRight
  STX paddleDirection
  RTS
setPaddleDirectionStill:
  LDX #standStill
  STX paddleDirection
  RTS

updatePaddle:
  LDX paddleLength              ;load snake length
  DEX                           ;snake length - 1
updateLoop:
  LDA paddleDirection           ;load paddleDirection
  LSR                           ;left shift
  BCS paddleGoLeft              ;if a 1 'fell off' during last step, branch
  LSR
  BCS paddleGoRight
  RTS

paddleGoLeft:
  LDA paddleStartL
  AND #$1f
  CMP #$1f
  BEQ skipPaddleMoveLeft
  DEC paddleStartL
skipPaddleMoveLeft:
  RTS

paddleGoRight:
  LDA paddleStartL
  ADC paddleLength
  STA check
  LDA #$1f
  BIT check
  BEQ skipMoveRight
  INC paddleStartL
skipMoveRight:
  RTS

paddleStayStill:
  RTS

drawPaddle: 
  LDA #0
  LDY paddleLength
  INY
  STA (paddleStartL),Y
  LDA #paddleColor
  LDY paddleLength
drawLoop: 
  STA (paddleStartL),Y
  DEY
  BNE drawLoop
  LDA #0
  STA (paddleStartL),Y
  RTS

updateBall:
  JSR resetToggles
  JSR calculateBallCollision
  JSR checkPaddleCollision
  JSR checkBrickCollision
  JSR toggleDirections
  JSR calculateNextBallPositionY
  JSR calculateNextBallPositionX
  RTS

resetToggles:
  LDA #false
  STA xShouldToggle
  STA yShouldToggle
  RTS  

; COLLISION DETECTION
calculateBallCollision:
  JSR calculateBallCollisionY
  JSR calculateBallCollisionX
  RTS
calculateBallCollisionY:
  LDA ballDirectionY
  CMP #ballUp
  BEQ calculateUpCollision
  BNE calculateDownCollision
calculateBallCollisionX:
  LDA ballDirectionX
  CMP #ballLeft
  BEQ calculateLeftCollision
  BNE calculateRightCollision

calculateUpCollision:
  LDA ballLocationL
  SEC                                         
  SBC #$20                                    
  STA calculatedCollisionPositionL   
  BCC calculateUpToNextBlockCollision         
  RTS
calculateUpToNextBlockCollision:
  LDX ballLocationH
  DEX
  CPX #$1
  BEQ setToggleYTrue
  STX calculatedCollisionPositionH    
  RTS
calculateDownCollision:
  LDA ballLocationL
  CLC                                         
  ADC #$20                                    
  STA calculatedCollisionPositionL
  BCS calculateDownToNextBlockCollision
  JSR checkPaddleCollision
  RTS
calculateDownToNextBlockCollision:
  LDX ballLocationH
  INX
  STX calculatedCollisionPositionH
  RTS
calculateLeftCollision:
  LDX calculatedCollisionPositionL 
  DEX 
  STX calculatedCollisionPositionL
  ; check if hit left side  => toggle x
  TXA
  AND #$1f
  CMP #$1f
  BEQ setToggleXTrue
  RTS
calculateRightCollision:
  LDX calculatedCollisionPositionL 
  INX 
  STX calculatedCollisionPositionL
  LDA #$1f
  BIT calculatedCollisionPositionL
  BEQ setToggleXTrue
  RTS

checkPaddleCollision:
  LDY #0
  LDA (calculatedCollisionPositionL),Y    
  CMP #paddleColor
  BEQ setToggleYTrue
  RTS

setToggleXTrue: 
  LDA #true
  STA xShouldToggle
  RTS

setToggleYTrue: 
  LDA #true
  STA yShouldToggle
  RTS

checkBrickCollision:
  JSR calculateBrickCollisionPosition
  JSR detectBrickCollision
  RTS

calculateBrickCollisionPosition:
  LDX ballLocationH
  STX calculatedBrickCollisionPositionH
  JSR calculateBrickCollisionY
  JSR calculateBrickCollisionX
  RTS
calculateBrickCollisionY:
  LDA ballDirectionY
  CMP #ballUp
  BEQ calculateUpBrickCollision
  BNE calculateDownBrickCollision
calculateBrickCollisionX:
  LDA ballDirectionX
  CMP #ballLeft
  BEQ calculateLeftBrickCollision
  BNE calculateRightBrickCollision

calculateUpBrickCollision:
  LDA ballLocationL
  SEC                                  
  SBC #$20                                   
  STA calculatedBrickCollisionPositionL   
  BCC calculateUpToNextBlockBrickCollision         
  RTS
calculateUpToNextBlockBrickCollision:
  LDX ballLocationH
  DEX
  CPX #$1
  BEQ setToggleYTrue
  STX calculatedBrickCollisionPositionH   
  RTS
calculateDownBrickCollision:
  LDA ballLocationL
  CLC                                  
  ADC #$20                                 
  STA calculatedBrickCollisionPositionL
  BCS calculateDownToNextBlockBrickCollision
  RTS
calculateDownToNextBlockBrickCollision:
  LDX ballLocationH
  INX
  STX calculatedBrickCollisionPositionH
  RTS
calculateLeftBrickCollision:
  LDX calculatedBrickCollisionPositionL 
  DEX 
  STX calculatedBrickCollisionPositionL
  RTS
calculateRightBrickCollision:
  LDX calculatedBrickCollisionPositionL 
  INX 
  STX calculatedBrickCollisionPositionL
  RTS

detectBrickCollision:
  LDY #0
  LDA (calculatedBrickCollisionPositionL),Y
  CMP #$0e
  BCC maybeBrickCollision
  RTS
maybeBrickCollision:
  LDY #0
  LDA (calculatedBrickCollisionPositionL),Y
  CMP #0
  BNE brickCollisionDetected
  RTS
brickCollisionDetected:
  TAX
  DEX
  TXA
  STA (calculatedBrickCollisionPositionL),Y
  INC playerPoints
  JSR setToggleYTrue
  RTS
  
; TOGGLE DIRECTIONS
toggleDirections:
  JSR toggleDirectionsY
  JSR toggleDirectionsX
  RTS

toggleDirectionsY: 
  LDA yShouldToggle
  CMP #true
  BEQ changeYDirection
  RTS 

toggleDirectionsX:
  LDA xShouldToggle
  CMP #true
  BEQ changeXDirection
  RTS

changeYDirection:
  LDA ballDirectionY
  CMP #ballUp
  BEQ setBallDirectionYDown
  BNE setBallDirectionYUp 

setBallDirectionYDown:
  LDA #ballDown
  STA ballDirectionY
  RTS
setBallDirectionYUp:
  LDA #ballUp
  STA ballDirectionY
  RTS

changeXDirection: 
  LDA ballDirectionX
  CMP #ballRight
  BEQ setBallDirectionXLeft
  BNE setBallDirectionXRight 

setBallDirectionXRight:
  LDA #ballRight
  STA ballDirectionX
  RTS
setBallDirectionXLeft:
  LDA #ballLeft
  STA ballDirectionX
  RTS

; POSITION CALCULATION
calculateNextBallPositionY:
  LDA ballDirectionY
  CMP #ballUp
  BEQ calculateUp
  BNE calculateDown
calculateNextBallPositionX: 
  LDA ballDirectionX
  CMP #ballLeft
  BEQ calculateLeft
  BNE calculateRight
  
calculateLeft:
  LDX calculatedPositionL 
  DEX 
  STX calculatedPositionL
  RTS
calculateRight:
  LDX calculatedPositionL  
  INX 
  STX calculatedPositionL
  RTS
calculateUp:
  LDA ballLocationL 
  SEC                            ;set carry flag
  SBC #$20                       ;subtract with carry
  STA calculatedPositionL
  BCC calculateUpToNextBlock     ;branch if carry flag is clear (go up to 8x32 block above)
  RTS
calculateUpToNextBlock: 
  LDX ballLocationH
  DEX
  TXA
  CMP #$1
  BEQ skipToReturn
  STX calculatedPositionH
skipToReturn:
  RTS
calculateDown:
  LDA ballLocationL
  CLC                             ; clear carry flag
  ADC #$20                        ; add dec 32 with carry (one line down)
  STA calculatedPositionL
  BCS calculateDownToNextBlock   
  RTS
calculateDownToNextBlock:
  LDX ballLocationH
  INX
  STX calculatedPositionH
  RTS


drawBall:
; clear old location
  LDY #0
  LDA #black
  STA (ballLocationL),Y 
; paint new location
  LDA #ballColor
  STA (calculatedPositionL),Y
; update ball position
  LDA calculatedPositionL
  STA ballLocationL
  LDA calculatedPositionH
  STA ballLocationH
  RTS

collision:
  JMP gameOver

spinWheels:
  LDX #70  
spinLoop:
  NOP
  NOP
  DEX
  BNE spinLoop
  RTS

gameOver:
;game is over




