{-# LANGUAGE LambdaCase #-}

-- ░▀█▀░█▄█░█▀█░█▀█░█▀▄░▀█▀░█▀▀
-- ░░█░░█░█░█▀▀░█░█░█▀▄░░█░░▀▀█
-- ░▀▀▀░▀░▀░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀
-- imports

import XMonad
-- import Data.Monoid
import System.Exit

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))

import XMonad.ManageHook

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.List       as L
import Data.Maybe

import XMonad.Util.Run (spawnPipe, hPutStrLn, runProcessWithInput)
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce

import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import qualified XMonad.Layout.Magnifier as Mag

import Graphics.X11.ExtraTypes.XF86

-- ░█▀▀░█▀█░█░░░█▀█░█▀▄░█▀▀
-- ░█░░░█░█░█░░░█░█░█▀▄░▀▀█
-- ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀
-- colors

type Color = String

background = "#272822"
foreground = "#f8f8f2"
red        = "#f92672"
green      = "#a6e22e"
yellow     = "#f4bf75"
blue       = "#66d9ef"
magenta    = "#ae81ff"
cyan       = "#a1efe4"


-- ░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀
-- ░█░░░█░█░█░█░█▀▀░░█░░█░█
-- ░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀
-- config

type TerminalCommand = String

myTerminal      = "alacritty"
-- myBrowser       = "qutebrowser"
myBrowser       = "google-chrome-stable"
myFileBrowser   = "thunar"

emacsCommand :: TerminalCommand
emacsCommand   = "emacs"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = True

myModMask :: KeyMask
myModMask = mod4Mask

myWorkspaces :: [WorkspaceId]
myWorkspaces = ["gen","www","emx","dev","slk","6","7","8","com"]

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"
myBorderWidth = 4

myScratchpads = [ NS "ncmpcpp" spawnNC findNC layoutNC
                , NS "terminal" spawnTM findTM layoutTM
                , NS "schedule" spawnSC findSC layoutNC
                , NS "help" spawnH findH layoutNC ]
  where
    spawnNC  = myTerminal ++ " --title ncmpcppScratchpad -e ncmpcpp"
    findNC   = title =? "ncmpcppScratchpad"
    layoutNC = customFloating $ W.RationalRect l t w h
      where
      h = 0.9
      w = 0.9
      t = 0.05
      l = 0.05

    spawnTM  = myTerminal ++ " --class instanceClass,floatingTerminal -e tmux new-session -A -s f"
    findTM   = className =? "floatingTerminal"
                                              
    layoutTM = customFloating $ W.RationalRect l t w h
      where
        l = 0.025
        t = 0.05
        h = 0.9
        w = 0.95

    spawnSC  = "sxiv ~/uni/schedule.png"
    findSC   = className =? "sxiv"

    spawnH   = "echo \"" ++ help ++ "\" | xmessage -file -"
    findH    = className =? "Xmessage"

