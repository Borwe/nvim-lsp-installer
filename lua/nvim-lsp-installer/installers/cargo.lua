local process = require "nvim-lsp-installer.process"
local path = require "nvim-lsp-installer.path"

local M = {}

---@param crate string The crate to install.
---@param opts {features:string|nil}
function M.crate(crate, opts)
    ---@type ServerInstallerFunction
    return function(_, callback, ctx)
        opts = opts or {}
        local args = { "install", "--root", ".", "--locked" }
        if ctx.requested_server_version then
            vim.list_extend(args, { "--version", ctx.requested_server_version })
        end
        if opts.features then
            vim.list_extend(args, { "--features", opts.features })
        end
        vim.list_extend(args, { crate })

        ctx.receipt:with_primary_source(ctx.receipt.cargo(crate))

        process.spawn("cargo", {
            args = args,
            cwd = ctx.install_dir,
            stdio_sink = ctx.stdio_sink,
        }, callback)
    end
end

---@param opts {path:string|nil}
function M.install(opts)
    ---@type ServerInstallerFunction
    return function(_, callback, ctx)
        opts = opts or {}
        local args = { "install", "--root", "." }
        if opts.path then
            vim.list_extend(args, { "--path", opts.path })
        end
        process.spawn("cargo", {
            args = args,
            cwd = ctx.install_dir,
            stdio_sink = ctx.stdio_sink,
        }, callback)
    end
end

---@param root_dir string The directory to resolve the executable from.
function M.env(root_dir)
    return {
        PATH = process.extend_path { path.concat { root_dir, "bin" } },
    }
end

return M
