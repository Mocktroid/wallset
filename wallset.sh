#! /bin/bash
# load config file:
[ -f "$HOME/.config/wallset/config" ] && source "$HOME/.config/wallset/config"

# colours
#######################################################
OFF='\033[0m'           # Off       #   >_
RED='\033[0;31m'        # Red       #   Error
GREEN='\033[0;32m'      # Green     #   files+done
YELLOW='\033[0;33m'     # Yellow    #   register-edit mode
BLUE='\033[0;34m'       # Blue      #   correction/suggestion
PURPLE='\033[0;35m'     # Purple    #   directory paths
CYAN='\033[0;36m'       # Cyan      #   Pictrue, Gif and Video edit
WHITE='\033[0;37m'      # White     #   Normal
#######################################################
# define function                                       ↓ is the first entry in .<register>-m_x_ file
# Function syntax: LiveWallpaper $MONITOR_x_ MonitorNUM DURATION=_x_ $FILE_x_ 
#                  $0            $1          $2         $3           $4-${inf.} → special operators(ex: zoom) and file
function LiveWallpaper(){
xwinwrap -g ${1} -ni -a -nf -ov -- mpv -wid %WID --hwdec=vdpau --vo=gpu --no-audio --no-border --no-config --no-window-dragging --no-input-default-bindings --no-osd-bar --no-sub --loop ${4} ${5} ${6} ${7} ${8} ${9} ${10} &
echo "${3}" > $(echo "/tmp/wallset/DURATION${2}")
}

# empty input
if [[ -z $1 ]] ;
    then    echo -e "${RED}Error:${OFF} no Input was provided. use '${BLUE}-h${OFF}' option for help"
            exit
# -h --help
elif [[ $1 = "-h" || $1 = "--help" ]] ;
    then    echo -e "Wallset - a tool to set pictures, gifs and videos as wallpapers for up to 6 Monitors
Disclaimer! Videos that are longer than 59 Minutes are not supported
wallset options:
Setup:
    -h      --help      print this text
    -v      --version   print version
    -i      --install   helper for getting wallset up and running.
    -m      --monitors  get Monitor specifications for config

Set wallpaper:
    -w      --wallpaper set file(s) as wallpaper(s). 
                        ex: wallset -w File1 File2 File3    →   File1 for Monitor1, ...
set Slideshow:
    -s      --slideshow set a <register-file> as source for slideshow. see below
    -p      --progress  shows how many files from the register are still to be displayed

general usage:
    -x      --kill      kills all Wallpapers
    -l      --log       prints a log of all last used files
    -sl     --showlog   shows all files in log with sxiv/mpv 
    -cl     --clearlog  clears the log 
            --restore   Restores last stored wallpaper [from Log]

register files:
    -r      --register  List all register.
                        If a register is specified enter ${YELLOW}register-edit${OFF} to manage specified register
                        add files to your register and manipulate, sort, filter and edit files.
                        wallset -r <register-file>
                        to create a new register-file use:
                        wallset -r new <register-file>
                        to delete a <register-file> use:
                        wallset -r remove <register-file>"
            exit
# -v --version
elif [[ $1 = "-v" || $1 = "--version" ]] ;
    then    echo -e "Wallset version ${version}" 
            exit
# -i --install
elif [[ $1 = "-i" || $1 = "--install" ]] ;
    then        echo -e "${CYAN}Disclaimer:${OFF} this is not a full installation scipt but a checklist on what modifications can be made to make the use of wallpaper.sh easier"
                INSTALL=TRUE
                while [[ $INSTALL = "TRUE" ]] ;
                do
                        echo -e "Helper Option are :\n1) install location\n2) monitor setup\n3) ~.bashrc or ~/.aliasrc \n4) polybar\n5) Dependencies\nq) to exit"
                        read -p "→ " WHAT
                        if [[ -z $WHAT ]] ;
                                then    echo -e "${RED}Error:${OFF} No input was provided"
                        # Option 1 install location
                        elif [[ $WHAT = "1" || $WHAT = "1)" ]] ;
                                then    echo -e "The recommendet location is ${PURPLE}/home/$USER/.config/wallset/${OFF}"
                                        read -p "do you want to use a different location? [y/N]? " CHANGELOCATION
                                        # Location to install to
                                        if [[ $CHANGELOCATION = "y" || $CHANGELOCATION = "Y" || $CHANGELOCATION = "yes" || $CHANGELOCATION = "Yes" || $CHANGELOCATION = "YES" ]] ;
                                                then    read -p "what directory do you want to move the files to? [full path]: " DIR
                                                        echo -e "'${PURPLE}$DIR${OFF}' will be used"
                                                else    echo -e "using '${PURPLE}~/.config/wallset/ ${OFF}'"
                                                        mkdir -p /home/$USER/.config/wallset
                                                        DIR=/home/$USER/.config/wallset/
                                        fi
                                        read -p "do you wish to move everything in '$(basename $PWD)' [Y/n]" ALL
                                        if [[ $ALL = "n" || $ALL = "N" || $ALL = "no" || $ALL = "No" || $ALL = "NO" ]];
                                                # mv only core files
                                                then    echo -e "moving corefiles to '${PURPLE}$CHANGELOCATION ${OFF}'"
                                                        mv -v {wallset.sh,defaultconfig,config,blackscreen.jpg,Log} $DIR
                                                # mv everything 
                                                else    echo -e "moving everything to '${PURPLE}$DIR${OFF}'"
                                                        mv -v * $DIR
                                                        mv -v .* $DIR
                                        fi
                                        echo -e "moving finished\n"
                        # Option 2 monitor
                        elif [[ $WHAT = "2" || $WHAT = "2" ]] ; 
                                then    echo -e "You need to enable/set up every Monitor yourself in config. You can specify each dimension via X11/Xorg yourself, but its easier to use xrandr
use the 'wallset.sh --monitors' option to get all the dimensions and put them in the config like ${GREEN}
MONITOR1=1920x1080+0+0
MONITOR2=1920x1080+1920+0
[...]${OFF}
this is the offset ↑↑↑↑↑↑
arandr (gui) can provide a script to place all Monitors you have into position.\n"
                        # Option 3 .bashrc or .aliasrc
                        elif [[ $WHAT = "3" || $WHAT = "3)" ]] ;
                                then    echo -e "to use wallset.sh easier it is recommended to set up an alias."
                                        read -p "Do you want to set up an alias? [Y/n]" ALIAS
                                        if [[ $ALIAS = "n" || $ALIAS = "N" || $ALIAS = "no" || $ALIAS = "No" || $ALIAS = "NO" ]] ;
                                                # No alias set up
                                                then    echo -e ""
                                                # set up alias
                                                else    # to which directory did u install wallset?
                                                        if [[ -z $DIR ]] ;
                                                                then    echo -e "to which directory did you install wallset ?"
                                                                        read -p "please provide the FULL path [ /home/... ]: " DIR
                                                                else    echo -e "you installed wallset to '${PURPLE}$DIR${OFF}'"
                                                        fi
                                                        # set up an alias
                                                        echo -e "you can set up multiple alias' in a special file '~/.aliasrc'"
                                                        echo -e "Do you want to use \n1) ~/.bashrc \n2) ~/.aliasrc"
                                                        read -p "→ " ALIAS
                                                        # alias to .bashrc
                                                        if [[ $ALIAS = "1" || $ALIAS = "1)" ]] ;
                                                                then    echo -e "# created by and for wallset \nalias wallset=\"$DIR\"" >> /home/$USER/.bashrc
                                                        # alias to .aliasrc
                                                        elif [[ $ALIAS = "2" || $ALIAS = "2)" ]] ;
                                                                then    echo -e "# created by and for wallset \nalias wallset=\"$DIR\"" >> /home/$USER/.aliasrc
                                                                        echo -e "you need to include \n'[ -f \"$HOME/.aliasrc\" ] && source \"$HOME/.aliasrc\"' \nin your .bashrc file to load .aliasrc"
                                                                        read -p "do you already set up an .aliasrc? if not please enter 'No' now [Y/n]: " ALIAS
                                                                        if [[ $ALIAS = "n" || $ALIAS = "N" || $ALIAS = "no" || $ALIAS = "No" || $ALIAS = "NO" ]] ;
                                                                                then    echo -e "including the necesary line in your .bashrc"
                                                                                        echo -e "# Include ~/.aliasrc as Storage for all alias\n[ -f \"$HOME/.aliasrc\" ] && source \"$HOME/.aliasrc\"" >> /home/$USER/.bashrc
                                                                        fi
                                                        # wrong input
                                                        else    echo -e "${RED}Error:${OFF} '${BLUE}${ALIAS}${OFF}' is not an Option."
                                                        fi
                                                        echo -e "for the alias to take effect you need to refresh/restart your terminal emulator"
                                        fi
                        # Option 4 polybar module
                        elif [[ $WHAT = "4" || $WHAT = "4)" ]] ;
                                then    echo -e "${CYAN}Disclaimer:${OFF} polbar module needs to be installed manually!
it is assumed you use terminator. and installed polybar to the default location
name of your default slideshow needs to be set manually
default name of polybar-module is 'wallset-polybar'
include this ${GREEN}text${OFF} in your polybar config and include the module-name into the desired place:
${GREEN}
[module/wallset-polybar]
type = custom/script
exec = /home/$USER/.config/wallset/wallset.sh --progress
click-left = /home/$USER/.config/wallset/wallset.sh --show-log
click-middle= /home/$USER/.config/wallset/wallset.sh --slideshow [insert]
click-right = terminator -e \"/home/$USER/.config/wallset/wallset.sh --show-log ; read EXIT ; exit\"
interval = 1
format-underline = #0000ff
format-background = #B30d2f48
format-padding = 1 ${OFF}\n"
                        # Option 5 Dependencies
                        elif [[ $WHAT = "5" || $WHAT = "5)" ]] ;
                                then    echo -e "It is assumed you use only the best - Archlinux\nyou need to install all dependencies manually:
xwinwrap-git            necessary               (AUR)
feh                     necessary               (extra)
mpv                     necessary               (community)
gawk                    necessary               (core)
sed                     necessary               (core)
gcc                     necessary               (core)               
xorg-xrandr             for --monitor           (extra)
ttf-font-awesome        for --progress/polybar  (community)
sxiv                    for --register          (community)
detox                   for --register          (community)
translate-shell         for --register          (community)
... more to insert here later 
"
                        # clear
                        elif [[ $WHAT = "clear" || $WHAT = "c" ]] ;
                                then    clear
                        # exit
                        elif [[ $WHAT = "q" || $WHAT = "exit" || $WHAT = "q)" ]] ;
                                then    INSTALL=
                        # unknown input
                        else    echo -e "${RED}Error:${OFF} Unknown option '${BLUE}$WHAT${OFF}'"
                        fi
                done
                exit
# -m --monitors
elif [[ $1 = "-m" || $1 = "--monitors" || $1 = "--monitor" ]] ;
    then        # Normal
                if [[ -z $2 ]] ;
                then    echo -e "List all available Monitors: ${BLUE}"
                        xrandr | grep connected | sed /disconnected/d
                        echo -e "${OFF}\t\t\t↑↑↑↑↑↑↑" "use this in config to define Monitors. or '${BLUE}--install${OFF}' option"
                        echo -e "\nfor a full list use xrandr or wallset -m full"
            # Full versionf
            elif [[ $2 = "full" || $2 = "-full" ]] ;
                then    clear
                        echo -e "all available Monitor options via xrandr:"
                        xrandr 

                else    echo -e "${RED}Error:${OFF} Unknown option 'wallset -m >${RED}${2}${OFF}<'"
            fi
            exit
