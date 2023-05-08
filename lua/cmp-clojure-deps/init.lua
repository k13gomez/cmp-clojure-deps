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
  return 'tools-deps-native'
end


function source:complete(params, callback)
  -- figure out if we are completing the package name or version
  local cur_line = params.context.cursor_line
  local cur_col = params.context.cursor.col
  local name = string.match(cur_line, '%s*([\w\/\-\.]+)[\s]+\{:mvn\/version*')
  local _, idx_after_version_quote = string.find(cur_line, '.*:mvn\/version\s+"')
  local find_version = false
  if idx_after_version_quote then
    find_version = cur_col >= idx_after_third_quote
  end

  if name == nil then return end
  if not find_version then return end

  if opts.only_latest_version then
  Job
    :new({
        "tools-deps-native",
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
        "tools-deps-native",
        "find-versions",
        name,
        on_exit = function(job)
          local result = job:result()
          table.remove(result, table.getn(result))
          local items = {}
          for _, version in ipairs(result) do
            if opts.only_semantic_versions and not string.match(version, '^%d+%.%d+%.%d+$') then
              goto continue
            else
              for _, ignoreString in ipairs(opts.ignore) do
                if string.match(version, ignoreString) then
                  goto continue
                end
              end
            end

            table.insert(items, { label = version })

            ::continue::
          end
          -- unfortunately, nvim-cmp uses its own sorting algorith which doesn't work for semantic versions
          -- but at least we can bring the original set in order
          table.sort(items, function(a,b)
            local a_major,a_minor,a_patch = string.match(a.label, '(%d+)%.(%d+)%.(%d+)')
            local b_major,b_minor,b_patch = string.match(b.label, '(%d+)%.(%d+)%.(%d+)')
            if a_major ~= b_major then return tonumber(a_major) > tonumber(b_major) end
            if a_minor ~= b_minor then return tonumber(a_minor) > tonumber(b_minor) end
            if a_patch ~= b_patch then return tonumber(a_patch) > tonumber(b_patch) end
          end)
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
