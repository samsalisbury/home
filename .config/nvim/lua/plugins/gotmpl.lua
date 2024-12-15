-- Configure .(go)tmpl files to use gotmpl filetype.
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".+.(go)?tmpl"] = "html",
  },
})