# -w --wallpaper
elif [[ $1 = "-w" || $1 = "--wallpaper" ]] ;
    then        # MONITOR1
                # set up check
                if [[ $MONITOR1 = "FALSE" || -z $MONITOR1 ]] ;
                        then    echo -e "${RED}Error:${OFF} No Monitor has been set up in the config. Please edit the config file or use '${BLUE}--install${OFF}' option"
                                exit
                # No File
                elif [[ -z $2 ]] ;
                        then    echo -e "${RED}Error:${OFF} No file was provided"
                                exit
                        else    # kill old xwinwrap instances
                                killall -q xwinwrap
                                # Write Progress
                                echo -e " 0/0" > /tmp/wallset/PROGRESS
                                # define FILE1 and FILETYPE1
                                FILE1=$2
                                FILETYPE1=$(echo "$2" | tail -c 5)
                                # MPV
                                if [[ $FILETYPE1 = ".gif" || $FILETYPE1 = ".GIF" ||  $FILETYPE1 = ".mp4" || $FILETYPE1 = ".MP4" || $FILETYPE1 = ".mkv" || $FILETYPE1 = ".MKV" || $FILETYPE1 = ".mov" || $FILETYPE1 = ".MOV" || $FILETYPE1 = ".mxf" || $FILETYPE1 = ".MXF" || $FILETYPE1 = ".mvi" || $FILETYPE1 = ".MVI" ]] ; 
                                        then    LiveWallpaper $MONITOR1 1 $FILE1 &
                                                FEH1=$PLACE/blackscreen.jpg
                                        else    # FEH
                                                FEH1=$FILE1
                                fi
                fi
                # MONITOR2
                if [[ $MONITOR2 != "FALSE" ]] ;
                        then    # define FILE2 and FILETYPE2
                                FILE2=$3
                                FILETYPE2=$(echo "$3" | tail -c 5)
                                if [[ -z $3 ]] ;
                                # no File provided for MONITOR2 -> use FILE from Monitor 1 
                                        then    FILE2=$2
                                                FILETYPE2=$FILETYPE1
                                fi
                                if [[ $FILETYPE2 = ".gif" || $FILETYPE2 = ".GIF" ||  $FILETYPE2 = ".mp4" || $FILETYPE2 = ".MP4" || $FILETYPE2 = ".mkv" || $FILETYPE2 = ".MKV" || $FILETYPE2 = ".mov" || $FILETYPE2 = ".MOV" || $FILETYPE2 = ".mxf" || $FILETYPE2 = ".MXF" || $FILETYPE2 = ".mvi" || $FILETYPE2 = ".MVI" ]] ; 
                                        then    LiveWallpaper $MONITOR2 2 $FILE2 &
                                                FEH2=$PLACE/blackscreen.jpg
                                        else    #FEH
                                                FEH2=$FILE2
                                fi 
                        else    FILE2=
                fi
                # MONITOR3
                if [[ $MONITOR3 != "FALSE" ]] ;
                        then    # define FILE3 and FILETYPE3
                                FILE3=$4
                                FILETYPE3=$(echo "$4" | tail -c 5)
                                if [[ -z $3 ]] ;
                                        # no File provided for MONITOR2 -> use FILE from Monitor 1 
                                        then    FILE3=$3
                                                FILETYPE3=$FILETYPE2
                                fi
                                if [[ $FILETYPE3 = ".gif" || $FILETYPE3 = ".GIF" ||  $FILETYPE3 = ".mp4" || $FILETYPE3 = ".MP4" || $FILETYPE3 = ".mkv" || $FILETYPE3 = ".MKV" || $FILETYPE3 = ".mov" || $FILETYPE3 = ".MOV" || $FILETYPE3 = ".mxf" || $FILETYPE3 = ".MXF" || $FILETYPE3 = ".mvi" || $FILETYPE3 = ".MVI" ]] ; 
                                        then        LiveWallpaper $MONITOR3 3 $FILE3 &
                                                FEH3=$PLACE/blackscreen.jpg
                                        else    #FEH
                                                FEH3=$FILE3
                                fi 
                        else    FILE3=
                fi
                # MONITOR4
                if [[ $MONITOR4 != "FALSE" ]] ;
                        then    # define FILE4 and FILETYPE4
                                FILE4=$4
                                FILETYPE4=$(echo "$5" | tail -c 5)
                                if [[ -z $3 ]] ;
                                        # no File provided for MONITOR2 -> use FILE from Monitor 1 
                                        then    FILE4=$4
                                                FILETYPE4=$FILETYPE3
                                fi
                                if [[ $FILETYPE4 = ".gif" || $FILETYPE4 = ".GIF" ||  $FILETYPE4 = ".mp4" || $FILETYPE4 = ".MP4" || $FILETYPE4 = ".mkv" || $FILETYPE4 = ".MKV" || $FILETYPE4 = ".mov" || $FILETYPE4 = ".MOV" || $FILETYPE4 = ".mxf" || $FILETYPE4 = ".MXF" || $FILETYPE4 = ".mvi" || $FILETYPE4 = ".MVI" ]] ; 
                                        then    LiveWallpaper $MONITOR4 4 $FILE4 &
                                                FEH4=$PLACE/blackscreen.jpg
                                        else    # FEH
                                                FEH4=$FILE4
                                fi 
                        else    FILE4=
                fi
                # MONITOR5
                if [[ $MONITOR5 != "FALSE" ]] ;
                        then    # define FILE5 and FILETYPE5
                                FILE5=$6
                                FILETYPE5=$(echo "$6" | tail -c 5)
                                if [[ -z $3 ]] ;
                                        # no File provided for MONITOR2 -> use FILE from Monitor 1 
                                        then    FILE5=$5
                                                FILETYPE5=$FILETYPE4
                                fi
                                if [[ $FILETYPE5 = ".gif" || $FILETYPE5 = ".GIF" ||  $FILETYPE5 = ".mp4" || $FILETYPE5 = ".MP4" || $FILETYPE5 = ".mkv" || $FILETYPE5 = ".MKV" || $FILETYPE5 = ".mov" || $FILETYPE5 = ".MOV" || $FILETYPE5 = ".mxf" || $FILETYPE5 = ".MXF" || $FILETYPE5 = ".mvi" || $FILETYPE5 = ".MVI" ]] ; 
                                        then    LiveWallpaper $MONITOR5 5 $FILE5 &
                                                FEH5=$PLACE/blackscreen.jpg
                                        else    # FEH
                                                FEH5=$FILE5
                                fi 
                        else    FILE5=
                fi
                # MONITOR6
                if [[ $MONITOR6 != "FALSE" ]] ;
                        then    # define FILE6 and FILETYPE6
                                FILE6=$7
                                FILETYPE6=$(echo "$7" | tail -c 5)
                                if [[ -z $3 ]] ;
                                        # no File provided for MONITOR2 -> use FILE from Monitor 1 
                                        then    FILE6=$6
                                                FILETYPE6=$FILETYPE5
                                fi
                                if [[ $FILETYPE6 = ".gif" || $FILETYPE6 = ".GIF" ||  $FILETYPE6 = ".mp4" || $FILETYPE6 = ".MP4" || $FILETYPE6 = ".mkv" || $FILETYPE6 = ".MKV" || $FILETYPE6 = ".mov" || $FILETYPE6 = ".MOV" || $FILETYPE6 = ".mxf" || $FILETYPE6 = ".MXF" || $FILETYPE6 = ".mvi" || $FILETYPE6 = ".MVI" ]] ; 
                                        then    LiveWallpaper $MONITOR6 6 $FILE6 &
                                                FILE6=$PLACE/blackscreen.jpg
                                        else    # FEH
                                                FEH6=$FILE6
                                fi 
                        else    FILE6=
                fi
                # set feh Background
                # if FILE_x_ is video/gif variable is set to blackscreen
                # if MONITOR_x_ is not set up variable is empty
                feh --bg-fill --no-fehbg $FEH1 $FEH2 $FEH3 $FEH4 $FEH5 $FEH6
                # write Log (needs to be done via variable. otherwise 'echo "[...] $(cat $PLACE/Log)" > $PLACE/Log' doesn't work.)
                NEWLOG=$(echo -e "$FILE1\n$FILE2\n$FILE3\n$FILE4\n$FILE5\n$FILE6\n$(cat $PLACE/Log)" | sed '/^$/d' | head -n $LOGLENGTH )
                echo -e "$NEWLOG" > $PLACE/Log
                exit

