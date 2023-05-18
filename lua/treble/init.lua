local M = {}

local vim = vim

local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local config = require("telescope.config")

local function list_buffers()
  local utils = require("bufferline.utils")
  return utils.get_valid_buffers()
end

local function get_buffer_name(buffer_number)
  return vim.api.nvim_buf_get_name(buffer_number)
end

local function buffer_file_name(buffer_name)
  return vim.fn.fnamemodify(buffer_name, ":p:t")
end

local function buffer_icons(buffer_name)
  local devicons = require("nvim-web-devicons")
  return devicons.get_icon(buffer_name, string.match(buffer_name, "%a+$"), { default = true })
end

local function make_buffer_entries(buffer_numbers)

  local results = {}
  for buffer_index, buffer_number in ipairs(buffer_numbers) do
    local buffer_name = get_buffer_name(buffer_number)
    local file_name = buffer_file_name(buffer_name)
    local devicons, devicons_highlight = buffer_icons(buffer_name)
    local entry = {
      buffer_index = buffer_index,
      buffer_number = buffer_number,
      buffer_name = buffer_name,
      file_name = file_name,
      devicons = devicons,
      devicons_highlight = devicons_highlight
    }
    table.insert(results, entry)
  end

  return results
end

local function icon_width()
  return 5
end

local function buffer_number_width()
  return 5
end

local function buffer_name_width()
  return 40
end

local function buffers(opts)
  opts = opts or {}

  local buffer_numbers = list_buffers()
  local buffer_entries = make_buffer_entries(buffer_numbers)
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = buffer_number_width() },
      { width = icon_width() },
      { width = buffer_name_width() },
    }
  }

  local make_display = function(entry)
    return displayer {
      { entry.buffer_index, "TelescopeResultsNumber" },
      { entry.devicons, entry.devicons_highlight },
      entry.file_name
    }
  end

  pickers.new(opts, {
    prompt_title = "buffers",
    attach_mappings = function(prompt_buffer_number, _)
      actions.select_default:replace(function()
        actions.close(prompt_buffer_number)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_set_current_buf(selection.buffer_number)
      end)
      return true
    end,
    finder = finders.new_table {
      results = buffer_entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.buffer_index .. " : " .. entry.file_name,
          buffer_index = entry.buffer_index,
          buffer_number = entry.buffer_number,
          buffer_name = entry.buffer_name,
          file_name = entry.file_name,
          devicons = entry.devicons,
          devicons_highlight = entry.devicons_highlight
        }
      end
    },
    sorter = config.values.generic_sorter(opts),
  }):find()
end

M.buffers = buffers

return M
