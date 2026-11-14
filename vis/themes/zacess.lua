-- Zacess High Contrast for vis.
-- Uses the terminal's ANSI names, so colors come straight from the Ghostty palette
-- (exact hex, no 256-color approximation) and the background stays transparent.
local lexers = vis.lexers

lexers.STYLE_DEFAULT        = 'back:default,fore:default'
lexers.STYLE_NOTHING        = ''
lexers.STYLE_ATTRIBUTE      = 'fore:blue'
lexers.STYLE_CLASS          = 'fore:yellow'
lexers.STYLE_COMMENT        = 'fore:black,italics'      -- ANSI black is #b3b3b3 here
lexers.STYLE_CONSTANT       = 'fore:magenta'
lexers.STYLE_DEFINITION     = 'fore:blue'
lexers.STYLE_ERROR          = 'fore:red,bold'
lexers.STYLE_FUNCTION       = 'fore:blue'
lexers.STYLE_HEADING        = 'fore:yellow,bold'
lexers.STYLE_KEYWORD        = 'fore:red,bold'
lexers.STYLE_LABEL          = 'fore:yellow'
lexers.STYLE_NUMBER         = 'fore:magenta'
lexers.STYLE_OPERATOR       = 'fore:red'
lexers.STYLE_REGEX          = 'fore:cyan'
lexers.STYLE_STRING         = 'fore:green'
lexers.STYLE_PREPROCESSOR   = 'fore:red'
lexers.STYLE_TAG            = 'fore:red'
lexers.STYLE_TYPE           = 'fore:yellow'
lexers.STYLE_VARIABLE       = 'fore:default'
lexers.STYLE_WHITESPACE     = ''
lexers.STYLE_EMBEDDED       = 'fore:cyan'
lexers.STYLE_IDENTIFIER     = ''

-- UI
lexers.STYLE_LINENUMBER        = 'fore:black'
lexers.STYLE_LINENUMBER_CURSOR = 'fore:yellow,bold'
lexers.STYLE_CURSOR            = 'reverse'
lexers.STYLE_CURSOR_PRIMARY    = 'back:yellow,fore:#000000'
lexers.STYLE_CURSOR_LINE       = 'underlined'
lexers.STYLE_COLOR_COLUMN      = 'back:black'
lexers.STYLE_SELECTION         = 'back:blue,fore:#000000'
lexers.STYLE_STATUS            = 'fore:black'
lexers.STYLE_STATUS_FOCUSED    = 'back:yellow,fore:#000000,bold'
lexers.STYLE_SEPARATOR         = 'fore:black'
lexers.STYLE_INFO              = 'fore:yellow,bold'
lexers.STYLE_EOF               = ''

-- Diff / markup
lexers.STYLE_ADDITION   = 'fore:green'
lexers.STYLE_DELETION   = 'fore:red'
lexers.STYLE_CHANGE     = 'fore:yellow'
lexers.STYLE_LINK       = 'fore:blue,underlined'
lexers.STYLE_LIST       = 'fore:yellow'
lexers.STYLE_BOLD       = 'bold'
lexers.STYLE_ITALIC     = 'italics'
lexers.STYLE_PROPERTY   = lexers.STYLE_ATTRIBUTE