# -s --slideshow
elif [[ $1 = "-s" || $1 = "--slideshow" ]] ;
        then    # empty argument $2
                if [[ -z $2 ]] ;
                        then    echo -e "${RED}Error:${OFF} No regsiter-file was provided \nuse ${BLUE}wallset -r${OFF} to list all available register-files"
                                exit
                # provided file has a bad name (blackscreen.jpg  config  defaultconfig   Log   wallset.sh)
                elif [[ $2 = "wallset.sh" || $2 = "blackscreen.jpg" || $2 = "config" || $2 = "defaultconfig" || $2 = "Log" ]] ;
                        then    echo -e "${RED}Error:${OFF} Bad Filename: >${BLUE}$2${OFF}< is used by wallset and is not a register-file"
                                exit
                # Does provided registerfile ($3) exist?
                fi 
                # while $2 is in folder do
                while [[ $(grep REGFILE= $PLACE/config | grep $2) = "REGFILE=$PLACE/$2" ]] ;
                do
                        # empty dotfile ( $PATH/.<register-file>-m1)
                        if [[ $(cat $PLACE/.${2}-m1 | wc -l) = "0" ]] ;
                                then    # refill ( see $SORT )
                                        if [[ $SORT = "RANDOM" ]] ;
                                                then    shuf $PLACE/$2 | sed '/^#/d;/^$/d' > $PLACE/.$2-m1
                                                        shuf $PLACE/.$2-m1 > $PLACE/.$2-m2
                                                        shuf $PLACE/.$2-m1 > $PLACE/.$2-m3
                                                        shuf $PLACE/.$2-m1 > $PLACE/.$2-m4
                                                        shuf $PLACE/.$2-m1 > $PLACE/.$2-m5
                                                        shuf $PLACE/.$2-m1 > $PLACE/.$2-m6
                                        elif [[ $SORT = "NORMAL" ]] ;
                                                then    cat $PLACE/2 | sed '/^#/d;/^$/d' > $PLACE/.$2-m1
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m2
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m3
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m4
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m5
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m6
                                        elif [[ $SORT = "REVERSE" ]] ;
                                                then    tac $PLACE/2 | sed '/^#/d;/^$/d' > $PLACE/.$2-m1
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m2
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m3
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m4
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m5
                                                        cat $PLACE/.$2-m1 > $PLACE/.$2-m6
                                        # Operator $SORT not set up properly
                                        else    echo -e "${RED}Error:${OFF} Sorting Operation in config not properly set up. Please edit the config file"
                                                exit
                                        fi # from refill operator
                        fi # from empty dotfiles
                        # ending old instances
                        killall -q xwinwrap
                        # removing old Duration files
                        rm -f /tmp/wallset/DURATION*
                        # getting Files
                        FILE1=$(cat $PLACE/.$2-m1 | head -n 1)
                        FILETYPE1=$(echo "$FILE1" | tail -c 5)
                        FILE2=$(cat $PLACE/.$2-m2 | head -n 1)
                        FILETYPE2=$(echo "$FILE2" | tail -c 5)
                        FILE3=$(cat $PLACE/.$2-m3 | head -n 1)
                        FILETYPE3=$(echo "$FILE3" | tail -c 5)
                        FILE4=$(cat $PLACE/.$2-m4 | head -n 1)
                        FILETYPE4=$(echo "$FILE4" | tail -c 5)
                        FILE5=$(cat $PLACE/.$2-m5 | head -n 1)
                        FILETYPE5=$(echo "$FILE5" | tail -c 5)
                        FILE6=$(cat $PLACE/.$2-m6 | head -n 1)
                        FILETYPE6=$(echo "$FILE6" | tail -c 5)
                        # Monitor1
                        if [[ $FILETYPE1 = ".gif" || $FILETYPE1 = ".GIF" ||  $FILETYPE1 = ".mp4" || $FILETYPE1 = ".MP4" || $FILETYPE1 = ".mkv" || $FILETYPE1 = ".MKV" || $FILETYPE1 = ".mov" || $FILETYPE1 = ".MOV" || $FILETYPE1 = ".mxf" || $FILETYPE1 = ".MXF" || $FILETYPE1 = ".mvi" || $FILETYPE1 = ".MVI" ]] ; 
                                then    LiveWallpaper $MONITOR1 1 $FILE1 
                                        FEH1=$PLACE/blackscreen.jpg
                                else    # FEH
                                        FEH1=$FILE1
                        fi
                        # MONITOR2
                        if [[ $MONITOR2 != "FALSE" ]] ;
                                then    
                                        if [[ $FILETYPE2 = ".gif" || $FILETYPE2 = ".GIF" ||  $FILETYPE2 = ".mp4" || $FILETYPE2 = ".MP4" || $FILETYPE2 = ".mkv" || $FILETYPE2 = ".MKV" || $FILETYPE2 = ".mov" || $FILETYPE2 = ".MOV" || $FILETYPE2 = ".mxf" || $FILETYPE2 = ".MXF" || $FILETYPE2 = ".mvi" || $FILETYPE2 = ".MVI" ]] ; 
                                                then    LiveWallpaper $MONITOR2 2 $FILE2 &
                                                        FEH2=$PLACE/blackscreen.jpg
                                                else    #FEH
                                                        FEH2=$FILE2
                                        fi
                                else    FILE2=
                        fi
                        # MONITOR3
                        if [[ $MONITOR3 != "FALSE" ]] ;
                                then    
                                        if [[ $FILETYPE3 = ".gif" || $FILETYPE3 = ".GIF" ||  $FILETYPE3 = ".mp4" || $FILETYPE3 = ".MP4" || $FILETYPE3 = ".mkv" || $FILETYPE3 = ".MKV" || $FILETYPE3 = ".mov" || $FILETYPE3 = ".MOV" || $FILETYPE3 = ".mxf" || $FILETYPE3 = ".MXF" || $FILETYPE3 = ".mvi" || $FILETYPE3 = ".MVI" ]] ; 
                                                then    LiveWallpaper $MONITOR3 3 $FILE3 &
                                                        FEH3=$PLACE/blackscreen.jpg
                                                else    #FEH
                                                        FEH3=$FILE3
                                        fi
                                else    FILE3=
                        fi
                        # MONITOR4
                        if [[ $MONITOR4 != "FALSE" ]] ;
                                then    
                                        if [[ $FILETYPE4 = ".gif" || $FILETYPE4 = ".GIF" ||  $FILETYPE4 = ".mp4" || $FILETYPE4 = ".MP4" || $FILETYPE4 = ".mkv" || $FILETYPE4 = ".MKV" || $FILETYPE4 = ".mov" || $FILETYPE4 = ".MOV" || $FILETYPE4 = ".mxf" || $FILETYPE4 = ".MXF" || $FILETYPE4 = ".mvi" || $FILETYPE4 = ".MVI" ]] ; 
                                                then    LiveWallpaper $MONITOR4 4 $FILE4 &
                                                        FEH4=$PLACE/blackscreen.jpg
                                                else    # FEH
                                                        FEH4=$FILE4
                                        fi
                                else    FILE4=
                        fi
                        # MONITOR5
                        if [[ $MONITOR5 != "FALSE" ]] ;
                                then    
                                        if [[ $FILETYPE5 = ".gif" || $FILETYPE5 = ".GIF" ||  $FILETYPE5 = ".mp4" || $FILETYPE5 = ".MP4" || $FILETYPE5 = ".mkv" || $FILETYPE5 = ".MKV" || $FILETYPE5 = ".mov" || $FILETYPE5 = ".MOV" || $FILETYPE5 = ".mxf" || $FILETYPE5 = ".MXF" || $FILETYPE5 = ".mvi" || $FILETYPE5 = ".MVI" ]] ; 
                                                then    LiveWallpaper $MONITOR5 5 $FILE5 &
                                                        FEH5=$PLACE/blackscreen.jpg
                                                else    # FEH
                                                        FEH5=$FILE5
                                        fi
                                else    FILE5=
                        fi
                        # MONITOR6
                        if [[ $MONITOR6 != "FALSE" ]] ;
                                then    
                                        if [[ $FILETYPE6 = ".gif" || $FILETYPE6 = ".GIF" ||  $FILETYPE6 = ".mp4" || $FILETYPE6 = ".MP4" || $FILETYPE6 = ".mkv" || $FILETYPE6 = ".MKV" || $FILETYPE6 = ".mov" || $FILETYPE6 = ".MOV" || $FILETYPE6 = ".mxf" || $FILETYPE6 = ".MXF" || $FILETYPE6 = ".mvi" || $FILETYPE6 = ".MVI" ]] ; 
                                                then    LiveWallpaper $MONITOR6 6 $FILE6 &
                                                        FILE6=$PLACE/blackscreen.jpg
                                                else    # FEH
                                                        FEH6=$FILE6
                                        fi
                                else    FILE6=
                        fi
                        # set feh Background
                        # if FILE_x_ is video/gif variable is set to blackscreen
                        # if MONITOR_x_ is not set up variable is empty
                        feh --bg-fill --no-fehbg $FEH1 $FEH2 $FEH3 $FEH4 $FEH5 $FEH6
                        # write Log (needs to be done via variable. otherwise 'echo "[...] $(cat $PLACE/Log)" > $PLACE/Log' doesn't work.)
                        NEWLOG=$(echo -e "$FILE1\n$FILE2\n$FILE3\n$FILE4\n$FILE5\n$FILE6\n$(cat $PLACE/Log)" | sed '/^$/d' | head -n $LOGLENGTH)
                        echo -e "$NEWLOG" > $PLACE/Log
                        # delete head from dotfiles
                        sed -i '1d' $PLACE/.$2-m1
                        sed -i '1d' $PLACE/.$2-m2
                        sed -i '1d' $PLACE/.$2-m3
                        sed -i '1d' $PLACE/.$2-m4
                        sed -i '1d' $PLACE/.$2-m5
                        sed -i '1d' $PLACE/.$2-m6
                        # write progress
                        echo " $(cat $PLACE/.$2-m1 | sed '/^#/d;/^$/d' | wc -l)/$(cat $PLACE/$2 | sed '/^#/d;/^$/d' | wc -l)" > /tmp/wallset/PROGRESS
                        #     ↑ font-awesome Picture Symbol                                
                        # Sleep Timer - calculated
                        if [[ $FORCEDINTERVAL = "TRUE" ]] ;
                                then    sleep   $INTERVAL
                        elif [[ $FORCEDINTERVAL = "FALSE" ]] ;
                                then    # Durations are stored in /tmp/wallset/DURATION_x_ - sleep largest NUM
                                        sleep $(echo -e "$INTERVAL\n$(cat /tmp/wallset/DURATION*)" | sort -nr | head -n 1)
                        fi
                # While Loop register-file exists
                done
                # Register file does not exits (never ending while loop only starts when register-file exists)
                echo -e "${RED}Error:${OFF} provided register-file >${BLUE}$2${OFF}< does not exist"
                exit
# -p --progress
elif [[ $1 = "-p" || $1 = "--progress" ]] ;
    then        # create /tmp/wallset/
                mkdir -p /tmp/wallset
                touch /tmp/wallset/PROGRESS
                # empty PROGRESS file
                if [[ -z $(cat /tmp/wallset/PROGRESS) ]] ;
                        then    echo -e "\n${RED}Error:${OFF} No slideshow is active"
                        else    cat /tmp/wallset/PROGRESS 
                fi
                exit
# -x --kill
elif [[ $1 = "-x" || $1 = "--kill" ]] ;
    then        echo "" > /tmp/wallset/PROGRESS
                killall -q xwinwrap wallset.sh 
                exit
# -l --log
elif [[ $1 = "-l" || $1 = "--log" ]] ;
    then    cat $PLACE/Log || echo -e "Log is empty"
            exit
# -sl --showlog                                 ↓↓↓↓ User error input - still accepted
elif [[ $1 = "-sl" || $1 = "--showlog" || $1 = "--show-log" ]] ;
    then    # all Picture files
            echo -e "Pictures:"
            sxiv -a -f -o $(cat $PLACE/Log | sed '/gif/d;/GIF/d;/mp4/d;/MP4/d;/mkv/d;/MKV/d;/mov/d;/MOV/d;/mxf/d;/MXF/d;/mvi/d;/MVI/d')
            # all Video files
            echo -e "Videos and Gif's"
            grep "gif\|GIF\|mp4\|MP4\|mkv\|MKV\|mov\|MOV\|mxf\|MXF\|mvi\|MVI" $PLACE/Log
            mpv -fs --really-quiet $(grep "gif\|GIF\|mp4\|MP4\|mkv\|MKV\|mov\|MOV\|mxf\|MXF\|mvi\|MVI" $PLACE/Log)
            exit
# -cl --clearlog
elif [[ $1 = "-cl" || $1 = "--clearlog" ]] ;
    then    rm -f $PLACE/Log & echo -e "Log cleared"
            exit
# --restore
elif [[ $1 = "--restore" ]] ;
    then    # restore every Monitor - check for Monitor 1 set up
            if [[ $MONITOR1 != "FALSE" ]] ;
                then    # See if Log exists
                        if [[ $(cat $PLACE/Log | wc -l) != "0" ]] ;
                            then    FILE1=$(cat $PLACE/Log | sed "1q;d" )
                                    FILE2=$(cat $PLACE/Log | sed "2q;d" )
                                    FILE3=$(cat $PLACE/Log | sed "3q;d" )
                                    FILE4=$(cat $PLACE/Log | sed "4q;d" )
                                    FILE5=$(cat $PLACE/Log | sed "5q;d" )
                                    FILE6=$(cat $PLACE/Log | sed "6q;d" )
                                    # ↑ sed function prints the n'th line ouf Log file
                                    $PLACE/wallset.sh -w $FILE1 $FILE2 $FILE3 $FILE4 $FILE5 $FILE6 &
                                    exit
                            # no Log
                            else    echo -e "${RED}Error:${OFF} Log was cleared. No files can be used to restore the Wallpaper"
                                    exit
                        fi
                # Monitor 1 not set up
                else    echo -e "${RED}Error:${OFF} Monitor1 has not been set up in config"
                        exit
            fi
# -r --register
elif [[ $1 = "-r" || $1 = "--register" ]] ;
        then    # empty input - list all available registerfiles
                if [[ -z $2 ]] ;
                        then    # no Register files exist
                                if [[ -z $REGFILE ]] ;
                                        then    echo -e "${RED}Error:${OFF} No register-files have been created yet \nuse '${BLUE}wallset -r new${OFF}' to create one"
                                                exit
                                fi
                                # list al Regfiles
                                echo -e "available register files are: ${YELLOW}"
                                basename -a $(grep REGFILE= $PLACE/config | grep /home/)
                                echo -e "${OFF}Which one do you want to edit?"
                                read EDIT
                                if [[ -z $EDIT ]] ;
                                        then    exit
                                        else    set r $EDIT
                                fi
                fi
                # create new register-file
                if [[ $2 = "new" || $2 = "create" ]] ;
                        then    # $3 is filename
                                # no filename was given - ask for one 
                                if [[ -z $3 ]] ;
                                        then    read -p "please name your new register-file: " NEWREGFILE
                                                set r $2 $NEWREGFILE
                                fi
                                # bad filename
                                if [[ $3 = "wallset.sh" || $3 = "defaultconfig" || $3 = "config" || $3 = "blackscreen.jpg" || $3 = "Log" ]] ;
                                        then    echo -e "${RED}Error:${OFF} Bad filename. the file '${BLUE}$3${OFF}' is already used by wallset.sh"
                                                exit
                                # file already exists
                                elif [[ $3 = $(basename -a $(cat $PLACE/config | grep REGFILE=) | grep $3 ) ]] ;
                                        then    echo -e "${RED}Error:${OFF} The register >${BLUE}$3${OFF}< already exists"
                                                exit
                                fi
                                # create new register
                                echo -e "creating new register file >${BLUE}$3${OFF}<" 
                                echo -e "# register file for wallset.sh" > $PLACE/$3
                                echo -e "REGFILE=$PLACE/$3" >> $PLACE/config
                                touch $PLACE/.${3}-m1 $PLACE/.${3}-m2 $PLACE/.${3}-m3 $PLACE/.${3}-m4 $PLACE/.${3}-m5 $PLACE/.${3}-m6
                                # wanting to edit the new register
                                echo -e "do you wish to edit '${YELLOW}$3${OFF}' [Y/n]? "
                                read EDIT
                                if [[ $EDIT = "n" || $EDIT = "N" || $EDIT = "no" || $EDIT = "No" || $EDIT = "NO" ]] ;
                                        then    exit
                                        # set register($3) as $2
                                        else    set r $3
                                fi 
                fi
                # register edit
                if [[ $2 = $(basename -a $(grep REGFILE= $PLACE/config) | grep $2) ]] ;
                        then    echo -e "Entering register-edit\nenter '${BLUE}-h${OFF}' for help${YELLOW}"
                                REGISTEREDIT=TRUE
