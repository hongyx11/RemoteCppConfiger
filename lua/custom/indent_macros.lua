-- Custom macro indentation for C/C++
local M = {}

-- Get indentation level of a line (number of leading spaces)
local function get_indent(line)
  local spaces = line:match("^(%s*)")
  return #spaces
end

function M.indent_preprocessor_directives()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified_lines = {}
  local macro_indent_stack = {} -- Stack to track macro indentation levels

  for i, line in ipairs(lines) do
    local leading_ws = line:match("^(%s*)")
    local trimmed = line:match("^%s*(.-)%s*$")

    -- Check if line is a preprocessor directive
    if trimmed:match("^#") then
      local directive = trimmed:match("^#(%w+)")

      if directive == "ifdef" or directive == "ifndef" or directive == "if" then
        -- Opening directive: find indent from previous non-empty, non-macro line
        local base_indent = 0
        for j = i - 1, 1, -1 do
          local prev_line = lines[j]
          local prev_trimmed = prev_line:match("^%s*(.-)%s*$")
          if prev_trimmed ~= "" and not prev_trimmed:match("^#") then
            -- Get the indentation of the actual code (not including the brace if present)
            local code_indent = get_indent(prev_line)
            -- If previous line ends with {, use that indent, otherwise look further
            if prev_trimmed:match("{%s*$") then
              base_indent = code_indent + 2 -- Indent inside the block
            else
              base_indent = code_indent
            end
            break
          end
        end

        -- If nested in another macro, stay at that level
        if #macro_indent_stack > 0 then
          base_indent = macro_indent_stack[#macro_indent_stack]
        end

        table.insert(modified_lines, string.rep(" ", base_indent) .. trimmed)
        table.insert(macro_indent_stack, base_indent) -- Push this level for nested macros

      elseif directive == "endif" then
        -- Closing directive: use the indent from the matching opening
        local base_indent = 0
        if #macro_indent_stack > 0 then
          base_indent = table.remove(macro_indent_stack)
        end
        table.insert(modified_lines, string.rep(" ", base_indent) .. trimmed)

      elseif directive == "else" or directive == "elif" then
        -- Middle directive: same indent as the opening
        local base_indent = 0
        if #macro_indent_stack > 0 then
          base_indent = macro_indent_stack[#macro_indent_stack]
        end
        table.insert(modified_lines, string.rep(" ", base_indent) .. trimmed)

      else
        -- Other preprocessor directives (define, include, etc.) - keep at column 0
        table.insert(modified_lines, trimmed)
      end
    else
      -- Not a preprocessor directive - keep original line unchanged
      table.insert(modified_lines, line)
    end
  end

  -- Apply changes
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, modified_lines)
end

return M
