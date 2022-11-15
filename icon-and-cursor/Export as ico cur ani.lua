---------- byteStreamBuffer library ----------
byteStreamBuffer = {
    prototype = {},
    meta = {},
    util = {}
}

-- returns true when v is integer
byteStreamBuffer.util.isInteger = function(v)
    return type(v) == "number" and v % 1 .. "" == "0"
end
-- returns true if v is byte number
byteStreamBuffer.util.isByte = function(v)
    return byteStreamBuffer.util.isInteger(v) and 0 <= v and v <= 0xFF
end
-- returns true if v is byteStreamBuffer
byteStreamBuffer.util.isbyteStreamBuffer = function(v)
    return type(v) == "table" and v.array ~= nil and getmetatable(v) == byteStreamBuffer.meta
end
-- assert with level
byteStreamBuffer.util.assert = function(value, msg, level)
    if not value then
    error(msg, level + 1)
    end
    return value
end
-- check type and assert with level
byteStreamBuffer.util.assertType = function(value, targetType, msgPrefix, level)
    local assert = false
    if targetType == "byte" then
    assert = not byteStreamBuffer.util.isByte(value)
    elseif targetType == "byteStreamBuffer" then
    assert = not byteStreamBuffer.util.isbyteStreamBuffer(value)
    elseif targetType == "integer" then
    assert = not byteStreamBuffer.util.isInteger(value)
    else
    assert = type(value) ~= targetType
    end

    if assert then
    error(msgPrefix .. "(" .. targetType .. " expected, got " .. type(value) .. ")", level + 1)
    end
end

-- append value
byteStreamBuffer.prototype.append = function(bsb, ...)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'append' ", 2)

    for i, data in ipairs({...}) do
    if byteStreamBuffer.util.isByte(data) then
        bsb:appendByte(data)
    elseif type(data) == "string" then
        bsb:appendString(data)
    elseif byteStreamBuffer.util.isbyteStreamBuffer(data) then
        bsb:appendByteStreamBuffer(data)
    else
        error("bad argument #" .. (i + 1) .. " to append (byte, string or byteStreamBuffer expected, got " .. type(data) .. ")")
    end
    end