######################## shortcuts - for register edit ########################
function selectionshortcut(){   if [[ $SELECTION = "pv" ]] ;                  # 
                                        then    SELECTION=picture-vertical    #
                                elif [[ $SELECTION = "ph" ]] ;                #
                                        then    SELECTION=picture-horizontal  #
                                elif [[ $SELECTION = "gv" ]] ;                #
                                        then    SELECTION=gif-vertical        #
                                elif [[ $SELECTION = "gh" ]] ;                #
                                        then    SELECTION=gif-horizontal      #
                                elif [[ $SELECTION = "vv" ]] ;                #
                                        then    SELECTION=video-vertical      #
                                elif [[ $SELECTION = "vh" ]] ;                #
                                        then    SELECTION=video-horizontal    #
                                elif [[ $SELECTION = "s" ]] ;                 #
                                        then    SELECTION=saved #videoedit saves to here
                                elif [[ $SELECTION = "u" ]] ;                 #
                                        then    SELECTION=unknown             #
                                fi                                            #
                        }                                                     #
###############################################################################
                                while [[ $REGISTEREDIT = "TRUE" ]] ;
                                do      # read ACTION
                                        read -p " $2 | $(basename $PWD) → " ACTION
                                        # Help
                                        if [[ $ACTION = "h" || $ACTION = "help" ]] ;
                                                then    echo -e "register edit Options are:
general usage:
h       help            print this message
q       exit            exit register edit
c       clear           clear terminal
cd [...]                change directory to [...]
pwd                     print current directory path
ls                      list directory contents
register:
n       nano            edit register file with nano
        switch          switch to different register file
        comment         add a comment to your register file
        detox           replaces bad characters in filenames
        bad             fixes too short/bad filenames and insters directoryname
t       trans           translates the filename 
selections:
s       sort            sorts all files in directory to fitting ${CYAN}selection${YELLOW}
a       add             asks for which ${CYAN}selection${YELLOW} to be added to register
sa      selectall       skips ${CYAN}selection${YELLOW} and adds all files in directory to register
l       list            lists all available ${CYAN}selection${YELLOW}
m       modify          asks for which ${CYAN}selection${YELLOW}to be modified
                        enters modify mode for pictures , videos , gifs.
                        in modify mode orientation, loops, playback speed,... can be adjusted."
######################################### insert custom bindings here #####################
                                        # Custom H for Horizontal - custom named register #
                                        elif [[ $ACTION = "H" ]] ;                        #
                                                then    echo -e "custom! Horizontal"      #
                                                        set r Horizontal                  #
                                        #        V for Vertical                           #
                                        elif [[ $ACTION = "V" ]] ;                        #
                                                then    echo -e "custom! Vertical"        #
                                                        set r Vertical                    #
                                        elif [[ $ACTION = "N" ]] ;                        #
                                                then    echo -e "custom! Normal"          #
                                                        set r Normal                      #
###########################################################################################
                                        # exit
                                        elif [[ $ACTION = "q" || $ACTION = "exit" ]] ;
                                                then    echo -e "${OFF}\c"
                                                        # delete /tmp/files
                                                        rm -f /tmp/wallset/selection*
                                                        # Leaving edit 
                                                        REGISTEREDIT=
                                        # nano resgiter-file
                                        elif [[ $ACTION = "n" || $ACTION = "nano" ]] ;
                                                then    nano $PLACE/$2
                                        # switch register
                                        elif [[ $ACTION = "switch" ]] ;
                                                then    echo -e "${OFF}available registers${YELLOW}"
                                                        basename -a $(grep REGFILE= $PLACE/config | grep /home/)
                                                        read -p "→ " REGISTER
                                                        # empty input
                                                        if [[ -z $REGISTER ]] ;
                                                                then    echo -e "${RED}Error:${OFF} empty input ${YELLOW}"
                                                        # REGSITER exist
                                                        elif [[ $REGISTER = $(basename -a $(grep REGFILE= $PLACE/config) | grep $REGISTER ) ]] ; 
                                                                then    set r $REGISTER
                                                                else    echo -e "${RED}Error: ${OFF} '${YELLOW}$REGISTER${OFF}' is not a register${YELLOW}"
                                                        fi
                                        # clear
                                        elif [[ $ACTION = "c" || $ACTION = "clear" ]] ;
                                                then    clear
                                        # cd 
                                        elif [[ $(echo -e "$ACTION" | head -c 2) = "cd" ]] ;
                                                then    cd $(echo -e "$ACTION" | sed 's/cd//')
                                        # pwd
                                        elif [[ $ACTION = "pwd" ]] ;
                                                then    echo -e "${OFF}\c"
                                                        pwd
                                                        echo -e "${YELLOW}\c"
                                        # ls
                                        elif [[ $ACTION = "ls" ]] ;
                                                then    echo -e "${OFF}\c"
                                                ls --color --group-directories-first
                                                echo -e "${YELLOW}\c"
                                        # comment
                                        elif [[ $ACTION = "comment" ]] ;
                                                then    read -p "Add your comment: " COMMENT
                                                        # on purpose no '-e' option ! otherwise \n could be used and new line is not started with '#'
                                                        echo -e "\n" >> $PLACE/$2
                                                        echo "# $COMMENT" >> $PLACE/$2
                                        # dexox - bad filename - characters
                                        elif [[ $ACTION = "detox" ]] ;
                                                then    echo -e "fixing bad characters in <filename>${OFF}"
                                                        detox -v .
                                                        echo -e "${GREEN}detox done${OFF}\nfilenames have changed you should '${BLUE}sort${OFF}' again${YELLOW}"
                                        # bad - bad filename - to common name
                                        elif [[ $ACTION = "bad" || $ACTION = "badname" ]] ;
                                                then    echo -e "fixing too short filenames${OFF}"
                                                        for FILE in $(ls) ;
                                                        do
                                                                NEWNAME=$(basename ${PWD}-${FILE}) 
                                                                mv -v -i $FILE $NEWNAME
                                                        done
                                                        echo -e "${GREEN}done fixing bad names${OFF}\nfilenames have changed you should '${BLUE}sort${OFF}' again${YELLOW}"
                                        # translate - bad filename - language
                                        elif [[ $ACTION = "trans" || $ACTION = "translate" || $ACTION = "t" ]] ;
                                                then    echo -e "translating file names${OFF}"
                                                        for FILE in $(ls)
                                                        do
                                                                echo -e "FILE= '${FILE}'"
                                                                NEWNAME=$(trans -brief $FILE | sed 's/ /_/g;s/(//g;s/)//g;s/!//g;s/?//g;s/://g;s/#//g;s/&/_and_/g')
                                                                mv -v -i "$(echo $FILE)" "$(echo $NEWNAME)"
                                                                echo -e ""
                                                        done
                                                        echo -e "${GREEN}translation done${OFF}\nfilenames have changed you should '${BLUE}sort${OFF}' again${YELLOW}"
                                        # sort all files
                                        elif [[ $ACTION = "s" || $ACTION = "sort" ]] ;
                                                then    # delete old selections
                                                        rm -f /tmp/wallset/selection*
                                                        # selection has been made (for list option)
                                                        SELECTIONMADE=TRUE
                                                        # sort files
                                                        for FILE in $(ls)
                                                        do
                                                                # Filetype
                                                                TYPE=$(echo "$FILE" | tail -c 5 )
                                                                # picture
                                                                if [[ $TYPE = ".png" || $TYPE = ".PNG" || $TYPE = "jpeg" || $TYPE = "JPEG" || $TYPE = ".jpg" || $TYPE = ".JPG" ]] ;
                                                                        then    TYPE=picture
                                                                # webp - can be animated - check that
                                                                elif [[ $TYPE = "webp" || $TYPE = "WEBP" ]] ;
                                                                        then    # webp format. check for frames and possibly convert
                                                                                if [[ $(identify $FILE | wc -l) = "1" ]] ;
                                                                                        # only 1 frame 
                                                                                        then    TYPE=picture
                                                                                        # more than 1 frame = "gif"
                                                                                        else    echo -e "${OFF}$FILE has multiple frames - ${GREEN}converting webp to gif${RED}"
                                                                                                # converting
                                                                                                NEWNAME=$(echo "$FILE"| sed 's/webp/gif/;s/WEBP/GIF/')
                                                                                                convert $FILE $NEWNAME
                                                                                                # delete old file
                                                                                                rm $FILE
                                                                                                FILE=$NEWNAME
                                                                                                TYPE=gif
                                                                                fi
                                                                # gif
                                                                elif [[ $TYPE = ".gif" || $TYPE = ".GIF" ]] ;
                                                                        then    TYPE=gif
                                                                # video
                                                                elif [[ $TYPE = ".mp4"|| $TYPE = ".MP4" || $TYPE = "mkv" || $TYPE = "MKV" || $TYPE = "mov" || $TYPE = ".MOV" || $TYPE = "mxf" || $TYPE = ".MXF" || $TYPE = ".mvi" || $TYPE = "MVI" ]] ;
                                                                        then    TYPE=video
                                                                # unknown
                                                                else    # sort to unkown
                                                                        TYPE=unknown
                                                                        echo -e "${YELLOW}$FILE → ${CYAN}unknown${YELLOW}"
                                                                        echo -e "$PWD/$FILE" >> /tmp/wallset/selection-unknown
                                                                fi
                                                                if [[ $TYPE != "unknown" ]] ;
                                                                        then    # Orientation
                                                                                WIDTH=$(identify -format "%[fx:w]" $FILE[0])
                                                                                HEIGHT=$(identify -format "%[fx:h]" $FILE[0])
                                                                                if [ $WIDTH -ge $HEIGHT ] ;
                                                                                        then    ORIENTATION=horizontal
                                                                                        else    ORIENTATION=vertical
                                                                                fi
                                                                                echo -e "${YELLOW}$FILE → ${CYAN}${TYPE}-${ORIENTATION}${YELLOW}"
                                                                                echo -e "$PWD/$FILE" >> /tmp/wallset/selection-${TYPE}-${ORIENTATION}
                                                                fi
                                                        done
                                                        echo -e "${GREEN}done${YELLOW}"
                                        # add selection
                                        elif [[ $ACTION = "a" || $ACTION = "add" ]] ;
                                                then    # check if selection has been made
                                                        if [[ $SELECTIONMADE = "TRUE" ]] ;
                                                                then    echo -e "${CYAN}\c"
                                                                        ls /tmp/wallset/selection-* | sed "s./tmp/wallset/selection-..g"
                                                                        echo -e "${YELLOW}\c"
                                                                        read -p "which selection to add: " SELECTION
                                                                        selectionshortcut # function see above
                                                                        # does selection exist?
                                                                        if [[ "/tmp/wallset/selection-$SELECTION" = $(ls /tmp/wallset/selection-* | grep $SELECTION ) ]] ;
                                                                                then    # if selection contains video or gifs add duration in front
                                                                                        if [[ $(echo "$SELECTION" | head -c 5) = "video" || $(echo "$SELECTION" | head -c 3) = "gif" ]] ;
                                                                                                # videos / gifs
                                                                                                then    for FILE in $(cat /tmp/wallset/selection-$SELECTION)
                                                                                                        do
                                                                                                                echo "$(ffmpeg -i $FILE 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }') $PWD/$FILE" >> $PLACE/$2
                                                                                                        done
                                                                                                        echo -e "adding ${CYAN}${SELECTION}${YELLOW}"
                                                                                                # pictures/ + unknown else
                                                                                                else    echo -e "adding ${CYAN}${SELECTION}${YELLOW}"
                                                                                                        cat /tmp/wallset/selection-$SELECTION >> $PLACE/$2
                                                                                        fi
                                                                                else    echo -e "${RED}Error:${YELLOW} >${CYAN}$SELECTION${YELLOW}< is not an ${CYAN}selection${YELLOW}"
                                                                        fi
                                                                else    echo -e "No selections have been made yet. use 'sort' option first"
                                                        fi
                                        # add all
                                        elif [[ $ACTION = "sa" || $ACTION = "selectall" ]] ;
                                                then    echo -e "adding all files to register"
                                                        for FILE in $(ls) ;
                                                        do 
                                                                # if file is video add duration
                                                                FILETYPE=$(echo "$FILE" | tail -c 5)
                                                                if [[ $FILETYPE = ".gif" || $FILETYPE = ".GIF" ||  $FILETYPE = ".mp4" || $FILETYPE = ".MP4" || $FILETYPE1 = ".mkv" || $FILETYPE1 = ".MKV" || $FILETYPE = ".mov" || $FILETYPE = ".MOV" || $FILETYPE = ".mxf" || $FILETYPE = ".MXF" || $FILETYPE = ".mvi" || $FILETYPE = ".MVI" ]] ; 
                                                                        then    echo "$(ffmpeg -i $FILE 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }') $PLACE/$FILE" >> $PLACE/$2
                                                                        else    echo -e "$PWD/$FILE" >> $PLACE/$2
                                                                fi
                                                        done
                                                        echo -e "${GREEN}done${YELLOW}"
                                        # list selections
                                        elif [[ $ACTION = "l" || $ACTION = "list" ]] ;
                                                then    # has a selection been made?
                                                        if [[ $SELECTIONMADE = "TRUE" ]] ;
                                                                then    echo -e "all available selections:${CYAN}"
                                                                        ls /tmp/wallset/selection-* | sed "s./tmp/wallset/selection-..g"
                                                                        echo -e "${YELLOW}\c"
                                                                else    echo -e "No selections have been made yet. use 'sort' option first"
                                                        fi
                                        # modify mode
                                        elif [[ $ACTION = "m" || $ACTION = "modify" ]] ;
                                                then    # list selections
                                                        echo -e "${CYAN}\c"
                                                        ls /tmp/wallset/selection-* | sed "s./tmp/wallset/selection-..g"
                                                        echo -e "${YELLOW}\c"
                                                        read -p "which selection to modify: " SELECTION
                                                        selectionshortcut # function see above
                                                        # does selection exist?
                                                        if [[ "/tmp/wallset/selection-$SELECTION" = $(ls /tmp/wallset/selection-* | grep $SELECTION ) ]] ;
                                                                then    # define EDIT options of $SELECTION are "pic | gif | vid | unk"
                                                                        if [[ $(echo "$SELECTION" | head -c 3) = "pic" ]] ;
                                                                                then    EDIT=picture
                                                                        elif [[ $(echo "$SELECTION" | head -c 3) = "gif" ]] ;
                                                                                then    EDIT=gif
                                                                        elif [[ $(echo "$SELECTION" | head -c 3) = "vid" ]] ;
                                                                                then    EDIT=video
                                                                        elif [[ $(echo "$SELECTION" | head -c 3) = "unk" ]] ;
                                                                                then    EDIT=unknown
                                                                        fi
