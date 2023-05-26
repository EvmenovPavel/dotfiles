local gsurface = require("gears.surface")
local lgi      = require("lgi")
local cairo    = lgi.cairo

local schar    = string.char
local sbyte    = string.byte
local tcat     = table.concat
local tins     = table.insert

local utils    = {}

function utils:is_empty(s)
	return s == nil or s == ""
end

function utils:convert_icon(w, h, rowstride, channels, data)
	-- Do the arguments look sane? (e.g. we have enough data)
	local expected_length = rowstride * (h - 1) + w * channels
	if w < 0 or h < 0 or rowstride < 0 or (channels ~= 3 and channels ~= 4) or
			string.len(data) < expected_length then
		w = 0
		h = 0
	end

	local format = cairo.Format[channels == 4 and 'ARGB32' or 'RGB24']

	-- Figure out some stride magic (cairo dictates rowstride)
	local stride = cairo.Format.stride_for_width(format, w)
	local append = schar(0):rep(stride - 4 * w)
	local offset = 0

	-- Now convert each row on its own
	local rows   = {}

	for _ = 1, h do
		local this_row = {}

		for i = 1 + offset, w * channels + offset, channels do
			local R, G, B, A = sbyte(data, i, i + channels - 1)
			tins(this_row, schar(B, G, R, A or 255))
		end

		-- Handle rowstride, offset is stride for the input, append for output
		tins(this_row, append)
		tins(rows, tcat(this_row))

		offset = offset + rowstride
	end

	local pixels = tcat(rows)
	local surf   = cairo.ImageSurface.create_for_data(pixels, format, w, h, stride)

	-- The surface refers to 'pixels', which can be freed by the GC. Thus,
	-- duplicate the surface to create a copy of the data owned by cairo.
	local res    = gsurface.duplicate_surface(surf)
	surf:finish()
	return res
end

return utils