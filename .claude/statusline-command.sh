#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
user=$(whoami)
host=$(hostname -s)

# Check git status
git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch="$branch"
        # Check if repo is dirty
        if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
            git_dirty="±"
        fi
    fi
fi

display_dir="${cwd/#$HOME/~}"

# Get context window information
used_percentage=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Powerline separator characters
SEP=""
SEP_THIN=""

# Build the prompt in agnoster style with powerline separators
output=""

# Segment 1: User@Host (black text on cyan background)
output+="\033[48;5;31m\033[30m $user@$host \033[0m"

# Separator and Segment 2: Directory (white text on blue background)
output+="\033[38;5;31m\033[48;5;33m$SEP\033[0m"
output+="\033[48;5;33m\033[97m $display_dir \033[0m"

# Segment 3: Git branch (if in git repo)
if [ -n "$git_branch" ]; then
    output+="\033[38;5;33m\033[48;5;22m$SEP\033[0m"
    output+="\033[48;5;22m\033[97m \ue0a0 $git_branch$git_dirty \033[0m"
    output+="\033[38;5;22m\033[48;5;238m$SEP\033[0m"
else
    output+="\033[38;5;33m\033[48;5;238m$SEP\033[0m"
fi

# Segment 4: Model name (white text on dark gray background)
output+="\033[48;5;238m\033[97m $model \033[0m"

# Segment 5: Context info (if available)
if [ -n "$used_percentage" ]; then
    total_tokens=$((total_input + total_output))
    if [ $total_tokens -ge 1000 ]; then
        total_k=$((total_tokens / 1000))
        token_display="${total_k}K"
    else
        token_display="$total_tokens"
    fi
    output+="\033[38;5;238m\033[48;5;58m$SEP\033[0m"
    output+="\033[48;5;58m\033[97m ${used_percentage}% $SEP_THIN ${token_display} \033[0m"
    output+="\033[38;5;58m$SEP\033[0m"
else
    output+="\033[38;5;238m$SEP\033[0m"
fi

printf "%b" "$output"
