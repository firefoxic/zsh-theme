# oh-my-zsh firefoxic Theme

### Node.js

ZSH_THEME_NODE_PROMPT_PREFIX="%B⬡%b "

# get the node-controlled node.js version
function node_prompt_info () {
	which node &>/dev/null || return
	local node_prompt=${$(node -v)#v}
	echo "[${ZSH_THEME_NODE_PROMPT_PREFIX}${node_prompt:gs/%/%%}]"
}

### Git [±main ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="(%{$fg_bold[blue]%}✹%{$reset_color%})"

firefoxic_git_info () {
	local ref
	ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	echo "${ref#refs/heads/}"
}

firefoxic_git_status () {
	local result gitstatus
	gitstatus="$(command git status --porcelain -b 2>/dev/null)"

	# check status of files
	local gitfiles="$(tail -n +2 <<< "$gitstatus")"
	if [[ -n "$gitfiles" ]]; then
		if [[ "$gitfiles" =~ $'(^|\n)[AMRD]. ' ]]; then
			result+="$ZSH_THEME_GIT_PROMPT_STAGED"
		fi
		if [[ "$gitfiles" =~ $'(^|\n).[MTD] ' ]]; then
			result+="$ZSH_THEME_GIT_PROMPT_UNSTAGED"
		fi
		if [[ "$gitfiles" =~ $'(^|\n)\\?\\? ' ]]; then
			result+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
		fi
		if [[ "$gitfiles" =~ $'(^|\n)UU ' ]]; then
			result+="$ZSH_THEME_GIT_PROMPT_UNMERGED"
		fi
	else
		result+="$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi

	# check status of local repository
	local gitbranch="$(head -n 1 <<< "$gitstatus")"
	if [[ "$gitbranch" =~ '^## .*ahead' ]]; then
		result+="$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
	if [[ "$gitbranch" =~ '^## .*behind' ]]; then
		result+="$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
	if [[ "$gitbranch" =~ '^## .*diverged' ]]; then
		result+="$ZSH_THEME_GIT_PROMPT_DIVERGED"
	fi

	# check if there are stashed changes
	if command git rev-parse --verify refs/stash &> /dev/null; then
		result+="$ZSH_THEME_GIT_PROMPT_STASHED"
	fi

	echo $result
}

firefoxic_git_prompt () {
	# ignore non git folders and hidden repos (adapted from lib/git.zsh)
	if ! command git rev-parse --git-dir &> /dev/null || [[ "$(command git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
		return
	fi

	# check git information
	local gitinfo=$(firefoxic_git_info)
	if [[ -z "$gitinfo" ]]; then
		return
	fi

	# quote % in git information
	local output="${gitinfo:gs/%/%%}"

	# check git status
	local gitstatus=$(firefoxic_git_status)
	if [[ -n "$gitstatus" ]]; then
		output+=" $gitstatus"
	fi

	echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${output}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

if [[ $EUID -eq 0 ]]; then
	_LIBERTY="%{$fg[red]%}#"
else
	_LIBERTY="%{$fg[green]%}$"
fi
_LIBERTY="$_LIBERTY%{$reset_color%}"

setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(firefoxic_git_prompt)$(node_prompt_info)'

autoload -U add-zsh-hook
