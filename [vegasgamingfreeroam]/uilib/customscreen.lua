screenX,screenY = guiGetScreenSize()
--
function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end
--
responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)
--
function resp(num)
	return num * responsiveMultipler
end
--
function respc(num)
	return math.ceil(num * responsiveMultipler)
end
--
function getResponsiveMultipler()
	return responsiveMultipler
end