################################################################################
#                                                                              #
#                           Argoth's ZSH Environment                           #
#                                                                              #
################################################################################
#                                                                              #
# Name        : .zshrc                                                         #
#                                                                              #
# Description : ZSH Resource File                                              #
#                                                                              #
# Comments    : This file is sourced after the system resource files,          #
#               superceding them, only during interactive shells.  If portions #
#               of the environment are missing, it can attempt to retrieve     #
#               them from the internet.                                        #
#                                                                              #
# File Order  : /etc/zshenv       $HOME/.zshenv                                #
#               /etc/zprofile     $HOME/.zprofile    (Login Only)              #
#               /etc/zshrc        $HOME/.zshrc       (Interactive Only)        #
#               /etc/zlogin       $HOME/.zlogin      (Login Only)              #
#               $HOME/.zlogout    /etc/zlogout       (Login Only - Exit)       #
#                                                                              #
# Author      : Ryan T. Tennant (Argoth)                                       #
#                                                                              #
# Date        : 2010/12/23                                                     #
#                                                                              #
################################################################################

# Temporary hack
CURDIR=`pwd`
cd ${HOME}

# RUN CODE

# Keep zsh environment synchronized with devunix.org environment
NETCHECK="false"

# If NETCHECK="true", local changes will be lost!

# ZSH History
HISTSIZE=2500
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# Ignore duplicate lines in history
setopt HIST_IGNORE_DUPS

# Append history
setopt INC_APPEND_HISTORY

# Share history between screen sessions
setopt SHARE_HISTORY

# Ignores duplications in history between sessions
# setopt HIST_IGNORE_ALL_DUPS

# Ignores lines starting with spaces
setopt HIST_IGNORE_SPACE

# setopt HIST_NO_STORE

# Time of history and how long it ran 
setopt EXTENDED_HISTORY

setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS


# Some custom zsh specific keybindings
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

#key bindings

# Files involved in sychronization 
# .zshenv
# .zprofile
# .zshrc
# .zlogin
# .zlogout
# .vimrc
# .vim/colors/jellybeans.vim
# .vim/colors/oceandeep.vim

# Locally customizable files

# .ircname - Contains the name you wish to use on IRC
 
# Common Variables

UNAME=(`uname -srm`)
SYS=${UNAME[1]}
VER=${UNAME[2]}
ARCH=${UNAME[3]}

SHELLVER=(`echo $ZSH_VERSION | sed 's/\./\ /g'`)
ZSH_MAJOR=$SHELLVER[1]
ZSH_MINOR=$SHELLVER[2]
ZSH_CHNGE=$SHELLVER[3]

SHORTHOST=`echo ${HOST} | sed 's/\..*$//'`

NULL=">/dev/null 2>&1"
SUCCESS="&& echo [ OK ] || echo [ FAILED ]" 


eval which curl ${NULL} && XFERAGENT="`which curl` -O -m 20"
eval which wget ${NULL} && XFERAGENT="`which wget` -N --timeout=1"
    
# Global Functions

download() {

    SITE="www.devunix.org"
    
    DIR="shell_environment"

    LASTPWD=`pwd`
    cd `dirname ${1}`

    printf "Downloading %-50s" $1

    if [ -n "${XFERAGENT}" ]; then

        eval ${XFERAGENT} http://${SITE}/${DIR}/${1} ${NULL}
        RETURNVAL=$?

        eval test ${RETURNVAL} -eq 0 ${SUCCESS}

        cd ${LASTPWD}

        return $RETURNVAL

    else

        FILE=`basename "/${1}"`

        # Telnet Hacks (Slow)
        
        ( echo "GET /${DIR}/${1} HTTP/1.1"; \
          echo "Host: ${SITE}"; echo "" ; \
          sleep 1 ) | telnet ${SITE} 80 2>/dev/null | \
          sed -n '13,$p' >  ${FILE}.tmp
          
          # Return state with telnet ambiguous

          if [ -s ${FILE}.tmp ]; then

              mv ${FILE}.tmp ${FILE}

              printf "[ OK ]\n"

              cd ${LASTPWD}

              return 0
              
          else

              rm ${FILE}.tmp

              printf "[ FAILED ]\n"

              cd ${LASTPWD}

              return 1

          fi

    fi

    return 0
    
}

