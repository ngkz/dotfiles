# abbreviation expansion
# needs extended_glob on
# https://web.archive.org/web/20180329223229/https://zshwiki.org/home/examples/zleiab for details
declare -A abbreviations

function magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[.\-+:|_a-zA-Z0-9]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    # also do history expansion on space
    zle magic-space
}

function no-magic-abbrev-expand() {
    LBUFFER+=' '
}

function help-magic-abbrev() {
  zle -M "$(print "Available abbreviations for expansion:"; print -a -C 2 ${(kv)abbreviations})"
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
zle -N help-magic-abbrev

bindkey            " "   magic-abbrev-expand     # perform abbreviation expansion
bindkey            "^x " no-magic-abbrev-expand
bindkey -M isearch " "   self-insert
bindkey            "^xb" help-magic-abbrev       # display list of abbreviations that would expand
