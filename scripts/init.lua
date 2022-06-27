local scripts     = {}

scripts.i3lock    = [[
i3lock  --insidever-color='#ffffff22'      --ringver-color='#bb00bbbb'     --insidewrong-color='#ffffff22'    --ringwrong-color='#880000bb'       --inside-color='#00000000'         --ring-color='#ff00ffcc'         --line-color='#00000000'           --separator-color='#ff00ffcc'     --verif-color='#ee00eeee'           --wrong-color='#ee00eeee'           --time-color='#ee00eeee'            --date-color='#ee00eeee'            --layout-color='#ee00eeee'          --keyhl-color='#880000bb'          --bshl-color='#880000bb'            --screen 1                    --blur 5                      --clock                       --indicator                   --time-str="%H:%M:%S"         --date-str="%A, %Y-%m-%d"        --keylayout 1
]]

scripts.setxkbmap = "setxkbmap -model pc105 -layout us,ua -variant qwerty -option grp:win_space_toggle"

return scripts