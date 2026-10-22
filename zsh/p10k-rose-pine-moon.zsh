# Rosé Pine Moon colors for Powerlevel10k, https://rosepinetheme.com/palette
# Sourced after ~/.p10k.zsh so `p10k configure` can regenerate that file without losing these.
# Segments not listed here use ANSI colors, which Ghostty's Rose Pine Moon theme already maps.

() {
  local base='#232136' overlay='#393552' muted='#6e6a86' subtle='#908caa' text='#e0def4'
  local love='#eb6f92' gold='#f6c177' rose='#ea9a97' pine='#3e8fb0' foam='#9ccfd8' iris='#c4a7e7'
  local hl_high='#56526e'

  # Left frame
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{$muted}╭─"
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX="%F{$muted}├─"
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{$muted}╰─"
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=$muted

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$base
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$iris

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$foam
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$love

  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$foam
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$base
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$hl_high
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$base

  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$rose
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$gold
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$iris
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$love
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$muted

  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_FOREGROUND=$foam
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_BACKGROUND=$overlay
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_FOREGROUND=$base
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_BACKGROUND=$love

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$base
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$gold

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$foam
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$overlay

  typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=$gold
  typeset -g POWERLEVEL9K_DIRENV_BACKGROUND=$overlay

  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$subtle
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=$overlay
}

(( ! $+functions[p10k] )) || p10k reload