verify() {

    MASTER="${1}.cksum"
    LOCAL="${1}.cksum.local.$$"

    eval download ${MASTER} ${NULL} && LOCALONLY="false" || LOCALONLY="true"
    
    if [ ${LOCALONLY} = "false" ]; then

        ( cd `dirname $1` ; cksum `basename $1` | \
            awk '{printf "%s %s %s\n",$1,$2,$3}' > `basename ${LOCAL}` )

        eval cmp ${MASTER} ${LOCAL} ${NULL} && UPDATED="0" || UPDATED="1"
        

        if [ ${UPDATED} = "1" ]; then

            echo "File ${1} has been updated!"
            printf "    %20s %7s\n" "CHECKSUM" "SIZE"
            printf "    %-7s [ %10s %7s ]\n" \
                "Master" \
                `awk '{print $1" "$2}' ${MASTER}`
            printf "    %-7s [ %10s %7s ]\n" \
                "Local" \
                `awk '{print $1" "$2}' ${LOCAL}`

        fi

        rm ${LOCAL}
        
        return ${UPDATED}

    else

        # Assume files are all okay
       
        return 0

    fi

    return 1
    
}

coherency() {

    if [ "${NETCHECK}" = "true" ]; then

        if [ -f ${HOME}/${1} ]; then

            verify ${1} && return 0 || download ${1} && return 1 || return 0

        else

            download ${1} && return 1 || return 0

        fi

    fi

}

# Version Specific Options

if [ ${ZSH_MAJOR} -ge 4 ]; then

    # Autoloads

    autoload -U compinit
    autoload -U colors
    compinit -C -d $HOME/.zcompdump.${SHORTHOST}
    colors

    # Keybindings

    bindkey -e

    # Styles

    # Menus
    zstyle ':completion:*' menu yes select

    # Completion (SSH)
    zstyle ':completion:*:scp:*' group-order \
        users files all-files hosts-domain hosts-host hosts-ipaddr
    zstyle ':completion:*:(ssh|scp|ftp|ncftp):*:hosts-host' ignored patterns \
        '*.*' loopback localhost
    zstyle ':completion:*:(ssh|scp|ftp|ncftp):*:hosts-domain' ignored-patterns \
            '<->.<->.<->.<->' '^*.*' '*@*'
    zstyle ':completion:*:(ssh|scp|ftp|ncftp):*:hosts-ipaddr' ignored-patterns \
            '^<->.<->.<->.<->' '127.0.0.<->'
    zstyle -e ':completion:*:(ssh|scp|ftp|ncftp):*' hosts 'reply=(
            ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) \
                /dev/null)"}%%[# ]*}//,/ } )'
                
    # Completion (File Listing)
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    
    # Completion (Kill)
    zstyle ':completion:*:*:kill:*' menu yes select
    zstyle ':completion:*:kill:*' force-list always

    if [ "$SYS" = "SunOS" ]; then
        zstyle ':completion:*:*:kill:*:processes' command 'ps -efo pid,user,fname'
    else
        zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
    fi

    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

fi

# ZSH Environment sanity

coherency ".zshenv"   || ENVUPD="TRUE"
coherency ".zprofile" || ENVUPD="TRUE"
coherency ".zshrc"    || ENVUPD="TRUE"
coherency ".zlogin"   || ENVUPD="TRUE"
coherency ".zlogout"  || ENVUPD="TRUE"

if [ -n "${ENVUPD}" ]; then

    # Indicates a core ZSH file has been updated, so respawn to inherit new
    # environment

    if [ -f $HOME/.zcompdump.${SHORTHOST} ]; then
        rm $HOME/.zcompdump.${SHORTHOST}
    fi
    
    unset ENVUPD
    exec zsh

fi

# Terminal Preferences

validate_term() {

     return `TERM=$1 2>&1 | wc -w`
     
}

mktermdb() {

    case $1 in

        TERMINFO)

            eval which tic ${NULL} && TIC=`which tic` || TIC="false"

            printf "    Compiling %-8s database %-30s" $1 ""

            eval ${TIC} ${FILE} ${NULL}
            RETURNVAL=$?

            eval test ${RETURNVAL} -eq 0 ${SUCCESS}

            return $RETURNVAL

        ;;

        TERMCAP)

            eval which infotocap ${NULL} \
                && INFOTOCAP=`which infotocap` || INFOTOCAP="false"

            printf "    Compiling %-8s database %-30s" $1 ""

            eval ${INFOTOCAP} ${FILE} >${TERMCAP} 2>/dev/null
            RETURNVAL=$?

            eval test ${RETURNVAL} -eq 0 ${SUCCESS}

            return $RETURNVAL
    
        ;;

    esac

    return 1
}

