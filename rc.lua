-- ↓↓↓1 IMPORTS
-- ↓↓↓2 LUAROCKS
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- ↑↑↑2 END LUAROCKS
-- ↓↓↓2 STANDARD AWESOME LIBRARY
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- ↑↑↑2 END STANDARD AWESOME LIBRARY
-- ↓↓↓2 WIDGET AND LAYOUT LIBRARY
local wibox = require("wibox")
-- ↑↑↑2 END WIDGET AND LAYOUT LIBRARY
-- ↓↓↓2 THEME HANDLING LIBRARY
local beautiful = require("beautiful")
-- ↑↑↑2 END THEME HANDLING LIBRARY
-- ↓↓↓2 NOTIFICATION LIBRARY
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- ↑↑↑2 END NOTIFICATION LIBRARY
-- ↓↓↓2 EXTRA HELP
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- ↑↑↑2 END EXTRA HELP
-- ↑↑↑1 END IMPORTS

-- ↓↓↓ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- ↑↑↑
-- ↓↓↓ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "mate-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- ↑↑↑
-- ↓↓↓ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- ↑↑↑
-- ↓↓↓1 Tag add edit delete functions
-- Functions from https://awesomewm.org/apidoc/core_components/tag.html
-- ↓↓↓2 def delete_tag()
local function delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end
-- ↑↑↑2 END delete_tag
-- ↓↓↓2 def add_tag()
local function add_tag()
    awful.tag.add("NewTag", {
        screen = awful.screen.focused(),
        layout = awful.layout.suit.floating }):view_only()
end
-- ↑↑↑2 END add_tag
-- ↓↓↓2 def rename_tag()
local function rename_tag()
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end

            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end
-- ↑↑↑2 END rename_tag
-- ↓↓↓2 def move_to_new_tag()
local function move_to_new_tag()
    local c = client.focus
    if not c then return end

    local t = awful.tag.add(c.class,{screen= c.screen })
    c:tags({t})
    t:view_only()
end
-- ↑↑↑2 END move_to_new_tag
-- ↓↓↓2 def copy_tag()
local function copy_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end

    local clients = t:clients()
    local t2 = awful.tag.add(t.name, awful.tag.getdata(t))
    t2:clients(clients)
    t2:view_only()
