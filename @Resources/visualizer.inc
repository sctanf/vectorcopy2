[Rainmeter]
Update=16
RightMouseUpAction=[!SkinCustomMenu]
ContextTitle=Calibrate Fast
ContextAction=[!CommandMeasure Processor calibrate(5)][!SetOption Rainmeter ContextTitle "Cancel Calibration"][!SetOption Rainmeter ContextAction "[!CommandMeasure Processor calibrate(0)]"][!SetOption Rainmeter ContextTitle2 ""][!SkinCustomMenu]
ContextTitle2=Calibrate Accurate
ContextAction2=[!CommandMeasure Processor calibrate(30)][!SetOption Rainmeter ContextTitle "Cancel Calibration"][!SetOption Rainmeter ContextAction "[!CommandMeasure Processor calibrate(0)]"][!SetOption Rainmeter ContextTitle2 ""][!SkinCustomMenu]
ContextTitle3=Calibrate Manual
ContextAction3=[!CommandMeasure Processor calibrate(-1)][!SetOption Rainmeter ContextTitle "Finish Calibration"][!SetOption Rainmeter ContextAction "[!CommandMeasure Processor calibrate(-1)]"][!SetOption Rainmeter ContextTitle2 "Cancel Calibration"][!SetOption Rainmeter ContextAction2 "[!CommandMeasure Processor calibrate(0)]"][!SetOption Rainmeter ContextTitle3 ""][!SkinCustomMenu]
ContextTitle4=---
ContextTitle5=Settings...
ContextAction5=["#CURRENTPATH#variables.inc"]
ContextTitle6=Rainmeter...
ContextAction6=[!SkinMenu]
@IncludeDefaultVariables=#@#defaultvariables.inc
@IncludeVariables=#CURRENTPATH#variables.inc
@IncludeType=#@##Type#.inc
@IncludeParent=#CURRENTPATH#parent.inc
@IncludeBands=#CURRENTPATH#bands.inc

[Update]
Measure=Calc
OnUpdateAction=[!Delay 0][!Update]

[Desktop]
Measure=Plugin
Plugin=Chameleon
Type=Desktop
OnChangeAction=[!UpdateMeasure C1][!UpdateMeasure C2][!UpdateMeasure C3]
ContextAwareColors=0

[C1]
Measure=Plugin
Plugin=Chameleon
Parent=Desktop
Color=#Chameleon#
Format=Dec
UpdateDivider=-1
RegExpSubstitute=1
Substitute="(.*),.*,.*":"\1"
[C2]
Measure=Plugin
Plugin=Chameleon
Parent=Desktop
Color=#Chameleon#
Format=Dec
UpdateDivider=-1
RegExpSubstitute=1
Substitute=".*,(.*),.*":"\1"
[C3]
Measure=Plugin
Plugin=Chameleon
Parent=Desktop
Color=#Chameleon#
Format=Dec
UpdateDivider=-1
RegExpSubstitute=1
Substitute=".*,.*,(.*)":"\1"

[Volume]
Measure=Plugin
Plugin=Win7AudioPlugin
UpdateDivider=-1
Disabled=1

[Processor]
Measure=Script
ScriptFile=#@#visualizer.lua
Disabled=1
