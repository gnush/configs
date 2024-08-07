-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- {{{ Error handling
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
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "themes/dark-orange/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

home = os.getenv("HOME") or "/tmp"

-- get the hostname
--local phostname = io.popen("uname -n") --io.popen("cat /proc/sys/kernel/hostname")
--local hostname = phostname:read()
--phostname:close()
local fhostname = io.open("/proc/sys/kernel/hostname")
local hostname = fhostname:read()
fhostname:close()



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
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

--Create battery, sound and network widget
mybatmon = wibox.widget.textbox()

mynetworkmenu = awful.menu({
    items = {
        { "Connection Editor", "nm-connection-editor" }
    },
    theme = { width = 150 }
})

mynetwork = wibox.widget.textbox()
mynetwork:buttons(
    awful.button({}, 1,
    function()
        --if mynetworkmenu and mynetworkmenu.wibox.visible then
        --    mynetworkmenu:hide()
        --else
        --    mynetworkmenu = generate_network_menu()
        --    mynetworkmenu:show()
        --end
        if mynetworkmenu and not mynetworkmenu.wibox.visible then
            mynetworkmenu = generate_network_menu()
        end
        mynetworkmenu:toggle()
    end)
)

myvolman = wibox.widget.textbox()
myvolman:buttons(awful.util.table.join(
    awful.button({}, 1, function() volume("mute", myvolman) end),
    awful.button({}, 4, function() volume("up", myvolman) end),
    awful.button({}, 5, function() volume("down", myvolman) end)
))

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
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

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
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
    awful.tag({ "term", "www", "chat", "dev", "misc" }, s, awful.layout.layouts[2])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher, -- i don't need this
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- mykeyboardlayout, -- who wants to see this?
            wibox.widget.systray(),
            myvolman,
            mynetwork,
            mybatmon, -- TODO: split this between desktop and laptop
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
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

    -- Standard program
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
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
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
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --           {description = "show the menubar", group = "launcher"}),
    -- i prefer to use dmenu instead
    -- {{ dmenu
    awful.key({modkey }, "p", function()
        awful.util.spawn_with_shell( "exe=`dmenu_run -i -nf '#f0dfaf' -nb '#1e2320' -sf '#f5a400' -sb '#1e2320'` && exec $exe")
        end,
        {{description = "show dmenu", group = "launcher"}}),
    awful.key({ }, "Print", function () awful.util.spawn("import -window root " .. home .. "/latestScreen.png") end),
    awful.key({ }, "XF86AudioRaiseVolume",    function () volume("up", myvolman) end),
    awful.key({ }, "XF86AudioLowerVolume",    function () volume("down", myvolman) end),
    awful.key({ }, "XF86AudioMute",           function () volume("mute", myvolman) end),
    awful.key({ }, "XF86WWW",                 function () awful.util.spawn("gksudo pm-suspend") end)
)

clientkeys = awful.util.table.join(
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
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
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

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

if hostname == "eee" then
    screen1 = 1
    screen2 = screen.count()
else
    screen1 = screen.count()
    screen2 = 1
end

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
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
                     -- disable hinting
                     size_hints_honor = false,
                     -- no per default maximized windows
                     maximized_vertical   = false,
                     maximized_horizontal = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "MPlayer",
          "gimp"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    -- NOTE: no titlebars for me
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
    { rule = {class = "feh"},
      properties = { tiling = true} },
    { rule = {class = "Pidgin"},
      properties = { screen = screen1, tag = "chat"} },
    --{ rule = {class = "Thunderbird"}, -- TODO: doesnt work anymore. update with new class or sth. same for Firefox
    --  properties = { screen = screen1, tag = "misc"} },
    { rule_any = {class = {"Firefox", "Opera", "Chromium"} },
      properties = { screen = screen2, tag = "www"} },
    { rule = {class = "Eclipse"},
      properties = { screen = screen2, tag = "dev"} },
    { rule_any = {class = {"Vlc", "plugin-container", "org-spoutcraft-launcher-Main"} },
      properties = { screen = screen2, tag = "misc"} }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
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
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ some functions
function battery_charge()
        local battery_present = awful.util.file_readable("/sys/class/power_supply/BAT0/present")
        local fmax  = io.open("/sys/class/power_supply/BAT0/energy_full")
        local fnow  = io.open("/sys/class/power_supply/BAT0/energy_now")
        local fsta  = io.open("/sys/class/power_supply/BAT0/status")

        local out   = ""

        if battery_present then
            local max = fmax:read()
            local now = fnow:read()
            local sta = fsta:read()
            fmax:close()
            fnow:close()
            fsta:close()

            if sta:match("Discharging") then
                out = "[Bat↓ " .. math.floor(tonumber(now) * 100 / tonumber(max)) .. "%]"
            elseif sta:match("Charging") then
                out = "[Bat↑ " .. math.floor(tonumber(now) * 100 / tonumber(max)) .. "%]"
            elseif sta:match("Full") then
                out = "[A/C]"
            else
                out = "[A/C]"
            end
        else
            -- out = "[A/C]"
            out = "" -- if no battery is present and we're unaware of a power cable and the pc is running it's magic
        end

        return out
end

function net_status(widget)
    local path_to_net = "/sys/class/net"
    local net = io.popen("ls -a " .. path_to_net .. " | grep enp") -- TODO: easy_async?

    for eth in net:lines() do
        local fstatus = io.open(path_to_net .. "/" .. eth .. "/operstate")
        local status = fstatus:read()
        fstatus:close()

        if status == "up" then -- not 100% accurate as a connection can be up but not have an adress, but close enough.
            widget:set_text("[Eth: UP]")
            return
        end
    end
    
    local wlan_present = awful.util.file_readable("/proc/net/wireless")
    if wlan_present then
        awful.spawn.easy_async("awk 'NR==3 {printf \"%3.0f\", $3*100/70}' /proc/net/wireless",
            function(stdout, stderr, reason, exit_code)
                if stdout == "" then
                    widget:set_text("[Wifi: D/C]")
                else
                    widget:set_text("[Wifi: " .. tonumber(stdout) .. "%]")
                end
            end)
    else
        widget:set_text("[Wifi: N/A]") -- TODO: change to Eth: Down?
    end
end

function volume(action, widget) -- easy_async this?
    local channel = "Master"
    local stat = ""
    local vol =""
    local pid = nil

    if action == "up" then
        pid = io.popen("amixer -q set " .. channel .. " 2%+")
        volume("", widget)
        io.close(pid)
    elseif action == "down" then
        pid = io.popen("amixer -q set " .. channel .. " 2%-")
        volume("", widget)
        io.close(pid)
    elseif action == "mute" then
        pid = io.popen("amixer -q set " .. channel .. " toggle")
        volume("", widget)
        io.close(pid)
    end
    -- update the widget
    pid = io.popen("amixer sget " .. channel)
    stat = pid:read("*all")
    io.close(pid)

    if stat == nil or stat == "" then
        vol = "[Vol: ?]"
    elseif stat:find("off") then
        vol = "[Vol: M]"
    else
        vol = "[Vol: " .. string.format("% 3d", stat:match("(%d?%d?%d)%%")) .. "%]"
    end

    widget:set_text(vol)
end

-- Generates a menu to interact with NetworkManager
function generate_network_menu(widget)
    local noop = function() end

    local function disconnect(device)
        return function()
            awful.spawn.easy_async("nmcli device disconnect " .. device, noop)
        end
    end

    local function connect_eth(device)
        return function()
            awful.spawn.easy_async("nmcli device connect " .. device, noop) -- TODO: callback → notify about successfull connection, also add this to connect_wifi
        end
    end

    local function connect_wifi(ssid, device)
        return function()
            if device then
                awful.spawn.easy_async("nmcli device wifi connect " .. ssid .. " ifname " .. device, noop)
            else
                awful.spawn.easy_async("nmcli device wifi connect " .. ssid, noop)
            end
        end
    end

    local static_entries = {
        { "Connection Editor", function() awful.spawn.raise_or_spawn("nm-connection-editor", {}) end } -- restores minimized windows and switches to the right tag
        --{ "Connection Editor", function() awful.spawn.single_instance("nm-connection-editor", {}) end } -- doesnt
    }

    local pid = io.popen("nmcli radio wifi")
    local wifi_state = pid:read() == "enabled" and "on" or "off"
    io.close(pid)
    
    local eth = {}
    local wifi = {
            { "Wifi: " .. wifi_state .. "\t\t[toggle]", function()
                                        if wifi_state == "on" then
                                            wifi_state = "off"
                                            awful.spawn.easy_async("nmcli radio wifi " .. wifi_state, noop)
                                        elseif wifi_state == "off" then
                                            wifi_state = "on"
                                            awful.spawn.easy_async("nmcli radio wifi " .. wifi_state, noop)
                                        end
                                      end
            }
    }

    -- use io. because we want synchronous stuff here
    pid = io.popen("nmcli device | tail -n +2")
    for k,entry in pairs(string_to_table(pid:read("*all"), elem_name)) do
        if entry[2] == "ethernet" and entry[3] == "connected" then
            table.insert(eth, { "Ethernet: " .. entry[4], noop})
            table.insert(eth, { "\t↑ disconnect", disconnect(entry[1])})
        elseif entry[2] == "ethernet" and entry[3] == "disconnected" then
            table.insert(eth, { "Connect " .. entry[1], connect_eth(entry[1]) })
        elseif entry[2] == "wifi" and entry[3] == "connected" then
    local wlan_present = awful.util.file_readable("/proc/net/wireless")
            local ICON_PATH = "/usr/share/icons/hicolor/22x22/apps/"
            local icon = ICON_PATH .. "nm-signal-00.png"
            if awful.util.file_readable("/proc/net/wireless") then
                local pWireless = io.popen("awk 'NR==3 {printf \"%3.0f\", $3*100/70}' /proc/net/wireless") -- TODO: replace through bars_to_nm_icon if we keep background scanning?
                local signal_strength = tonumber(pWireless:read())
                io.close(pWireless)

                if signal_strength > 20 and signal_strength <= 45 then
                    icon = ICON_PATH .. "nm-signal-25.png"
                elseif signal_strength > 45 and signal_strength <= 70 then
                    icon = ICON_PATH .. "nm-signal-50.png"
                elseif signal_strength > 70 and signal_strength <= 95 then
                    icon = ICON_PATH .. "nm-signal-75.png"
                else
                    icon = ICON_PATH .. "nm-signal-100.png"
                end
            end
            table.insert(wifi, { entry[4] .. "\t\t[disconnect]", disconnect(entry[1]), icon })
        else
            -- TODO: what to do with other types?
        end
    end
    io.close(pid)


    -- add wifi scan list (maybe only for those ssids that have a profile)
    local scan_list = {}
    for k,wifi_net in pairs(wifi_list) do
        table.insert(scan_list, { " " .. wifi_net.ssid, connect_wifi(wifi_net.ssid), bars_to_nm_icon(wifi_net.bars) })
    end
    table.insert(wifi, {"Scan List …", scan_list })

    -- TODO: replace awful.util.table with gears.table in the rest of the conf
    local networkmenu = awful.menu({
        items = gears.table.join(
            eth,
            wifi,
            static_entries
        ),
        theme = { width = 175 } -- TODO: find a way to measure it dynamically
    })

    return networkmenu
end

-- Assumes each line of the argument to be separated by spaces.
-- Returns A table with one entry per input line.
function string_to_table(argument_lines)
    local result = {}
    for line in argument_lines:gmatch("[^\n]+") do
        table.insert(result, string_split_whitespace(line))
    end

    return result
end

-- Assumes each line of the argument to be separated by spaces.
-- Returns A table, where elem_names specifies the names associated with the different words per line.
function string_to_associative_table(argument_lines, elem_names)
    elem_names = elem_names or {"type", "connection"}

    local result = {}
    for line in argument_lines:gmatch("[^\n]+") do
        local result_entry = {}
        for i,entry in ipairs(string_split_whitespace(line)) do
            result_entry[elem_names[i]] = entry
        end

        table.insert(result, result_entry)
    end

    return result
end

function string_split_whitespace(input)
    local result = {}

    for word in input:gmatch("%S+") do
        table.insert(result, word)
    end

    return result
end

wifi_list = {}
function wifi_scan() -- TODO: ssids with spaces in the name break things
    awful.spawn.with_line_callback("nmcli device wifi list", {
        stdout = function(line)
            local words = string_split_whitespace(line)

            local ssid = ""
            local rate = ""
            local bars = ""

            if (words[1] == "IN-USE") then
                -- header line → ignore
                return
            elseif (words[1] == "*") then
                -- connected network
                ssid = words[3]
                rate = words[6]
                bars = words[9]
            else
                -- not connectet
                ssid = words[2]
                rate = words[5]
                bars = words[8]
            end

            local result = {}
            result["ssid"] = ssid
            result["rate"] = rate
            result["bars"] = bars

            table.insert(wifi_list, result)
        end
    })
end

-- Bars are expected to be formatted like the output from 'nmcli device wifi list'
function bars_to_nm_icon(bars)
    local ICON_PATH = "/usr/share/icons/hicolor/22x22/apps/"
    if     bars == "____" then
        return ICON_PATH .. "nm-signal-00.png"
    elseif bars == "▂___" then
        return ICON_PATH .. "nm-signal-25.png"
    elseif bars == "▂▄__" then
        return ICON_PATH .. "nm-signal-50.png"
    elseif bars == "▂▄▆_" then
        return ICON_PATH .. "nm-signal-75.png"
    elseif bars == "▂▄▆█" then
        return ICON_PATH .. "nm-signal-100.png"
    end
end

-- timers at the end, else call_now doesnt work because stuff is not initialized yet
-- Update the widgets every five seconds.
mywidgetupdatetimer = gears.timer({
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function()      
        mybatmon:set_text(battery_charge())
        net_status(mynetwork)
        volume("update", myvolman)
    end
})

-- Scan for wifi every 5 minutes TODO, if not connected to a wifi
mywifiscantimer = gears.timer({
    timeout = 300,
    call_now = true,
    autostart = true,
    callback = function()
        -- TODO: maybe change this to a more "functional" approach.
        -- e.g. in wifi_scan() use awful.spawn.easy_async instead of .with_line_callback()
        wifi_list = {} -- clear the wifi list
        wifi_scan() -- add new scan to wifi list
    end
})