end
-- ↑↑↑2 END copy_tag
-- ↑↑↑1 END Tag add edit delete functions
-- ↓↓↓ Wibar
-- Create a textclock widget
--mytextclock = wibox.widget.textclock()
mytextclock = wibox.widget.textclock(" %a %b %d, %I:%M%p ")


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    -- awful.tag({ "1-TERM", "2-WEB", "3-COMM", "4-OBSIDIAN", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    ----------------------------------------------------------------------
    -- My custom tags

    -- Terminal tag
    awful.tag.add("1-TERM", {
        icon = "terminal-icon.png",
        layout = awful.layout.layouts[10],
        screen = s,
        selected = true,
    })
    -- Web tag
    awful.tag.add("2-WEB", {
        --icon = "terminal-icon.png",
        layout = awful.layout.layouts[10],
        screen = s,
    })
    -- Comm tag
    awful.tag.add("3-COMM", {
        --icon = "terminal-icon.png",
        layout = awful.layout.layouts[10],
        screen = s,
    })
    -- Obsidian tag
    awful.tag.add("4-OBSIDIAN", {
        layout = awful.layout.layouts[2],
        screen = s,
    })

    -- END my custom tags
    ----------------------------------------------------------------------

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            --mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- ↑↑↑
-- ↓↓↓ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- ↑↑↑
-- ↓↓↓1 Key bindings
    -- ↓↓↓2 GLOBAL
    globalkeys = gears.table.join(
        -- ↓↓↓3 AWESOME
        awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
                {description="show help", group="awesome"}),
        awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
                {description = "show main menu", group = "awesome"}),
        -- ↑↑↑3 END AWESOME
        -- ↓↓↓3 CLIENT NAVIGATION
        awful.key({ modkey,           }, "j",
            function ()
                awful.client.focus.byidx( 1)
            end,
            {description = "focus next by index", group = "client"}
        ),
        awful.key({ modkey,           }, "k",
            function ()
                awful.client.focus.byidx(-1)
            end,
            {description = "focus previous by index", group = "client"}
        ),
        -- ↑↑↑3 END CLIENT MANIPULATION
        -- ↓↓↓3 TAG MANIPULATION
            -- ↓↓↓4 NAVIGATION
            awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
                    {description = "go back", group = "tag"}),
            awful.key({ modkey, "Shift"   }, ",",   awful.tag.viewprev,
                    {description = "view previous", group = "tag"}),
            awful.key({ modkey, "Shift"   }, ".",  awful.tag.viewnext,
                    {description = "view next", group = "tag"}),
            -- ↑↑↑4 END NAVIGATION
            -- ↓↓↓4 ADD/EDIT/DELTE
            awful.key({ modkey,  "Shift"  }, "c", add_tag,
                    {description = "add a tag", group = "tag"}),
            awful.key({ modkey,  "Shift"  }, "d", delete_tag,
                    {description = "delete the current tag", group = "tag"}),
            awful.key({ modkey,  "Shift"  }, "!", move_to_new_tag,
                    {description = "add a tag with the focused client", group = "tag"}),
            --awful.key({ modkey, "Mod1"   }, "a", copy_tag,
                    --{description = "create a copy of the current tag", group = "tag"}),
            awful.key({ modkey, "Shift"   }, "r", rename_tag,
                    {description = "rename the current tag", group = "tag"}),
            -- ↑↑↑4 END ADD/EDIT/DELTE
        -- ↑↑↑3 END TAG MANIPULATION
        -- ↓↓↓3 LAYOUT MANIPULATION
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
                {description = "swap with next client by index", group = "client"}),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
                {description = "swap with previous client by index", group = "client"}),
        awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
                {description = "focus the next screen", group = "screen"}),
        awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
                {description = "focus the previous screen", group = "screen"}),
        awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
                {description = "jump to urgent client", group = "client"}),
        awful.key({ modkey,           }, "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            {description = "go back", group = "client"}),
        -- ↑↑↑3 END LAYOUT MANIPULATION
        -- ↓↓↓3 STANDARD PROGRAM
        awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
                {description = "open a terminal", group = "launcher"}),
        awful.key({ modkey, "Control" }, "r", awesome.restart,
                {description = "reload awesome", group = "awesome"}),
        awful.key({ modkey, "Shift"   }, "q", awesome.quit,
                {description = "quit awesome", group = "awesome"}),

        awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
                {description = "increase master width factor", group = "layout"}),
        awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
                {description = "decrease master width factor", group = "layout"}),
        awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
                {description = "increase the number of master clients", group = "layout"}),
        awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
                {description = "decrease the number of master clients", group = "layout"}),
        awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
                {description = "increase the number of columns", group = "layout"}),
        awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
                {description = "decrease the number of columns", group = "layout"}),
        awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
                {description = "select next", group = "layout"}),
        awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
                {description = "select previous", group = "layout"}),

        awful.key({ modkey, "Control" }, "n",
                function ()
                    local c = awful.client.restore()
                    -- Focus restored client
                    if c then
                        c:emit_signal(
                            "request::activate", "key.unminimize", {raise = true}
                        )
                    end
                end,
                {description = "restore minimized", group = "client"}),
        -- ↑↑↑3 END STANDARD PROGRAM
        -- ↓↓↓3 PROMPT
        awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
                {description = "run prompt", group = "launcher"}),

        awful.key({ modkey }, "x",
                function ()
                    awful.prompt.run {
                        prompt       = "Run Lua code: ",
                        textbox      = awful.screen.focused().mypromptbox.widget,
                        exe_callback = awful.util.eval,
                        history_path = awful.util.get_cache_dir() .. "/history_eval"
                    }
                end,
                {description = "lua execute prompt", group = "awesome"}),
        -- ↑↑↑3 END PROMPT
        -- ↓↓↓3 MENUBAR
        awful.key({ modkey }, "p", function() menubar.show() end,
                {description = "show the menubar", group = "launcher"})
        -- ↑↑↑3 END MENUBAR
    )
    -- ↑↑↑2 END GLOBAL
        -- ↓↓↓3 NUMBER KEY INTERACTION BINDING GENERATION
        -- Bind all key numbers to tags.
        -- Be careful: we use keycodes to make it work on any keyboard layout.
        -- This should map on the top row of your keyboard, usually 1 to 9.
        for i = 1, 9 do
            globalkeys = gears.table.join(globalkeys,
                -- View tag only.
                awful.key({ modkey }, "#" .. i + 9,
                        function ()
                                local screen = awful.screen.focused()
                                local tag = screen.tags[i]
                                if tag then
                                tag:view_only()
                                end
                        end,
                        {description = "view tag #"..i, group = "tag"}),
                -- Toggle tag display.
                awful.key({ modkey, "Control" }, "#" .. i + 9,
                        function ()
                            local screen = awful.screen.focused()
                            local tag = screen.tags[i]
                            if tag then
                                awful.tag.viewtoggle(tag)
                            end
                        end,
                        {description = "toggle tag #" .. i, group = "tag"}),
                -- Move client to tag.
                awful.key({ modkey, "Shift" }, "#" .. i + 9,
                        function ()
                            if client.focus then
                                local tag = client.focus.screen.tags[i]
                                if tag then
                                    client.focus:move_to_tag(tag)
                                end
                            end
                        end,
                        {description = "move focused client to tag #"..i, group = "tag"}),
                -- Toggle tag on focused client.
                awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                        function ()
                            if client.focus then
                                local tag = client.focus.screen.tags[i]
                                if tag then
                                    client.focus:toggle_tag(tag)
                                end
                            end
                        end,
                        {description = "toggle focused client on tag #" .. i, group = "tag"})
            )
        end
        -- ↑↑↑3 END NUMBER KEY INTERACTION BINDING GENERATION
    -- ↓↓↓2 CLIENT
        -- ↓↓↓3 KEYBOARD
        clientkeys = gears.table.join(
            awful.key({ modkey,           }, "f",
                function (c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end,
                {description = "toggle fullscreen", group = "client"}),
            awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                    {description = "close", group = "client"}),
            awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                    {description = "toggle floating", group = "client"}),
            awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                    {description = "move to master", group = "client"}),
            awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                    {description = "move to screen", group = "client"}),
            awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                    {description = "toggle keep on top", group = "client"}),
            awful.key({ modkey,           }, "n",
                function (c)
                    -- The client currently has the input focus, so it cannot be
                    -- minimized, since minimized clients can't have the focus.
                    c.minimized = true
                end ,
                {description = "minimize", group = "client"}),
            awful.key({ modkey,           }, "m",
                function (c)
                    c.maximized = not c.maximized
                    c:raise()
                end ,
                {description = "(un)maximize", group = "client"}),
            awful.key({ modkey, "Control" }, "m",
                function (c)
                    c.maximized_vertical = not c.maximized_vertical
                    c:raise()
                end ,
                {description = "(un)maximize vertically", group = "client"}),
            awful.key({ modkey, "Shift"   }, "m",
                function (c)
                    c.maximized_horizontal = not c.maximized_horizontal
                    c:raise()
                end ,
                {description = "(un)maximize horizontally", group = "client"})
        )
        -- ↑↑↑3 END KEYBOARD
        -- ↓↓↓3 MOUSE
        clientbuttons = gears.table.join(
            awful.button({ }, 1, function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
            end),
            awful.button({ modkey }, 1, function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.move(c)
            end),
            awful.button({ modkey }, 3, function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.resize(c)
            end)
        )
        -- ↑↑↑3 END MOUSE
    -- ↑↑↑2 END CLIENT
-- Set keys
root.keys(globalkeys)
-- ↑↑↑1
-- ↓↓↓ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- ↓↓↓2 All CLIENTS MATCH
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false -- This makes mate-terminal fille the entire assigned area.
     }
    },
    -- ↑↑↑2 END All CLIENTS MATCH
    -- ↓↓↓2 FLOATING CLIENTS
    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},
    
        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},
    -- ↑↑↑2 END FLOATING CLIENTS
    -- ↓↓↓2 TITLE BARS (OFF)
    -- Remove title bars.
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },
    -- ↑↑↑2 END TITLE BARS (OFF)
    -- ↓↓↓2 EXAMPLE SETTING AN APPLICATION TO STAY ON A SPECIFIC TAG ON A SPECIFIC SCREEN
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
    -- ↑↑↑2 END EXAMPLE SETTING APPLICATION TO STAY ON A SPECIFIC TAG ON A SPECIFIC SCREEN
}
-- ↑↑↑
-- ↓↓↓ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- ↑↑↑
-- ↓↓↓1 HOLD JUNK
-- -- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()
-- ↑↑↑1 END HOLD JUNK
