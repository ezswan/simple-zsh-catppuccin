# -*- mode: sh; -*-
# vim: set ft=sh :
# Catppuccin Mocha Theme v1.2.5
#
# https://github.com/dracula/dracula-theme
#
# Copyright 2019, All rights reserved
#
# Code licensed under the MIT license
# http://zenorocha.mit-license.org
#
# @author Zeno Rocha <hi@zenorocha.com>
# @maintainer Avalon Williams <avalonwilliams@protonmail.com>

# Initialization {{{
source ${0:A:h}/lib/async.zsh
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST
async_init
PROMPT=''
# }}}

# Options {{{
# Set to 0 to disable the git status
CATPPUCCIN_DISPLAY_GIT=${CATPPUCCIN_DISPLAY_GIT:-1}

# Set to 1 to show the date
CATPPUCCIN_DISPLAY_TIME=${CATPPUCCIN_DISPLAY_TIME:-0}

# Set to 1 to show the 'context' segment
CATPPUCCIN_DISPLAY_CONTEXT=${CATPPUCCIN_DISPLAY_CONTEXT:-0}

# Changes the arrow icon
CATPPUCCIN_ARROW_ICON=${CATPPUCCIN_ARROW_ICON:-➜ }

# Set to 1 to use a new line for commands
CATPPUCCIN_DISPLAY_NEW_LINE=${CATPPUCCIN_DISPLAY_NEW_LINE:-0}

# Set to 1 to show full path of current working directory
CATPPUCCIN_DISPLAY_FULL_CWD=${CATPPUCCIN_DISPLAY_FULL_CWD:-0}

# function to detect if git has support for --no-optional-locks
catppuccin_test_git_optional_lock() {
	local git_version=${DEBUG_OVERRIDE_V:-"$(git version | cut -d' ' -f3)"}
	local git_version="$(git version | cut -d' ' -f3)"
	# test for git versions < 2.14.0
	case "$git_version" in
		[0-1].*)
			echo 0
			return 1
			;;
		2.[0-9].*)
			echo 0
			return 1
			;;
		2.1[0-3].*)
			echo 0
			return 1
			;;
	esac

	# if version > 2.14.0 return true
	echo 1
}

# use --no-optional-locks flag on git
CATPPUCCIN_GIT_NOLOCK=${CATPPUCCIN_GIT_NOLOCK:-$(catppuccin_test_git_optional_lock)}

# time format string
if [[ -z "$CATPPUCCIN_TIME_FORMAT" ]]; then
	CATPPUCCIN_TIME_FORMAT="%-H:%M"
	# check if locale uses AM and PM
	if locale -ck LC_TIME 2>/dev/null | grep -q '^t_fmt="%r"$'; then
		CATPPUCCIN_TIME_FORMAT="%-I:%M%p"
	fi
fi
# }}}

# Status segment {{{
catppuccin_arrow() {
	if [[ "$1" = "start" ]] && (( ! CATPPUCCIN_DISPLAY_NEW_LINE )); then
		print -P "%F{#f5c2e7}$CATPPUCCIN_ARROW_ICON%f"  # Pink
	elif [[ "$1" = "end" ]] && (( CATPPUCCIN_DISPLAY_NEW_LINE )); then
		print -P "\n%F{#f5c2e7}$CATPPUCCIN_ARROW_ICON%f"  # Pink
	fi
}

# arrow is green if last command was successful, red if not, 
# turns yellow in vi command mode
PROMPT+='%(1V:%F{#f9e2af}:%(?:%F{#a6e3a1}:%F{#f38ba8}))%B$(catppuccin_arrow start)'  # Yellow, Green, Red
# }}}

# Time segment {{{
catppuccin_time_segment() {
	if (( CATPPUCCIN_DISPLAY_TIME )); then
		print -P "%D{$CATPPUCCIN_TIME_FORMAT} "
	fi
}

PROMPT+='%F{#94e2d5}%B$(catppuccin_time_segment)'  # Teal
# }}}

# User context segment {{{
catppuccin_context() {
	if (( CATPPUCCIN_DISPLAY_CONTEXT )); then
		if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]] || (( EUID == 0 )); then
			echo '%n@%m '
		else
			echo '%n '
		fi
	fi
}

