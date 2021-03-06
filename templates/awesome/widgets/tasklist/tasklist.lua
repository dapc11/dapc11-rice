local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local clickable_container = require('widgets.tasklist.clickable_container')

local function list_update(w, buttons, label, data, objects)
    -- Update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, cb, tb, cbm, bgb, tbm, ibm, tt, l, ll, bg_clickable
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
            tt = cache.tt
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()
            cb = wibox.widget {
                {
                    {markup = '', widget = wibox.widget.textbox},
                    margins = dpi(1),
                    widget = wibox.container.margin
                },
                widget = clickable_container
            }
            cb.shape = gears.shape.circle
            cbm = wibox.widget {
                -- 4, 8 ,12 ,12 -- close button
                cb,
                left = dpi(4),
                right = dpi(8),
                top = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            }
            cbm:buttons(gears.table.join(
                            awful.button({}, 1, nil, function()
                    o:kill()
                end)))
            bg_clickable = clickable_container()
            bgb = wibox.container.background()
            tbm = wibox.widget {
                tb,
                left = dpi(4),
                right = dpi(4),
                widget = wibox.container.margin
            }
            ibm = wibox.widget {
                -- 12 top bottom
                ib,
                left = dpi(6),
                right = dpi(6),
                top = dpi(6),
                bottom = dpi(6),
                widget = wibox.container.margin
            }
            l = wibox.layout.fixed.horizontal()
            ll = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)
            l:add(tbm)
            ll:add(l)
            ll:add(cbm)

            bg_clickable:set_widget(ll)
            -- And all of this gets a background
            bgb:set_widget(bg_clickable)

            -- Tooltip to display whole title, if it was truncated
            tt = awful.tooltip({
                objects = {tb},
                mode = 'outside',
                align = 'bottom',
                delay_show = 1
            })

            data[o] = {
                ib = ib,
                tb = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm,
                tt = tt
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        args = args or {}

        -- The text might be invalid, so use pcall.
        if text == nil or text == '' then
            tbm:set_margins(0)
        else
            -- Truncate when title is too long
            local text_only = text:match('>(.-)<')
            if (utf8.len(text_only) > 24) then
                text = text:gsub('>(.-)<', '>' ..
                                     string.sub(text_only, 1,
                                                utf8.offset(text_only, 22) - 1) ..
                                     '...<')
                tt:set_text(text_only)
                tt:add_to_object(tb)
            else
                tt:remove_from_object(tb)
            end
            if not tb:set_markup_silently(text) then
                tb:set_markup('<i>&lt;Invalid text&gt;</i>')
            end
        end
        bgb:set_bg(bg)
        if type(bg_image) == 'function' then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb, o, nil, objects, i)
        end
        bgb:set_bgimage(bg_image)
        if icon then
            ib.image = gears.surface(icon)
        else
            ibm:set_margins(0)
        end

        bgb.shape = args.shape
        bgb.shape_border_width = args.shape_border_width
        bgb.shape_border_color = args.shape_border_color

        w:add(bgb)
    end
end

local tasklist_buttons = awful.util.table.join(
                             awful.button({}, 1, function(c)
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
            c:emit_signal('request::activate')
            c:raise()
        end
    end), awful.button({}, 2, function(c) c:kill() end), awful.button({}, 4,
                                                                      function()
        awful.client.focus.byidx(1)
    end), awful.button({}, 5, function() awful.client.focus.byidx(-1) end))

local task_list = function(s)
    return awful.widget.tasklist {
    screen   = s,
    filter   = awful.widget.tasklist.filter.focused,
    buttons  = tasklist_buttons,
    layout   = {
        spacing = 10,
        layout  = wibox.layout.flex.horizontal
    },
    style = {
        align = "center",
    },
    -- Notice that there is *NO* wibox.wibox prefix, it is a template,
    -- not a widget instance.
    widget_template = {
        {
            {
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    left = 10,
                    right = 10,
                    margin = 10,
                    widget  = wibox.container.margin,
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 10,
            right = 10,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
    },
}end

return task_list
