function Initialize()
	local version = '010000'
	local parent = [=[
[P]
Measure=Plugin
Plugin=AudioAnalyzer_1_1
Disabled=1
Type=Parent
MagicNumber=104
Processing=0
Processing_0=Channels #Channel# | Handlers ]=]
	local processing = ',PNUMH1,PNUMH2,PNUMH3,PNUMH4,NUM'
	local group = [=[
Handler_PNUMH1=Type FFT | BinWidth #AccuracyNUM# | OverlapBoost #OverlapNUM# | CascadesCount #CascadesNUM# | WindowFunction #WindowFunction#
Handler_PNUMH2=Type BandResampler | Source PNUMH1 | Bands Log (#Bands#+1) #FreqMin# #FreqMax#
Handler_PNUMH3=Type TimeResampler | Source PNUMH2 | Granularity 16 | Attack #Attack# | Decay #Decay#
Handler_PNUMH4=Type UniformBlur | Source PNUMH3 | Radius #Blur#
Handler_NUM=Type ValueTransformer | Source PNUMH4 | Transform dB Map[From #MinSensitivity# : #MaxSensitivity#]
]=]
	local band = [=[
[NUM]
Measure=Plugin
Plugin=AudioAnalyzer_1_1
Type=Child
Parent=P
ValueId=0
Index=NUM
Channel=#Channel#
]=]
	bands = SKIN:GetVariable('Bands', 0)
	local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'bands.inc')
	if file then
		fileversion = file:read()
		bandCount = file:read()
		file:close()
	end
	if (bands ~= (bandCount or nil)) or (fileversion ~= version) then
		local section = {version..string.char(10)..bands..string.char(10)}
		for i=1,bands+1 do
			section[i+1] = string.gsub(band, 'NUM', i-1)
		end
		local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'bands.inc', 'w')
		file:write(table.concat(section))
		file:close()
	end
	
	groups = SKIN:GetVariable('Groups', 0)
	local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'parent.inc')
	if file then
		fileversion = file:read()
		groupCount = file:read()
		file:close()
	end
	if (groups ~= (groupCount or nil)) or (fileversion ~= version) then
		local section = {version..string.char(10)..groups..string.char(10)..parent..'P0H1,P0H2,P0H3,P0H4,0'}
		for i=1,groups-1 do
			section[i+1] = string.gsub(processing, 'NUM', i)
		end
		section = {table.concat(section)..string.char(10)}
		for i=1,groups do
			section[i+1] = string.gsub(group, 'NUM', i-1)
		end
		local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'parent.inc', 'w')
		file:write(table.concat(section))
		file:close()
	end
	
	local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'variables.inc')
	if file then
		file:close()
	else
		os.execute('copy "' .. SKIN:GetVariable('@') .. 'defaultvariables.inc" "' .. SKIN:GetVariable('CURRENTPATH') .. 'variables.inc"')
	end
	
	if (bands ~= (bandCount or nil)) or (groups ~= (groupCount or nil)) or (fileversion ~= version) then
		SKIN:Bang('!Refresh')
		return
	end
	
	--load calibration file
	local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'calibration.txt')
	if file then
		bandCount = file:read()
		if bands == bandCount then
			bCal = {}
			for i=1,bands do
				bCal[i] = file:read()
			end
		end
		file:close()
	end
	
	--display calibration file
	if bCal then
		local bCalMax = 0
		for i=1,bands do
			if bCal[i] - 1 > bCalMax then bCalMax = bCal[i] - 1 end
		end
		SKIN:Bang('!SetOption', 'Calibration', 'Path', '0,0|LineTo0,0')
		SKIN:Bang('!SetOption', 'Calibration', 'Shape', 'PathPath|StrokeColorFFFFFF|StrokeWidth1')
		path = {'0,' .. (1-(bCal[1]-1)/bCalMax)*32}
		for i=1,bands do
			path[i*2] = '|LineTo' .. (i-1)*500/(bands-1) .. ','
		end
		local p = path
		for i=1,bands do
			p[i*2+1] = (1-(bCal[i]-1)/bCalMax)*32
		end
		SKIN:Bang('!SetOption', 'Calibration', 'Path', table.concat(p))
	end
	
	--timer
	st = 0
	el = 0
	st2 = os.clock()
	el2 = 0
	st3 = os.clock()
	el3 = 0
	st4 = os.clock()
	el4 = 0
	eli = 0
	frametimeStart = os.clock()
	frametimeIndex = 0
	frametimeAvg = {}
	frametimeSize = 16
	for i=1,frametimeSize do
		frametimeAvg[i] = 0
	end
	--timer
	
	visType = string.upper(SKIN:GetVariable('Type', 'BAR'))
	visType = ((visType == "BAR" and 1) or (visType == "POLY" and 2)) or 1
	
	colorType = string.upper(SKIN:GetVariable('Color', 'CUSTOM'))
	colorType = ((colorType == "CUSTOM" and 1) or (colorType == "CHAMELEON" and 2)) or 1
	
	scale = SKIN:GetVariable('Scale', 1)
	
	barSpacing = SKIN:GetVariable('BarSpacing', 0)
	width = SKIN:GetVariable('Width', 0)
	barWidth = SKIN:GetVariable('BarWidth', 0)
	barRoundSize = SKIN:GetVariable('BarRoundSize', 0)
	height = SKIN:GetVariable('Height', 0)
	baseHeight = SKIN:GetVariable('BaseHeight', 0)
	trueHeight = height-baseHeight
	
	invert = string.upper(SKIN:GetVariable('Invert', 'NO'))
	invert = ((invert == "YES" and 1) or (colorType == "NO" and 2)) or 2
	
	avgType = string.upper(SKIN:GetVariable('AvgType', 'FLAT'))
	avgType = (((avgType == "FLAT" and 1) or (avgType == "LINEAR" and 2)) or (avgType == "EXPONENTIAL" and 3)) or 1
	avgConst = 1
	weight = 1
	avgSizeOld = 0
	avgSize = 1
	avgTime = SKIN:GetVariable('AvgTime', 0)
	avgBase = SKIN:GetVariable('AvgBase', 1)
	avgIndex = 0
	
	calTime = 0
	calIndex = 0
	calCancel = false
	
	power = SKIN:GetVariable('Power', 1)
	
	bSrc = {}
	bAvg = {{}}
	cutoff = {}
	
	for i=1,avgTime do
		bAvg[i] = {}
	end
	
	for i=1,groups-1 do
		cutoff[i] = SKIN:GetVariable('Cutoff' .. i-1, 0)
	end
	
	for i=1,bands do
		bSrc[i] = SKIN:GetMeasure(i)
		for j=groups-1,1,-1 do
			if i<bands*cutoff[j] then
				SKIN:Bang('!SetOption', i, 'ValueId', j)
				break
			end
		end
	end
	
	if colorType == 1 then
		SKIN:Bang('!SetOption', 'Shape', 'Color', 'FillColor#Custom#,#Alpha#|StrokeWidth0')
	elseif colorType == 2 then
		SKIN:Bang('!SetOption', 'Shape', 'Color', 'FillColor[RGB],#Alpha#|StrokeWidth0')
	end
	
	if visType == 1 then
		SKIN:Bang('!SetOption', 'Shape', 'TransformationMatrix', '(Cos(-#Angle#%360*Pi/180));(-Sin(-#Angle#%360*Pi/180));(Sin(-#Angle#%360*Pi/180));(Cos(-#Angle#%360*Pi/180));(((90<#Angle#%360)&(#Angle#%360<270)?Abs(Cos(#Angle#%360*Pi/180))*(#BarWidth#+#barSpacing#)*#Bands#*#Scale#:0)+((0<#Angle#%360)&(#Angle#%360<180)?Abs(Sin(#Angle#%360*Pi/180))*#Height#*#Scale#:0));(((180<#Angle#%360)&(#Angle#%360<360)?Abs(Sin(#Angle#%360*Pi/180))*(#BarWidth#+#barSpacing#)*#Bands#*#Scale#:0)+((90<#Angle#%360)&(#Angle#%360<270)?Abs(Cos(#Angle#%360*Pi/180))*#Height#*#Scale#:0))')
		SKIN:Bang('!SetOption', 'Shape', 'Shape', 'Rectangle0,0,0,0')
		bar = {'Rectangle', '', ',' .. height*scale .. ',' .. barWidth*scale .. ',', '', ',' .. barRoundSize*scale .. '|ExtendColor'}
	elseif visType == 2 then
		SKIN:Bang('!SetOption', 'Shape', 'TransformationMatrix', '(Cos(-#Angle#%360*Pi/180));(-Sin(-#Angle#%360*Pi/180));(Sin(-#Angle#%360*Pi/180));(Cos(-#Angle#%360*Pi/180));(((90<#Angle#%360)&(#Angle#%360<270)?Abs(Cos(#Angle#%360*Pi/180))*#Width#*#Scale#:0)+((0<#Angle#%360)&(#Angle#%360<180)?Abs(Sin(#Angle#%360*Pi/180))*#Height#*#Scale#:0));(((180<#Angle#%360)&(#Angle#%360<360)?Abs(Sin(#Angle#%360*Pi/180))*#Width#*#Scale#:0)+((90<#Angle#%360)&(#Angle#%360<270)?Abs(Cos(#Angle#%360*Pi/180))*#Height#*#Scale#:0))')
		SKIN:Bang('!SetOption', 'Shape', 'Path', '0,0|LineTo0,0')
		SKIN:Bang('!SetOption', 'Shape', 'Shape', 'PathPath|ExtendColor')
		--SKIN:Bang('!SetOption', 'Shape', 'Shape', 'PathPath|FillColor000000|StrokeWidth0')
		--SKIN:Bang('!SetOption', 'Shape', 'Shape2', 'Rectangle0,0,' .. width*scale .. ',' .. height*scale .. '|ExtendColor')
		--SKIN:Bang('!SetOption', 'Shape', 'Shape3', 'Combine Shape2|IntersectShape')
		path = {'0,' .. height*scale}
		for i=1,bands do
			path[i*2] = '|LineTo' .. (i-1)*width/(bands-1)*scale .. ','
		end
		path[2+bands*2] = '|LineTo' .. width*scale .. ',' .. height*scale .. '|Closepath1'
	end
	
	SELF:Enable()
