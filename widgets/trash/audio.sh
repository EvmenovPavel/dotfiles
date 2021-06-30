#!/bin/sh

set -ue

debug=false

log() { if $debug ; then echo "$1" ; fi }
die() { echo "[DIE]: $1" ; exit 1 ; }

checkbins() {
  if ! hash mpc &>/dev/null ; then
    die "mpc is no found"
  fi
}

searchAlbumCover() {
  local MUSIC_DIR="$1"
  local file="$(mpc --format %file% current)"
  local album_dir="${file%/*}"
  local cover=""
  local src=""
  album_dir="$MUSIC_DIR/$album_dir"
  [ -d "$album_dir" ] && {
    covers="$(find "$album_dir" -maxdepth 1 -regex '.*\.\(jpe?g\|png\)' | head -n 1)"
    src="$(echo -n "$covers")"
    [ -f "$src" ] && echo "$src"
  }
}

call_mpc_details() {
  local img title artist state album

  img=$(searchAlbumCover "$1")
  title="$(mpc current -f %title% | tr -d "%([]){}\1/")"
  artist="$(mpc current -f %artist% | tr -d "%([]){}\1/")"
  state="$(mpc status | grep -oe "paused\|playing")"
  if [[ $(mpc current -f %album%) == "" ]] ; then
    album=""
  else
    album="$(mpc current -f %album% | tr -d "%([]){}\1/")"
  fi

  echo "img:[$img] title:[${title:0:30}] artist:[$artist] state:[$state] album:[$album]"
}

music_details() {
  local mpd_is_playing="$(mpc | grep -o "playing\|paused")"
  if [ ! -z $mpd_is_playing ] ; then
    call_mpc_details "$1"
  else
    die "mpd play nothing for now Or your system language is different than english"
  fi
}

case $1 in
  music_details)
    [ -d $2 ] || die "music dir $2 is no found"
    checkbins
    music_details "$2"
    shift
    shift
    ;;
  -d | --debug)
    debug=true
    shift
    ;;
  *)
    die "arg: $1 is unknown, call: $0 music_details [PATH music dir]"
esac
