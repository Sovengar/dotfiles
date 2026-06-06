local M = {}

function M.setup()
  if vim.g.hyde_wallbash_reload_started then
    return
  end
  vim.g.hyde_wallbash_reload_started = true

  local uv = vim.uv or vim.loop
  local colors_dir = vim.fn.stdpath("config") .. "/colors"
  local wallbash_file = "wallbash.vim"

  local watcher = uv.new_fs_event()
  local timer = uv.new_timer()

  if not watcher or not timer then
    return
  end

  watcher:start(colors_dir, {}, function(err, filename)
    if err or (filename and filename ~= wallbash_file) then
      return
    end

    timer:stop()
    timer:start(150, 0, function()
      vim.schedule(function()
        if vim.g.colors_name == "wallbash" and vim.fn.filereadable(colors_dir .. "/" .. wallbash_file) == 1 then
          vim.cmd.colorscheme("wallbash")
        end
      end)
    end)
  end)

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("hyde_wallbash_reload", { clear = true }),
    callback = function()
      timer:stop()
      timer:close()
      watcher:stop()
      watcher:close()
    end,
  })
end

return M
