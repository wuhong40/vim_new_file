"command! Dbg call <SID>dbg()
"
function! s:dbg()
    "let lines=["#endif  /* @FILE_NAME_UPPER@_H_@YEAR@@MONTH@@DAY@@HOUR@@MIN@ */"]
    "call s:replace_lines(lines)
    call s:create_new_file("h")
endfunction
let g:wh_create_new_file_class="common"

function! s:is_new_file()
    let line_cnt = line("w$")
    let i = 1
    while i <= line_cnt
        let line = getline(i)
        if line !~ '^\s*$'
            return 0
        endif
        let i += 1
    endwhile

    return 1
endfunction

function! s:create_new_file(filetype)
    let lines = []
    if s:is_new_file()
        let lines = s:get_lines_after_replace(a:filetype, g:wh_create_new_file_class)

        "find insert place
        let pos = s:find_insert_position(lines)
        "echo pos

        let line_idx = 0
        for line in lines
            call append(line_idx, lines[line_idx])
            let line_idx += 1
        endfor

        call cursor(pos)
    endif
endfunction

function! s:get_lines_after_replace(filetype, class)
    let temp_file_path=g:dir_template . a:class."/".a:filetype.".txt"

    if filereadable(temp_file_path)
        let lines = readfile(temp_file_path)
        return s:replace_lines(lines)
    endif

    return []
endfunction

function! s:replace_lines(lines)

    "Replace file name
    call s:replace_str("@FILE_NAME@", s:get_file_name()  , a:lines)
    call s:replace_str("@FILE_BASE_NAME@", s:get_file_base_name()  , a:lines)
    call s:replace_str("@FILE_PATH@", s:get_file_path()  , a:lines)
    call s:replace_str("@FILE_NAME_UPPER@", toupper(s:get_file_name())  , a:lines)
    call s:replace_str("@FILE_BASE_NAME_UPPER@", toupper(s:get_file_base_name())  , a:lines)

    " Replace datetime
    call s:replace_str("@YEAR@"  , s:get_year()  , a:lines)
    call s:replace_str("@MONTH@" , s:get_month() , a:lines)
    call s:replace_str("@DAY@"   , s:get_day()   , a:lines)
    call s:replace_str("@HOUR@"  , s:get_hour()  , a:lines)
    call s:replace_str("@MIN@"   , s:get_min()   , a:lines)
    call s:replace_str("@SEC@"   , s:get_sec()   , a:lines)

    call s:replace_str("@DATE@"     , s:get_date()     , a:lines)
    call s:replace_str("@TIME@"     , s:get_time()     , a:lines)
    call s:replace_str("@DATETIME@" , s:get_datetime() , a:lines)

    " Replace Author Info
    call s:replace_str("@AUTHOR@", g:author_name, a:lines)
    call s:replace_str("@EMAIL@", g:author_email, a:lines)

    return a:lines
endfunction

function! s:get_file_name()
    return fnamemodify(bufname("%"), ":t")
endfunction

function! s:get_file_path()
    return fnamemodify(bufname("%"), ":p")
endfunction

function! s:get_file_base_name()
    return fnamemodify(bufname("%"), ":t:r")
endfunction

function! s:get_year()
    return strftime("%Y")
endfunction

function! s:get_month()
    return strftime("%m")
endfunction

function! s:get_day()
    return strftime("%d")
endfunction

function! s:get_date()
    return strftime("%Y-%m-%d")
endfunction

function! s:get_time()
    return strftime("%H:%M:%S")
endfunction

function! s:get_datetime()
    return strftime("%Y-%m-%d %H:%M:%S")
endfunction

function! s:get_hour()
    return strftime("%H")
endfunction

function! s:get_min()
    return strftime("%M")
endfunction

function! s:get_sec()
    return strftime("%S")
endfunction

function! s:replace_str(oldstr, newstring, lines)
    let i   = 0
    let len = len(a:lines)
    while i < len
        let line = a:lines[i]
        if line =~# a:oldstr
            let line = substitute(line, a:oldstr, a:newstring, "g")
            let a:lines[i] = line
        endif
        let i = i + 1
    endwhile
endfunction

function! s:find_insert_position(lines)
    let pos = [0, 0]
    let i   = 0
    let len = len(a:lines)
    let insert_str = "@INSERT@"

    while i < len
        let line = a:lines[i]
        "echo line."___".insert_str
        if line =~# insert_str
            let pos[0] = i + 1
            let pos[1] = match(line, insert_str)
            "echo pos
            let line = substitute(line, insert_str, "", "g")
            let a:lines[i] = line
            break
        endif
        let i = i + 1
    endwhile

    return pos
endfunction

augroup CreateNewFile
    autocmd CreateNewFile BufNewFile,BufRead *.h call <SID>create_new_file("h")
    autocmd CreateNewFile BufNewFile,BufRead *.hpp call <SID>create_new_file("hpp")
    autocmd CreateNewFile BufNewFile,BufRead *.c call <SID>create_new_file("c")
    autocmd CreateNewFile BufNewFile,BufRead *.cpp call <SID>create_new_file("cpp")
    autocmd CreateNewFile BufNewFile,BufRead *.go call <SID>create_new_file("go")
    autocmd CreateNewFile BufNewFile,BufRead *.py call <SID>create_new_file("py")
    autocmd CreateNewFile BufNewFile,BufRead *.html,*.htm   call <SID>create_new_file("html")
    autocmd CreateNewFile BufNewFile,BufRead *.js  call <SID>create_new_file("js")
    autocmd CreateNewFile BufNewFile,BufRead *.css call <SID>create_new_file("css")
    autocmd CreateNewFile BufNewFile,BufRead *.sh  call <SID>create_new_file("sh")
augroup END

