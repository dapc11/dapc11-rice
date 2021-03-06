-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
local hotkeys_popup = require("awful.hotkeys_popup")

-- bar widgets
local battery_widget = require("widgets.battery.battery")
local calendar_widget = require("widgets.calendar.calendar")
local volume_widget = require("widgets.volume.volume")
local wireless_widget = require("widgets.network.wireless")
local task_list_widget = require("widgets.tasklist.tasklist")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

--  Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
--

-- Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
beautiful.taglist_bg_occupied = "{{base02}}"
beautiful.taglist_shape_focus = gears.shape.rounded_bar
beautiful.taglist_shape = gears.shape.rounded_bar

-- This is used later as the default terminal and editor to run.
terminal = "{{terminal}}"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.magnifier
}
--

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--

--  Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %y-%m-%d  %H:%M:%S", 1)
local month_calendar = awful.widget.calendar_popup.month(
    {
        week_numbers = true,
        margin = 5,
        style_weeknumber = {border_width = 0, bg_color = "{{base03}}"},
        style_normal = {border_width = 0},
        style_weekday = {border_width = 0}
    }
)
month_calendar:attach(mytextclock, "tr")

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c) if c == client.focus then c.minimized = true else c:emit_signal("request::activate", "tasklist", {raise = true}) end end),
    awful.button({}, 3, function() awful.menu.client_list({theme = {width = 250}}) end),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function create_tags(s)
    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, awful.layout.layouts[1])
end

local function create_layout_box(s)
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
        gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end)
        )
)
end

local function create_tag_list(s)
    return awful.widget.taglist {
        screen = s,
        filter = function (t) return t.selected or #t:clients() > 0 end,
        buttons = awful.button({}, 1, function(t) t:view_only() end)
    }
end

local function setup_wibox(s)
    local separator = wibox.widget {
        shape = gears.shape.circle,
        forced_width = 10,
        opacity = 0,
        widget = wibox.widget.separator
    }

    function boxWidget(widget)
        return {
            {widget, widget = wibox.container.margin},
            shape = gears.shape.rounded_rect,
            bg = beautiful.bg_normal,
            shape_clip = true,
            widget = wibox.container.background
        }
    end

    local left = {
        {
            layout = wibox.layout.fixed.horizontal,
            separator,
            boxWidget(s.mytaglist),
            separator,
            boxWidget({
                s.mylayoutbox,
                left = 2,
                right = 2,
                widget = wibox.container.margin
            }),
            separator
        },
        top = 4,
        widget = wibox.container.margin
    }

    local middle = {
        task_list_widget(s),
        top = 4,
        widget = wibox.container.margin
    }

    local right = {
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            separator,
            boxWidget(wireless_widget({
                popup_position = "top_right",
                main_color = "{{base07}}"
            })),
            separator,
            boxWidget(battery_widget({
                low_level_color = "{{base08}}",
                medium_level_color = "{{base0A}}",
                charging_color = "{{base06}}"
            })),
            separator,
            boxWidget(volume_widget {
                widget_type = 'icon_and_text',
                mute_color = '{{base08}}'
            }),
            separator,
            boxWidget(mytextclock),
            separator
        },
        top = 4,
        widget = wibox.container.margin
    }

    s.mywibox:setup{
        {
            layout = wibox.layout.align.horizontal,expand = "none", left, middle, right
        },
        left = 8,
        right = 8,
        top = -2,
        bottom = 1,
        widget = wibox.container.margin
    }
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    create_tags(s)
    create_layout_box(s)
    s.mytaglist = create_tag_list(s)
    s.mywibox = awful.wibar({position = "top", screen = s})

    setup_wibox(s)
end)
--

--  Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
--

