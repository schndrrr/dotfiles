local Extension = {}
local api = vim.api

-- Default configuration
local default_opts = {
  -- Context window settings
  max_tokens = 90000,
  warning_threshold = 0.75, -- Warn at 75%
  critical_threshold = 0.85, -- Critical at 85%
  
  -- Token estimation
  chars_per_token = 4, -- Average characters per token
  
  -- Display settings
  show_context_window = true,
  show_notifications = true,
  
  -- Progress bar styles: "blocks", "ascii", "minimal", "detailed", "bar_only"
  progress_style = "blocks",
  
  -- Window position: "bottom", "top", "top-right", "bottom-right", "center"
  window_position = "bottom",
  
  -- Keymaps
  keymaps = {
    check_context = "gcc", -- Check current context usage
    summarize_chat = "gcs", -- Create summary
    start_fresh_with_summary = "gcf", -- Start new chat with summary
    toggle_context = "<leader>tt", -- Toggle context window
  },
  
  -- Summary settings
  summary_opts = {
    max_summary_tokens = 2000,
    system_prompt = "Create a concise summary of this conversation that preserves the key context, decisions made, and current state. Focus on information that would be useful for continuing the conversation in a new chat session.",
  }
}

local config = {}
local context_data = {}
local context_enabled = true
local context_win = nil
local context_buf = nil

-- Check if current buffer is a codecompanion chat buffer
local function is_codecompanion_buffer()
  local bufnr = api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local bufname = api.nvim_buf_get_name(bufnr)
  
  return filetype == "codecompanion" or 
         bufname:match("codecompanion") or
         bufname:match("CodeCompanion Chat")
end

