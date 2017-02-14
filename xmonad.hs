import Graphics.X11.ExtraTypes.XF86
import System.Exit
import System.IO
import XMonad
import XMonad.Config.Desktop
import XMonad.Actions.GridSelect
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe)
import qualified Data.Map as M
import qualified XMonad.StackSet as W

--ManageHooks
myManageHook = composeAll [
    isFullscreen --> (doF W.focusDown <+> doFullFloat),
    isDialog --> doCenterFloat,
    appName =? "desktop_window" --> doIgnore
    ]

-- Define the names of all workspaces
myWorkspaces = ["1-docs", "2-code", "3-code", "4-chat", "5-reading"] ++ map show [6..9]

-- Define Terminal
myTerminal = "gnome-terminal"

-- Define Layout
myLayout =  tiled ||| Mirror tiled ||| Full
    where tiled = Tall nmaster delta ratio
          nmaster = 1 -- default number of windows in master screen
          delta = 3/100 -- default percent of resizing panes
          ratio = 3/5 -- default proportion of screen occupied by master pane

-- Define BorderColor
myNormalBorderColor = "#353945"
myFocusedBorderColor = "#ffffff"
myXmobarColorfg = "#fdf6e3"
myXmobarColorbg = ""
myXmonadPromptConfig = def {
    position = Top,
    alwaysHighlight = True,
    promptBorderWidth = 0,
    font = "xft:monospace:size=12"
}


main = do
    spawn "feh --bg-scale ~/.xmonad/background.jpg"
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc.hs"
    xmonad $ desktopConfig {
        manageHook = myManageHook <+> manageDocks <+> manageHook desktopConfig,
        handleEventHook = docksEventHook <+> handleEventHook desktopConfig,
        layoutHook = avoidStruts $ smartBorders myLayout,
        terminal = myTerminal,
        logHook = dynamicLogWithPP $ xmobarPP {
                ppOutput = hPutStrLn xmproc,
                ppTitle = xmobarColor myXmobarColorfg myXmobarColorbg . shorten 60,
                ppLayout = const "" -- to disable the layout info on xmobar
            },
        borderWidth = 1,
        workspaces = myWorkspaces,
        normalBorderColor = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor
    } `additionalKeys` [
            ((mod4Mask, xK_l), spawn "slock"),
            ((0, xF86XK_MonBrightnessUp), spawn "xbacklight +20"),
            ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -20"),
            ((mod4Mask, xK_c), spawn "chromium"),
            ((mod4Mask, xK_e), spawn "zathura"),
            ((mod4Mask, xK_a), spawn "gnome-screenshot --interactive"),
            ((mod4Mask, xK_t), spawn "touchpad_toggle.sh"),
            ((mod4Mask, xK_b), sendMessage ToggleStruts),
            ((mod1Mask, xK_Tab), goToSelected def),
            ((mod1Mask, xK_p), shellPrompt myXmonadPromptConfig)
        ]
