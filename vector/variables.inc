[Variables]
          ___      ___    __  ___  ___      __
||  / / //___) ) //   ) )  / /   //   ) ) //  ) )   ____
|| / / //       //        / /   //   / / //
||/ / ((____   ((____    / /   ((___/ / //
                                             _   ___     ))
    ___      ___      ___                  //  //   ) ) //
  //   ) ) //   ) ) //   ) ) //   / /     //    ___/ / //
 //       //   / / //___/ / ((___/ /     //   / ____/ //
((____   ((___/ / //            / /     ((   / /____ //

; DISPLAY
; ----------------------------------------

; Visualizer type
; Bar | Poly
Type=Poly

; Color of the Visualizer
; Custom | Chameleon
Color=Custom

; Custom color
; Integer, 0 - 255 each
Custom=255,255,255

; Chameleon color
; Foreground1/2 | Background1/2 | Light1/2/3/4 | Dark1/2/3/4 | Average
Chameleon=Foreground1

; Transparency of the Visualizer
; Integer, 0 - 255
Alpha=255

; Visualizer size multiplier
; Real, >= 0.0
Scale=1

; Height of the Visualizer
; Real, >= 0.0 | #WORKAREAHEIGHT# | #WORKAREAWIDTH# | #SCREENAREAHEIGHT# | #SCREENAREAWIDTH#
Height=300

; [POLY TYPE ONLY] Width of the Visualizer
; Real, >= 0.0 | #WORKAREAWIDTH# | #WORKAREAHEIGHT# | #SCREENAREAWIDTH# | #SCREENAREAHEIGHT#
Width=#WORKAREAWIDTH#

; [BAR TYPE ONLY] Width of each Visualizer bar
; Real, >= 0.0
BarWidth=1

; [BAR TYPE ONLY] Spacing in between each Visualizer bar
; Real, >= 0.0
BarSpacing=1

; [BAR TYPE ONLY] Size of round corners on each Visualizer bar
; Real, >= 0.0
BarRoundSize=0

; Minimum height
; Real, >= 0.0
BaseHeight=0

; Flip the Visualizer
; Yes | No
Invert=No

; Visualizer rotation in degrees
; Real
Angle=0

; BAND COUNT
; ----------------------------------------

; Number of bands the Visualizer will use (bar count)
; Integer, >= 0
Bands=256

; RESPONSE
; ----------------------------------------

; The channel bands will respond to
; FL | FR | C | LFE | BL | BR | SL | SR | Auto
Channel=Auto

; Minimum response frequency
; Real, >= 1.0
FreqMin=20

; Maximum response frequency
; Real, >= 1.0
FreqMax=16000

; Rising duration
; Integer, >= 0
Attack=0

; Falling duration
; Integer, >= 0
Decay=0

; Minimum band sensitivity
; Real, <= 0.0
MinSensitivity=-240

; Maximum band sensitivity
; Real, <= 0.0
MaxSensitivity=-18

; Volume calibration target
; Real, 0.0 - 1.0
VolumeTarget=0.95

; Use volume calibration (Right-click > Calibrate)
; Yes | No
NormalizeVolume=No

; Use spectrum calibration (Right-click > Calibrate)
; Yes | No
NormalizeSpectrum=No

; ACCURACY
; ----------------------------------------

; Band group count
; Integer, >= 1
Groups=6

; Band group cutoffs
; Real, 0.0 - 1.0
Cutoff0=0.71
Cutoff1=0.54
Cutoff2=0.25
Cutoff3=0.20
Cutoff4=0.15

; Band group accuracy
; Real, > 0.0
Accuracy0=30
Accuracy1=20
Accuracy2=12
Accuracy3=9
Accuracy4=8
Accuracy5=7

; Band group frame overlap
; Real, >= 1.0
Overlap0=2
Overlap1=3
Overlap2=8
Overlap3=12
Overlap4=15
Overlap5=15

; Method for processing FFT results
; None | Hann | Hamming | Kaiser | Exponential | Chebyshev
WindowFunction=Hann

; BAND CONTROL
; ----------------------------------------

; Exponential factor
; Gives louder bars more presence over quieter bars
; Real, > 0.0
Power=32

; Proc smoothing type
; Flat | Linear | Exponential
AvgType=Exponential

; Proc smoothing time in milliseconds
; Real, >= 0.0
AvgTime=16

; Proc smoothing factor (for Exponential smoothing type)
; Real, > 0.0
AvgBase=2
