" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
local package_path_str = "/home/h7x4/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/h7x4/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/h7x4/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/h7x4/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/h7x4/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

_G.packer_plugins = {
  ["fzf.vim"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/fzf.vim"
  },
  ["goyo.vim"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/goyo.vim"
  },
  ["limelight.vim"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/limelight.vim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  semshi = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/semshi"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-gitgutter"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-gitgutter"
  },
  ["vim-monokai"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-monokai"
  },
  ["vim-polyglot"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-polyglot"
  },
  ["vim-tmux"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-tmux"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/home/h7x4/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator"
  }
}

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
