local Job = require "plenary.job"

local source = {}
local opts = {
  ignore = {},
  only_semantic_versions = false,
  only_latest_version = false
}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

function source:is_available()
  local filename = vim.fn.expand('%:t')
  return filename == "deps.edn"
end

function source:get_debug_name()
  return 'tools-deps-helper'
end


function source:complete(params, callback)
  local cur_line = params.context.cursor_line
  local cur_col = params.context.cursor.col
  local name = string.match(cur_line, '%s*([%a%d%-%_%/%.]+)%s+{:mvn/version')
  local _, idx_after_version_quote = string.find(cur_line, '%s*:mvn/version%s+"')
  local find_version = false

  if idx_after_version_quote then
    find_version = cur_col + 1 >= idx_after_version_quote
  end

  if name == nil then return end
  if not find_version then return end

  if opts.only_latest_version then
  Job
    :new({
        "tools-deps-helper",
        "find-versions",
        name,
        on_exit = function(job)
          local result = job:result()
          local version = result[0]
          if version then
            local versions = {
              { label = version },
              { label = "^" .. version },
              { label = "~" .. version }
            }
            callback(versions)
          end
        end
    }):start()
  else Job
    :new({
        "tools-deps-helper",
        "find-versions",
        name,
        on_exit = function(job)
          local result = job:result()
          local items = {}
          for idx, item in ipairs(result) do
            local version = item
            local order_id = idx
            if opts.only_semantic_versions and not string.match(version, '^%d+%.%d+%.%d+$') then
              goto continue
            else
              for _, ignoreString in ipairs(opts.ignore) do
                if string.match(version, ignoreString) then
                  goto continue
                end
              end
            end

            table.insert(items, { label = version, id = order_id })

            ::continue::
          end
          callback(items)
        end
    }):start()
  end
end

function source:resolve(completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  callback(completion_item)
end

require('cmp').register_source("clojure-tools-deps", source.new())

return {
  setup = function(_opts)
    if _opts then
      opts = vim.tbl_deep_extend('force', opts, _opts) -- will extend the default options
    end
  end
}
