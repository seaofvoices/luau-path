-- additional tests that were reported

local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local Path = require('../Path')

local expect = jestGlobals.expect
local it = jestGlobals.it
local describe = jestGlobals.describe

describe('issue #3', function()
    it(`set empty extension on 'src/abc' gives 'src/abc'`, function()
        local path = Path.new('src/abc')

        path:setExtension('')

        expect(path:toString()).toEqual(Path.new('src'):join('abc'):toString())
        expect(path:equal(Path.new('src/abc'))).toBe(true)
    end)
end)
