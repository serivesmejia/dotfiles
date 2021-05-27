#!/bin/bash

# disabling weird middle button behavior
I=0

while :
do
    I=I+1

    TOUCHPAD_ID=`xinput &> /dev/null | grep -i Touchpad | awk '{print $"$I"}' | sed 's/id=//g'`
    MIDDLE_BUTTON_ID=`xinput --list-props $TOUCHPAD_ID &> /dev/null | grep -i Middle | grep -vi Default | sed 's/[(|):]//g' | awk '{print $5}'` &> /dev/null
    OUTPUT=$(xinput --set-prop $TOUCHPAD_ID $MIDDLE_BUTTON_ID 1 &> /dev/null)

    if [[ "$OUTPUT" != *"unable"* ]]; then
        break
    fi
done

export PATH=$PATH:$HOME/.emacs.d/bin/:$HOME/.local/bin

alias emc='emacsclient -c'
alias emckill='emacsclient -e "(kill-emacs)"'
alias emcstart='emacs --daemon'
alias emcrestart='doom sync;emckill;emcstart'

alias trim='sudo fstrim -v ~/.'