--  Key bindings
globalkeys = gears.table.join(
    awful.key({modkey}, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),
    awful.key({modkey}, "Down", function() awful.client.focus.byidx(1) end, {description = "focus next by index", group = "client"}),
    awful.key({modkey}, "Up", function() awful.client.focus.byidx(-1) end, {description = "focus previous by index", group = "client"}),
    awful.key({modkey}, "w", function() awful.spawn("{{browser}}") end, {description = "show main menu", group = "awesome"}),

-- Layout manipulation
    awful.key({modkey, "Shift"}, "Down", function() awful.client.swap.byidx(1) end, {description = "swap with next client by index", group = "client"}),
    awful.key({modkey, "Shift"}, "Up", function() awful.client.swap.byidx(-1) end, {description = "swap with previous client by index", group = "client"}),
    awful.key({modkey, "Control"}, "Down", function() awful.screen.focus_relative(1) end, {description = "focus the next screen", group = "screen"}),
    awful.key({modkey, "Control"}, "Up", function() awful.screen.focus_relative(-1) end, {description = "focus the previous screen", group = "screen"}),
    awful.key({modkey}, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
-- Standard program
    awful.key({modkey}, "Return", function() awful.spawn(terminal) end, {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    awful.key({modkey}, "s", function() awful.spawn("rofi -normal-window -show window -theme ~/.config/rofi/config") end, {description = "switch window", group = "launcher"}),
    awful.key({modkey}, "d", function() awful.spawn("rofi -normal-window -show drun -display-drun '' -modi drun -theme ~/.config/rofi/config") end, {description = "launch application", group = "launcher"}),
    awful.key({modkey}, "BackSpace", function() awful.spawn("sysact") end, {description = "session management", group = "launcher" }),
    awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

    awful.key({modkey}, "l", function() awful.tag.incmwfact(0.05) end, {description = "increase master width factor", group = "layout"}),
    awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end, {description = "decrease master width factor", group = "layout"}),
    awful.key({modkey, "Shift"}, "h", function() awful.tag.incnmaster(1, nil, true) end, {description = "increase the number of master clients", group = "layout"}),
    awful.key({modkey, "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}),
    awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1, nil, true) end, {description = "increase the number of columns", group = "layout"}),
    awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end, {description = "decrease the number of columns", group = "layout"}),
    awful.key({modkey}, "space", function() awful.layout.inc(1) end, { description = "select next", group = "layout" }),
    awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(-1) end, {description = "select previous", group = "layout"}),

    awful.key({modkey, "Control"}, "n", function() local c = awful.client.restore() if c then c:emit_signal("request::activate", "key.unminimize", {raise = true}) end end, {description = "restore minimized", group = "client"})
)
clientkeys = gears.table.join(
    awful.key({modkey}, "f", function(c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey}, "q", function(c) c:kill() end, {description = "close", group = "client" }),
    awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {description = "toggle floating", group = "client"}),
    awful.key({modkey, "Control"}, "Return", function(c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"}),
    awful.key({modkey}, "o", function(c) c:move_to_screen() end, { description = "move to screen", group = "client" }),
    awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end, {description = "toggle keep on top", group = "client"}),
    awful.key({modkey}, "m", function(c) c.maximized = not c.maximized c:raise() end, {description = "(un)maximize", group = "client"}),
    awful.key({modkey, "Control"}, "m", function(c) c.maximized_vertical = not c.maximized_vertical c:raise() end, {description = "(un)maximize vertically", group = "client"}),
    awful.key({modkey, "Shift"}, "m", function(c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end, {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then tag:view_only() end
    end, {description = "view tag #" .. i, group = "tag"}),
    -- Toggle tag display.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then awful.tag.viewtoggle(tag) end
    end, {description = "toggle tag #" .. i, group = "tag"}),
    -- Move client to tag.
    awful.key({modkey, "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then client.focus:move_to_tag(tag) end
        end
    end, {description = "move focused client to tag #" .. i, group = "tag"}),
    -- Toggle tag on focused client.
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then client.focus:toggle_tag(tag) end
        end
    end, {description = "toggle focused client on tag #" .. i, group = "tag"}))
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
    awful.button({modkey}, 1, function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
    awful.button({modkey}, 3, function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c) end)
)

-- Set keys
root.keys(globalkeys)
--

--  Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    }, -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA", -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry"
            },
            class = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
                "Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui", "veromix", "Rofi", "rofi", "xtightvncviewer"
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester" -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {floating = true}
    }, -- Add titlebars to normal clients and dialogs
    {
        rule_any = {type = {"normal", "dialog"}},
        properties = {titlebars_enabled = false}
    }, 
    {rule = {class = "Google-chrome"}, properties = {screen = 1, tag = "2"}},
    {rule = {class = "Firefox"}, properties = {screen = 1, tag = "2"}},
    {rule = {class = "Code"}, properties = {screen = 1, tag = "3"}},
    {rule = {class = "Evolution"}, properties = {screen = 1, tag = "1"}},
    {rule = {class = "Jetbrains-idea-ce"}, properties = {screen = 1, tag = "3"}},
    {rule = {class = "Jetbrains-pycharm-ce"}, properties = {screen = 1, tag = "3"}},
    {rule = {class = "Wfica"}, properties = {screen = 1, tag = "6"}},
    {rule = {class = "wfica"}, properties = {screen = 1, tag = "6"}},
    {rule = {class = "Libreoffice-writer"}, properties = {screen = 1, tag = "7"}},
    {rule = {class = "Thunar"}, properties = {screen = 1, tag = ""}},
    {rule = {class = "PulseUi"}, properties = {screen = 1, tag = "8"}},
    {rule = {class = "Pidgin"}, properties = {screen = 1, tag = "9"}},
    {rule = {class = "Telegram"}, properties = {screen = 1, tag = "9"}},
    {rule = {class = "Teams-for-linux"}, properties = {screen = 1, tag = "9"}},
    {rule = {name = "Microsoft Teams Notification"}, properties = {screen = 1, tag = "9"}}
}
--

--  Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and
        not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function() c:emit_signal("request::activate", "titlebar", {raise = true}) awful.mouse.client.move(c) end),
        awful.button({}, 3, function() c:emit_signal("request::activate", "titlebar", {raise = true}) awful.mouse.client.resize(c) end)
    )

    awful.titlebar(c):setup{
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus c.opacity = 1.0 end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal c.opacity = 0.9 end)
client.connect_signal("manage", function(c) c.shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end end)

-- Focus urgent tags automatically
tag.connect_signal("property::urgent", function(t) awful.screen.focus(t.screen) if not(t.selected) then t:view_only() end end)

-- Focus urgent clients automatically
client.connect_signal("property::urgent", function(c) c.minimized = false c:jump_to() end)
