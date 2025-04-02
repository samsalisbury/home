return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "swift" })
    end,
  },

  --{
  --  "williamboman/mason.nvim",
  --  optional = true,
  --  opts = function(_, opts)
  --    opts.ensure_installed = opts.ensure_installed or {}
  --    vim.list_extend(opts.ensure_installed, {
  --      "swiftlint", -- Required by nvim-lint swiftlint
  --      "swiftformat", -- Required by confirm.nvim swiftformat
  --      "xcbeautify", -- Required by xcodebuild.nvim
  --      "xcode-build-server", -- Required by nvim-lspconfig sourcekit
  --    })
  --  end,
  --},

  --{
  --  "neovim/nvim-lspconfig",
  --  opts = {
  --    servers = {
  --      sourcekit = {
  --        cmd = {
  --          "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
  --          "-I /opt/homebrew/Caskroom/tuist/4.44.3/",
  --          "-I .",
  --        },
  --        root_dir = function(filename, _)
  --          local util = require("lspconfig.util")
  --          return util.root_pattern("buildServer.json")(filename)
  --            or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
  --            or util.find_git_ancestor(filename)
  --            or util.root_pattern("Package.swift")(filename)
  --        end,

  --        on_attach = function(client, bufnr)
  --          local opts = { noremap = true, silent = true }
  --          opts.buffer = bufnr

  --          opts.desc = "Show line diagnostics"
  --          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

  --          opts.desc = "Show documentation for what is under cursor"
  --          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  --        end,
  --      },
  --    },
  --  },
  --},

  {
    "neovim/nvim-lspconfig",

    dependencies = {
      --"hrsh7th/nvim-cmp-lsp",
    },
    opts = {
      servers = {
        sourcekit = {
          timeout = 10000,
          cmd = {
            "xcrun",
            "sourcekit-lsp",
            --"-I",
            --"/opt/homebrew/Caskroom/tuist/4.44.3/",
            --"-I .",
          },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("buildServer.json")(filename)
              or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
              or util.find_git_ancestor(filename)
              or util.root_pattern("Package.swift")(filename)
          end,
          capabilities = {
            textDocument = {
              diagnostic = {
                dynamicRegistration = true,
                relatedDocumentSupport = true,
              },
              workspace = {
                didChangeWatchedFiles = {
                  dynamicRegistration = true,
                },
              },
            },
          },

          --on_attach = function(client, bufnr)
          --  local opts = { noremap = true, silent = true }
          --  opts.buffer = bufnr

          --  opts.desc = "Show line diagnostics"
          --  vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

          --  opts.desc = "Show documentation for what is under cursor"
          --  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          --end,
        },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },
  {
    "wojciech-kulik/xcodebuild-nvim-preview",
    dependencies = {
      "wojciech-kulik/xcodebuild.nvim",
    },
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("xcodebuild").setup({
        code_coverage = {
          enabled = true,
        },
      })

      vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
      vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
      vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })
      vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
      vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })
      vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", { desc = "Show All Xcodebuild Actions" })
      vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
      vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
      vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
      vim.keymap.set(
        "n",
        "<leader>xC",
        "<cmd>XcodebuildShowCodeCoverageReport<cr>",
        { desc = "Show Code Coverage Report" }
      )
      vim.keymap.set("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", { desc = "Show QuickFix List" })
    end,
  },
}
