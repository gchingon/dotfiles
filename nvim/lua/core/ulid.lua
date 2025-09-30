local M = {}

-- Crockford Base32 alphabet (no I, L, O, U)
local BASE32_CHARS = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

-- Bitwise operations for LuaJIT
local bor, band, rshift, lshift = bit.bor, bit.band, bit.rshift, bit.lshift

-- Encode a 128-bit binary string into Crockford Base32
local function base32_encode(bytes)
  local bits = 0
  local value = 0
  local output = {}

  for i = 1, #bytes do
    value = bor(lshift(value, 8), bytes:byte(i))
    bits = bits + 8

    while bits >= 5 do
      local index = band(rshift(value, bits - 5), 0x1F)
      table.insert(output, BASE32_CHARS:sub(index + 1, index + 1))
      bits = bits - 5
    end
  end

  if bits > 0 then
    local index = band(lshift(value, 5 - bits), 0x1F)
    table.insert(output, BASE32_CHARS:sub(index + 1, index + 1))
  end

  return table.concat(output)
end

-- Generate a ULID string (timestamp + random)
function M.generate_ulid(timestamp_ms)
  -- Timestamp: 48 bits (6 bytes)
  local ts = timestamp_ms or (os.time() * 1000)
  local ts_bytes = string.char(
    band(rshift(ts, 40), 0xFF),
    band(rshift(ts, 32), 0xFF),
    band(rshift(ts, 24), 0xFF),
    band(rshift(ts, 16), 0xFF),
    band(rshift(ts, 8), 0xFF),
    band(ts, 0xFF)
  )

  -- Randomness: 80 bits (10 bytes)
  local rand_bytes = {}
  for _ = 1, 10 do
    table.insert(rand_bytes, string.char(math.random(0, 255)))
  end

  local full_bytes = ts_bytes .. table.concat(rand_bytes)
  return base32_encode(full_bytes)
end

-- Generate example date in the correct format
function M.get_example_date()
  local now = os.date("*t")
  local months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}
  return string.format("%d-%s-%dT%02d:%02d-0600", 
                      now.day, 
                      months[now.month], 
                      now.year,
                      now.hour,
                      now.min)
end

-- Parse timestamp from created field or use current time
function M.ulid_from_created_or_now(created)
  local timestamp_ms
  
  if created then
    -- Match the format: "d-MMM-YYYYTHH:MM-0600" or "dd-MMM-YYYYTHH:MM-0600"
    local day, month, year, hour, min = created:match("(%d+)%-(%a+)%-(%d+)T(%d+):(%d+)%-0600")
    
    if day and month and year and hour and min then
      local months = {
        JAN = 1, FEB = 2, MAR = 3, APR = 4, MAY = 5, JUN = 6,
        JUL = 7, AUG = 8, SEP = 9, OCT = 10, NOV = 11, DEC = 12
      }
      
      local month_num = months[month:upper()]
      if month_num then
        -- Convert to numbers
        day = tonumber(day)
        year = tonumber(year)
        hour = tonumber(hour)
        min = tonumber(min)
        
        -- Validate ranges
        if day and day >= 1 and day <= 31 and
           year and year >= 1000 and
           hour and hour >= 0 and hour <= 23 and
           min and min >= 0 and min <= 59 then
          
          local time = os.time({
            year = year,
            month = month_num,
            day = day,
            hour = hour,
            min = min,
            sec = 0
          })
          
          timestamp_ms = time * 1000
        end
      end
    end
    
    -- If parsing failed, show error message
    if not timestamp_ms then
      local example = M.get_example_date()
      vim.notify(
        string.format('Date improperly formatted. Expected format: "%s"', example),
        vim.log.levels.ERROR
      )
    end
  end
  
  -- If no created field or parsing failed, use current time
  if not timestamp_ms then
    timestamp_ms = os.time() * 1000
  end
  
  return M.generate_ulid(timestamp_ms)
end

return M