# a common shortcuts for all editmodes (picture gif video unknown)
#################################################################
function editshortcut(){
        # help - general usage
        if [[ $MOD = "h" || $MOD = "help" ]] ;
                then    echo -e "$EDIT edit
 general usage:
h       help            to print this message
b       back            to leave $EDIT edit
q       exit            to leave $EDIT edit and register edit
c       clear           clear terminal
l       list            lists all files in $SELECTION
        print           print all marked files"
        # back to RegisterEdit
        elif [[ $MOD = "b" || $MOD = "back" ]] ;
                then    echo -e "${YELLOW}\c"
                        MARK=
                        EDIT=
        # selection edit AND RegisterEdit
        elif [[ $MOD = "q" || $MOD = "exit" ]] ;
                then    echo -e "${OFF}\c"
                        # delete /tmp/files
                        rm -f /tmp/wallset/selection*
                        rm -f /tmp/wallset/mark*
                        # Leaving edit
                        MARK=
                        EDIT=
                        REGISTEREDIT=
        # clear
        elif [[ $MOD = "c" || $MOD = "clear" ]] ;
                then    clear
                        # for video ad gif option
                        MESSAGE="\c"
        # list all files in selection
        elif [[ $MOD = "l" || $MOD = "list" ]] ;
                then    # for video and gif option necessary to do it like this
                        MESSAGE="all files in selection $SELECTION\n$(basename -a $(cat /tmp/wallset/selection-${SELECTION}))"
                        echo -e "$MESSAGE"
        # print marked files in selection
        elif [[ $MOD = "print" ]] ;
                then    # marked files?
                        if [[ $MARK = "TRUE" ]];
                                then    MESSAGE="marked file(s)\n$(basename -a $(cat /tmp/wallset/mark-$SELECTION))"
                                        echo -e "$MESSAGE"
                                else    MESSAGE="no files have been marked yet. use 'm' option"
                                        echo -e "$MESSAGE"
                        fi
        fi
}
#################################################################
                                                                # file list is stored in /tmp/wallset/selection-$SELECTION
                                                                        # set entery message:
                                                                        echo -e "entering $EDIT edit\n${CYAN}enter 'h' for help"
                                                                        # picture edit
                                                                        while [[ $EDIT = "picture" ]] ;
                                                                        do      
                                                                                # MF marked files: ex. [7]
                                                                                if [[ $MARK = "TRUE" ]] ;
                                                                                        then    MF="[$(cat /tmp/wallset/mark-$SELECTION | wc -l)]"
                                                                                        else    MF=
                                                                                fi
                                                                                read -p " $2 | $SELECTION $MF → " MOD
                                                                                # editshortcut for options (q ; b ; list ; )
                                                                                editshortcut # shortcuts for general functions
                                                                                
                                                                                # specified options only for editmode
                                                                                if [[ $MOD = "h" || $MOD = "help" ]] ;
                                                                                        then    echo -e "d       delete          marked files
m       mark            opens sxiv. mark files with 'm' to further edit
 picture specific:
s       show            shows marked files in sxiv
+                       remove all non-marked files from selection
-                       remove marked files from selection
r       rotate          rotate pictures, asks for rotation"
                                                                                # delete
                                                                                elif [[ $MOD = "d" || $MOD = "delete" ]] ;
                                                                                        then    # marked files?
                                                                                                if [[ $MARK = "TRUE" ]] ;
                                                                                                        # confirm deletion
                                                                                                        then    read -p "Are you sure you want to delete $MF marked files [y/N]? " CONFIRM
                                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "Y" || $CONFIRM = "yes" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                                        then    # delete files
                                                                                                                                echo -e "${RED}\c"
                                                                                                                                rm -v $(cat /tmp/wallset/mark-$SELECTION)
                                                                                                                                echo -e "$CYAN\c"
                                                                                                                                # clear marking
                                                                                                                                MARK=
                                                                                                                                rm -f /tmp/wallset/mark-$SELECTION
                                                                                                                        else    echo -e "Aborting"
                                                                                                                fi
                                                                                                        # no marked files
                                                                                                        else    echo -e "no files have been marked. use 'm' option first"
                                                                                                fi
                                                                                # mark
                                                                                elif [[ $MOD = "m" || $MOD = "mark" ]] ;
                                                                                        then    sxiv -a -o -f $(cat /tmp/wallset/selection-$SELECTION) > /tmp/wallset/mark-$SELECTION
                                                                                                if [[ $(cat /tmp/wallset/mark-$SELECTION | wc -l) = "0" ]] ;
                                                                                                        # no marked files
                                                                                                        then    echo -e "no files have been marked"
                                                                                                                MARK=
                                                                                                        # file have been marked
                                                                                                        else    MARK=TRUE
                                                                                                fi
                                                                                # show marked files in sxiv
                                                                                elif [[ $MOD = "s" || $MOD = "show" ]] ;
                                                                                        then    # marked?
                                                                                                if [[ $MARK = "TRUE" ]] ;
                                                                                                        then    echo -e "marked files:"
                                                                                                                sxiv -f -b $(cat /tmp/wallset/mark-$SELECTION)
                                                                                                        else    echo -e "no files have been marked"
                                                                                                fi
                                                                                # + remove all not marked files from selection
                                                                                elif [[ $MOD = "+" ]] ;
                                                                                        then    echo -e "keeping marked files, removing all other files from selection >$SELECTION< Are you sure? [y/N]"
                                                                                                read CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "yes" || $CONFIRM = "Y" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    cat /tmp/wallset/mark-$SELECTION > /tmp/wallset/selection-$SELECTION
                                                                                                                # unmark files 
                                                                                                                MARK=
                                                                                                                rm -f /tmp/wallset/mark*
                                                                                                                echo -e "selection filtered"
                                                                                                        else    echo -e "Aborting"
                                                                                                fi
                                                                                # - remove marked files from selection
                                                                                elif [[ $MOD = "-" ]] ;
                                                                                        then    echo -e "removing marked files from selection >$SELECTION< Are you sure? [y/N]"
                                                                                                read CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "yes" || $CONFIRM = "Y" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    for FILE in $(cat /tmp/wallset/mark-$SELECTION)
                                                                                                                do
                                                                                                                        DELETELINE=$(grep -n "${FILE}" /tmp/wallset/selection-$SELECTION | sed 's/:/\n/g' | head -n 1)
                                                                                                                        sed -i "${DELETELINE}d" /tmp/wallset/selection-$SELECTION
                                                                                                                        echo -e "removed $(basename $FILE)"
                                                                                                                done
                                                                                                                # unmark files 
                                                                                                                MARK=
                                                                                                                rm -f /tmp/wallset/mark*
                                                                                                                echo -e "selection filtered"
                                                                                                        else    echo -e "Aborting"
                                                                                                fi
                                                                                # rotate
                                                                                elif [[ $MOD = "rotate" ||$MOD = "r" ]] ;
                                                                                        then    # marked?
                                                                                                if [[ $MARK = "TRUE" ]] ;
                                                                                                        then    #questions
                                                                                                                echo -e "rotate X° clockwise. specify a noumber or use the shortcut:\nr\t90° clockwise\nl\t90° counterclockwise\nf\tfull 180° flip"
                                                                                                                read -p " → " ROTATION
                                                                                                                echo -e "the rotation creates new files. do you want to keep the original file(s) [y/N]?"
                                                                                                                read -p " → " KEEP
                                                                                                                # rotation shortcuts
                                                                                                                if [[ $ROTATION = "r" ]];
                                                                                                                        then    ROTATION="90"
                                                                                                                elif [[ $ROTATION = "l" ]];
                                                                                                                        then    ROTATION="-90"
                                                                                                                elif [[ $ROTATION = "f" ]] ;
                                                                                                                        then    ROTATION="180"
                                                                                                                fi
                                                                                                                # empty argument ROTATION
                                                                                                                if [[ -z $ROTATION ]] ;
                                                                                                                        then    echo -e "${RED}Error:${CYAN} empty argument."
                                                                                                                        # conversion loop
                                                                                                                        else    for FILE in $(cat /tmp/wallset/mark-$SELECTION)
                                                                                                                                do      
                                                                                                                                        if [[ $KEEP = "y" || $KEEP = "Y" || $KEEP = "yes" || $KEEP = "Yes" || $KEEP = "YES" ]] ;
                                                                                                                                                # Keep original file
                                                                                                                                                then    # FILE is in /path/...filename
                                                                                                                                                        NEWFILE=$PWD/$(basename $FILE | sed 's/^/rotated-/')
                                                                                                                                                        echo -e "$(basename $FILE) → ${GREEN}$(basename $NEWFILE)${CYAN}"
                                                                                                                                                        convert $FILE -rotate $ROTATION $NEWFILE
                                                                                                                                                # overwrite the new file
                                                                                                                                                else    NEWFILE=$PWD/NEWFILE
                                                                                                                                                        echo -e "converting ${GREEN}$(basename $FILE)${CYAN}"
                                                                                                                                                        convert $FILE -rotate $ROTATION $NEWFILE
                                                                                                                                                        mv $NEWFILE $FILE
                                                                                                                                        fi
                                                                                                                                done
                                                                                                                                echo -e "${GREEN}done${CYAN}"
                                                                                                                                # unmark files 
                                                                                                                                MARK=
                                                                                                                                rm -f /tmp/wallset/mark*
                                                                                                                fi
                                                                                                        # not marked yet       
                                                                                                        else    echo -e "no files have been marked"
                                                                                                fi
                                                                                fi
                                                                        # end of picture edit
                                                                        done
                                                                        # preperation - setting variables
                                                                        if [[ $EDIT = "gif" ]] ;
                                                                                then    cat /tmp/wallset/selection-$SELECTION > /tmp/wallset/mark-$SELECTION
                                                                                        MARK=TRUE
                                                                                        MESSAGE="Welcome to $EDIT edit\nenter 'h' for help"
                                                                                        # zoom - fit to screen
                                                                                        ZOOMOPTION="${GREEN}Fit screen${CYAN}"
                                                                                        ZOOMVALUE="1"
                                                                                        # pause - start normal
                                                                                        PAUSEOPTION="${GREEN}normal${CYAN}"
                                                                                        PAUSE=
                                                                                        # speed
                                                                                        SPEEDVALUE="1"
                                                                                        # duration
                                                                                        MF=$(basename $(cat /tmp/wallset/mark-$SELECTION | head -n 1))
                                                                                        DURATION_FULL=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//'g)
                                                                                        DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                        # loop
                                                                                        LOOPOPTION="${GREEN}Full gif${CYAN}"
                                                                                        LOOPVALUE_A=
                                                                                        LOOPVALUE_B=
                                                                        fi
                                                                        # gif edit
                                                                        while [[ $EDIT = "gif" ]] ;
                                                                        do
                                                                                # make screen
                                                                                # mark file
                                                                                MF=$(basename $(cat /tmp/wallset/mark-$SELECTION | head -n 1))
                                                                                clear
                                                                                echo -e "########################################################\n
