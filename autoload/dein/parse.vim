"=============================================================================
" FILE: parse.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:git = dein#types#git#define()

function! dein#parse#_init(repo, options) abort "{{{
  let plugin = s:git.init(a:repo, a:options)
  let plugin.repo = a:repo
  return extend(plugin, a:options)
endfunction"}}}
function! dein#parse#_dict(plugin) abort "{{{
  let plugin = {
        \ 'type': 'none',
        \ 'uri': '',
        \ 'rev': '',
        \ 'rtp': '',
        \ 'if': '',
        \ 'sourced': 0,
        \ 'local': 0,
        \ 'base': dein#_get_base_path() . '/repos',
        \ 'frozen': 0,
        \ 'depends': [],
        \ 'hooks': {},
        \ 'dummy_commands': [],
        \ 'dummy_mappings': [],
        \ 'on_i': 0,
        \ 'on_ft': [],
        \ 'on_cmd': [],
        \ 'on_func': [],
        \ 'on_map': [],
        \ 'on_unite': [],
        \ 'on_path': [],
        \ 'on_source': [],
        \ 'pre_cmd': [],
        \ 'pre_func': [],
        \ }

  call extend(plugin, a:plugin)

  if !has_key(plugin, 'name')
    let plugin.name = dein#parse#_name_conversion(plugin.repo)
  endif

  if !has_key(plugin, 'normalized_name')
    let plugin.normalized_name = substitute(
          \ fnamemodify(plugin.name, ':r'),
          \ '\c^n\?vim[_-]\|[_-]n\?vim$', '', 'g')
  endif

  if !has_key(plugin, 'directory')
    let plugin.directory = plugin.name
  endif

  if plugin.rev != ''
    let plugin.directory .= '_' . substitute(plugin.rev,
          \ '[^[:alnum:]_-]', '_', 'g')
  endif

  if plugin.base[0:] == '~'
    let plugin.base = dein#_expand(plugin.base)
  endif
  let plugin.base = dein#_chomp(plugin.base)

  if !has_key(plugin, 'path')
    let plugin.path = plugin.base.'/'.plugin.directory
  endif

  " Check relative path.
  if (!has_key(a:plugin, 'rtp') || a:plugin.rtp != '')
        \ && plugin.rtp !~ '^\%([~/]\|\a\+:\)'
    let plugin.rtp = plugin.path.'/'.plugin.rtp
  endif
  if plugin.rtp[0:] == '~'
    let plugin.rtp = dein#_expand(plugin.rtp)
  endif
  let plugin.rtp = dein#_chomp(plugin.rtp)

  if !has_key(plugin, 'augroup')
    let plugin.augroup = plugin.normalized_name
  endif

  " Set lazy flag
  if !has_key(a:plugin, 'lazy')
    let plugin.lazy = plugin.on_i
          \ || !empty(plugin.on_ft)     || !empty(plugin.on_cmd)
          \ || !empty(plugin.on_func)   || !empty(plugin.on_map)
          \ || !empty(plugin.on_unite)  || !empty(plugin.on_path)
          \ || !empty(plugin.on_source)
  endif

  return plugin
endfunction"}}}
function! dein#parse#_list(plugins) abort "{{{
  return map(copy(a:plugins), 'dein#parse#_dict(v:val)')
endfunction"}}}

function! dein#parse#_name_conversion(path) abort "{{{
  return fnamemodify(get(split(a:path, ':'), -1, ''),
        \ ':s?/$??:t:s?\c\.git\s*$??')
endfunction"}}}

" vim: foldmethod=marker
