local gsurface = require("gears.surface")
local cairo    = require("lgi").cairo

local utils    = {}

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
	local append = string.char(0):rep(stride - 4 * w)
	local offset = 0

	-- Now convert each row on its own
	local rows   = {}

	for _ = 1, h do
		local this_row = {}

		for i = 1 + offset, w * channels + offset, channels do
			local R, G, B, A = string.byte(data, i, i + channels - 1)
			table.insert(this_row, string.char(B, G, R, A or 255))
		end

		-- Handle rowstride, offset is stride for the input, append for output
		table.insert(this_row, append)
		table.insert(rows, table.concat(this_row))

		offset = offset + rowstride
	end

	local pixels = table.concat(rows)
	local surf   = cairo.ImageSurface.create_for_data(pixels, format, w, h, stride)

	-- The surface refers to 'pixels', which can be freed by the GC. Thus,
	-- duplicate the surface to create a copy of the data owned by cairo.
	local res    = gsurface.duplicate_surface(surf)
	surf:finish()
	return res
end

return utils