end
function Update()
	--make calibration file
	if calibrating then
		calIndex = calIndex + 1
		local bCalc = {}
		for i=1,bands do
			local b = bSrc[i]:GetValue()
			if b < 0 then
				bCalc[i] = 0
			else
				bCalc[i] = b
			end
		end
		bAvg[calIndex] = bCalc
		
		if not calTime then return end
		if os.clock()-calStartTime < calTime then return end
		SKIN:Bang('PlayStop')
		if not calCancel then
			local bCal = {}
			local bMax = 0
			for i=1,bands do
				local out = 0
				for j=1,calIndex do
					out = out + bAvg[j][i]
				end
				if out > bMax then bMax = out end
				bCal[i] = out
			end
			for i=1,bands do
				bCal[i] = bMax/bCal[i]..string.char(10)
			end
			local file = io.open(SKIN:GetVariable('CURRENTPATH') .. 'calibration.txt', 'w')
			if not calCancel then file:write(bands..string.char(10)..table.concat(bCal)) end
			file:close()
		end
		if volume then SKIN:Bang('!CommandMeasure Volume "SetVolume ' .. volume .. '"') end
		SKIN:Bang('!Refresh')
		return
	end
	
	--timer
	st=os.clock()
	--timer
	
	local c = {}
	local bCalc = {}
	--avgIndex = (avgIndex + 1) % avgSize
	avgIndex = 0
	k = avgIndex + 1
	for i=1,bands do
		local b = bSrc[i]:GetValue()
		if bCal then
			b = b * bCal[i]
		end
		if b < 0 then
			bCalc[i] = 0
		else
			bCalc[i] = b^power
		end
	end
	table.insert(bAvg,k,bCalc)
	--for i=avgSize-1,1,-1 do
	--	bAvg[i+1] = bAvg[i]
	--end
	--bAvg[k] = bCalc
	
	--timer
	--el=os.clock()-st;
	el=(el*eli+(os.clock()-st))/(eli+1);
	st4=os.clock()
	--timer
	
	local bMax = 0
	if tonumber(avgSize) > 1 then
		for i=1,bands do
			local out = 0
			--if avgType == 1 then
			--	for j=1,avgSize do
			--		out = out + (bAvg[j][i] or 0)
			--	end
			--	out = out * avgConst
			--elseif avgType == 2 then
			--	k = avgIndex + 1
			--	for j=1,avgSize do
			--		out = out + (bAvg[k][i] or 0) * j
			--		k = k % avgSize + 1
			--	end
			--	out = out * avgConst
			--elseif avgType == 3 then
			--	k = avgIndex + 1
			--	avgWeight = 0
			--	weight = 1
			--	for j=1,avgSize do
			--		out = out + (bAvg[k][i] or 0) * weight
			--		weight = weight * avgBase
			--		k = k % avgSize + 1
			--	end
			--	out = out * avgConst
			--else
			--	out = bAvg[k][i]
			--end
			if avgType == 1 then
				for j=avgSize,1,-1 do
					out = out + (bAvg[j][i] or 0)
				end
				out = out * avgConst
			elseif avgType == 2 then
				for j=avgSize,1,-1 do
					out = out + (bAvg[j][i] or 0) * j
					k = k % avgSize + 1
				end
				out = out * avgConst
			elseif avgType == 3 then
				avgWeight = 0
				weight = 1
				for j=avgSize,1,-1 do
					out = out + (bAvg[j][i] or 0) * weight
					weight = weight * avgBase
				end
				out = out * avgConst
			else
				out = bAvg[1][i]
			end
			if out > bMax then bMax = out end
			c[i] = out
		end
	else
		for i=1,bands do
			local out = bAvg[k][i]
			if out > bMax then bMax = out end
		end
		c = bAvg[k]
	end
	SKIN:Bang('!SetOption','TimeMeter','Shape14','Rectangle0,0,' .. math.min((bMax-1)*500,500) .. ',8|FillColorFFFFFF|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape16','Rectangle0,0,' .. math.min((bMax-2)*500,500) .. ',8|FillColorFF0000|StrokeWidth0')
	SKIN:Bang('!SetOption','Multiplier','Text',string.format("%.2f",bMax));
	
	--timer
	--el4=os.clock()-st4;
	el4=(el4*eli+(os.clock()-st4))/(eli+1);
	st2=os.clock()
	--timer
	
	if bMax < 1/1000 then
		SKIN:Bang('!DisableMeasure', 'Update')
		--SKIN:Bang('!HideMeter', 'Shape')
	else
		SKIN:Bang('!EnableMeasure', 'Update')
		if bMax > 1 then print(bMax) else bMax = 1 end
		if invert == 1 then
			if visType == 1 then
				local p = bar
				local spacing = (barSpacing+barWidth)*scale
				for i=1,bands do
					p[2] = (i-1)*spacing
					p[4] = (-baseHeight-(trueHeight)*c[bands+1-i]/bMax)*scale
					SKIN:Bang('!SetOption', 'Shape', 'Shape' .. i+1, table.concat(p))
				end
			elseif visType == 2 then
				local p = path
				for i=1,bands do
					p[i*2+1] = (trueHeight-trueHeight*c[bands+1-i]/bMax)*scale
				end
				SKIN:Bang('!SetOption', 'Shape', 'Path', table.concat(p))
			end
		else
			if visType == 1 then
				local p = bar
				local spacing = (barSpacing+barWidth)*scale
				for i=1,bands do
					p[2] = (i-1)*spacing
					p[4] = (-baseHeight-(trueHeight)*c[i]/bMax)*scale
					SKIN:Bang('!SetOption', 'Shape', 'Shape' .. i+1, table.concat(p))
				end
			elseif visType == 2 then
				local p = path
				for i=1,bands do
					p[i*2+1] = (trueHeight-trueHeight*c[i]/bMax)*scale
				end
				SKIN:Bang('!SetOption', 'Shape', 'Path', table.concat(p))
			end
		end
		--SKIN:Bang('!ShowMeter', 'Shape')
	end
	
	--frametime
	frametimeIndex=frametimeIndex%frametimeSize+1;frametimeAvg[frametimeIndex]=os.clock()-frametimeStart;frametime=0;for i=1,frametimeSize do frametime=frametime+frametimeAvg[i] end;frametime=frametime/frametimeSize;frametimeStart=os.clock()
	--frametime
	
	--timer
	--el2=os.clock()-st2;el3=os.clock()-st3;
	el2=(el2*eli+(os.clock()-st2))/(eli+1);el3=(el3*eli+(os.clock()-st3))/(eli+1);
	if not last then
		last = 0
		last2 = 0
		last3 = 0
		last4 = 0
		last5 = 0
		last6 = 0
		last7 = 0
	end
	SKIN:Bang('!SetOption','TimeMeter','Shape2','Rectangle' .. math.min((last7)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000010|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape3','Rectangle' .. math.min((last6)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000020|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape4','Rectangle' .. math.min((last5)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000030|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape5','Rectangle' .. math.min((last4)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000040|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape6','Rectangle' .. math.min((last3)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000050|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape7','Rectangle' .. math.min((last2)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000060|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape8','Rectangle' .. math.min((last)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000070|StrokeWidth0')
	last7 = last6
	last6 = last5
	last5 = last4
	last4 = last3
	last3 = last2
	last2 = last
	last=os.clock()-st3
	SKIN:Bang('!SetOption','TimeMeter','Shape9','Rectangle' .. math.min((os.clock()-st3)/100*6*1000*500-15,495) .. ',0,30,8|FillColorFF000080|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape10','Rectangle' .. math.min((el)/100*6*1000*500-0.5,500) .. ',0,1,8|FillColor00FF00|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape11','Rectangle' .. math.min((el+el4)/100*6*1000*500-0.5,500) .. ',0,1,8|FillColor00FF00|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape12','Rectangle' .. math.min((el+el4+el2)/100*6*1000*500-0.5,500) .. ',0,1,8|FillColor00FF00|StrokeWidth0')
	SKIN:Bang('!SetOption','TimeMeter','Shape13','Rectangle' .. math.min((frametime)/100*6*1000*500-1,500) .. ',0,2,8|FillColor00FFFF|StrokeWidth0')
	SKIN:Bang('!SetOption','UpdateTime1','Text',string.format("%.2f",(el+el4+el2)*1000));
	SKIN:Bang('!SetOption','UpdateTime2','Text',string.format("%.2f",frametime*1000));
	--SKIN:Bang('!SetOption','UpdateTime','Text',string.format("%.3f",el*1000)..' / '..string.format("%.3f",el4*1000)..' / '..string.format("%.3f",el2*1000)..' | '..string.format("%.3f",(el+el4+el2)*1000)..' -> '..string.format("%.2f",el3*1000)..' | '..string.format("%.2f",frametime*1000)..' -> avgSize '..avgSize);
	st3=os.clock()
	if eli<49 then eli=eli+1 end
	--timer
	
	--use frametime for adaptive avg size
	--need to discard unused values!!!
	avgSize=math.floor(math.max(math.min(avgTime/1000/frametime,avgTime),1)+0.5)
	if avgSize ~= avgSizeOld then
		if avgSizeOld > avgSize then
			for i=avgSize+1,avgSizeOld do
				bAvg[i] = {}
			end
		end
		avgSizeOld = avgSize
		if avgSize == 1 then
			avgConst = 1
		else
			if avgType == 1 then
				avgConst = 1/avgSize
			elseif avgType == 2 then
				avgConst = 1/(avgSize*(avgSize+1)/2)
			elseif avgType == 3 then
				weight = 1
				for i=1,avgSize do
					avgConst = avgConst + weight
					weight = weight * avgBase
				end
				avgConst = 1/avgConst
			end
		end
	end
end
function calibrate(duration)
	if duration > 0 then
		SKIN:Bang('PlayLoop #@#noise.wav')
		calTime = duration
		SKIN:Bang('!EnableMeasure Volume')
		SKIN:Bang('!UpdateMeasure Volume')
		SKIN:Bang('!Update')
		volume = SKIN:GetMeasure('Volume'):GetValue()
		SKIN:Bang('!CommandMeasure Volume "SetVolume 0"')
		calStartTime = os.clock()
		calibrating = 1
	elseif duration == 0 then
		calTime = 1
		calCancel = 1
	elseif calibrating then
		calTime = 1
	else
		calTime = false
		calStartTime = os.clock()
		calibrating = 1
	end
end