-- ░█░█░█▀▀░█░█░█▀▀
-- ░█▀▄░█▀▀░░█░░▀▀█
-- ░▀░▀░▀▀▀░░▀░░▀▀▀
-- keys

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
     ((modm .|. shiftMask,  xK_l ), sendMessage NextLayout)
    -- , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- , ((modm,               xK_n     ), refresh)
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp  )
    -- , ((modm,               xK_m     ), windows W.focusMaster  )
    -- , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm .|. shiftMask, xK_q     ), io exitSuccess)
    , ((modm              , xK_c     ), myRestartHook )
    ]

    ++

    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

     ++

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3

    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_u, xK_i] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    ++

    -- TODO: Clean up formatting

    [
      ((modm .|. shiftMask , xK_Return),    spawn $ myTerminal ++ " --class instanceClass,termTerminal -e tmux new-session -A -s term")
    , ((modm               , xK_BackSpace), kill)
    -- , ((modm               , xK_s),         spawn myBrowser)
    , ((modm               , xK_f),         sendMessage $ Toggle FULL)
    -- , ((modm .|. shiftMask , xK_w),         spawn "io.elementary.code -t")
    -- , ((modm               , xK_a),         spawn "copyq toggle")
    -- , ((modm               , xK_e),         spawn emacsCommand)
    -- , ((modm .|. shiftMask , xK_e),         spawn myFileBrowser)
    -- , ((modm               , xK_r),         spawn "rofi -show drun")
    -- , ((modm               , xK_p),         spawn "mpc toggle")
    , ((modm               , xK_q),         namedScratchpadAction myScratchpads "ncmpcpp")
    -- , ((modm               , xK_minus),     namedScratchpadAction myScratchpads "schedule")
    -- , ((modm               , xK_F7),        spawn "amixer set Master 2%-")
    -- , ((modm               , xK_F8),        spawn "amixer set Master 2%+")
    -- , ((modm               , xK_c),         spawn myTerminal ++ " -e cfile")
    -- , ((modm               , xK_n),         spawn "fcitx-remote -s fcitx-keyboard-no")
    -- , ((modm               , xK_m),         spawn "fcitx-remote -s fcitx-keyboard-us")
    -- , ((modm               , xK_b),         spawn "fcitx-remote -s mozc")
    , ((modm               , xK_Return),    namedScratchpadAction myScratchpads "terminal")
    , ((modm               , xK_space ),    namedScratchpadAction myScratchpads "terminal")
    , ((modm .|. shiftMask , xK_space ),    spawn $ myTerminal ++ " -e tmux")
    -- , ((0                  , xK_Print ),    spawn "skushoclip")
    -- , ((shiftMask          , xK_Print ),    spawn "skusho")
    -- , ((modm               , xK_Print ),    spawn "$HOME/.scripts/git/boomer/boomer")
    -- , ((modm               , xK_v ),        spawn "rofi -modi lpass:$HOME/.scripts/rofi/lpass//rofi-lpass -show lpass")

    -- , ((0, xF86XK_AudioRaiseVolume   ), spawn "amixer set Master 2%+")
    -- , ((0, xF86XK_AudioLowerVolume   ), spawn "amixer set Master 2%-")
    -- , ((0, xF86XK_AudioMute          ), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

    -- , ((0, xF86XK_AudioPlay          ), spawn "mpc toggle")
    -- , ((0, xF86XK_AudioPrev          ), spawn "mpc prev")
    -- , ((0, xF86XK_AudioNext          ), spawn "mpc next")

    -- , ((0, xF86XK_MonBrightnessUp    ), spawn "light -A 5")
    -- , ((0, xF86XK_MonBrightnessDown  ), spawn "light -U 5")

    , ((modm .|. shiftMask, xK_slash ), namedScratchpadAction myScratchpads "help")
    , ((modm .|. shiftMask, xK_d     ), viewDropboxStatus)
    ]

termIsOpen :: X Bool
termIsOpen = isOpen
  where 
    output :: X String
    output = liftIO $ runProcessWithInput "tmux" ["ls", "-F", "#{session_name}", "#{?session_attached,1,}"] ""

    isOpen = ((\(Just x) -> (x!!5) == '1')
             <$> (listToMaybe . filter (L.isInfixOf "term") . lines))
             <$> output

viewDropboxStatus :: X ()
viewDropboxStatus = spawn =<< ((++) "notify-send -t 3000 " . unpack) <$> status
  where
    status :: X String
    status = liftIO $ runProcessWithInput "python" ["$HOME/.scripts/dropbox.py", "status"] ""

    unpack :: String -> String
    unpack =  wrap "\" " "\"" . unwords . map (wrap " [" "] "). lines


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- ░█░░░█▀█░█░█░█▀█░█░█░▀█▀
-- ░█░░░█▀█░░█░░█░█░█░█░░█░
-- ░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀▀░░▀░
-- layout


myLayout =
  fullscreenFull $
  avoidStruts $
  smartBorders $
  spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True $
  mkToggle (NOBORDERS ?? FULL ?? EOT) $
  tiled |||
  Mag.magnifier tiled |||
  Mirror tiled |||
  Full

  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100


------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , className =? "QjackCtl"       --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , resource  =? "fcitx-config"   --> doFloat
    , className =? "copyq"          --> doFloat
    , className =? "discord"        --> doShift "com"
    ] <+> namedScratchpadManageHook myScratchpads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------

-- ░█░█░█▄█░█▀█░█▀▄░█▀█░█▀▄
-- ░▄▀▄░█░█░█░█░█▀▄░█▀█░█▀▄
-- ░▀░▀░▀░▀░▀▀▀░▀▀░░▀░▀░▀░▀
-- xmobar

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myLogHook xmproc = dynamicLogWithPP $ xmobarPP
  {
    ppOutput          = hPutStrLn xmproc
  , ppCurrent         = xmobarColor green      "" . wrap "[" "]"
  , ppVisible         = xmobarColor green      ""
  , ppHidden          = xmobarColor blue       ""
  , ppHiddenNoWindows = xmobarColor yellow     ""
  , ppTitle           = xmobarColor foreground "" . shorten 60
  , ppSep             = "<fc=#666666> <fn=0>|</fn> </fc>"
  , ppUrgent          = xmobarColor red        "" . wrap "!" "!"
  , ppExtras          = [windowCount]
  , ppLayout          =
      wrap "<fn=4>" "</fn>" .
      (\case
        "Spacing Full"           -> "🖵"
        "Spacing Tall"           -> "🗗"
        "Spacing Magnifier Tall" -> "\128269" -- 🔍
        "Spacing Mirror Tall"    -> "\129694" -- 🪞
      )
  , ppOrder           = \(ws:l:t:ex) -> [ws,l] ++ ex ++ [t]
  }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook :: X ()
myStartupHook = do
  spawn "stalonetray &"
  spawnOnce "$HOME/.xmonad/setup-script/xinit.sh"

myRestartHook :: X ()
myRestartHook = do
  spawn "killall stalonetray"
  spawn "killall xmobar"
  spawn "xmonad --recompile"
  spawn "xmonad --restart"

------------------------------------------------------------------------

main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar --recompile"
  xmonad
    $ fullscreenSupport
    $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
    }

-- TODO: Generate this automatically
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
