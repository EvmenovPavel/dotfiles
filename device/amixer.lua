local amixer       = {}

amixer.volumeRaise = "amixer -D pulse set Master 3%%+"
amixer.volumeLower = "amixer -D pulse set Master 3%%-"
-- баг, звук не включается после отключения (amixer -q set %s toggle)
amixer.volumeMute  = "amixer -D pulse set Master 1+ toggle"

return amixer