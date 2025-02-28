-- Configure bufferline to only show if there is at least one regular file
-- buffer open (this excludes no-name buffers and the neo-tree buffer).
-- The standard vim option vim.options.showtabline only allows showing the
-- tab line automatically when there are two or more buffers open, which isn't
-- what I want.
return {
  "akinsho/bufferline.nvim",
  config = function()
    require("bufferline").setup({
      options = {
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            text_align = "left",
            separator = true,
          },
        },
        custom_filter = function(buf_number)
          local name = vim.api.nvim_buf_get_name(buf_number)
          local ft = vim.bo[buf_number].filetype
          return name ~= "" and ft ~= "neo-tree"
        end,
      },
    })

    local function update_tabline_visibility()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      local valid_count = 0
      for _, buf in ipairs(buffers) do
        local name = buf.name
        local ft = vim.bo[buf.bufnr].filetype
        if name ~= "" and ft ~= "neo-tree" then
          valid_count = valid_count + 1
        end
      end
      if valid_count >= 1 then
        vim.opt.showtabline = 2 -- Show when one or more real buffers exist
      else
        vim.opt.showtabline = 0 -- Hide when no real buffers exist
      end
    end

    -- Hook into additional events and add a slight delay to catch the final state
    local events = { "VimEnter", "BufAdd", "BufDelete", "BufEnter", "BufWinEnter", "WinEnter", "FocusGained" }
    vim.api.nvim_create_autocmd(events, {
      --callback = update_tabline_visibility,
      callback = function()
        vim.defer_fn(update_tabline_visibility, 10) -- 10ms delay to let everything settle
      end,
    })
  end,
}
