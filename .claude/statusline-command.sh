#!/bin/zsh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
user=$(whoami)

# Check git status (catppuccin mocha: teal for clean, yellow for dirty)
git_branch=""
git_dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch="$branch"
        if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            git_dirty=" ✗"
        else
            git_dirty=" ✔"
        fi
    fi
fi

display_dir="${cwd/#$HOME/~}"

# Get context window information
used_percentage=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Powerline separator
SEP=$'\ue0b0'
GIT_ICON=$'\ue0a0'

# Catppuccin Mocha palette (24-bit ANSI)
# Base (dark bg):  #1e1e2e
# Surface0:        #313244
# Surface1:        #45475a
# Pink (user):     #f5c2e7
# Blue (dir):      #89b4fa
# Teal (git):      #94e2d5
# Yellow (dirty):  #f9e2af
# Mauve (model):   #cba6f7
# Overlay0 (text): #6c7086  (used as dark fg on colored bg)

BASE="\033[38;2;30;30;46m"          # #1e1e2e fg
SURF0_BG="\033[48;2;49;50;68m"      # #313244 bg
SURF1_BG="\033[48;2;69;71;90m"      # #45475a bg
PINK_FG="\033[38;2;245;194;231m"    # #f5c2e7
PINK_BG="\033[48;2;245;194;231m"    # #f5c2e7
BLUE_FG="\033[38;2;137;180;250m"    # #89b4fa
BLUE_BG="\033[48;2;137;180;250m"    # #89b4fa
TEAL_FG="\033[38;2;148;226;213m"    # #94e2d5
TEAL_BG="\033[48;2;148;226;213m"    # #94e2d5
YELLOW_FG="\033[38;2;249;226;175m"  # #f9e2af
MAUVE_FG="\033[38;2;203;166;247m"   # #cba6f7
MAUVE_BG="\033[48;2;203;166;247m"   # #cba6f7
DARK_FG="\033[38;2;30;30;46m"       # dark text for light backgrounds
RESET="\033[0m"

output=""

# Segment 1: username — pink text on surface0 bg
output+="${SURF0_BG}${PINK_FG} ${user} ${RESET}"

# Separator: surface0 -> blue
output+="${BLUE_BG}${BASE}${SEP}${RESET}"

# Segment 2: current directory — dark text on blue bg
output+="${BLUE_BG}${DARK_FG} ${display_dir} ${RESET}"

# Segment 3: git branch (if in git repo)
if [ -n "$git_branch" ]; then
    output+="${TEAL_BG}${BLUE_FG}${SEP}${RESET}"
    output+="${TEAL_BG}${DARK_FG} ${GIT_ICON} ${git_branch}${git_dirty} ${RESET}"
    output+="${SURF1_BG}${TEAL_FG}${SEP}${RESET}"
else
    output+="${SURF1_BG}${BLUE_FG}${SEP}${RESET}"
fi

# Segment 4: model name — mauve text on surface1 bg
output+="${SURF1_BG}${MAUVE_FG} ${model} ${RESET}"

# Segment 5: context usage (if available)
if [ -n "$used_percentage" ]; then
    total_tokens=$((total_input + total_output))
    if [ "$total_tokens" -ge 1000 ]; then
        token_display="$(( total_tokens / 1000 ))K"
    else
        token_display="$total_tokens"
    fi
    output+="${SURF0_BG}${MAUVE_FG}${SEP}${RESET}"
    output+="${SURF0_BG}${YELLOW_FG} ctx:${used_percentage}% ${token_display}tok ${RESET}"
    output+="${RESET}${SURF0_BG}${SEP}${RESET}"
else
    output+="${RESET}${SURF1_BG}${SEP}${RESET}"
fi

printf "%b" "$output"
