local health = vim.health

local M = {}

local function check_for_plugin(plugin_name)
  local plugin = require(plugin_name)
  if plugin ~= nil then
    health.report_ok(plugin_name .. " is installed")
  else
    health.report_error(plugin_name .. " is missing")
  end
end

M.check = function()
  health.report_start("Checking for required plugins")
  check_for_plugin("telescope")
  check_for_plugin("bufferline")
end

return M