-- Token estimation function
local function estimate_tokens(text)
  if not text or #text == 0 then return 0 end
  
  local base_tokens = math.ceil(#text / config.chars_per_token)
  
  -- Add overhead for message structure
  local overhead_factor = 1.1
  
  -- Count code blocks and add extra tokens
  local code_blocks = 0
  for _ in text:gmatch("```") do
    code_blocks = code_blocks + 1
  end
  local code_overhead = math.floor(code_blocks / 2) * 50
  
  return math.ceil(base_tokens * overhead_factor) + code_overhead
end

-- Get comprehensive chat content including all context
local function get_comprehensive_chat_content()
  local total_content = ""
  local debug_info = {}
  
  -- Get the current buffer content (visible chat)
  if is_codecompanion_buffer() then
    local bufnr = api.nvim_get_current_buf()
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    total_content = table.concat(lines, "\n")
    debug_info.buffer_chars = #total_content
  end
  
  -- Try to get actual message history from codecompanion (includes context from files/tools)
  local ok, Chat = pcall(require, "codecompanion.strategies.chat")
  if ok then
    local current_chat = Chat.buf_get_chat()
    local messages = nil
    
    -- Find messages in the correct location
    if current_chat and current_chat[1] and current_chat[1].chat and current_chat[1].chat.messages then
      messages = current_chat[1].chat.messages
    elseif current_chat and current_chat.messages then
      messages = current_chat.messages
    end
    
    if messages and #messages > 0 then
      local message_content = ""
      local hidden_content = 0
      
      for i, message in ipairs(messages) do
        local content = ""
        
        -- Handle different content types more thoroughly
        if type(message.content) == "string" then
          content = message.content
        elseif type(message.content) == "table" then
          -- Try to capture all possible content structures
          for j, part in ipairs(message.content) do
            -- Standard text content
            if part.text then
              content = content .. part.text .. "\n"
            -- Alternative text structure
            elseif part.type == "text" and part.content then
              content = content .. part.content .. "\n"
            -- File content (might be in different structure)
            elseif part.type == "file" then
              if part.content then
                content = content .. part.content .. "\n"
                hidden_content = hidden_content + #part.content
              elseif part.text then
                content = content .. part.text .. "\n"
                hidden_content = hidden_content + #part.text
              end
            -- Buffer content
            elseif part.type == "buffer" then
              if part.content then
                content = content .. part.content .. "\n"
                hidden_content = hidden_content + #part.content
              elseif part.text then
                content = content .. part.text .. "\n"
                hidden_content = hidden_content + #part.text
              end
            -- Tool results (MCP, etc.)
            elseif part.type == "tool_call" or part.type == "tool_result" then
              if part.content then
                content = content .. part.content .. "\n"
                hidden_content = hidden_content + #part.content
              elseif part.result then
                content = content .. tostring(part.result) .. "\n"
                hidden_content = hidden_content + #tostring(part.result)
              end
            -- Any other content with a content field
            elseif part.content then
              content = content .. tostring(part.content) .. "\n"
            end
          end
        end
        
        -- Also check for additional fields that might contain context
        if message.context then
          if type(message.context) == "string" then
            content = content .. message.context .. "\n"
            hidden_content = hidden_content + #message.context
          elseif type(message.context) == "table" then
            for _, ctx in ipairs(message.context) do
              if type(ctx) == "string" then
                content = content .. ctx .. "\n"
                hidden_content = hidden_content + #ctx
              end
            end
          end
        end
        
        -- Check for files/buffers in message metadata
        if message.files then
          for _, file in ipairs(message.files) do
            if file.content then
              content = content .. file.content .. "\n"
              hidden_content = hidden_content + #file.content
            end
          end
        end
        
        -- Add role prefix for better token estimation
        message_content = message_content .. string.format("[%s]: %s\n\n", message.role or "unknown", content)
      end
      
      debug_info.message_chars = #message_content
      debug_info.hidden_chars = hidden_content
      debug_info.total_messages = #messages
      debug_info.messages_location = "current_chat[1].chat.messages"
      
      -- Use message content if it's more comprehensive than buffer content
      if #message_content > #total_content then
        total_content = message_content
      end
    end
  end
  
  -- Store debug info for inspection
  context_data.debug = debug_info
  
  return total_content
end

-- Calculate context usage
local function calculate_context_usage()
  local content = get_comprehensive_chat_content()
  local content_tokens = estimate_tokens(content)
  
  -- Add system prompt overhead
  local system_overhead = 300
  
  -- Add buffer for response generation
  local response_buffer = 1000
  
  local total_tokens = content_tokens + system_overhead + response_buffer
  
  context_data = {
    content_tokens = content_tokens,
    system_overhead = system_overhead,
    response_buffer = response_buffer,
    total_tokens = total_tokens,
    max_tokens = config.max_tokens,
    usage_percent = total_tokens / config.max_tokens,
    remaining_tokens = config.max_tokens - total_tokens,
  }
  
  return context_data
end

-- Generate progress bar based on style
local function generate_progress_bar(usage_percent, style)
  local bar_length = style == "minimal" and 15 or 30
  local filled = math.floor(usage_percent * bar_length)
  local empty = bar_length - filled
  
  if style == "blocks" then
    return string.rep("█", filled) .. string.rep("░", empty)
  elseif style == "ascii" then
    return "[" .. string.rep("=", filled) .. string.rep("-", empty) .. "]"
  elseif style == "minimal" then
    return string.rep("■", filled) .. string.rep("□", empty)
  elseif style == "detailed" then
    local quarter_filled = math.floor(filled / 4) * 4
    local remainder = filled - quarter_filled
    local blocks = ""
    
    -- Full blocks
    blocks = blocks .. string.rep("█", quarter_filled / 4)
    
    -- Partial blocks
    if remainder >= 3 then
      blocks = blocks .. "▊"
    elseif remainder >= 2 then
      blocks = blocks .. "▌"
    elseif remainder >= 1 then
      blocks = blocks .. "▎"
    end
    
    -- Empty blocks
    blocks = blocks .. string.rep("░", math.ceil(empty / 4))
    
    return blocks:sub(1, bar_length)
  end
  
  -- Fallback to blocks
  return string.rep("█", filled) .. string.rep("░", empty)
end

-- Get window position configuration
local function get_window_position(width, height)
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines
  
  local positions = {
    bottom = {
      row = screen_height - height - 3,
      col = math.floor((screen_width - width) / 2)
    },
    top = {
      row = 1,
      col = math.floor((screen_width - width) / 2)
    },
    ["top-right"] = {
      row = 1,
      col = screen_width - width - 2
    },
    ["bottom-right"] = {
      row = screen_height - height - 3,
      col = screen_width - width - 2
    },
    center = {
      row = math.floor((screen_height - height) / 2),
      col = math.floor((screen_width - width) / 2)
    }
  }
  
  return positions[config.window_position] or positions.bottom
end

-- Show context window
local function show_context_window()
  if not config.show_context_window or not context_enabled then return end
  if not is_codecompanion_buffer() then return end
  
  local data = calculate_context_usage()
  local percent = math.floor(data.usage_percent * 100)
  
  -- Determine status and color
  local status_icon = "✅"
  local hl_group = "String"
  
  if data.usage_percent >= config.critical_threshold then
    status_icon = "⚠️ "
    hl_group = "ErrorMsg"
  elseif data.usage_percent >= config.warning_threshold then
    status_icon = "🟡"
    hl_group = "WarningMsg"
  end
  
  -- Generate progress bar
  local progress_bar = generate_progress_bar(data.usage_percent, config.progress_style)
  
  -- Create window content based on style
  local context_text = {}
  local win_height = 3
  
  if config.progress_style == "bar_only" then
    -- Minimal version - just the progress bar and percentage
    table.insert(context_text, progress_bar)
    table.insert(context_text, string.format("%d%%", percent))
    win_height = 2
  else
    -- Full version with all info
    table.insert(context_text, string.format("%s Context: %d%% (%d/%d tokens)", 
      status_icon, percent, data.total_tokens, data.max_tokens))
    table.insert(context_text, progress_bar)
    table.insert(context_text, string.format("Content: %d | System: %d | Buffer: %d | Free: %d", 
      data.content_tokens, data.system_overhead, data.response_buffer, data.remaining_tokens))
    win_height = 3
  end
  
  -- Create buffer if needed
  if not context_buf or not api.nvim_buf_is_valid(context_buf) then
    context_buf = api.nvim_create_buf(false, true)
    vim.bo[context_buf].bufhidden = "hide"
    vim.bo[context_buf].buftype = "nofile"
    vim.bo[context_buf].swapfile = false
    vim.bo[context_buf].filetype = "codecompanion-context"
  end
  
  -- Update buffer content
  api.nvim_buf_set_lines(context_buf, 0, -1, false, context_text)
  
  -- Create or update window
  if not context_win or not api.nvim_win_is_valid(context_win) then
    local win_width = math.min(80, vim.o.columns - 4)
    local pos = get_window_position(win_width, win_height)
    
    local window_opts = {
      relative = "editor",
      width = win_width,
      height = win_height,
      row = pos.row,
      col = pos.col,
      style = "minimal",
      focusable = false,
    }
    
    -- Add border and title only for non-bar_only styles
    if config.progress_style ~= "bar_only" then
      window_opts.border = "rounded"
      window_opts.title = " CodeCompanion Context "
      window_opts.title_pos = "center"
    else
      window_opts.border = "none"
    end
    
    context_win = api.nvim_open_win(context_buf, false, window_opts)
    
    -- Set highlighting
    vim.wo[context_win].winhighlight = "Normal:FloatNormal,FloatBorder:FloatBorder"
  end
  
  -- Update highlighting
  local ns_id = api.nvim_create_namespace("context_manager")
  api.nvim_buf_clear_namespace(context_buf, ns_id, 0, -1)
  api.nvim_buf_add_highlight(context_buf, ns_id, hl_group, 0, 0, -1)
  api.nvim_buf_add_highlight(context_buf, ns_id, "Comment", 2, 0, -1)
end

-- Hide context window
local function hide_context_window()
  if context_win and api.nvim_win_is_valid(context_win) then
    api.nvim_win_close(context_win, true)
    context_win = nil
  end
end

-- Toggle context window
local function toggle_context_window()
  context_enabled = not context_enabled
  
  if context_enabled then
    -- Force show immediately if in codecompanion buffer
    if is_codecompanion_buffer() then
      vim.defer_fn(function()
        show_context_window()
      end, 50) -- Small delay to ensure proper state
    end
  else
    hide_context_window()
  end
end

-- Inspect message structure for debugging
local function inspect_message_structure()
  local inspection = {}
  
  -- First, let's see what Chat strategies are available
  local ok, Chat = pcall(require, "codecompanion.strategies.chat")
  if not ok then 
    table.insert(inspection, "Error: codecompanion.strategies.chat not available")
    return table.concat(inspection, "\n")
  end
  
  table.insert(inspection, "Chat module loaded successfully")
  
  -- Try to get current chat
  local current_chat = Chat.buf_get_chat()
  if not current_chat then
    table.insert(inspection, "No current chat found")
    
    -- Let's see what's in the Chat module
    table.insert(inspection, "\nAvailable Chat functions:")
    for k, v in pairs(Chat) do
      table.insert(inspection, "  " .. k .. " (" .. type(v) .. ")")
    end
    
    return table.concat(inspection, "\n")
  end
  
  table.insert(inspection, "Current chat found!")
  
  -- Show what's in the chat object
  table.insert(inspection, "\nChat object keys:")
  for k, v in pairs(current_chat) do
    if k == "messages" then
      table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. (v and #v or "nil"))
    elseif type(v) == "table" then
      table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. #v)
    else
      table.insert(inspection, "  " .. k .. " (" .. type(v) .. ")")
    end
  end
  
  -- Let's inspect the table at key "1" since that seems to be where data is
  if current_chat[1] and type(current_chat[1]) == "table" then
    table.insert(inspection, "\nInspecting current_chat[1]:")
    for k, v in pairs(current_chat[1]) do
      if k == "messages" then
        table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. (v and #v or "nil"))
      elseif type(v) == "table" then
        table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. #v)
      else
        table.insert(inspection, "  " .. k .. " (" .. type(v) .. ")")
      end
    end
    
    -- Check if messages are in current_chat[1].chat (deeper inspection)
    if current_chat[1].chat and type(current_chat[1].chat) == "table" then
      table.insert(inspection, "\nInspecting current_chat[1].chat:")
      for k, v in pairs(current_chat[1].chat) do
        if k == "messages" then
          table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. (v and #v or "nil"))
        elseif type(v) == "table" then
          table.insert(inspection, "  " .. k .. " (" .. type(v) .. ") - length: " .. #v)
        else
          table.insert(inspection, "  " .. k .. " (" .. type(v) .. ")")
        end
      end
      
      -- Check if messages are in current_chat[1].chat.messages
      if current_chat[1].chat.messages and #current_chat[1].chat.messages > 0 then
        local messages = current_chat[1].chat.messages
        table.insert(inspection, "\nMessages found in current_chat[1].chat.messages: " .. #messages)
        
        for i, message in ipairs(messages) do
          if i <= 2 then -- Only inspect first 2 messages
            table.insert(inspection, "\nMessage " .. i .. " (" .. (message.role or "unknown") .. "):")
            
            -- Show all message keys
            local keys = {}
            for k, v in pairs(message) do
              table.insert(keys, k .. "(" .. type(v) .. ")")
            end
            table.insert(inspection, "  Keys: " .. table.concat(keys, ", "))
            
            -- Show content structure
            if type(message.content) == "table" then
              table.insert(inspection, "  Content parts: " .. #message.content)
              for j, part in ipairs(message.content) do
                if j <= 3 then -- Show first 3 parts
                  local part_info = "    Part " .. j .. ": "
                  local part_keys = {}
                  for k, v in pairs(part) do
                    if k == "text" or k == "content" then
                      local preview = tostring(v):sub(1, 50):gsub("\n", "\\n")
                      table.insert(part_keys, k .. "=[" .. #tostring(v) .. " chars]" .. preview .. "...")
                    else
                      table.insert(part_keys, k .. "(" .. type(v) .. ")")
                    end
                  end
                  table.insert(inspection, part_info .. table.concat(part_keys, ", "))
                end
              end
            elseif type(message.content) == "string" then
              local preview = message.content:sub(1, 100):gsub("\n", "\\n")
              table.insert(inspection, "  Content: [" .. #message.content .. " chars] " .. preview .. "...")
            end
          end
        end
      else
        table.insert(inspection, "No messages in current_chat[1].chat")
      end
    end
    
    -- Check if messages are in current_chat[1].messages
    if current_chat[1].messages and #current_chat[1].messages > 0 then
      local messages = current_chat[1].messages
      table.insert(inspection, "\nMessages found in current_chat[1].messages: " .. #messages)
    else
      table.insert(inspection, "No messages in current_chat[1].messages")
    end
  end
  
  -- If we have messages, inspect them (legacy check)
  if current_chat.messages and #current_chat.messages > 0 then
    table.insert(inspection, "\nMessages found: " .. #current_chat.messages)
    
    for i, message in ipairs(current_chat.messages) do
      if i <= 2 then -- Only inspect first 2 messages
        table.insert(inspection, "\nMessage " .. i .. " (" .. (message.role or "unknown") .. "):")
        
        -- Show all message keys
        local keys = {}
        for k, v in pairs(message) do
          table.insert(keys, k .. "(" .. type(v) .. ")")
        end
        table.insert(inspection, "  Keys: " .. table.concat(keys, ", "))
        
        -- Show content structure
        if type(message.content) == "table" then
          table.insert(inspection, "  Content parts: " .. #message.content)
          for j, part in ipairs(message.content) do
            if j <= 2 then
              local part_info = "    Part " .. j .. ": "
              local part_keys = {}
              for k, v in pairs(part) do
                if k == "text" or k == "content" then
                  local preview = tostring(v):sub(1, 50):gsub("\n", "\\n")
                  table.insert(part_keys, k .. "=[" .. #tostring(v) .. " chars]" .. preview .. "...")
                else
                  table.insert(part_keys, k .. "(" .. type(v) .. ")")
                end
              end
              table.insert(inspection, part_info .. table.concat(part_keys, ", "))
            end
          end
        elseif type(message.content) == "string" then
          local preview = message.content:sub(1, 100):gsub("\n", "\\n")
          table.insert(inspection, "  Content: [" .. #message.content .. " chars] " .. preview .. "...")
        end
      end
    end
  else
    table.insert(inspection, "No messages in chat object")
  end
  
  return table.concat(inspection, "\n")
end

-- Check context usage (manual command)
local function check_context_usage()
  local data = calculate_context_usage()
  local percent = math.floor(data.usage_percent * 100)
  
  local status = data.usage_percent >= config.critical_threshold and "⚠️  Critical!" or
                data.usage_percent >= config.warning_threshold and "🟡 Warning" or "✅ Good"
  
  local info = string.format([[
Context Usage: %d%% (%d/%d tokens)

Breakdown:
• Content (chat + context): %d tokens
• System overhead: %d tokens  
• Response buffer: %d tokens
• Remaining: %d tokens

Status: %s]], 
    percent, 
    data.total_tokens, 
    data.max_tokens,
    data.content_tokens,
    data.system_overhead,
    data.response_buffer,
    data.remaining_tokens,
    status
  )
  
  -- Add debug information if available
  if data.debug then
    local debug = data.debug
    info = info .. string.format([[

Debug Info:
• Buffer chars: %s
• Message chars: %s  
• Hidden content chars: %s
• Total messages: %s
• Messages location: %s]], 
      debug.buffer_chars or "N/A",
      debug.message_chars or "N/A",
      debug.hidden_chars or "0",
      debug.total_messages or "N/A",
      debug.messages_location or "N/A"
    )
  end
  
  vim.notify(info, vim.log.levels.INFO, { title = "Context Manager" })
end

-- Add inspection command
local function inspect_messages()
  local structure = inspect_message_structure()
  
  -- Create a temporary buffer to show the structure
  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "text"
  
  local lines = vim.split(structure, "\n")
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  vim.cmd("split")
  api.nvim_set_current_buf(buf)
  
  vim.notify("Message structure inspection opened in split", vim.log.levels.INFO)
end

-- Create enhanced summary
local function create_enhanced_summary()
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("CodeCompanion not available", vim.log.levels.ERROR)
    return
  end
  
  local Chat = require("codecompanion.strategies.chat")
  local current_chat = Chat.buf_get_chat()
  
  if not current_chat then
    vim.notify("No active chat found", vim.log.levels.ERROR)
    return
  end
  
  local content = get_comprehensive_chat_content()
  if #content == 0 then
    vim.notify("No content to summarize", vim.log.levels.INFO)
    return
  end
  
  local summary_prompt = string.format([[
%s

Please create a summary of the above conversation that:
1. Captures the main topic and goals
2. Lists key decisions or solutions discussed
3. Includes any important code snippets or configurations
4. Notes the current state/progress
5. Mentions any pending questions or next steps

Keep the summary under %d tokens while preserving essential context.
]], content, config.summary_opts.max_summary_tokens)

  codecompanion.chat({ 
    adapter = current_chat.adapter,
    model = current_chat.model,
  }, {
    {
      role = "system",
      content = config.summary_opts.system_prompt
    },
    {
      role = "user", 
      content = summary_prompt
    }
  })
end

-- Start fresh chat with summary
local function start_fresh_with_summary()
  local data = calculate_context_usage()
  
  if data.content_tokens < 3000 then
    vim.notify("Current chat is too short to summarize. Starting fresh chat directly.", vim.log.levels.INFO)
    require("codecompanion").chat()
    return
  end
  
  vim.notify("Creating summary for new chat session...", vim.log.levels.INFO)
  create_enhanced_summary()
  
  vim.defer_fn(function()
    vim.notify("Copy the summary to your new chat session", vim.log.levels.INFO)
  end, 1000)
end

-- Notification system
local function check_and_notify()
  if not config.show_notifications then return end
  
  local data = calculate_context_usage()
  
  if data.usage_percent >= config.critical_threshold then
    vim.notify(
      string.format("Context is %d%% full. Consider summarizing!", 
        math.floor(data.usage_percent * 100)),
      vim.log.levels.WARN,
      { title = "Context Manager" }
    )
  elseif data.usage_percent >= config.warning_threshold then
    vim.notify(
      string.format("Context is %d%% full.", 
        math.floor(data.usage_percent * 100)),
      vim.log.levels.INFO,
      { title = "Context Manager" }
    )
  end
end

-- Setup auto-update system
local function setup_auto_update()
  local group = api.nvim_create_augroup("ContextManager", { clear = true })
  
  -- Show/hide based on buffer type
  api.nvim_create_autocmd({"BufEnter", "FileType"}, {
    group = group,
    pattern = "*",
    callback = function()
      if is_codecompanion_buffer() then
        vim.defer_fn(function()
          show_context_window()
          check_and_notify()
        end, 100)
      else
        hide_context_window()
      end
    end,
  })
  
  -- Update on text changes
  api.nvim_create_autocmd({"TextChanged", "TextChangedI", "InsertLeave"}, {
    group = group,
    pattern = "*",
    callback = function()
      if is_codecompanion_buffer() then
        vim.defer_fn(function()
          show_context_window()
          check_and_notify()
        end, 300)
      end
    end,
  })
  
  -- Handle window resize
  api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if is_codecompanion_buffer() and context_enabled then
        hide_context_window()
        vim.defer_fn(show_context_window, 100)
      end
    end,
  })
end

-- Setup keymaps
local function setup_keymaps()
  -- Global toggle
  vim.keymap.set("n", config.keymaps.toggle_context, toggle_context_window, 
    { silent = true, desc = "Toggle context window" })
  
  -- Buffer-specific keymaps for codecompanion
  api.nvim_create_autocmd("FileType", {
    pattern = "codecompanion",
    callback = function()
      local opts = { buffer = true, silent = true }
      
      vim.keymap.set("n", config.keymaps.check_context, check_context_usage,
        vim.tbl_extend("force", opts, { desc = "Check context usage" }))
      
      vim.keymap.set("n", config.keymaps.summarize_chat, create_enhanced_summary,
        vim.tbl_extend("force", opts, { desc = "Create summary" }))
      
      vim.keymap.set("n", config.keymaps.start_fresh_with_summary, start_fresh_with_summary,
        vim.tbl_extend("force", opts, { desc = "Start fresh with summary" }))
    end,
  })
end

-- Extension setup
function Extension.setup(opts)
  config = vim.tbl_deep_extend("force", default_opts, opts or {})
  
  setup_auto_update()
  setup_keymaps()
  
  -- User commands
  api.nvim_create_user_command("CCContextCheck", check_context_usage, {
    desc = "Check context usage"
  })
  
  api.nvim_create_user_command("CCContextSummary", create_enhanced_summary, {
    desc = "Create summary"
  })
  
  api.nvim_create_user_command("CCContextFresh", start_fresh_with_summary, {
    desc = "Start fresh chat with summary"
  })
  
  api.nvim_create_user_command("CCContextToggle", toggle_context_window, {
    desc = "Toggle context window"
  })
  
  api.nvim_create_user_command("CCContextInspect", inspect_messages, {
    desc = "Inspect message structure for debugging"
  })
end

-- Exports
Extension.exports = {
  check_context = check_context_usage,
  create_summary = create_enhanced_summary,
  start_fresh = start_fresh_with_summary,
  toggle_context = toggle_context_window,
  get_context_data = function() return context_data end,
}

return Extension