PROMPT+='%F{#cba6f7}%B$(catppuccin_context)'  # Mauve
# }}}

# Directory segment {{{
catppuccin_directory() {
	if (( CATPPUCCIN_DISPLAY_FULL_CWD )); then
		print -P '%~ '
	else
		print -P '%c '
	fi
}

PROMPT+='%F{#89b4fa}%B$(catppuccin_directory)'  # Blue
# }}}

# Custom variable {{{
custom_variable_prompt() {
	[[ -z "$CATPPUCCIN_CUSTOM_VARIABLE" ]] && return
	echo "%F{#f9e2af}$CATPPUCCIN_CUSTOM_VARIABLE "  # Yellow
}

PROMPT+='$(custom_variable_prompt)'
# }}}

# Async git segment {{{
catppuccin_git_status() {
	(( ! CATPPUCCIN_DISPLAY_GIT )) && return
	cd "$1"
	
	local ref branch lockflag
	
	(( CATPPUCCIN_GIT_NOLOCK )) && lockflag="--no-optional-locks"

	ref=$(=git $lockflag symbolic-ref --quiet HEAD 2>/dev/null)

	case $? in
		0)   ;;
		128) return ;;
		*)   ref=$(=git $lockflag rev-parse --short HEAD 2>/dev/null) || return ;;
	esac

	branch=${ref#refs/heads/}
	
	if [[ -n $branch ]]; then
		echo -n "${ZSH_THEME_GIT_PROMPT_PREFIX}${branch}"

		local git_status icon
		git_status="$(LC_ALL=C =git $lockflag status 2>&1)"
		
		if [[ "$git_status" =~ 'new file:|deleted:|modified:|renamed:|Untracked files:' ]]; then
			echo -n "$ZSH_THEME_GIT_PROMPT_DIRTY"
		else
			echo -n "$ZSH_THEME_GIT_PROMPT_CLEAN"
		fi

		echo -n "$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}

catppuccin_git_callback() {
	CATPPUCCIN_GIT_STATUS="$3"
	zle && zle reset-prompt
	async_stop_worker catppuccin_git_worker catppuccin_git_status "$(pwd)"
}

catppuccin_git_async() {
	async_start_worker catppuccin_git_worker -n
	async_register_callback catppuccin_git_worker catppuccin_git_callback
	async_job catppuccin_git_worker catppuccin_git_status "$(pwd)"
}

add-zsh-hook precmd catppuccin_git_async

PROMPT+='$CATPPUCCIN_GIT_STATUS'

ZSH_THEME_GIT_PROMPT_CLEAN=") %F{#a6e3a1}%B✔ "  # Green
ZSH_THEME_GIT_PROMPT_DIRTY=") %F{#f9e2af}%B✗ "  # Yellow
ZSH_THEME_GIT_PROMPT_PREFIX="%F{#f5c2e7}%B("  # Pink
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
# }}}

# Linebreak {{{
PROMPT+='%(1V:%F{#f9e2af}:%(?:%F{#a6e3a1}:%F{#f38ba8}))%B$(catppuccin_arrow end)'  # Yellow, Green, Red
# }}}

# define widget without clobbering old definitions
catppuccin_defwidget() {
	local fname=catppuccin-wrap-$1
	local prev=($(zle -l -L "$1"))
	local oldfn=${prev[4]:-$1}

	# if no existing zle functions, just define it normally
	if [[ -z "$prev" ]]; then
		zle -N $1 $2
		return
	fi

	# if already defined, return
	[[ "${prev[4]}" = $fname ]] && return
	
	oldfn=${prev[4]:-$1}

	zle -N catppuccin-old-$oldfn $oldfn

	eval "$fname() { $2 \"\$@\"; zle catppuccin-old-$oldfn -- \"\$@\"; }"

	zle -N $1 $fname
}

# ensure vi mode is handled by prompt
catppuccin_zle_update() {
	if [[ $KEYMAP = vicmd ]]; then
		psvar[1]=vicmd
	else
		psvar[1]=''
	fi

	zle reset-prompt
	zle -R
}

catppuccin_defwidget zle-line-init catppuccin_zle_update
catppuccin_defwidget zle-keymap-select catppuccin_zle_update

# Ensure effects are reset
PROMPT+='%f%b'