-- This is my first lua file!
--[[
    While using lua to configure tools in the past,
    I've never actually used lua for scripting. Neat!
--]]

---------------------------------------------
-- VARIABLES
---------------------------------------------

num = 42 -- All numbers are doubles and this one is the answer to the universe.
-- 64bit doubles have 52 bits for storing exact int values;
-- precision is not a problem for ints that need < 52 bits.

str1 = 'Derek'
str2 = "Jess"
str3 = [[
    Multiline string notation is super weird!!!
]]

str3 = nil -- now str3 is undefined

while num < 50 do
    -- blocks are similar to bash with do/end
    num = num + 1 -- reassignment using "self" similar to python but no ++ or += operators
end

if num > 40 then
    print('over 40')
elseif str1 ~= 'Derek' then
    -- FUCK THIS! NOT EQUALS is ~= instead of !=... fucking weird
    -- EQUALS is still == like python, so we got that going for us
    io.write('not over 40\n') -- Kinda the same as print. Defaults to stdout.
else
    -- VARIABLES ARE GLOBAL BY DEFAULT!!! WTF?!?!
    thisIsGlobal = 'wtf'

    -- Do locals like this:
    local line = io.read() -- reads stdin

    -- String concat is weird as fuck
    print('Winter is cumming, ' .. line) -- `..` is concat for strings... actually kinda makes sense considering elipsis'.
end

-- Lua is very forgiving (but a little dangerous)
-- because undefined variables just return nil... i.e. this doesn't error out:
foo = someUndefinedVariable -- foo = nil

boolsAreEasy = true

if boolsAreEasy then print('Bools are easy, dumbass.') end -- so are oneline ifs!

-- 'or' and 'and' operators are short-circuited
ans = not boolsAreEasy and 'yes' or 'no' --> 'no'... double negatives... giggity

-- ranged for loops!
derekSum = 0
for i = 1, 100 do -- range includes both ends unline all other languages :facepalm:
    derekSum = derekSum + 1
end

-- Count down is interesting...
-- "100, 1, -1" <-- count down using "comma -1" is somewhat intuitive
jessSum = 0
for j = 100, 1, -1 do jessSum = jessSum + j end

-- Rnage is `geing, end[, step]`

-- until (as opposed to while) loops are neat and easier to read than pythonic until loops!!!
repeat
    print("you repeat this until something...")
    num = num - 1
until num == 0

---------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------

-- function defs are a mix of python/ruby/bash
function fib(n)
    if n < 2 then return 1 end
    return fib(n - 2) + fib(n - 1) -- RECURSIVE FUNCTIONS!!! NEAT!
end

-- closures and anan functions are supported.
function adder(x)
    -- OK this is fucking nuts... x is stored!
    return function (y) return x + y end
end
a1 = adder(9)
a2 = adder(36)
print(a1(16)) --> 25
print(a2(64)) --> 100 -- WHAT?!

-- BEWARE
-- Returns, func calls, and assignments all work
-- with lists that may be mismatched in length.
-- Unmatched receivers are nil;
-- unmatched senders are discarded.

x, y, z = 1, 2, 3, 4
-- 4 is just thrown away. Bad form and you should feel bad, but compiler won't get mad.

function bar(a, b, c)
    print(a, b, c)
    return 4, 8, 15, 16, 23, 42
end

x, y = bar('zarbadon')

-- Functions are first-class, may be local/global.
-- These are the same:
function f(x) return x * x end
f = function (x) return x * x end

-- And so are these:
local function g(x) return math.sin(x) end
local g; g  = function (x) return math.sin(x) end
-- the 'local g' decl makes g-self-references ok.
-- also math is a builtin... neat.

-- print has a shorthand if you only have one string "argument"
-- i.e. don't always need parens
print 'hello, buck nut.'

-------------------------------------------------------------------
-- Tables (are basically dicts/maps/hashes... why does every lang call them something different?!?)
-------------------------------------------------------------------

myTable = {key1 = 'v1', key2 = 'pens', key3 = false, key4 = 9001}
print(myTable.key1)
print(myTable.key2)
print(myTable.key3)
print(myTable.key4)
myTable.newKey = 'stinky' -- create a new key/val in the "table"
print(myTable.newKey)
myTable.key2 = nil -- nix that key/val
print(myTable.key2) --> nil
print(myTable) -- just prints the type and pointer... not that helpful in real-world

-- iterating on a table is as expected and pythonic but using "pairs" builtin function
for k, v in pairs(myTable) do
    print(k, v)
end

-- _G is a special builtin that is a table of ALL THE GLOBALS
for k, v in pairs(_G) do
    print(k, v)
end

-- lists are a thing but use brackets... because lua is special and bashlike
x = {'p1', 'p2', 'p3'}
-- oh... AND LISTS START WITH 1 (NOT 0) BECAUSE LUA IS INSANE
print(x[0]) --> nil
print(x[1]) --> 'p1'
-- lists aren't actually a real thing is "why"...
-- x is actually a table and ints are autoassigned as keys because, idfk