marked file:\t${GREEN}$MF${CYAN}\t\t
Zoom:\t\t$ZOOMOPTION \tFiles left:\t${GREEN}$(cat /tmp/wallset/mark-$SELECTION | wc -l )/$(cat /tmp/wallset/selection-$SELECTION | wc -l)${CYAN}
playing starts:\t$PAUSEOPTION \t\tplayback speed:\t${GREEN}${SPEEDVALUE}x${CYAN}
Duration: \t${GREEN}$DURATION_FULL${CYAN} \tDuration (s): \t${GREEN}$DURATION_SEC${CYAN}
Loop:\t\t$LOOPOPTION
\n########################################################\n\n$MESSAGE\n"
                                                                                read -p " $2 → " MOD
                                                                                # editshortcut for options (q ; b ; list ; )
                                                                                editshortcut # shortcuts for general functions
                                                                                
                                                                                # specified options only for editmode
                                                                                if [[ $MOD = "h" || $MOD = "help" ]] ;
                                                                                        then    MESSAGE="general usage:
h       help            to print this message
b       back            to leave $EDIT edit
q       exit            to leave $EDIT edit and register edit
c       clear           clear terminal
l       list            lists all files in $SELECTION
        print           print all marked files
        delete          marked files
 gif specific:
p       play            play marked file in mpv with options
        show            play marked file in mpv without options
        sxiv            show gif in sxiv
        pause           toggle option gif starts normal/paused
-                       remove marked files from selection
r       rotate          rotate gif, asks for rotation
s       save            saves ${GREEN}options${CYAN} to ${YELLOW}selection 'saved'${CYAN}
n       next            unmarks currently marked file and marks next file
l       loop            toggles loop on or of
        A       selects starpoint for loop
        B       selects endpoint for loop
z       zoom            toggles fit to screen zoom on or off
        speed           set playback speed
