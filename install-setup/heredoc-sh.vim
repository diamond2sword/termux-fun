
function! Main()
	syntax cluster shHeredocHL contains=@sh

	let g:heredocStartPattern = '<<-\?\s*\(["\x27]\)\(\(\w\+\)EOF\)\1\s*'
	let g:previousDefinedHeredocFiletype = v:null
	let g:neededHeredocFiletypeList = ['sh', 'zsh', 'bash']

	for filetype in g:neededHeredocFiletypeList
		call DefineHeredocSyntaxRegionFor(filetype)
	endfor

	nnoremap G :call UpdateCursorHeredocSyntaxRegion()<CR>
endfunction

function! UpdateCursorHeredocSyntaxRegion()
	let [l:heredocStartRow, _] = searchpos(g:heredocStartPattern, 'zbnW')
	let l:heredocStartString = getline(l:heredocStartRow)
	let l:heredocStartMatchList = matchlist(l:heredocStartString, g:heredocStartPattern)
	if len(l:heredocStartMatchList) == 0
		return v:null
	endif
	let l:filetype = tolower(l:heredocStartMatchList[3])

	if count(g:neededHeredocFiletypeList, l:filetype) != 0
		return v:null
	endif

	if l:filetype == g:previousDefinedHeredocFiletype
		return v:null
	endif

	let l:syntaxPath = 'syntax/' . l:filetype . '.vim'
	if findfile(l:syntaxPath, &runtimepath) == ""
		return v:null
	endif
	
	if g:previousDefinedHeredocFiletype == v:null
		call DefineHeredocSyntaxRegionFor(l:filetype)
		let g:previousDefinedHeredocFiletype = l:filetype
		return v:null
	endif

	let l:previousRegion = 'heredoc' . g:previousDefinedHeredocFiletype
	if hlexists(l:previousRegion) 
		execute 'syntax clear ' . l:previousRegion
		let g:previousDefinedHeredocFiletype = v:null
		return v:null
	endif

	call DefineHeredocSyntaxRegionFor(l:filetype)
	let g:previousDefinedHeredocFiletype = l:filetype
endfunction

function! DefineHeredocSyntaxRegionFor(filetype)
	let l:bcs = b:current_syntax
	unlet b:current_syntax
	execute 'silent! syntax include @' . a:filetype . ' syntax/' . a:filetype . '.vim'
	let b:current_syntax = l:bcs

	let l:region = 'heredoc' . a:filetype
	let l:delimiter = toupper(a:filetype)
	let l:start_pattern = '/<<-\?\s*\([\x27"]\)' . l:delimiter . 'EOF\1\s*/'
	let l:end_pattern = '/^' . l:delimiter . 'EOF$/'
	execute 'syntax region ' . l:region . 
		\ ' matchgroup=Snip' .
		\ ' start=' . l:start_pattern . 
		\ ' end=' . l:end_pattern .
		\ ' containedin=@sh,@shHereDocHL contains=@' . a:filetype
	execute 'syntax cluster shHeredocHL add=' . l:region
endfunction

call Main()
