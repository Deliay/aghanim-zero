_G.month_table = setmetatable({
  [1] = 31, [3] = 31, [4] = 30, [5] = 31,
  [6] = 30, [7] = 31, [8] = 31, [9] = 30,
  [10] = 31, [11] = 30, [12] = 31,
}, {
  __index = function(t, k)
      error("invalid month: " .. tostring(k))
  end
})

os = {}
local function date() 
  local date_str = GetSystemDate()
  local time_str = GetSystemTime()
  local year, month, day

  -- 根据日期字符串格式解析年、月、日
  local start = string.find(date_str, "/");
  print(start)
  if start == 5 then
      year, month, day = string.match(date_str, "(%d+)/(%d+)/(%d+)")
  else
      month, day, year = string.match(date_str, "(%d+)/(%d+)/(%d+)")
      year = year + 2000
  end

  -- 根据时间字符串格式解析小时、分钟、秒
  local hour, min, sec = string.match(time_str, "(%d+):(%d+):(%d+)")

  -- 将解析出的数字转换为整数
  year, month, day, hour, min, sec = tonumber(year), tonumber(month), tonumber(day),
                                     tonumber(hour), tonumber(min), tonumber(sec)
  print(year, month, day, hour, min, sec)
  -- 计算秒数
  -- local time_in_seconds = ((year - 1970) * 365 + math.floor((year - 1969) / 4)) * 86400
  --                       + (month_table[month] or 0) * 86400 + (day - 1) * 86400
  --                       + hour * 3600 + min * 60 + sec
  return string.format("%04d-%02d-%02dT%02d:%02d:%02d", tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(min), tonumber(sec))
end
os.date = date
_G.os = os
print(os.date())
local raven = require "raven/init"

_G.rvn = raven.new {
    -- multiple senders are available for different networking backends,
    -- doing a custom one is also very easy.
    sender = require("raven.senders.luasocket").new {
        dsn = "https://019a61e0147c4d8588a48bd3354036c6@o4505115042840576.ingest.sentry.io/4505115046313984",
    },
    tags = { project = "aghanim_zero"},
}

local function sentryHandler(f, ...) 
  local succeed, ret = rvn:call(f, ...)
  if succeed then
    return ret
  else
    error(ret)
  end
end

-- variable 'ok' should be false, and an exception will be sent to sentry
_G.sentryHandler = sentryHandler

return true