------------------------------------------------------------------------------
-- metatables and metamethods
-- oh boy
------------------------------------------------------------------------------

-- A table can have a metatable that gives the table
-- operator-overloadish behavior. Apparently, later we'll see
-- how metatables support js-prototypey behavior.

f1 = {a = 1, b = 2}  -- Represents the fraction a/b.
f2 = {a = 2, b = 3}

-- I don't understand what I just said... I hate js.

-- This would fail:
-- s = f1 + f2

metafraction = {}
function metafraction.__add(f1, f2)
  sum = {}
  sum.b = f1.b * f2.b
  sum.a = f1.a * f2.b + f2.a * f1.b
  return sum
end

setmetatable(f1, metafraction)
setmetatable(f2, metafraction)

s = f1 + f2  -- call __add(f1, f2) on f1's metatable

-- f1, f2 have no key for their metatable, unlike
-- prototypes in js, so you must retrieve it as in
-- getmetatable(f1). The metatable is a normal table
-- with keys that Lua knows about, like __add.

-- But the next line fails since s has no metatable:
-- t = s + s
-- Class-like patterns given below would fix this.

-- An __index on a metatable overloads dot lookups:
defaultFavs = {animal = 'gru', food = 'donuts'}
myFavs = {food = 'pizza'}
setmetatable(myFavs, {__index = defaultFavs})
eatenBy = myFavs.animal  -- works! thanks, metatable

-- Direct table lookups that fail will retry using
-- the metatable's __index value, and this recurses.

-- An __index value can also be a function(tbl, key)
-- for more customized lookups.

-- Values of __index,add, .. are called metamethods.
-- Full list. Here a is a table with the metamethod.

-- __add(a, b)                     for a + b
-- __sub(a, b)                     for a - b
-- __mul(a, b)                     for a * b
-- __div(a, b)                     for a / b
-- __mod(a, b)                     for a % b
-- __pow(a, b)                     for a ^ b
-- __unm(a)                        for -a
-- __concat(a, b)                  for a .. b
-- __len(a)                        for #a
-- __eq(a, b)                      for a == b
-- __lt(a, b)                      for a < b
-- __le(a, b)                      for a <= b
-- __index(a, b)  <fn or a table>  for a.b
-- __newindex(a, b, c)             for a.b = c
-- __call(a, ...)                  for a(...)

-- Long story long, you probably don't ever need to do the above ever.

----------------------------------------------------
-- class-like tables and inheritance
----------------------------------------------------

-- Classes aren't built in; there are different ways
-- to make them using tables and metatables.

-- Explanation for this example is below it.

Dog = {}

function Dog:new()
  newObj = {sound = 'woof'}
  self.__index = self
  return setmetatable(newObj, self)
end

function Dog:makeSound()
  print('I say ' .. self.sound)
end

mrDog = Dog:new()
mrDog:makeSound()  -- 'I say woof'

-- 1. Dog acts like a class; it's really a table.
-- 2. function tablename:fn(...) is the same as
--    function tablename.fn(self, ...)
--    The : just adds a first arg called self.
--    Read 7 & 8 below for how self gets its value.
-- 3. newObj will be an instance of class Dog.
-- 4. self = the class being instantiated. Often
--    self = Dog, but inheritance can change it.
--    newObj gets self's functions when we set both
--    newObj's metatable and self's __index to self.
-- 5. Reminder: setmetatable returns its first arg.
-- 6. The : works as in 2, but this time we expect
--    self to be an instance instead of a class.
-- 7. Same as Dog.new(Dog), so self = Dog in new().
-- 8. Same as mrDog.makeSound(mrDog); self = mrDog.

----------------------------------------------------

-- Inheritance example:

LoudDog = Dog:new()

function LoudDog:makeSound()
  s = self.sound .. ' '
  print(s .. s .. s)
end

seymour = LoudDog:new()
seymour:makeSound()  -- 'woof woof woof'

-- 1. LoudDog gets Dog's methods and variables.
-- 2. self has a 'sound' key from new(), see 3.
-- 3. Same as LoudDog.new(LoudDog), and converted to
--    Dog.new(LoudDog) as LoudDog has no 'new' key,
--    but does have __index = Dog on its metatable.
--    Result: seymour's metatable is LoudDog, and
--    LoudDog.__index = LoudDog. So seymour.key will
--    = seymour.key, LoudDog.key, Dog.key, whichever
--    table is the first with the given key.
-- 4. The 'makeSound' key is found in LoudDog; this
--    is the same as LoudDog.makeSound(seymour).

-- If needed, a subclass's new() is like the base's:
function LoudDog:new()
  newObj = {}
  -- set up newObj
  self.__index = self
  return setmetatable(newObj, self)
end

----------------------------------------------------
-- mdules
----------------------------------------------------

-- Work like js
-- use `require('file')`
print(M) --> nil -- something defined as a local in myModule but not defined here.
x = require('myModule')
print(x) --> 'something local in the module'

-- Adopted from http://tylerneylon.com/a/learn-lua/