# Capabilities Database

case "$SYS" in

    *BSD ) # TERMCAP based systems

        if [ -f $HOME/.termcap ]; then
            TERMCAP="$HOME/.termcap"
            export TERMCAP

        else

            touch $HOME/.termcap

            TERMCAP=$HOME/.termcap
            export TERMCAP
                
            FILE="terminfo.src"
            eval download ${FILE} || return 1

            eval mktermdb TERMCAP 2>/dev/null \
                || rm -f ${HOME}/.termcap && unset TERMCAP

            rm ${FILE}

        fi

        ;;

    * ) # TERMINFO based systems

        if [ -d $HOME/.terminfo ]; then

            TERMINFO="$HOME/.terminfo"
            export TERMINFO

        else

            mkdir $HOME/.terminfo

            TERMINFO=$HOME/.terminfo
            export TERMINFO
                
            FILE="terminfo.src"
            eval download ${FILE} || return 1

            eval mktermdb TERMINFO 2>/dev/null \
                || rm -rf ${HOME}/.terminfo && unset TERMINFO

	        rm ${FILE}
            
        fi

        ;;

esac

# Terminal Capabilities

case "$TERM" in

    xterm*|dtterm ) 

        # Assume modern X terminal with 256 color capability
        
        validate_term xterm-256color && TERM="xterm-256color"
        validate_term "$TERM" || TERM="xterm"

        # Automatically update xterm title with active command 

        if  [ "$ZSH_MAJOR" -ge 4 ]; then
            preexec () {print -Pn "\e]0;%m:%l    -   ${(qV)1}\a"}
            precmd () {print -Pn "\e]0;%m:%l    -    idle \a"}
        else
            preexec () {print -Pn "\e]0;%m:%l    -   ${*}\a"}
            precmd () {print -Pn "\e]0;%m:%l    -    idle \a"}
        fi

        ;;
    * ) 

        validate_term "$TERM" || TERM="vt100"

        ;;
esac


# Color Prompts

case "$TERM" in

        *256color) # Advanced
        
            if [ "$ZSH_MAJOR" -ge 4 -a \
                 "$ZSH_MINOR" -ge 3 -a \
                 "$ZSH_CHNGE" -ge 9 ]; then

                PROMPT="%103F%n%f@%103F%m%f : "
                RPROMPT=": %156F%~%f (%103F%?%f)"

            else

                PROMPT='%{[38;05;103m%}%n%{[38;05;255m%}@%{[38;05;103m%}%m%{[38;05;255m%} : '
                RPROMPT=': %{[38;05;156m%}%~%{[38;05;255m%} (%{[38;05;103m%}%?%{[38;05;255m%})'

            fi

            ;;

        xterm*) # Standard
           
            PROMPT="%{$fg[green]%}%n%{$fg[white]%}@%{$fg[green]%}%m%{$fg[white]%} : "
            RPROMPT=":%{$fg[cyan]%} %~ %{$fg[white]%}(%{$fg[green]%}%?%{$fg[white]%})"

            ;;

        *) # Basic

            PROMPT="%B%n%b@%B%m%b : "
            RPROMPT=": %B%~%b (%B%?%b)"

            ;;
esac

# Color GNU ls

eval ls --v $NULL && GNULS="true" || GNULS="false"

