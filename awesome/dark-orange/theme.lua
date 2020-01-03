-----------------------------------
--  "dark-orange" awesome theme  --
--          By gnush.            --
-----------------------------------
--  initially based on "Zenburn" --
--      By Adrian C. (anrxc)     --
-----------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
theme.wallpaper = "~/bilder/wallpaper/current"
-- }}}

-- {{{ Styles
theme.font      = "sans 8"

-- {{{ Colors
theme.fg_normal = "#F0DFAF"
theme.fg_focus  = "#F4BF07"
theme.fg_urgent = "#DD0000"
theme.bg_normal = "#1E2320"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#1E2320"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width  = 1
theme.border_normal = "#1E2320"
theme.border_focus  = "#F4BF07"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 15
theme.menu_width  = 100
-- }}}

-- for a global installation use /usr/share/awesome (or whoever you have put it)
themeDir = "~/.config/awesome/themes/dark-orange"

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = themeDir .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = themeDir .. "/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = themeDir .. "/awesome-icon.png"
theme.menu_submenu_icon      = themeDir .. "/submenu.png"
theme.tasklist_floating_icon = themeDir .. "/floatingw.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = themeDir .. "/layouts/tile.png"
theme.layout_tileleft   = themeDir .. "/layouts/tileleft.png"
theme.layout_tilebottom = themeDir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = themeDir .. "/layouts/tiletop.png"
theme.layout_fairv      = themeDir .. "/layouts/fairv.png"
theme.layout_fairh      = themeDir .. "/layouts/fairh.png"
theme.layout_spiral     = themeDir .. "/layouts/spiral.png"
theme.layout_dwindle    = themeDir .. "/layouts/dwindle.png"
theme.layout_max        = themeDir .. "/layouts/max.png"
theme.layout_fullscreen = themeDir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = themeDir .. "/layouts/magnifier.png"
theme.layout_floating   = themeDir .. "/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = themeDir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themeDir .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = themeDir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themeDir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themeDir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themeDir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themeDir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themeDir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themeDir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themeDir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themeDir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themeDir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themeDir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themeDir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themeDir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themeDir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themeDir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themeDir .. "/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
