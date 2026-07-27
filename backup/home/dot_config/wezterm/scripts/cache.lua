local M = {}
local values = {}

function M.get(key, ttl, fn)
  local now = os.time()
  if values[key] and (now - values[key].time) < ttl then
    return values[key].value
  end

  local value = fn()
  values[key] = { value = value, time = now }
  return value
end

return M
