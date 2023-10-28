local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require"telescope.config".values
local utils = require "telescope._extensions.yadm.utils"


-- Default configuration options
local defaults = {
  ignore_patterns = {"/tmp/"},
  only_cwd = false,
}


--Effective extension options, available after the setup call.
local options
local M = {}
M.setup = function(opts)
  options = utils.assign({}, defaults, opts)
end


local function make_yadm_path(file_path, opts)
  -- local current_dir = vim.fn.getcwd()
  local dir = vim.fn.expand('~')
  dir = vim.fn.fnamemodify(dir, ':p')
  return  vim.fn.fnameescape(dir .. '/' .. file_path)
end


local function is_ignored(file_path, opts)
  -- Check if a file path is in the ignore list
  if opts.ignore_patterns == nil then
    return false
  end
  for _,p in ipairs(opts.ignore_patterns) do
   if string.find(file_path, p) then return true end
  end
  return false
end


-- Add a yadm file to the result list
local function add_yadm_file(result_list, result_map, file_path, opts)
  -- Check if the file should be shown based on options
  -- Format yadm path
  if not opts.only_cwd then file_path = make_yadm_path(file_path, opts) end

  local should_add = file_path ~= nil and file_path ~= ""
  if result_map[file_path] then
    should_add = false
  elseif is_ignored(file_path, opts) then
    should_add = false
  end

  if should_add then
    table.insert(result_list, file_path)
    result_map[file_path] = true
  end
end


local function sort_files(result_list, files_map, recent_bufs)
  table.sort(result_list, function(a, b)
    local a_recency = recent_bufs[a]
    local b_recency = recent_bufs[b]
    if a_recency == nil and b_recency == nil then
      local a_map = files_map[a]
      local b_map = files_map[b]
      if a_map == nil and b_map == nil then
        return a < b
      end
      if a_map == nil then
        return false
      end
      if b_map == nil then
        return true
      end
      return a_map < b_map
    end
    if a_recency == nil then
      return false
    end
    if b_recency == nil then
      return true
    end
    return b_recency < a_recency
  end)
end


-- Prepare the list of yadm files
local function prepare_yadm_files(opts)
  -- List to store the resulting yadm files
  local result_list = {}
  -- A map to keep track of files that have been added to result_list.
  local result_map = {}
  local files_map = {}

  local cmd
  if opts.only_cwd then
    cmd = "yadm list --files"
  else
    cmd = "yadm list --files -a"
  end
  -- Loop through the files in the Vim files list.
  for i, file in ipairs(vim.fn.systemlist(cmd)) do
  -- for i, file in ipairs(vim.v.oldfiles) do
    add_yadm_file(result_list, result_map, file, opts)
    files_map[file] = i
  end

  --Map from file path to its recency number. The higher the number,
  --the more recently the file was used.
  local recent_bufs = {}

  -- Sort the resulting list based on recency and file names.
  sort_files(result_list, files_map, recent_bufs)

  return result_list
end


-- Initiate the file picking using Telescope
M.pick = function(opts)
  if not options then
    error("Plugin is not set up, call require('telescope').load_extension('yadm_files')")
  end
  opts = utils.assign({}, options, opts)
  pickers.new(opts, {
    prompt_title = "Yadm files",
    finder = finders.new_table {
      -- results = find_yadm_files(opts),
      results = prepare_yadm_files(opts),
      entry_maker = make_entry.gen_from_file(opts)
    },
    sorter = conf.file_sorter(),
    previewer = conf.file_previewer(opts)
  }):find()
end

return M