if [ "$GNULS" = "true" ]; then

    alias ls='ls -F --color=auto'
    
    # Get coreutils version
    
    COREUTILVER=`eval ls --v $NULL | head -1 | awk '{print $NF}' | cut -d. -f1`

    case "$TERM" in

        *256color) # LS_COLORS - 256 colors

            case "$COREUTILVER" in

                8) LS_COLORS="no=38;5;246:fi=38;5;246:rs=0:di=38;5;156:ln=38;5;255:mh=38;5;246:pi=38;5;229:so=38;5;229:do=38;5;229:bd=38;5;229:cd=38;5;229:or=38;5;160:mi=38;5;160:su=38;5;117:sg=38;5;117:ca=38;5;246:tw=38;5;156:ow=38;5;156:st=38;5;117:ex=38;5;246:"
                ;;

                6|7) LS_COLORS="no=38;5;246:fi=38;5;246:di=38;5;156:ln=38;5;255:pi=38;5;229:so=38;5;229:do=38;5;229:bd=38;5;229:cd=38;5;229:or=38;5;160:mi=38;5;160:su=38;5;117:sg=38;5;117:tw=38;5;156:ow=38;5;156:st=38;5;117:ex=38;5;246:"
                ;;

                *) LS_COLORS="no=38;5;250:fi=38;5;250:di=38;5;156:ln=38;5;117:pi=38;5;250:so=38;5;250:do=38;5;250:bd=38;5;250:cd=38;5;250:or=38;5;52:mi=38;5;52:ex=38;5;250:"
                ;;

            esac

            ;;

        *) #LS_COLORS
            
            case "$COREUTILVER" in

                8) LS_COLORS="no=00:fi=00:rs=0:di=00;36:ln=00;00:mh=00:pi=00;00:so=00;00:do=00;00:bd=00;00:cd=00;00:or=00;00:su=00;00:sg=00;00:ca=00;00:tw=00;00:ow=00;30:st=00;30:ex=00;00:"
                ;;

                *) LS_COLORS="no=00:fi=00:di=00;36:ln=00;00:pi=00;00:so=00;00:do=00;00:bd=00;00:cd=00;00:or=00;00:su=00;00:sg=00;00:tw=00;00:ow=00;00:st=00;00:ex=00;00:"
                ;;

            esac

         ;;

    esac

    export LS_COLORS

fi


# Color VIM environment 

eval which vim $NULL && VIM="true" || VIM="false"

if [ "$VIM" = "true" ]; then
    
    alias vi=`which vim`

    # Get VIM version
    # VIMVER=`vim --version 2>&1 | head -1 | awk '{print $5}'

    coherency ".vimrc"

    if [ ! -d $HOME/.vim/backup -o \
         ! -d $HOME/.vim/colors -o \
         ! -d $HOME/.vim/tmp -o \
         ! -d $HOME/.vim/plugin ]; then 

        mkdir -p $HOME/.vim/backup $HOME/.vim/colors $HOME/.vim/tmp \
                 $HOME/.vim/plugin
    fi

    coherency ".vim/colors/jellybeans.vim"

    coherency ".vim/colors/oceandeep.vim"

fi

# General Aliases

alias la='ls -a'
alias ll='ls -l'
alias ll='ls -la'
alias lsd='ls -d */'
alias xterm='xterm -bg black -fg white -fn nexus'

case "$SYS" in

    SunOS)

        alias eeprom="/usr/platform/${ARCH}/sbin/eeprom"
        alias prtdiag="/usr/platform/${ARCH}/sbin/prtdiag"
        alias ps='/usr/ucb/ps'
        alias se='/opt/RICHPse/bin/se'
        
        ;;

    Linux)  

        alias mailx='mail'
        eval which vim $NULL && alias vi=`which vim`

        ;;

    Darwin)

        alias top='top -ocpu -s 5 -n 15'
        alias nslookup='nslookup -sil'
        eval which vim $NULL && alias vi=`which vim`

        ;;

esac
    
# Miscellaneous Options

EDITOR=vi

if [ -f $HOME/.ircname ]; then
    IRCNAME=`cat .ircname`
else
    IRCNAME=""
fi

eval which less $NULL && PAGER=`which less` || PAGER=`which more`

# Display MOTD

## Solaris expects login shells to handle MOTD display

if [ "$SYS" = "SunOS" -a ! -f "$HOME/.hushlogin" ]; then
    cat /etc/motd
fi

# Exports

export EDITOR PAGER TERM IRCNAME

# Clear variables

unset ARCH COREUTILVER ENV FILE GNULS LOCAL LOCALONLY MASTER NETCHECK NULL \
      OLDPWD RETURNVAL SHELLVER SHORTHOST SITE SUCCESS SYS UNAME UPDATED URL \
      VER VIM XFERAGENT ZSH_MAJOR ZSH_MINOR ZSH_CHNGE

# Clear functions

unfunction download verify coherency validate_term mktermdb

# Clear Temporary Hack
cd ${CURDIR}
unset CURDIR

# END RUN CODE