d       duration        set playback duration as a wallpaper in seconds"
                                                                                # delete
                                                                                elif [[ $MOD = "delete" ]] ;
                                                                                        then    read -p "Are you sure you want to delete $MF marked files [y/N]? " CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "Y" || $CONFIRM = "yes" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    # delete files
                                                                                                                MESSAGE="${RED}removed '$MF' ${CYAN}"
                                                                                                                rm -f $PWD/$MF
                                                                                                                # delete from selection
                                                                                                                DELETELINE=$(grep -n $(cat /tmp/wallset/mark-$SELECTION | head -n 1) /tmp/wallset/selection-$SELECTION | sed 's/:/\n/g' | head -n 1)
                                                                                                                sed -i "${DELETELINE}d" /tmp/wallset/selection-$SELECTION
                                                                                                                # delete from mark
                                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                        else    MESSAGE="Aborting"
                                                                                                fi
                                                                                # play - with options
                                                                                elif [[ $MOD = "p" || $MOD = "play" ]] ;
                                                                                        then    MESSAGE="playing ${GREEN}$MF${CYAN} with options"
                                                                                                # loop options
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        then    mpv -fs --loop $PAUSE --panscan=$ZOOMVALUE --speed=$SPEEDVALUE $PWD/$MF
                                                                                                        else    mpv -fs --loop $PAUSE --panscan=$ZOOMVALUE --speed=$SPEEDVALUE --ab-loop-a=$LOOPVALUE_A --ab-loop-b=$LOOPVALUE_B --start=$LOOPVALUE_A $PWD/$MF
                                                                                                fi
                                                                                                echo -e "${CYAN}\c"
                                                                                # show - play without options
                                                                                elif [[ $MOD = "show" ]] ;
                                                                                        then    MESSAGE="playing ${GREEN}$MF${CYAN} without options"
                                                                                                mpv -fs --loop $PAUSE $PWD/$MF
                                                                                                echo -e "${CYAN}\c"
                                                                                elif [[ $MOD = "sxiv" ]] ;
                                                                                        then    MESSAGE="playing ${GREEN}$MF${CYAN} in sxiv"
                                                                                                sxiv -a -f $MF
                                                                                # pause $PAUSEOPTION=normal/paused and $PAUSE=<empty>/--pause
                                                                                elif [[ $MOD = "pause" ]] ;
                                                                                        then    # toggle options
                                                                                                if [[ $PAUSEOPTION = "${GREEN}normal${CYAN}" ]] ;
                                                                                                        then    PAUSEOPTION="${RED}paused${CYAN}"
                                                                                                                PAUSE="--pause"
                                                                                                        else    PAUSEOPTION="${GREEN}normal${CYAN}"
                                                                                                                PAUSE=
                                                                                                fi
                                                                                                MESSAGE="\c"
                                                                                # - remove marked file from selection
                                                                                elif [[ $MOD = "-" ]] ;
                                                                                        then    echo -e "removing ${GREEN}$MF${CYAN} from selection ${YELLOW}$SELECTION${CYAN} Are you sure? [y/N]"
                                                                                                read -p " $2 → " CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "yes" || $CONFIRM = "Y" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    # delete from selection 
                                                                                                                DELETELINE=$(grep -n $(cat /tmp/wallset/mark-$SELECTION | head -n 1 ) /tmp/wallset/selection-$SELECTION | sed 's/:/\n/g' | head -n 1)
                                                                                                                sed -i "${DELETELINE}d" /tmp/wallset/selection-$SELECTION
                                                                                                                MESSAGE="removed  ${GREEN}$MF${CYAN} from ${YELLOW}$SELECTION${CYAN}"
                                                                                                                # delete from mark
                                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                        else    MESSAGE="Aborting"
                                                                                                fi
                                                                                #
                                                                                # r - rotate gif, asks for rotation
                                                                                elif [[ $MOD = "r" || $MOD = "rotate" ]] ;
                                                                                        then    echo -e "Enter how to rotate and or flip the file:\n0 = 90° CounterClockwise and Vertical Flip\n1 = 90° Clockwise\n2 = 90° CounterClockwise\n3 = 90° Clockwise and Vertical Flip"
                                                                                                read -p " $2 → " ROTATION
                                                                                                if [[ $ROTATION = "0" || $ROTATION = "1" || $ROTATION = "2" || $ROTATION = "3" ]] ;
                                                                                                        # good argument conversion 
                                                                                                        then    read -p "the rotation creates new files. do you want to keep the original file(s) [y/N]?" KEEP
                                                                                                                # doing the rotation
                                                                                                                if [[ $ROTATION = "0" ]] ;
                                                                                                                        then    echo -e "rotate left and flip"
                                                                                                                                ffmpeg -i $MF -vf "transpose=0" rotated-$MF
                                                                                                                elif [[ $ROTATION = "1" ]] ;
                                                                                                                        then    echo -e "rotate right"
                                                                                                                                ffmpeg -i $MF -vf "transpose=1" rotated-$MF
                                                                                                                elif [[ $ROTATION = "2" ]] ;
                                                                                                                        then    echo -e "rotate left"
                                                                                                                                ffmpeg -i $MF -vf "transpose=2" rotated-$MF
                                                                                                                elif [[ $ROTATION = "3" ]] ;
                                                                                                                        then    echo -e "rotate right and flip"
                                                                                                                                ffmpeg -i $MF -vf "transpose=3" rotated-$MF
                                                                                                                fi
                                                                                                                # KEEP original argument
                                                                                                                if [[ $KEEP = "y" || $KEEP = "Y" || $KEEP = "yes" || $KEEP = "Yes" || $KEEP = "YES" ]] ;
                                                                                                                        then    # Keep original file = do nothing
                                                                                                                                MESSAGEEXTENSION="new file ${GREEN}rotated-$MF${CYAN} created\n"
                                                                                                                        else    # overwrite the new file
                                                                                                                                MESSAGEEXTENSION=
                                                                                                                                mv rotated-$MF $MF
                                                                                                                fi #            ↓ for displaying if original was kept
                                                                                                                MESSAGE="${MESSAGEEXTENSION}${GREEN}converting $MF done${CYAN}"
                                                                                                        # Error bad argument ROTATION
                                                                                                        else    MESSAGE="${RED}Error:${CYAN} bad argument '$ROTATION'"
                                                                                                fi
                                                                                # s save - saves ${GREEN}options${CYAN} to ${YELLOW}selection 'edited'${CYAN}
                                                                                elif [[ $MOD = "save" ]] ;
                                                                                        then    MESSAGE="saved to ${YELLOW}selection 'saved'${CYAN}"
                                                                                                # adding a comment
                                                                                                read -p "Do you want to add a comment [y/N]? " COMMENT
                                                                                                if [[ $COMMENT = "y" || $COMMENT = "Y" || $COMMENT = "yes" || $COMMENT = "Yes" || $COMMENT = "YES" ]] ;
                                                                                                        then    read -p "your comment: " COMMENT
                                                                                                                # no -e option on purpose
                                                                                                                echo "# $COMMENT" >> /tmp/wallset/selection-saved
                                                                                                fi
                                                                                                # loop options
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        then    echo -e "$DURATION_SEC --panscan=$ZOOMVALUE --speed=$SPEEDVALUE $PWD/$MF" >> /tmp/wallset/selection-saved
                                                                                                        # errorhandling if LOOPVALUE_A or LOOPVALUE_B are blank reject saving
                                                                                                        else    if [[ -z $LOOPVALUE_A || -z $LOOPVALUE_B ]];
                                                                                                                        then    MESSAGE="${RED}Error:${CYAN} the Loop is not closed yet"
                                                                                                                        else    echo "$DURATION_SEC --panscan=$ZOOMVALUE --speed=$SPEEDVALUE --ab-loop-a=$LOOPVALUE_A --abloop-b=$LOOPVALUE_B --start=$LOOPVALUE_A $PWD/$MF" >> /tmp/wallset/selection-saved
                                                                                                                fi
                                                                                                fi
                                                                                # next - unmarks currently marked file and marks next file
                                                                                elif [[ $MOD = "n" || $MOD = "next" ]] ; 
                                                                                        then    # remove file from marking
                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                # setting variables
                                                                                                # Loop
                                                                                                LOOPOPTION="${GREEN}Full gif${CYAN}"
                                                                                                LOOPVALUE_A=
                                                                                                LOOPVALUE_A_SEC=
                                                                                                LOOPVALUE_B=
                                                                                                LOOPVALUE_B_SEC=
                                                                                                # Zoomoption stays the same
                                                                                                # pauseoption stays the same
                                                                                                # speedoption gets reset to 1
                                                                                                SPEEDVALUE="1"
                                                                                                # recalculate duration
                                                                                                if [[ -z $(cat /tmp/wallset/mark-$SELECTION) ]] ;
                                                                                                        then    # no more files remaining
                                                                                                                MESSAGE="No more files remaining. go back"
                                                                                                                DURATION_FULL="no file"
                                                                                                                DURATION_SEC="no file"
                                                                                                        else    MESSAGE="next file"
                                                                                                                DURATION_FULL=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//'g)
                                                                                                                DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                fi
                                                                                # l loop - toggles loop on or of
                                                                                elif [[ $MOD = "loop" ]] ;
                                                                                        then    # toggle Loopoptions
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Enabling Loop. Select Startpoint A and Endpoint B\n${RED}Disclaimer${CYAN} points need to be entered in the same format:\nhour:minute:second.milli-seconds"
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                        else    MESSAGE="playing full gif"
                                                                                                                LOOPOPTION="${GREEN}Full gif${CYAN}"
                                                                                                                LOOPVALUE_A=
                                                                                                                LOOPVALUE_B=
                                                                                                fi
                                                                                # A - selects starpoint for loop
                                                                                elif [[ $MOD = "A" ]] ;
                                                                                        then    # loop not enabled yet
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Loop is not enabled yet. use option 'loop' first" 
                                                                                                        else    read -p "enter Startpoint A in correct format: " LOOPVALUE_A
                                                                                                                # refresh LOOPOPTION
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                                MESSAGE="Start A set as $LOOPVALUE_A"
                                                                                                fi
                                                                                # B - selects endpoint for loop
                                                                                elif [[ $MOD = "B" ]] ;
                                                                                        then    # loop not enabled yet
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Loop is not enabled yet. use option 'loop' first" 
                                                                                                        else    echo -e "time format is h:m:sec.subsec ex: 0:15:24.06"
                                                                                                                read -p "enter a time where the loop ends: " LOOPVALUE_B
                                                                                                                # refresh LOOPOPTION
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                                MESSAGE="End B set as ${LOOPVALUE_B}"
                                                                                                fi
                                                                                # z zoom - toggles fit to screen zoom on or off
                                                                                elif [[ $MOD = "z" || $MOD = "zoom" ]] ;
                                                                                        then    if [[ $ZOOMVALUE = "0" ]] ;
                                                                                                        then    ZOOMOPTION="${GREEN}Fit screen${CYAN}"
                                                                                                                ZOOMVALUE=1
                                                                                                        else    ZOOMOPTION="${RED}Off\t${CYAN}"
                                                                                                                ZOOMVALUE=0
                                                                                                fi
                                                                                # speed >X< - sets playback speed to value >X< / asks for Value
                                                                                elif [[ $MOD = "speed" ]] ;
                                                                                        then    read -p "select playback speed: " SPEEDVALUE
                                                                                                if [[ -z $SPEEDVALUE ]] ;
                                                                                                        then    SPEEDVALUE=1
                                                                                                fi
                                                                                                MESSAGE="speed set to ${GREEN}${SPEEDVALUE}x${CYAN}"

                                                                                # duration
                                                                                elif [[ $MOD = "d" || $MOD = "duration" ]] ;
                                                                                        then    # if loop is enabled calculate the loop length 
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full gif${CYAN}" ]] ;
                                                                                                        # full gif
                                                                                                        then    echo -e "The gif duration is $DURATION_SEC seconds"
                                                                                                        # looping gif diffetently
                                                                                                        else    LOOPVALUE_A_SEC=$(echo "$LOOPVALUE_A" | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                LOOPVALUE_B_SEC=$(echo "$LOOPVALUE_B" | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                echo -e "The length of your loop is ${GREEN)}$(echo "$LOOPVALUE_A_SEC $LOOPVALUE_B_SEC=" | awk '{print $2 - $1}')${CYAN}"
                                                                                                fi
                                                                                                read -p "set play duration in seconds: " DURATION_SEC
                                                                                                # empty argument - reset to full
                                                                                                if [[ -z $DURATION_SEC ]] ;
                                                                                                        then    DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                MESSAGE="Duration reset"
                                                                                                        else    MESSAGE="play duration set"
                                                                                                fi
                                                                                # errorhandling unknown input
                                                                                elif [[ $MOD = "c" || $MOD = "clear" || $MOD = "l" || $MOD = "list" || $MOD = "print" ]] ;
                                                                                        then    echo -e "\c"
                                                                                # unknown input
                                                                                else    MESSAGE="${RED}Error:${CYAN} unknown input >${RED}$MOD${CYAN}<"
                                                                                fi
                                                                        # end of gif edit
                                                                        done
                                                                        # video edit
                                                                        # preperation - setting variables
                                                                        if [[ $EDIT = "video" ]] ;
                                                                                then    cat /tmp/wallset/selection-$SELECTION > /tmp/wallset/mark-$SELECTION
                                                                                        MARK=TRUE
                                                                                        MESSAGE="Welcome to $EDIT edit\nenter 'h' for help"
                                                                                        # zoom
                                                                                        ZOOMOPTION="${RED}Off\t${CYAN}"
                                                                                        ZOOMVALUE="0"
                                                                                        # pause
                                                                                        PAUSEOPTION="${RED}paused${CYAN}"
                                                                                        PAUSE="--pause"
                                                                                        # speed
                                                                                        SPEEDVALUE="1"
                                                                                        # duration
                                                                                        MF=$(basename $(cat /tmp/wallset/mark-$SELECTION | head -n 1))
                                                                                        DURATION_FULL=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//'g)
                                                                                        DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                        # loop
                                                                                        LOOPOPTION="${GREEN}Full video${CYAN}"
                                                                                        LOOPVALUE_A=
                                                                                        LOOPVALUE_B=
                                                                        fi
                                                                        while [[ $EDIT = "video" ]] ;
                                                                        do      # make screen
                                                                                # mark file
                                                                                MF=$(basename $(cat /tmp/wallset/mark-$SELECTION | head -n 1))
                                                                                clear
                                                                                echo -e "########################################################\n
marked file:\t${GREEN}$MF${CYAN}\t\t
Zoom:\t\t$ZOOMOPTION \tFiles left:\t${GREEN}$(cat /tmp/wallset/mark-$SELECTION | wc -l )/$(cat /tmp/wallset/selection-$SELECTION | wc -l)${CYAN}
playing starts:\t$PAUSEOPTION \t\tplayback speed:\t${GREEN}${SPEEDVALUE}x${CYAN}
Duration: \t${GREEN}$DURATION_FULL${CYAN} \tDuration (s): \t${GREEN}$DURATION_SEC${CYAN}
Loop:\t\t$LOOPOPTION
\n########################################################\n\n$MESSAGE\n"
                                                                                read -p " $2 → " MOD
                                                                                # editshortcut for options (q ; b ; list ; )
                                                                                editshortcut # shortcuts for general functions
                                                                                
                                                                                # specified options only for editmode
                                                                                if [[ $MOD = "h" || $MOD = "help" ]] ;
                                                                                        then    MESSAGE="general usage:
h       help            to print this message
b       back            to leave $EDIT edit
q       exit            to leave $EDIT edit and register edit
c       clear           clear terminal
l       list            lists all files in $SELECTION
        print           print all marked files
        delete          marked files
 video specific:
p       play            play marked file in mpv with options
        show            play marked file in mpv without options
        pause           toggle option video starts normal/paused
-                       remove marked files from selection
r       rotate          rotate video, asks for rotation
s       save            saves ${GREEN}options${CYAN} to ${YELLOW}selection 'saved'${CYAN}
n       next            unmarks currently marked file and marks next file
l       loop            toggles loop on or of
        A       selects starpoint for loop
        B       selects endpoint for loop
z       zoom            toggles fit to screen zoom on or off
        speed           set playback speed
d       duration        set playback duration as a wallpaper in seconds"
                                                                                # delete
                                                                                elif [[ $MOD = "delete" ]] ;
                                                                                        then    read -p "Are you sure you want to delete $MF marked files [y/N]? " CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "Y" || $CONFIRM = "yes" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    # delete files
                                                                                                                MESSAGE="${RED}removed '$MF' ${CYAN}"
                                                                                                                rm -f $PWD/$MF
                                                                                                                # delete from selection
                                                                                                                DELETELINE=$(grep -n $(cat /tmp/wallset/mark-$SELECTION | head -n 1) /tmp/wallset/selection-$SELECTION | sed 's/:/\n/g' | head -n 1)
                                                                                                                sed -i "${DELETELINE}d" /tmp/wallset/selection-$SELECTION
                                                                                                                # delete from mark
                                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                        else    MESSAGE="Aborting"
                                                                                                fi
                                                                                # play - with options
                                                                                elif [[ $MOD = "p" || $MOD = "play" ]] ;
                                                                                        then    MESSAGE="playing ${GREEN}$MF${CYAN} with options"
                                                                                                # loop options
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        then    mpv -fs $PAUSE --panscan=$ZOOMVALUE --speed=$SPEEDVALUE $PWD/$MF
                                                                                                        else    mpv -fs $PAUSE --panscan=$ZOOMVALUE --speed=$SPEEDVALUE --ab-loop-a=$LOOPVALUE_A --ab-loop-b=$LOOPVALUE_B --start=$LOOPVALUE_A $PWD/$MF
                                                                                                fi
                                                                                                echo -e "${CYAN}\c"
                                                                                # show - play without options
                                                                                elif [[ $MOD = "show" ]] ;
                                                                                        then    MESSAGE="playing ${GREEN}$MF${CYAN} without options"
                                                                                                mpv -fs $PAUSE $PWD/$MF
                                                                                                echo -e "${CYAN}\c"
                                                                                # pause $PAUSEOPTION=normal/paused and $PAUSE=<empty>/--pause
                                                                                elif [[ $MOD = "pause" ]] ;
                                                                                        then    # toggle options
                                                                                                if [[ $PAUSEOPTION = "${GREEN}normal${CYAN}" ]] ;
                                                                                                        then    PAUSEOPTION="${RED}paused${CYAN}"
                                                                                                                PAUSE="--pause"
                                                                                                        else    PAUSEOPTION="${GREEN}normal${CYAN}"
                                                                                                                PAUSE=
                                                                                                fi
                                                                                                MESSAGE="\c"
                                                                                # - remove marked file from selection
                                                                                elif [[ $MOD = "-" ]] ;
                                                                                        then    echo -e "removing ${GREEN}$MF${CYAN} from selection ${YELLOW}$SELECTION${CYAN} Are you sure? [y/N]"
                                                                                                read -p " $2 → " CONFIRM
                                                                                                if [[ $CONFIRM = "y" || $CONFIRM = "yes" || $CONFIRM = "Y" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ;
                                                                                                        then    # delete from selection 
                                                                                                                DELETELINE=$(grep -n $(cat /tmp/wallset/mark-$SELECTION | head -n 1 ) /tmp/wallset/selection-$SELECTION | sed 's/:/\n/g' | head -n 1)
                                                                                                                sed -i "${DELETELINE}d" /tmp/wallset/selection-$SELECTION
                                                                                                                MESSAGE="removed  ${GREEN}$MF${CYAN} from ${YELLOW}$SELECTION${CYAN}"
                                                                                                                # delete from mark
                                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                        else    MESSAGE="Aborting"
                                                                                                fi
                                                                                #
                                                                                # r - rotate video, asks for rotation
                                                                                elif [[ $MOD = "r" || $MOD = "rotate" ]] ;
                                                                                        then    echo -e "Enter how to rotate and or flip the file:\n0 = 90° CounterClockwise and Vertical Flip\n1 = 90° Clockwise\n2 = 90° CounterClockwise\n3 = 90° Clockwise and Vertical Flip"
                                                                                                read -p " $2 → " ROTATION
                                                                                                if [[ $ROTATION = "0" || $ROTATION = "1" || $ROTATION = "2" || $ROTATION = "3" ]] ;
                                                                                                        # good argument conversion 
                                                                                                        then    read -p "the rotation creates new files. do you want to keep the original file(s) [y/N]?" KEEP
                                                                                                                # doing the rotation
                                                                                                                if [[ $ROTATION = "0" ]] ;
                                                                                                                        then    echo -e "rotate left and flip"
                                                                                                                                ffmpeg -i $MF -vf "transpose=0" rotated-$MF
                                                                                                                elif [[ $ROTATION = "1" ]] ;
                                                                                                                        then    echo -e "rotate right"
                                                                                                                                ffmpeg -i $MF -vf "transpose=1" rotated-$MF
                                                                                                                elif [[ $ROTATION = "2" ]] ;
                                                                                                                        then    echo -e "rotate left"
                                                                                                                                ffmpeg -i $MF -vf "transpose=2" rotated-$MF
                                                                                                                elif [[ $ROTATION = "3" ]] ;
                                                                                                                        then    echo -e "rotate right and flip"
                                                                                                                                ffmpeg -i $MF -vf "transpose=3" rotated-$MF
                                                                                                                fi
                                                                                                                # KEEP original argument
                                                                                                                if [[ $KEEP = "y" || $KEEP = "Y" || $KEEP = "yes" || $KEEP = "Yes" || $KEEP = "YES" ]] ;
                                                                                                                        then    # Keep original file = do nothing
                                                                                                                                MESSAGEEXTENSION="new file ${GREEN}rotated-$MF${CYAN} created\n"
                                                                                                                        else    # overwrite the new file
                                                                                                                                MESSAGEEXTENSION=
                                                                                                                                mv rotated-$MF $MF
                                                                                                                fi #            ↓ for displaying if original was kept
                                                                                                                MESSAGE="${MESSAGEEXTENSION}${GREEN}converting $MF done${CYAN}"
                                                                                                        # Error bad argument ROTATION
                                                                                                        else    MESSAGE="${RED}Error:${CYAN} bad argument '$ROTATION'"
                                                                                                fi
                                                                                # s save - saves ${GREEN}options${CYAN} to ${YELLOW}selection 'edited'${CYAN}
                                                                                elif [[ $MOD = "save" ]] ;
                                                                                        then    MESSAGE="saved to ${YELLOW}selection 'saved'${CYAN}"
                                                                                                # adding a comment
                                                                                                read -p "Do you want to add a comment [y/N]? " COMMENT
                                                                                                if [[ $COMMENT = "y" || $COMMENT = "Y" || $COMMENT = "yes" || $COMMENT = "Yes" || $COMMENT = "YES" ]] ;
                                                                                                        then    read -p "your comment: " COMMENT
                                                                                                                # no -e option on purpose
                                                                                                                echo "# $COMMENT" >> /tmp/wallset/selection-saved
                                                                                                fi
                                                                                                # loop options
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        then    echo -e "$DURATION_SEC --panscan=$ZOOMVALUE --speed=$SPEEDVALUE $PWD/$MF" >> /tmp/wallset/selection-saved
                                                                                                        # errorhandling if LOOPVALUE_A or LOOPVALUE_B are blank reject saving
                                                                                                        else    if [[ -z $LOOPVALUE_A || -z $LOOPVALUE_B ]];
                                                                                                                        then    MESSAGE="${RED}Error:${CYAN} the Loop is not closed yet"
                                                                                                                        else    echo "$DURATION_SEC --panscan=$ZOOMVALUE --speed=$SPEEDVALUE --ab-loop-a=$LOOPVALUE_A --abloop-b=$LOOPVALUE_B --start=$LOOPVALUE_A $PWD/$MF" >> /tmp/wallset/selection-saved
                                                                                                                fi
                                                                                                fi
                                                                                # next - unmarks currently marked file and marks next file
                                                                                elif [[ $MOD = "n" || $MOD = "next" ]] ; 
                                                                                        then    # remove file from marking
                                                                                                sed -i '1d' /tmp/wallset/mark-$SELECTION
                                                                                                # setting variables
                                                                                                # Loop
                                                                                                LOOPOPTION="${GREEN}Full video${CYAN}"
                                                                                                LOOPVALUE_A=
                                                                                                LOOPVALUE_A_SEC=
                                                                                                LOOPVALUE_B=
                                                                                                LOOPVALUE_B_SEC=
                                                                                                # Zoomoption stays the same
                                                                                                # pauseoption stays the same
                                                                                                # speedoption gets reset to 1
                                                                                                SPEEDVALUE="1"
                                                                                                # recalculate duration
                                                                                                if [[ -z $(cat /tmp/wallset/mark-$SELECTION) ]] ;
                                                                                                        then    # no more files remaining
                                                                                                                MESSAGE="No more files remaining. go back"
                                                                                                                DURATION_FULL="no file"
                                                                                                                DURATION_SEC="no file"
                                                                                                        else    MESSAGE="next file"
                                                                                                                DURATION_FULL=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//'g)
                                                                                                                DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                fi
                                                                                # l loop - toggles loop on or of
                                                                                elif [[ $MOD = "loop" ]] ;
                                                                                        then    # toggle Loopoptions
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Enabling Loop. Select Startpoint A and Endpoint B\n${RED}Disclaimer${CYAN} points need to be entered in the same format:\nhour:minute:second.milli-seconds"
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                        else    MESSAGE="playing full video"
                                                                                                                LOOPOPTION="${GREEN}Full video${CYAN}"
                                                                                                                LOOPVALUE_A=
                                                                                                                LOOPVALUE_B=
                                                                                                fi
                                                                                # A - selects starpoint for loop
                                                                                elif [[ $MOD = "A" ]] ;
                                                                                        then    # loop not enabled yet
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Loop is not enabled yet. use option 'loop' first" 
                                                                                                        else    read -p "enter Startpoint A in correct format: " LOOPVALUE_A
                                                                                                                # refresh LOOPOPTION
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                                MESSAGE="Start A set as $LOOPVALUE_A"
                                                                                                fi
                                                                                # B - selects endpoint for loop
                                                                                elif [[ $MOD = "B" ]] ;
                                                                                        then    # loop not enabled yet
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        then    MESSAGE="Loop is not enabled yet. use option 'loop' first" 
                                                                                                        else    echo -e "time format is h:m:sec.subsec ex: 0:15:24.06"
                                                                                                                read -p "enter a time where the loop ends: " LOOPVALUE_B
                                                                                                                # refresh LOOPOPTION
                                                                                                                LOOPOPTION="Start A: \t${GREEN}${LOOPVALUE_A}${CYAN}\n\t\tEnd B: \t\t${GREEN}${LOOPVALUE_B}${CYAN}"
                                                                                                                MESSAGE="End B set as ${LOOPVALUE_B}"
                                                                                                fi
                                                                                # z zoom - toggles fit to screen zoom on or off
                                                                                elif [[ $MOD = "z" || $MOD = "zoom" ]] ;
                                                                                        then    if [[ $ZOOMVALUE = "0" ]] ;
                                                                                                        then    ZOOMOPTION="${GREEN}Fit screen${CYAN}"
                                                                                                                ZOOMVALUE=1
                                                                                                        else    ZOOMOPTION="${RED}Off\t${CYAN}"
                                                                                                                ZOOMVALUE=0
                                                                                                fi
                                                                                # speed >X< - sets playback speed to value >X< / asks for Value
                                                                                elif [[ $MOD = "speed" ]] ;
                                                                                        then    read -p "select playback speed: " SPEEDVALUE
                                                                                                if [[ -z $SPEEDVALUE ]] ;
                                                                                                        then    SPEEDVALUE=1
                                                                                                fi
                                                                                                MESSAGE="speed set to ${GREEN}${SPEEDVALUE}x${CYAN}"

                                                                                # duration
                                                                                elif [[ $MOD = "d" || $MOD = "duration" ]] ;
                                                                                        then    # if loop is enabled calculate the loop length 
                                                                                                if [[ $LOOPOPTION = "${GREEN}Full video${CYAN}" ]] ;
                                                                                                        # full video
                                                                                                        then    echo -e "The video duration is $DURATION_SEC seconds"
                                                                                                        # looping video
                                                                                                        else    LOOPVALUE_A_SEC=$(echo "$LOOPVALUE_A" | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                LOOPVALUE_B_SEC=$(echo "$LOOPVALUE_B" | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                echo -e "The length of your loop is ${GREEN)}$(echo "$LOOPVALUE_A_SEC $LOOPVALUE_B_SEC=" | awk '{print $2 - $1}')${CYAN}"
                                                                                                fi
                                                                                                read -p "set play duration in seconds: " DURATION_SEC
                                                                                                # empty argument - reset to full
                                                                                                if [[ -z $DURATION_SEC ]] ;
                                                                                                        then    DURATION_SEC=$(ffmpeg -i $MF 2>&1 | grep Duration | awk '{print $2}' | sed 's/,//g' | awk '{ split ( $1 , A , ":" ); split (A[3] , B, "." ); print  3600*A[1] + 60*A[2] + B[1] "." B[2] }')
                                                                                                                MESSAGE="Duration reset"
                                                                                                        else    MESSAGE="play duration set"
                                                                                                fi
                                                                                # errorhandling unknown input
                                                                                elif [[ $MOD = "c" || $MOD = "clear" || $MOD = "l" || $MOD = "list" || $MOD = "print" ]] ;
                                                                                        then    echo -e "\c"
                                                                                # unknown input
                                                                                else    MESSAGE="${RED}Error:${CYAN} unknown input >${RED}$MOD${CYAN}<"
                                                                                fi
                                                                        # end of video edit
                                                                        done
                                                                        # unknown edit
                                                                        if [[ $EDIT = "unknown" ]] ;
                                                                                then    echo -e "Unknown edit is a modified shell promt.\nuse 'h' option to see how to mark and handle files"
                                                                        fi
                                                                        while [[ $EDIT = "unknown" ]] ;
                                                                        do
                                                                                read -p " $2 $(echo -e '\n')→ " MOD
                                                                                if [[ $MOD = "h" || $MOD = "help" ]] ;
                                                                                        then    echo -e "general usage:
h       help            to print this message
b       back            to leave $EDIT edit
q       exit            to leave $EDIT edit and register edit
c       clear           clear terminal
l       list            lists all files in $SELECTION
 unknown specific:
cd      has been disabled
marking files is not needed.
i       identifies all files in ${YELLOW}selection${CYAN}"
                                                                                # back to RegisterEdit
                                                                                elif [[ $MOD = "b" || $MOD = "back" ]] ;
                                                                                        then    echo -e "${YELLOW}\c"
                                                                                                EDIT=
                                                                                # selection edit AND RegisterEdit
                                                                                elif [[ $MOD = "q" || $MOD = "exit" ]] ;
                                                                                        then    echo -e "${OFF}\c"
                                                                                                # delete /tmp/files
                                                                                                rm -f /tmp/wallset/selection*
                                                                                                rm -f /tmp/wallset/mark*
                                                                                                # Leaving edit
                                                                                                EDIT=
                                                                                                REGISTEREDIT=
                                                                                # clear
                                                                                elif [[ $MOD = "c" || $MOD = "clear" ]] ;
                                                                                        then    clear
                                                                                # list all files in selection
                                                                                elif [[ $MOD = "l" || $MOD = "list" ]] ;
                                                                                        then    # for video and gif option necessary to do it like this
                                                                                                echo -e "all files in selection $SELECTION\n$(basename -a $(cat /tmp/wallset/selection-${SELECTION}))"
                                                                                # disable cd
                                                                                elif [[ $(echo "$MOD" | head -c 2) = "cd" ]];
                                                                                        then    echo -e "cd has been disabled to make sure all files are in 'pwd'"
                                                                                # identify file with file
                                                                                elif [[ $MOD = "i" ]] ;
                                                                                        then    file $(basename -a $(cat /tmp/wallset/selection-unknown))
                                                                                # else execute entererd option in bash prompt
                                                                                else    $MOD || (clear ; echo -e "${RED}Error:${CYAN} unknown command '${RED}$MOD${CYAN}'")
                                                                                        echo -e "${CYAN}\c"
                                                                                fi
                                                                        done                                                                
                                                                else    echo -e "${RED}Error:${YELLOW} >${CYAN}$SELECTION${YELLOW}< is not an ${CYAN}selection${YELLOW}"
                                                        fi
                                        # Error - unkown option
                                        else    echo -e "${RED}Error:${OFF} unknown option >${RED}${ACTION}${YELLOW}<"
                                        fi
                                
                                done
                                exit
                fi
                # delete a register
                if [[ $2 = "rm" || $2 = "remove" || $2 = "delete" ]] ;
                        then    # empty $3 regfile-name
                                if [[ -z $3 ]] ;
                                        then    echo -e "${RED}Error:${OFF} empty argument. No register to delete provided"
                                                exit
                                        # confirmation
                                        else    echo -e "Do you really want to delete '${YELLOW}$3${OFF}' [y/N] ?"
                                                read CONFIRM
                                                if [[ $CONFIRM = "y" || $CONFIRM = "Y" || $CONFIRM = "yes" || $CONFIRM = "Yes" || $CONFIRM = "YES" ]] ; 
                                                        then    # check for bad filenames
                                                                if [[ $3 = "wallset.sh" || $3 = "defaultconfig" || $3 = "config" || $3 = "blackscreen.jpg" || $3 = "Log" ]] ;
                                                                        then    echo -e "${RED}Error:${OFF} Bad filename. the file '${BLUE}$3${OFF}' is used by wallset.sh and can not be deleted."
                                                                        else    echo -e "deleting ${YELLOW}$3${OFF}"
                                                                                rm $PLACE/$3 $PLACE/.${3}-m*
                                                                                # delete Line from config
                                                                                DELETELINE=$(grep -n REGFILE= $PLACE/config | grep $PLACE/$3 | sed 's/:/\n/g' | head -n 1)
                                                                                sed -i "${DELETELINE}d" $PLACE/config
                                                                fi
                                                        else    echo -e "Aborting"
                                                fi
                                                exit
                                fi
                fi
                # register does not exist
                echo -e "${RED}Error:${OFF} register '$2' does not exist" 
                exit
fi
# unknown input
echo -e "${RED}Error:${OFF} invalid option 'wallset >${RED}${1}${OFF}<'. Use '${BLUE}-h${OFF}' option for help"
exit



## end
####################################################


# helper:
if [[ $1 = "" || $1 = "" ]] ;
    then    exit #cmd
    else    exit #cmd
fi

####
arrangement for videoedit

file :          <file>                  selected Nr./Total
Zoom ON/OFF             loop: off/(start:       end:): Off(=0)
playback speed=X                Duration : in seconds / in minutes and seconds

<<comment
### used /tmp/files
/tmp/wallset/DURATION_x_ (1-6) for video length to sort all out

#/tmp/wallset/PROGRESS

comment