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
        custom_filter = function(bufnr)
          local name = vim.api.nvim_buf_get_name(bufnr)
          local ft = vim.bo[bufnr].filetype
          return name ~= "" and ft ~= "neo-tree"
        end,
      },
    })

    local no_file_win = nil
    local no_file_buf = nil

    -- Find a window whose buffer is not neo-tree.
    local function get_main_window()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" then
          return win
        end
      end
      return nil
    end

    local function show_no_file_message()
      local main_win = get_main_window()
      if not main_win then
        return
      end

      local win_width = vim.api.nvim_win_get_width(main_win)
      local win_height = vim.api.nvim_win_get_height(main_win)

      if no_file_win and vim.api.nvim_win_is_valid(no_file_win) then
        vim.api.nvim_win_set_config(no_file_win, {
          relative = "win",
          win = main_win,
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
        })
      else
        no_file_buf = vim.api.nvim_create_buf(false, true)
        local opts = {
          style = "minimal",
          relative = "win",
          win = main_win,
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          border = "none",
        }
        no_file_win = vim.api.nvim_open_win(no_file_buf, false, opts)
        -- Use the standard float background so it matches your theme.
        vim.api.nvim_win_set_option(no_file_win, "winhl", "Normal:NormalFloat")
      end

      -- Prepare a centered message.
      local message = "No Files Open"
      local pad_left = math.floor((win_width - #message) / 2)
      local padded_message = string.rep(" ", pad_left) .. message
      local pad_top = math.floor((win_height - 1) / 2)
      local pad_bottom = win_height - pad_top - 1
      local lines = {}
      for _ = 1, pad_top do
        table.insert(lines, "")
      end
      table.insert(lines, padded_message)
      for _ = 1, pad_bottom do
        table.insert(lines, "")
      end

      vim.api.nvim_buf_set_option(no_file_buf, "modifiable", true)
      vim.api.nvim_buf_set_lines(no_file_buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(no_file_buf, "modifiable", false)
    end

    local function hide_no_file_message()
      if no_file_win and vim.api.nvim_win_is_valid(no_file_win) then
        vim.api.nvim_win_close(no_file_win, true)
        no_file_win = nil
        no_file_buf = nil
      end
    end

    local function is_neotree_open()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neo-tree" then
          return true
        end
      end
      return false
    end

    local function update_placeholder()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      local valid_count = 0
      for _, buf in ipairs(buffers) do
        local name = buf.name
        local ft = vim.bo[buf.bufnr].filetype
        if name ~= "" and ft ~= "neo-tree" then
          valid_count = valid_count + 1
        end
      end

      if valid_count < 1 then
        vim.opt.showtabline = 0
        if is_neotree_open() then
          show_no_file_message()
        else
          hide_no_file_message()
        end
      else
        vim.opt.showtabline = 2
        hide_no_file_message()
      end
    end

    local events = {
      "VimEnter", "BufAdd", "BufDelete", "BufEnter",
      "BufWinEnter", "WinEnter", "FocusGained", "WinResized"
    }
    vim.api.nvim_create_autocmd(events, {
      callback = function()
        vim.defer_fn(update_placeholder, 10)
      end,
    })
  end,
}