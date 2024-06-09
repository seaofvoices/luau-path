-- tests are based of Rust path standard library, taken from the documentation comments
-- https://github.com/rust-lang/rust/blob/40ae34194c586eea3614d3216322053d2e8e7b37/library/std/src/path/tests.rs

local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local Path = require('../Path')

type Path = Path.Path

local expect = jestGlobals.expect
local it = jestGlobals.it
local describe = jestGlobals.describe

-- When running tests in Roblox Studio, the output filters strings that look
-- like urls or paths, so the test names are awful. To work around that, this
-- function inserts an invisible space between each character.
local function display(content: string?): string?
    return content and table.concat(string.split(content, ''), '\u{200F}\u{200F}\u{200E}\u{200E}')
end

describe('ancestors', function()
    it('verifies the ancestors of `/foo/bar`', function()
        local ancestors = Path.new('/foo/bar'):ancestors()

        expect(Path.new('/foo/bar'):parent()).toBeDefined()
        local a = ancestors:next()
        expect(a).toBeDefined()
        expect(a).toEqual(Path.new('/foo/bar'))

        expect(ancestors:next()).toEqual(Path.new('/foo'))
        expect(ancestors:next()).toEqual(Path.new('/'))
        expect(ancestors:next()).toEqual(nil)
    end)

    it('verifies the ancestors of `../foo/bar`', function()
        local ancestors = Path.new('../foo/bar'):ancestors()

        expect(ancestors:next()).toEqual(Path.new('../foo/bar'))
        expect(ancestors:next()).toEqual(Path.new('../foo'))
        expect(ancestors:next()).toEqual(Path.new('..'))
        expect(ancestors:next()).toEqual(Path.new(''))
        expect(ancestors:next()).toEqual(nil)
    end)
end)

describe('stripPrefix', function()
    local cases: { [string]: Path } = {
        ['/'] = Path.new('test/haha/foo.txt'),
        ['/test'] = Path.new('haha/foo.txt'),
        ['/test/'] = Path.new('haha/foo.txt'),
        ['/test/haha/foo.txt'] = Path.new(''),
        ['/test/haha/foo.txt/'] = Path.new(''),
    }

    for prefix, expectPath in cases do
        it(`removes '{display(prefix)}' from '/test/haha/foo.txt'`, function()
            local path = Path.new('/test/haha/foo.txt')
            expect(path:stripPrefix(prefix)).toEqual(expectPath)
        end)

        it(`removes '{display(prefix)}' from '/test/haha/foo.txt' (as path value)`, function()
            local path = Path.new('/test/haha/foo.txt')
            expect(path:stripPrefix(Path.new(prefix))).toEqual(expectPath)
        end)
    end
end)

describe('startsWith', function()
    local trueCases = {
        { '/etc/passwd', '/etc' },
        { '/etc/passwd', '/etc/' },
        { '/etc/passwd', '/etc/passwd' },
        { '/etc/passwd', '/etc/passwd/' }, -- extra slash is okay
        { '/etc/passwd', '/etc/passwd///' }, -- multiple extra slashes are okay
    }

    local falseCases = {
        { '/etc/passwd', '/e' },
        { '/etc/passwd', '/etc/passwd.txt' },
        { '/etc/foo.rs', '/etc/foo' },
    }

    for expected, cases in { [true] = trueCases, [false] = falseCases } do
        for _, info in cases do
            local path = info[1]
            local prefix = info[2]
            it(
                `checks if '{display(path)}' `
                    .. (if expected then 'starts' else 'does not start')
                    .. ` with '{display(prefix)}'`,
                function()
                    expect(Path.new(path):startsWith(prefix)).toEqual(expected)
                end
            )

            it(
                `checks if '{display(path)}' `
                    .. (if expected then 'starts' else 'does not start')
                    .. ` with '{display(prefix)}' (as path value)`,
                function()
                    expect(Path.new(path):startsWith(Path.new(prefix))).toEqual(expected)
                end
            )
        end
    end
end)

describe('endsWith', function()
    local trueCases = {
        { '/etc/resolv.conf', 'resolv.conf' },
        { '/etc/resolv.conf', 'etc/resolv.conf' },
        { '/etc/resolv.conf', '/etc/resolv.conf' },
    }

    local falseCases = {
        { '/etc/resolv.conf', '/resolv.conf' },
        { '/etc/resolv.conf', 'conf' },
    }

    for expected, cases in { [true] = trueCases, [false] = falseCases } do
        for _, info in cases do
            local path = info[1]
            local suffix = info[2]
            it(
                `checks if '{display(path)}' `
                    .. (if expected then 'ends' else 'does not end')
                    .. ` with '{display(suffix)}'`,
                function()
                    -- print('---- PARENT ----')
                    -- for _, c in Path.new(path):components():collect() do
                    --     print('->', tostring(c))
                    -- end
                    -- print('---- PARENT #2 ----')
                    -- for _, c in Path.new(path):components() do
                    --     print('->', tostring(c))
                    -- end
                    -- print('---- PARENT #3 ----')
                    -- local comps = Path.new(path):components()
                    -- local d = require('@pkg/luau-disk')
                    -- for _, c in
                    --     d.Array.reverse(d.Array.fromFn(function()
                    --         return comps:nextBack()
                    --     end))
                    -- do
                    --     print('->', tostring(c))
                    -- end

                    -- print('---- REV PARENT ----')
                    -- for _, c in Path.new(path):components():rev():collect() do
                    --     print('->', tostring(c))
                    -- end

                    -- print('---- REV PARENT #2 ----')
                    -- for _, c in Path.new(path):components():rev() do
                    --     print('->', tostring(c))
                    -- end

                    expect(Path.new(path):endsWith(suffix)).toEqual(expected)
                end
            )

            -- it(
            --     `checks if '{display(path)}' `
            --         .. (if expected then 'ends' else 'does not end')
            --         .. ` with '{display(suffix)}' (as path)`,
            --     function()
            --         expect(Path.new(path):endsWith(Path.new(suffix))).toEqual(expected)
            --     end
            -- )
        end
    end
end)
