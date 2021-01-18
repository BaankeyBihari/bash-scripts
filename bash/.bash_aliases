# Following aliases will be available only in interactive mode
if [[ $- == *"i"* ]]; then
    # enable color support of ls and also add handy aliases
    # Sourced from https://tldp.org/LDP/abs/html/sample-bashrc.html
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias dir='dir --color=auto'
        alias vdir='vdir --color=auto'

        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
    #-------------------------------------------------------------
    # The 'ls' family (this assumes you use a recent GNU ls).
    #-------------------------------------------------------------
    # Add human-readable sizes by default on 'ls':
    alias ls='ls -h'
    alias lx='ls -lXB'  #  Sort by extension.
    alias lk='ls -lSr'  #  Sort by size, biggest last.
    alias lt='ls -ltr'  #  Sort by date, most recent last.
    alias lc='ls -ltcr' #  Sort by/show change time,most recent last.
    alias lu='ls -ltur' #  Sort by/show access time,most recent last.

    # The ubiquitous 'll': directories first, with alphanumeric sorting:
    alias ll="ls -lv --group-directories-first"
    alias lm='ll |more'     #  Pipe through 'more'
    alias lr='ll -R'        #  Recursive ls.
    alias la='ll -A'        #  Show hidden files.
    alias tree='tree -Csuh' #  Nice alternative to 'recursive ls' ...
    # Pretty-print of some PATH variables:
    alias path='echo -e ${PATH//:/\\n}'
    alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
    alias du='du -kh' # Makes a more readable output.
    alias df='df -kTh'
fi

# Following aliases are available even in non interactive shells

# SCRIPT ALIASES BEGIN
alias ii="/home/sudhan/bin/scripts/ii.sh"
alias test="/home/sudhan/bin/scripts/test.sh"
alias repeats="/home/sudhan/bin/scripts/repeats.sh"
alias iq="/home/sudhan/bin/scripts/iq.sh"
alias pp="/home/sudhan/bin/scripts/pp.sh"
# SCRIPT ALIASES END
