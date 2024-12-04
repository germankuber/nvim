local M = {}

local snapshot_root = vim.fn.stdpath("data") .. "/file_versions"
local max_versions = 20 -- Maximum number of versions allowed

vim.fn.mkdir(snapshot_root, "p")

-- Function to calculate a hash of the file content
local function calculate_file_hash(filepath)
  local lines = vim.fn.readfile(filepath)
  return vim.fn.sha256(table.concat(lines, "\n"))
end

-- Function to clean the oldest version if more than max_versions exist
local function clean_old_versions(version_dir)
  local files = vim.fn.globpath(version_dir, "*", false, true)
  if #files > max_versions then
    table.sort(files, function(a, b)
      return vim.fn.getftime(a) < vim.fn.getftime(b) -- Sort by modification time
    end)
    vim.fn.delete(files[1]) -- Delete the oldest file
  end
end

-- Function to save a new version of the file
function M.save_version()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" or vim.bo.buftype ~= "" then return end -- Skip if no file or non-file buffer

  local file_dir = vim.fn.fnamemodify(filepath, ":h")
  local file_name = vim.fn.fnamemodify(filepath, ":t")
  local version_dir = snapshot_root .. "/" .. vim.fn.sha256(file_dir)

  vim.fn.mkdir(version_dir, "p")

  -- Calculate the current file hash
  local current_hash = calculate_file_hash(filepath)

  -- Check if a version with the same hash already exists
  local files = vim.fn.globpath(version_dir, "*", false, true)
  for _, file in ipairs(files) do
    if calculate_file_hash(file) == current_hash then
      -- vim.notify("No changes detected, version not saved.", vim.log.levels.INFO)
      return
    end
  end

  -- Clean old versions before saving
  clean_old_versions(version_dir)

  -- Save the new version
  local timestamp = os.date("%Y%m%d%H%M%S")
  local version_file = string.format("%s/%s-%s.%s", version_dir, file_name, timestamp, vim.fn.fnamemodify(filepath, ":e"))

  vim.fn.writefile(vim.fn.readfile(filepath), version_file)
  -- vim.notify("New version saved: " .. version_file, vim.log.levels.INFO)
end

-- Automatically trigger the save_version function on file save
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = M.save_version,
})

return M
