local M = {}

-- Crockford Base32 alphabet (no I, L, O, U)
local BASE32_CHARS = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

-- Helper function to safely extract bits from large numbers
-- Uses math operations instead of bitwise to avoid 32-bit overflow
local function extract_bits(value, shift, mask)
  return math.floor(value / (2 ^ shift)) % mask
end

-- Encode timestamp (48 bits) to 10 Base32 characters
local function encode_timestamp(timestamp_ms)
  local chars = {}
  
  -- Extract 10 characters (each 5 bits) from 48-bit timestamp
  -- Work from most significant to least significant
  for i = 9, 0, -1 do
    local shift = i * 5
    local index = extract_bits(timestamp_ms, shift, 32)  -- 32 = 2^5
    table.insert(chars, BASE32_CHARS:sub(index + 1, index + 1))
  end
  
  return table.concat(chars)
end

-- Encode randomness (80 bits) to 16 Base32 characters
local function encode_random(random_bytes)
  local chars = {}
  local value = 0
  local bits = 0
  
  -- Process all 10 bytes (80 bits)
  for i = 1, #random_bytes do
    value = value * 256 + random_bytes:byte(i)
    bits = bits + 8
    
    -- Extract 5-bit chunks when we have enough bits
    while bits >= 5 do
      bits = bits - 5
      local index = extract_bits(value, bits, 32)  -- 32 = 2^5
      table.insert(chars, BASE32_CHARS:sub(index + 1, index + 1))
    end
  end
  
  return table.concat(chars)
end

-- Generate a ULID string (timestamp + random)
function M.generate_ulid(timestamp_ms)
  -- Use provided timestamp or current time
  local ts = timestamp_ms or (os.time() * 1000)
  
  -- Ensure timestamp is within valid 48-bit range (0 to 281474976710655)
  -- This represents dates from 1970 to year 10889
  local MAX_TIMESTAMP = 281474976710655
  if ts > MAX_TIMESTAMP then
    ts = MAX_TIMESTAMP
  end
  if ts < 0 then
    ts = 0
  end
  
  -- Generate 10 random bytes (80 bits)
  local rand_bytes = {}
  for _ = 1, 10 do
    table.insert(rand_bytes, string.char(math.random(0, 255)))
  end
  local rand_str = table.concat(rand_bytes)
  
  -- Encode timestamp (10 chars) + randomness (16 chars) = 26 chars total
  return encode_timestamp(ts) .. encode_random(rand_str)
end

-- Generate example date in the correct format
function M.get_example_date()
  local now = os.date("*t")
  return string.format("%04d-%02d-%02d_%02d:%02d:%02d-0600", 
                      now.year,
                      now.month,
                      now.day,
                      now.hour,
                      now.min,
                      now.sec)
end

-- Parse timestamp from created field or use current time
function M.ulid_from_created_or_now(created)
  local timestamp_ms
  
  if created and created ~= "" then
    -- Try new format first: YYYY-MM-DD_HH:MM:SS-0600
    local year, month, day, hour, min, sec = created:match("(%d%d%d%d)%-(%d%d)%-(%d%d)_(%d%d):(%d%d):(%d%d)%-0600")
    
    -- Try without seconds: YYYY-MM-DD_HH:MM-0600
    if not year then
      year, month, day, hour, min = created:match("(%d%d%d%d)%-(%d%d)%-(%d%d)_(%d%d):(%d%d)%-0600")
      sec = "0"
    end
    
    -- Try legacy format with seconds: d-MMM-YYYYTHH:MM:SS-0600
    if not year then
      local d, m, y, h, mi, s = created:match("(%d+)%-(%a+)%-(%d+)T(%d+):(%d+):(%d+)%-0600")
      if d and m and y then
        local months = {
          JAN = 1, FEB = 2, MAR = 3, APR = 4, MAY = 5, JUN = 6,
          JUL = 7, AUG = 8, SEP = 9, OCT = 10, NOV = 11, DEC = 12
        }
        month = tostring(months[m:upper()] or 0)
        day = d
        year = y
        hour = h
        min = mi
        sec = s
      end
    end
    
    -- Try legacy format without seconds: d-MMM-YYYYTHH:MM-0600
    if not year then
      local d, m, y, h, mi = created:match("(%d+)%-(%a+)%-(%d+)T(%d+):(%d+)%-0600")
      if d and m and y then
        local months = {
          JAN = 1, FEB = 2, MAR = 3, APR = 4, MAY = 5, JUN = 6,
          JUL = 7, AUG = 8, SEP = 9, OCT = 10, NOV = 11, DEC = 12
        }
        month = tostring(months[m:upper()] or 0)
        day = d
        year = y
        hour = h
        min = mi
        sec = "0"
      end
    end
    
    if year and month and day and hour and min and sec then
      -- Convert to numbers
      year = tonumber(year)
      month = tonumber(month)
      day = tonumber(day)
      hour = tonumber(hour)
      min = tonumber(min)
      sec = tonumber(sec)
      
      -- Validate ranges
      if year and year >= 1000 and
         month and month >= 1 and month <= 12 and
         day and day >= 1 and day <= 31 and
         hour and hour >= 0 and hour <= 23 and
         min and min >= 0 and min <= 59 and
         sec and sec >= 0 and sec <= 59 then
        
        -- Create timestamp with parsed date/time including seconds
        local time = os.time({
          year = year,
          month = month,
          day = day,
          hour = hour,
          min = min,
          sec = sec
        })
        
        -- Add milliseconds (approximate based on random)
        local ms = math.random(0, 999)
        timestamp_ms = time * 1000 + ms
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