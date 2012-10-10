-- for 3.4.10

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/own/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/dark-orange/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- get the hostname
local fhostname = io.popen("cat /proc/sys/kernel/hostname")
local hostname = fhostname:read()
fhostname:close()

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
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
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "term", "www", "chat", "dev", "misc" }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

--Create battery, sound and wifi widget
mybatmon = widget({ type = "textbox", name = "mybatmon", align = "right"})

mywifimenu = awful.menu({
    items = {
        { "vpn", nil },
        { "cased", nil },
        { "hrz", function() awful.util.spawn("gksudo vpnc /etc/vpnc/hrz.conf") end },
        { "disconnect", function() awful.util.spawn("gksudo vpnc-disconnect") end }
    }
})
mywifi = widget({ type = "textbox", name = "mywifi", align = "right" })
mywifi:buttons(awful.util.table.join(
    awful.button({}, 1, function() mywifimenu:toggle() end)
))

myvolman = widget({ type = "textbox", name = "myvolman", align = "right" })
myvolman:buttons(awful.util.table.join(
    awful.button({}, 1, function() volume("mute", myvolman) end),
    awful.button({}, 4, function() volume("up", myvolman) end),
    awful.button({}, 5, function() volume("down", myvolman) end)
))

-- mywifi = awful.widget.textbox()

-- wifi widget with menu
--mywifimenu = awful.menu({ items = { { "cased", vpn("cased") },
--                                    { "hrz", vpn("hrz") }
--                                  }
--                        })
--mywifi = awful.widget.launcher({ name="mywifi", align = "right", menu = mywifimenu })

-- button widget test
mybuttons = widget({ type = "textbox" })
mybuttons.text = "doedel"

mybuttons:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn() end)
))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
           -- mylauncher, --disables the menu icon in the titlebar
                          -- dmenu makes it useless 
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        hostname == "eee" and mybatmon or nil,
        --mybuttons,
        mytest,
        hostname == "zuiop" and myvolman or nil,
        mywifi,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
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
-- {{ dmenu
    awful.key({modkey }, "p", function()
        awful.util.spawn_with_shell( "exe=`dmenu_run -i -nf '#f0dfaf' -nb '#1e2320' -sf '#f5a400' -sb '#1e2320'` && exec $exe")
    end),
    
    -- moc keybindings
    awful.key({ modkey, }, "n", function()
                                    os.execute("mocp -f")
                                    --awful.util.spawn_with_shell("mocp -f")

                                    --local mocp = io.popen("mocp -Q '%artist - %song\n(%album)'")
                                    --local s = ""

                                    --for l in mocp:lines() do
                                    --    s = s .. l .. "\n"
                                    --end

                                    --naughty.notify({text=s})
                                end),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    awful.key({ }, "XF86AudioRaiseVolume",    function () volume("up", myvolman) end),
    awful.key({ }, "XF86AudioLowerVolume",    function () volume("down", myvolman) end),
    awful.key({ }, "XF86AudioMute",           function () volume("mute", myvolman) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
--    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules

-- on laptops, use the extra plugged display
if hostname == "eee" then
    display = screen.count()
else
    display = 1
end

awful.rules.rules = {
    --disable hinting
    { rule = { },
      properties = { size_hints_honor = false  } },
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
        properties = { floating = true } },
    { rule = { class = "pinentry" },
        properties = { floating = true } },
    { rule = { class = "gimp" },
        properties = { floating = true } },
    { rule = { class = "feh" },
        properties = { tiling = true,
                       tag = tags[display][5] } },
    { rule = { class = "Firefox" },
        properties = { tag = tags[display][2] } },
    { rule = { class = "opera" },
        properties = { tag = tags[display][2] } },
    { rule = { class = "Chromium" },
        properties = { tag = tags[display][2] } },
    { rule = { class = "Eclipse" },
        properties = { tag = tags[display][4] } },
    { rule = { class = "Vlc" },
        properties = { tag = tags[display][5] } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- timer
mytimer = timer({ timeout = 2 })
mytimer:add_signal("timeout",
                    function()
                        mybatmon.text = battery_charge()
                        mywifi.text = wifi()
                        volume("update", myvolman)
                    end)
mytimer:start()


-- some functions
function battery_charge()
--    if hostname == "eee" then
        local fbat  = io.open("/sys/class/power_supply/BAT0/present")
        local fmax  = io.open("/sys/class/power_supply/BAT0/charge_full")
        local fnow  = io.open("/sys/class/power_supply/BAT0/charge_now")
        local fsta  = io.open("/sys/class/power_supply/BAT0/status")

        local out   = ""

        if fbat ~= nil then
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
            else
                out = "[A/C]"
            end
        else
            out = "[A/C]"
        end

        return out
--    else
--        return ""
--    end
end

function wifi()
    local flink = io.open("/sys/class/net/wlan0/wireless/link")

    --local link = flink:read()
    --flink:close()
    local out = ""
    if flink ~= nil then
        local link = flink:read()
        flink:close()
        
        if tonumber(link) <= 10 then
            out = "[Wifi: D/C]"
        else
            out = "[Wifi: " .. math.floor(tonumber(link) * 100 / 70)  .. "%]"
        end
    else
        out = "[Wifi: N/A]"
    end
    return out
end

function volume(action, widget)
    local channel = "Master"
    local stat = ""
    local vol =""

    if action == "up" then
        io.popen("amixer -q set " .. channel .. " 2%+")
        volume("", widget)
    elseif action == "down" then
        io.popen("amixer -q set " .. channel .. " 2%-")
        volume("", widget)
    elseif action == "mute" then
        io.popen("amixer -q set " .. channel .. " toggle")
        volume("", widget)
    else
        -- update the widget
        stat = io.popen("amixer sget " .. channel):read("*all")


        if stat:find("off") then
            vol = "[Vol: M]"
        else
            vol = "[Vol: " .. string.format("% 3d", stat:match("(%d?%d?%d)%%")) .. "%]"
        end

        widget.text = vol
    end
end