end
-- append byte number
byteStreamBuffer.prototype.appendByte = function(bsb, data)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendByte' ", 2)
    byteStreamBuffer.util.assertType(data, "byte", "bad argument #2 to 'appendByte' ", 2)

    bsb[#bsb + 1] = data
end
-- append number in little endian
byteStreamBuffer.prototype.appendMultiByteLE = function(bsb, data, size)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendMultiByteLE' ", 2)
    byteStreamBuffer.util.assertType(data, "integer", "bad argument #2 to 'appendMultiByteLE' ", 2)
    byteStreamBuffer.util.assertType(size, "integer", "bad argument #3 to 'appendMultiByteLE' ", 2)
    byteStreamBuffer.util.assert(size > 0, "bad argument #3 to 'appendMultiByteLE' (size must be grater than 0)", 2)

    if data < 0 then
    data = 1 << (size * 8) + data
    end

    local d = data
    for i = 1, size do
    bsb[#bsb + 1] = d & 0xFF
    d = d >> 8
    end
end
-- append number in big endian
byteStreamBuffer.prototype.appendMultiByteBE = function(bsb, data, size)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendMultiByteBE' ", 2)
    byteStreamBuffer.util.assertType(data, "integer", "bad argument #2 to 'appendMultiByteBE' ", 2)
    byteStreamBuffer.util.assertType(size, "integer", "bad argument #3 to 'appendMultiByteBE' ", 2)
    byteStreamBuffer.util.assert(size > 0, "bad argument #3 to 'appendMultiByteBE' (size must be grater than 0)", 2)

    if data < 0 then
    data = 1 << (size * 8) + data
    end

    local mask = 0xFF << ((size - 1) * 8)
    local shift = size - 1
    for i = 1, size do
    bsb[#bsb + 1] = (data & mask) >> (shift * 8)
    mask = mask >> 8
    shift = shift - 1
    end
end
-- append string sa byte sequence
byteStreamBuffer.prototype.appendString = function(bsb, data)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendString' ", 2)
    byteStreamBuffer.util.assertType(data, "string", "bad argument #2 to 'appendString' ", 2)

    for _, byte in ipairs({ data:byte(1, -1) }) do
    bsb[#bsb + 1] = byte
    end
end
-- append string as pascal string
byteStreamBuffer.prototype.appendPascalString = function(bsb, data)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendPascalString' ", 2)
    byteStreamBuffer.util.assertType(data, "string", "bad argument #2 to 'appendPascalString' ", 2)

    bsb[#bsb + 1] = #data
    for _, byte in ipairs({ data:byte(1, -1) }) do
    bsb[#bsb + 1] = byte
    end
end
-- append slice of byteStreamBuffer
byteStreamBuffer.prototype.appendByteStreamBuffer = function(bsb, bsb2)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'appendByteStreamBuffer' ", 2)
    byteStreamBuffer.util.assertType(bsb2, "byteStreamBuffer", "bad argument #2 to 'appendByteStreamBuffer' ", 2)

    for i = 1, #bsb2 do
    bsb[#bsb + 1] = bsb2[i]
    end
end
-- clear buffer
byteStreamBuffer.prototype.clear = function(bsb)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'clear' ", 2)
    bsb.array = {}
end
-- convert to string
byteStreamBuffer.prototype.tostring = function(bsb)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'tostring' ", 2)

    local str = ""
    for i = 1, #bsb do
    str = str .. string.format("%c", bsb[i])
    end

    return str
end
-- returns slice of buffer
byteStreamBuffer.prototype.slice = function(bsb, startIndex, lastIndex)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'slice' ", 2)
    byteStreamBuffer.util.assertType(startIndex, "integer", "bad argument #2 to 'slice' ", 2)
    byteStreamBuffer.util.assertType(lastIndex, "integer", "bad argument #3 to 'slice' ", 2)

    if startIndex < 1 then
    startIndex = #bsb + startIndex
    end
    if lastIndex < 1 then
    lastIndex = #bsb + lastIndex
    end

    local result = byteStreamBuffer()
    for i = startIndex, lastIndex do
    result[#result + 1] = bsb[i]
    end

    return result
end
-- compress buffer with pack bits and return new buffer
byteStreamBuffer.prototype.packBits = function(bsb)
    byteStreamBuffer.util.assertType(bsb, "byteStreamBuffer", "bad argument #1 to 'packBits' ", 2)
    if #bsb == 0 then
    return byteStreamBuffer()
    end

    local result = byteStreamBuffer()
    local buff = byteStreamBuffer()
    local flag = -1
    local size = 0xFF

    local i = 1
    while i <= #bsb do
    if flag == 0 then
        -- continuous
        if buff[#buff] == bsb[i] then
        buff[#buff + 1] = bsb[i]
        else
        result[#result + 1] = size - (#buff - 2)
        result[#result + 1] = buff[1]
        buff:clear()
        buff[1] = bsb[i]
        flag = -1
        end
    elseif flag == 1 then
        -- discontinuous
        if buff[#buff] ~= bsb[i] then
        buff[#buff+1] = bsb[i]
        else
        result[#result+1] = #buff - 2
        result:appendByteStreamBuffer(buff, 1, -1)
        buff:clear()
        buff[1] = bsb[i]
        buff[2] = bsb[i]
        flag = 0
        end
    else
        -- undetermined
        if #buff ~= 0 then
        if buff[#buff] == bsb[i] then
            flag = 0
        else
            flag = 1
        end
        end
        buff[#buff+1] = bsb[i]
    end

    if #buff > size/2 then
        if flag == 0 then
        result[#result+1] = size - (#buff - 2)
        result[#result+1] = buff[1]
        else
        result[#result+1] = #buff - 1
        result:appendByteStreamBuffer(buff)
        end
        buff = {}
        flag = -1
    end

    i = i + 1
    end

    if #buff ~= 0 then
    if flag == 0 then
        result[#result+1] = size - (#buff - 2)
        result[#result+1] = buff[1]
    else
        result[#result+1] = #buff - 1
        result.appendByteStreamBuffer(buff)
    end
    end

    return result
end

byteStreamBuffer.meta.__index = function(bsb, index)
    if byteStreamBuffer.util.isInteger(index) then
    return bsb.array[index]
    else
    return byteStreamBuffer.prototype[index]
    end
end
byteStreamBuffer.meta.__newindex = function(bsb, index, value)
    if not byteStreamBuffer.util.isByte(value) then
    error("Value must be byte number, got " .. value, 2)
    end
    if byteStreamBuffer.util.isInteger(index) then
    bsb.array[index] = value
    end
end
byteStreamBuffer.meta.__len = function(bsb)
    return #bsb.array
end
byteStreamBuffer.meta.__tostring = function(bsb)
    local str = "byteStreamBuffer[" .. #bsb.array .. "] { "

    for i = 1, #bsb.array do
    if i ~= 1 then
        str = str .. ", "
    end
    str = str .. bsb.array[i]
    end

    str = str .. " }"
    return str
end
byteStreamBuffer.meta.__concat = function(bsb1, bsb2)
    local bsb = byteStreamBuffer()
    for i = 1, #bsb1 do
    bsb.array[#bsb.array + 1] = bsb1[i]
    end
    for i = 1, #bsb2 do
    bsb.array[#bsb.array + 1] = bsb2[i]
    end
    return bsb
end

setmetatable(byteStreamBuffer, {
    __call = function()
    -- create new byteStreamBuffer
    local bsb = {
        array = {}
    }
    setmetatable(bsb, byteStreamBuffer.meta)

    return bsb
    end
})
---------- byteStreamBuffer library ----------

-- shows alert with failure message
function failAlert(text)
  app.alert{
    title = "Export Failed",
    text = text,
    buttons = "OK"
  }
end





------------------------------
-- ENTRY
------------------------------

if app.apiVersion < 1 then
    failAlert("This script requires Aseprite v1.2.10-beta3 or above.")
    return
end

if not app.activeSprite then
    failAlert("No sprite selected.")
    return
end
local sprite = Sprite(app.activeSprite)
sprite:flatten()

local targetCels = sprite.cels
local dpi = 96
local iconInfoHeaderSize = 16
local bitmapInfoHeaderSize = 40
local usePalette = (sprite.colorMode == ColorMode.Indexed and #sprite.palette < 256)
local paletteSize = 0
if usePalette then
    paletteSize = #sprite.palette
end

local images = {}
for i, cel in ipairs(targetCels) do
    local colorData = byteStreamBuffer()
    local left = cel.bounds.x
    local top = cel.bounds.y
    local right = cel.bounds.x + cel.bounds.width - 1
    local bottom = cel.bounds.y + cel.bounds.height - 1

    if left < 0 then left = 0 end
    if top < 0 then top = 0 end
    if right >= sprite.width then right = sprite.width - 1 end
    if bottom >= sprite.height then bottom = sprite.height - 1 end

    for i = bottom, sprite.height - 1 do
        colorData:appendMultiByteLE(0, sprite.width)
    end

    for y = bottom, top, -1 do
        colorData:appendMultiByteLE(0, left)

        for x = left, right do
            color = cel.image:getPixel(x - cel.bounds.x, y - cel.bounds.y)
            if usePalette then
                -- use color palette
                colorData:appendByte(color)
            elseif cel.image.colorMode == ColorMode.GRAY then
                colorData:appendByte(app.pixelColor.grayaV(color))
                colorData:appendByte(app.pixelColor.grayaV(color))
                colorData:appendByte(app.pixelColor.grayaV(color))
            elseif cel.image.colorMode == ColorMode.RGB then
                colorData:appendByte(app.pixelColor.rgbaR(color))
                colorData:appendByte(app.pixelColor.rgbaG(color))
                colorData:appendByte(app.pixelColor.rgbaB(color))
            end
        end

        colorData:appendMultiByteLE(0, sprite.width - 1 - right)
    end

    for i = 0, top do
        colorData:appendMultiByteLE(0, sprite.width)
    end

    images[i] = data
end

local data = byteStreamBuffer()

local filename = app.fs.filePathAndTitle(sprite.filename) .. ".ico"
local file = io.open(filename, "wb")
if not file then
  failAlert("Failed to open the file to export.")
  return
end

-- file header
---- reserved
data:appendMultiByteLE(0, 2)
---- resource type (1: icon / 2: cursor)
data:appendMultiByteLE(1, 2)
---- number of images
data:appendMultiByteLE(#targetFrames, 2)

-- icon header
-- record offset of icon header to update info later
local iconHeaderOffsets = {}
for index, frame in ipairs(targetFrames) do
    iconHeaderOffsets[index] = #data
    ---- width and height
    data:append(sprite.width)
    data:append(sprite.height)
    ---- color count
    if #palette < 256 then
        data:append(#palette)
    else
        data:append(0)
    end
    ---- resevered
    data:append(0)
    ---- hotspot x, y for cursor, reserverd for ico
    data:appendMultiByteLE(0, 2)
    data:appendMultiByteLE(0, 2)
    ---- icon data size, deside later
    if usePalette then
        bitmapInfoHeaderSize + paletteSize * 4 +
    data:appendMultiByteLE(0, 4)
    ---- offset until bitmap info header, deside later
    data:appendMultiByteLE(0, 4)
end