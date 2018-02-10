# This script is about some introduction about regex in julia

z = "node87"
x = r"^\s*(?:#|$)"
typeof(x)

ismatch(x,"not a comment")

m = match(r"[0-9]", z)
z[5:end]


# search
search("foobarbaz", 'b')    # 4
# search with offset
search("foobarbaz", 'b', 4) # 4
search("foobarbaz", 'b', 5) # 7
# reverse search
rsearch("foobarbaz", 'b')   # 7


# length in characters
length("foo")               # 3
length("╯°□°)╯︵ ┻━┻")      # 11
# length in bytes. Differs from length for unicode characters
endof("foo")                # 3
endof("╯°□°)╯︵ ┻━┻")       # 25

a = "foo"
b = "bar"
z = "baz"
string(a, b, z) # "foobarbaz"
"$a$b$c"        # "foobarbaz"
"\$a"           # "\$a"

# Reversse a string
reverse("What happens if I reverse this?")                 # "?siht esrever I fi sneppah tahW"

#Strip whitespace
s = "  foo  \n " # "  foo  \n "
lstrip(s)       # "foo  \n"
strip(s)        # "foo"
rstrip(s)       # "  foo"
chomp(s)        # "  foo  "

#--- Regex
foo_star = Regex("foo.*")
ismatch(foo_star, "foo") # true
ismatch(foo_star, "bar") # false
# the r_str(s) macro is defined as Regex(s)
fs = r"foo.*"
ismatch(fs, "foo")       # true
ismatch(fs, "bar")       # false

fbb = r"(foo)(bar)?(baz|zab)" # r"(foo)(bar)?(baz|zab)"
match(fbb, "foo")        # nothing
m = match(fbb, "foobaz") # RegexMatch("foobaz", 1="foo", 2=nothing, 3="baz")
m.captures               # ["foo", nothing, "baz"]
m.offsets                # [1, 0, 4]
# TODO: case sensitive matches, greedy vs. non-greedy, etc.
