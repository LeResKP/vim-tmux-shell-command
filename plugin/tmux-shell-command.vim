if exists("g:loaded_tmux_shell_command")
    finish
endif

let g:loaded_tmux_shell_command = 1


function! s:GetTmuxTarget()
    if exists("g:tmux_shell_command_target")
        return g:tmux_shell_command_target
    endif

    if $TMUX == ''
        return ''
    endif

    let session=system("tmux display-message -p '#S'")
    let window=system("tmux list-windows | grep '(active)$' | cut -f 1 -d ':'")
    let panes=system("tmux list-pane | grep -v '(active)$' | cut -f 1 -d ':'")

    " We get the first available pane in this window
    return session[0].':'.window[0].'.'.panes[0]
endfunction

function! RunTmuxShellCommand(cmd)

    let target = s:GetTmuxTarget()
    if target == ''
        echohl ErrorMsg | echo 'No target available. Are you in a tmux session?' | echohl None
        return
    endif

    execute 'silent !tmux send-keys -t '.target." c-l"
    execute 'silent !tmux send-keys -t '.target." '".a:cmd."' ENTER"
    redraw!
endfunction

command! -complete=shellcmd -nargs=+ TmuxShell call RunTmuxShellCommand(<q-args>)
ca tsh TmuxShell
