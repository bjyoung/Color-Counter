# Lua Coding Style Guide

Guide that describes code styling practices used in Pixel Counter.

## General Recommendation

When in doubt, follow existing code base conventions.

## Files

- Name of LUA, JSON files: kebab-case
- Name of README files: ALLCAPS
- Names of other file types and directories: Pascal Case, but spaces are allowed

## Functions

- Name using camelCase
- Modifiers, `function` keyword, name and parameters should be on the same line
- `end` keyword should be on its own line

```lua
function addValues(x, y)
    -- Code here
end
```

## Variables

- Name using camelCase

## Constants

- Variables and fields that can be made constants should always be constants
- Use constants instead of magic numbers
- Name with UPPERCASE_SNAKECASE

```lua
CONSTANT = 50
```

## Commenting

- Place comments on a separate line, not at the end of a line of code
- Begin comment with an uppercase letter
- Do not end comments with a period
- Insert one space between comment delimiter (--) and the comment

```lua
 -- This is an example comment
```

## Whitespace & Indentation

- Maximum of one statement per line
- Column limit: 150
- Indent by two spaces
- No tabs
- No line break before `then` keyword
- Always have a line break after `then` and `else` keywords
- Use a single blank line between consecutives functions and between functions and variables at the same level
- No consecutive or trailing whitespace
- No consecutive line breaks
- No blank lines at the start or end of a file

```lua
if true then
    -- Do stuff here
else
    -- Do stuff here
end
```

## Variable Scope

- Use local rather than globals whenever possible
- Always have global variables at the top of the script

## Top-Level Declarations

- File contents should serve one purpose
- Declarations that appear earlier in the file should help explain those farther down
- Declarations should follow some logical order (not chronological)
