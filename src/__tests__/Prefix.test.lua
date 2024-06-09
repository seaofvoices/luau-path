local Disk = require('@pkg/luau-disk')
local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local Path = require('../Path')
local Prefix = require('../Prefix')
local sysPath = require('../sys/path')

local Array = Disk.Array
local Map = Disk.Map

type Prefix = Prefix.Prefix

-- When running tests in Roblox Studio, the output filters strings that look
-- like urls or paths, so the test names are awful. To work around that, this
-- function inserts an invisible space between each character.
local function display(content: string?): string?
    return content and table.concat(string.split(content, ''), '\u{200F}\u{200F}\u{200E}\u{200E}')
end

local expect = jestGlobals.expect
local it = jestGlobals.it
local describe = jestGlobals.describe

local IS_WINDOWS = sysPath.MAIN_SEPARATOR_STR == '\\'

describe('Prefix', function()
    if not IS_WINDOWS then
        return
    end

    local function getPathPrefix(s: string): Prefix
        local path = Path.new(s)

        local component = path:components():next()

        assert(component ~= nil, 'expected at least one component')
        assert(component.type == 'prefix', 'expected prefix component')

        return (component :: any).parsed
    end

    local cases: { [string]: Prefix } = {
        [ [[\\?\pictures\kittens]] ] = Prefix.Verbatim('pictures'),
        [ [[\\?\UNC\server\share]] ] = Prefix.VerbatimUNC('server', 'share'),
        [ [[\\?\c:\]] ] = Prefix.VerbatimDisk('C'),
        [ [[\\.\BrainInterface]] ] = Prefix.DeviceNS('BrainInterface'),
        [ [[\\server\share]] ] = Prefix.UNC('server', 'share'),
        [ [[C:\Users\Rust\Pictures\Ferris]] ] = Prefix.Disk('C'),
    }

    for path, expectPrefix in cases do
        it(`parses the prefix in '{display(path)}'`, function()
            expect(expectPrefix).toEqual(getPathPrefix(path))
        end)
    end
end)

describe('isVerbatim', function()
    local cases: { [Prefix]: boolean } = {
        [Prefix.Verbatim('pictures')] = true,
        [Prefix.VerbatimUNC('server', 'share')] = true,
        [Prefix.VerbatimDisk('C')] = true,
        [Prefix.DeviceNS('BrainInterface')] = false,
        [Prefix.UNC('server', 'share')] = false,
        [Prefix.Disk('C')] = false,
    }

    for prefix, expected in cases do
        local formatted = `\{ {table.concat(
            Array.map(Map.entries(prefix), function(entry)
                return `{entry[1]} = {entry[2]}`
            end),
            ', '
        )} }`

        it(`tests if {formatted} is verbatim = {expected}`, function()
            expect(prefix:isVerbatim()).toEqual(expected)
        end)
    end
end)
