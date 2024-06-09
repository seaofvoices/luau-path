-- tests are based of Rust path standard library
-- https://github.com/rust-lang/rust/blob/40ae34194c586eea3614d3216322053d2e8e7b37/library/std/src/path/tests.rs

local Disk = require('@pkg/luau-disk')
local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local Path = require('../Path')
local sysPath = require('../sys/path')

local Array = Disk.Array

local expect = jestGlobals.expect
local it = jestGlobals.it
local describe = jestGlobals.describe

local IS_WINDOWS = sysPath.MAIN_SEPARATOR_STR == '\\'

-- When running tests in Roblox Studio, the output filters strings that look
-- like urls or paths, so the test names are awful. To work around that, this
-- function inserts an invisible space between each character.
local function display(content: string?): string?
    return content and table.concat(string.split(content, ''), '\u{200F}\u{200F}\u{200E}\u{200E}')
end

local function t1(path: string, info: { iter: { string } })
    it(
        `checks if '{display(path)}' decomposes into = ['{table.concat(
            Array.map(info.iter, display),
            "', '"
        )}']`,
        function()
            local path = Path.new(path)

            local comps = Array.map(path:components():collect(), tostring)
            local exps = info.iter

            expect(comps).toEqual(exps)
        end
    )
end

local function t2(path: string, info: { has_root: boolean, is_absolute: boolean })
    it(`checks if '{display(path)}' has_root = '{info.has_root}'`, function()
        local path = Path.new(path)

        expect(path:hasRoot()).toEqual(info.has_root)
    end)

    it(`checks if '{display(path)}' is_absolute = '{info.is_absolute}'`, function()
        local path = Path.new(path)

        expect(path:isAbsolute()).toEqual(info.is_absolute)
    end)
end

local function t3(path: string, info: { parent: string?, file_name: string? })
    it(`checks if '{display(path)}' parent = '{display(info.parent)}'`, function()
        local path = Path.new(path)

        local parent = path:parent()

        expect(parent and parent:toString()).toEqual(info.parent)
    end)

    it(`checks if '{display(path)}' file_name = '{display(info.file_name)}'`, function()
        local path = Path.new(path)

        expect(path:fileName()).toEqual(info.file_name)
    end)
end

local function t4(path: string, info: { file_stem: string?, extension: string? })
    it(`checks if '{display(path)}' has a stem = '{display(info.file_stem)}'`, function()
        local path = Path.new(path)

        expect(path:fileStem()).toEqual(info.file_stem)
    end)

    it(`checks if '{display(path)}' has an extension = '{display(info.extension)}'`, function()
        local path = Path.new(path)

        expect(path:extension()).toEqual(info.extension)
    end)
end

local function t5(path: string, info: { file_prefix: string?, extension: string? })
    it(`checks if '{display(path)}' has a prefix = '{display(info.file_prefix)}'`, function()
        local path = Path.new(path)

        expect(path:filePrefix()).toEqual(info.file_prefix)
    end)

    it(`checks if '{display(path)}' has an extension = '{display(info.extension)}'`, function()
        local path = Path.new(path)

        expect(path:extension()).toEqual(info.extension)
    end)
end

type Info = {
    iter: { string },
    has_root: boolean,
    is_absolute: boolean,
    parent: string?,
    file_name: string?,
    file_stem: string?,
    extension: string?,
    file_prefix: string?,
}

local function t(path: string, info: Info)
    t1(path, info)
    t2(path, info)
    t3(path, info)
    t4(path, info)
    t5(path, info)
end

describe('test_decompositions_unix', function()
    if IS_WINDOWS then
        return
    end

    t('', {
        iter = {},
        has_root = false,
        is_absolute = false,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('/', {
        iter = { '/' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('/foo', {
        iter = { '/', 'foo' },
        has_root = true,
        is_absolute = true,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('/foo/', {
        iter = { '/', 'foo' },
        has_root = true,
        is_absolute = true,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/bar', {
        iter = { 'foo', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('/foo/bar', {
        iter = { '/', 'foo', 'bar' },
        has_root = true,
        is_absolute = true,
        parent = '/foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('///foo///', {
        iter = { '/', 'foo' },
        has_root = true,
        is_absolute = true,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('///foo///bar', {
        iter = { '/', 'foo', 'bar' },
        has_root = true,
        is_absolute = true,
        parent = '///foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('./.', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('/..', {
        iter = { '/', '..' },
        has_root = true,
        is_absolute = true,
        parent = '/',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('../', {
        iter = { '..' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/.', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/..', {
        iter = { 'foo', '..' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/./', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/./bar', {
        iter = { 'foo', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('foo/../', {
        iter = { 'foo', '..' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/../bar', {
        iter = { 'foo', '..', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo/..',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('./a', {
        iter = { '.', 'a' },
        has_root = false,
        is_absolute = false,
        parent = '.',
        file_name = 'a',
        file_stem = 'a',
        extension = nil,
        file_prefix = 'a',
    })

    t('.', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('./', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('a/b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a//b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a/./b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a/b/c', {
        iter = { 'a', 'b', 'c' },
        has_root = false,
        is_absolute = false,
        parent = 'a/b',
        file_name = 'c',
        file_stem = 'c',
        extension = nil,
        file_prefix = 'c',
    })

    t('.foo', {
        iter = { '.foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = '.foo',
        file_stem = '.foo',
        extension = nil,
        file_prefix = '.foo',
    })

    t('a/.foo', {
        iter = { 'a', '.foo' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = '.foo',
        file_stem = '.foo',
        extension = nil,
        file_prefix = '.foo',
    })

    t('a/.rustfmt.toml', {
        iter = { 'a', '.rustfmt.toml' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = '.rustfmt.toml',
        file_stem = '.rustfmt',
        extension = 'toml',
        file_prefix = '.rustfmt',
    })

    t('a/.x.y.z', {
        iter = { 'a', '.x.y.z' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = '.x.y.z',
        file_stem = '.x.y',
        extension = 'z',
        file_prefix = '.x',
    })
end)

describe('test_decompositions_windows', function()
    if not IS_WINDOWS then
        return
    end

    t('', {
        iter = {},
        has_root = false,
        is_absolute = false,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('/', {
        iter = { '\\' },
        has_root = true,
        is_absolute = false,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\', {
        iter = { '\\' },
        has_root = true,
        is_absolute = false,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('c:', {
        iter = { 'c:' },
        has_root = false,
        is_absolute = false,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('c:\\', {
        iter = { 'c:', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('c:/', {
        iter = { 'c:', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('/foo', {
        iter = { '\\', 'foo' },
        has_root = true,
        is_absolute = false,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('/foo/', {
        iter = { '\\', 'foo' },
        has_root = true,
        is_absolute = false,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/bar', {
        iter = { 'foo', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('/foo/bar', {
        iter = { '\\', 'foo', 'bar' },
        has_root = true,
        is_absolute = false,
        parent = '/foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('///foo///', {
        iter = { '\\', 'foo' },
        has_root = true,
        is_absolute = false,
        parent = '/',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('///foo///bar', {
        iter = { '\\', 'foo', 'bar' },
        has_root = true,
        is_absolute = false,
        parent = '///foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('./.', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('/..', {
        iter = { '\\', '..' },
        has_root = true,
        is_absolute = false,
        parent = '/',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('../', {
        iter = { '..' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/.', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/..', {
        iter = { 'foo', '..' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/./', {
        iter = { 'foo' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = 'foo',
        file_stem = 'foo',
        extension = nil,
        file_prefix = 'foo',
    })

    t('foo/./bar', {
        iter = { 'foo', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('foo/../', {
        iter = { 'foo', '..' },
        has_root = false,
        is_absolute = false,
        parent = 'foo',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('foo/../bar', {
        iter = { 'foo', '..', 'bar' },
        has_root = false,
        is_absolute = false,
        parent = 'foo/..',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('./a', {
        iter = { '.', 'a' },
        has_root = false,
        is_absolute = false,
        parent = '.',
        file_name = 'a',
        file_stem = 'a',
        extension = nil,
        file_prefix = 'a',
    })

    t('.', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('./', {
        iter = { '.' },
        has_root = false,
        is_absolute = false,
        parent = '',
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('a/b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a//b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a/./b', {
        iter = { 'a', 'b' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('a/b/c', {
        iter = { 'a', 'b', 'c' },
        has_root = false,
        is_absolute = false,
        parent = 'a/b',
        file_name = 'c',
        file_stem = 'c',
        extension = nil,
        file_prefix = 'c',
    })

    t('a\\b\\c', {
        iter = { 'a', 'b', 'c' },
        has_root = false,
        is_absolute = false,
        parent = 'a\\b',
        file_name = 'c',
        file_stem = 'c',
        extension = nil,
        file_prefix = 'c',
    })

    t('\\a', {
        iter = { '\\', 'a' },
        has_root = true,
        is_absolute = false,
        parent = '\\',
        file_name = 'a',
        file_stem = 'a',
        extension = nil,
        file_prefix = 'a',
    })

    t('c:\\foo.txt', {
        iter = { 'c:', '\\', 'foo.txt' },
        has_root = true,
        is_absolute = true,
        parent = 'c:\\',
        file_name = 'foo.txt',
        file_stem = 'foo',
        extension = 'txt',
        file_prefix = 'foo',
    })

    t('\\\\server\\share\\foo.txt', {
        iter = { '\\\\server\\share', '\\', 'foo.txt' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\server\\share\\',
        file_name = 'foo.txt',
        file_stem = 'foo',
        extension = 'txt',
        file_prefix = 'foo',
    })

    t('\\\\server\\share', {
        iter = { '\\\\server\\share', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\server', {
        iter = { '\\', 'server' },
        has_root = true,
        is_absolute = false,
        parent = '\\',
        file_name = 'server',
        file_stem = 'server',
        extension = nil,
        file_prefix = 'server',
    })

    t('\\\\?\\bar\\foo.txt', {
        iter = { '\\\\?\\bar', '\\', 'foo.txt' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\bar\\',
        file_name = 'foo.txt',
        file_stem = 'foo',
        extension = 'txt',
        file_prefix = 'foo',
    })

    t('\\\\?\\bar', {
        iter = { '\\\\?\\bar' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\', {
        iter = { '\\\\?\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\UNC\\server\\share\\foo.txt', {
        iter = { '\\\\?\\UNC\\server\\share', '\\', 'foo.txt' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\UNC\\server\\share\\',
        file_name = 'foo.txt',
        file_stem = 'foo',
        extension = 'txt',
        file_prefix = 'foo',
    })

    t('\\\\?\\UNC\\server', {
        iter = { '\\\\?\\UNC\\server' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\UNC\\', {
        iter = { '\\\\?\\UNC\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\C:\\foo.txt', {
        iter = { '\\\\?\\C:', '\\', 'foo.txt' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\C:\\',
        file_name = 'foo.txt',
        file_stem = 'foo',
        extension = 'txt',
        file_prefix = 'foo',
    })

    t('\\\\?\\C:\\', {
        iter = { '\\\\?\\C:', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\C:', {
        iter = { '\\\\?\\C:' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\foo/bar', {
        iter = { '\\\\?\\foo/bar' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\C:/foo/bar', {
        iter = { '\\\\?\\C:', '\\', 'foo/bar' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\C:/',
        file_name = 'foo/bar',
        file_stem = 'foo/bar',
        extension = nil,
        file_prefix = 'foo/bar',
    })

    t('\\\\.\\foo\\bar', {
        iter = { '\\\\.\\foo', '\\', 'bar' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\.\\foo\\',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('\\\\.\\foo', {
        iter = { '\\\\.\\foo', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\.\\foo/bar', {
        iter = { '\\\\.\\foo', '\\', 'bar' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\.\\foo/',
        file_name = 'bar',
        file_stem = 'bar',
        extension = nil,
        file_prefix = 'bar',
    })

    t('\\\\.\\foo\\bar/baz', {
        iter = { '\\\\.\\foo', '\\', 'bar', 'baz' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\.\\foo\\bar',
        file_name = 'baz',
        file_stem = 'baz',
        extension = nil,
        file_prefix = 'baz',
    })

    t('\\\\.\\', {
        iter = { '\\\\.\\', '\\' },
        has_root = true,
        is_absolute = true,
        parent = nil,
        file_name = nil,
        file_stem = nil,
        extension = nil,
        file_prefix = nil,
    })

    t('\\\\?\\a\\b\\', {
        iter = { '\\\\?\\a', '\\', 'b' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\a\\',
        file_name = 'b',
        file_stem = 'b',
        extension = nil,
        file_prefix = 'b',
    })

    t('\\\\?\\C:\\foo.txt.zip', {
        iter = { '\\\\?\\C:', '\\', 'foo.txt.zip' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\C:\\',
        file_name = 'foo.txt.zip',
        file_stem = 'foo.txt',
        extension = 'zip',
        file_prefix = 'foo',
    })

    t('\\\\?\\C:\\.foo.txt.zip', {
        iter = { '\\\\?\\C:', '\\', '.foo.txt.zip' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\C:\\',
        file_name = '.foo.txt.zip',
        file_stem = '.foo.txt',
        extension = 'zip',
        file_prefix = '.foo',
    })

    t('\\\\?\\C:\\.foo', {
        iter = { '\\\\?\\C:', '\\', '.foo' },
        has_root = true,
        is_absolute = true,
        parent = '\\\\?\\C:\\',
        file_name = '.foo',
        file_stem = '.foo',
        extension = nil,
        file_prefix = '.foo',
    })

    t('a/.x.y.z', {
        iter = { 'a', '.x.y.z' },
        has_root = false,
        is_absolute = false,
        parent = 'a',
        file_name = '.x.y.z',
        file_stem = '.x.y',
        extension = 'z',
        file_prefix = '.x',
    })
end)

describe('test_stem_ext', function()
    t4('foo', { file_stem = 'foo', extension = nil })

    t4('foo.', { file_stem = 'foo', extension = '' })

    t4('.foo', { file_stem = '.foo', extension = nil })

    t4('foo.txt', { file_stem = 'foo', extension = 'txt' })

    t4('foo.bar.txt', { file_stem = 'foo.bar', extension = 'txt' })

    t4('foo.bar.', { file_stem = 'foo.bar', extension = '' })

    t4('.', { file_stem = nil, extension = nil })

    t4('..', { file_stem = nil, extension = nil })

    t4('.x.y.z', { file_stem = '.x.y', extension = 'z' })

    t4('..x.y.z', { file_stem = '..x.y', extension = 'z' })

    t4('', { file_stem = nil, extension = nil })
end)

describe('test_prefix_ext', function()
    t5('foo', {
        file_prefix = 'foo',
        extension = nil,
    })

    t5('foo.', {
        file_prefix = 'foo',
        extension = '',
    })

    t5('.foo', {
        file_prefix = '.foo',
        extension = nil,
    })

    t5('foo.txt', {
        file_prefix = 'foo',
        extension = 'txt',
    })

    t5('foo.bar.txt', { file_prefix = 'foo', extension = 'txt' })

    t5('foo.bar.', { file_prefix = 'foo', extension = '' })

    t5('.', { file_prefix = nil, extension = nil })

    t5('..', { file_prefix = nil, extension = nil })

    t5('.x.y.z', { file_prefix = '.x', extension = 'z' })

    t5('..x.y.z', { file_prefix = '.', extension = 'z' })

    t5('', { file_prefix = nil, extension = nil })
end)

describe('test_push', function()
    local function tp(path: string, push: string, expected: string)
        it(
            `checks if pushing '{display(push)}' onto '{display(path)}' gives '{display(expected)}'`,
            function()
                local actual = Path.new(path)
                actual:push(push)

                expect(actual:toString()).toEqual(expected)
            end
        )
    end

    -- if cfg!(unix) || cfg!(all(target_env = "sgx", target_vendor = "fortanix")) {
    if not IS_WINDOWS then
        tp('', 'foo', 'foo')
        tp('foo', 'bar', 'foo/bar')
        tp('foo/', 'bar', 'foo/bar')
        tp('foo//', 'bar', 'foo//bar')
        tp('foo/.', 'bar', 'foo/./bar')
        tp('foo./.', 'bar', 'foo././bar')
        tp('foo', '', 'foo/')
        tp('foo', '.', 'foo/.')
        tp('foo', '..', 'foo/..')
        tp('foo', '/', '/')
        tp('/foo/bar', '/', '/')
        tp('/foo/bar', '/baz', '/baz')
        tp('/foo/bar', './baz', '/foo/bar/./baz')
    else
        tp('', 'foo', 'foo')
        tp('foo', 'bar', [[foo\bar]])
        tp('foo/', 'bar', [[foo/bar]])
        tp([[foo\]], 'bar', [[foo\bar]])
        tp('foo//', 'bar', [[foo//bar]])
        tp([[foo\\]], 'bar', [[foo\\bar]])
        tp('foo/.', 'bar', [[foo/.\bar]])
        tp('foo./.', 'bar', [[foo./.\bar]])
        tp([[foo\.]], 'bar', [[foo\.\bar]])
        tp([[foo.\.]], 'bar', [[foo.\.\bar]])
        tp('foo', '', 'foo\\')
        tp('foo', '.', [[foo\.]])
        tp('foo', '..', [[foo\..]])
        tp('foo', '/', '/')
        tp('foo', [[\]], [[\]])
        tp('/foo/bar', '/', '/')
        tp([[\foo\bar]], [[\]], [[\]])
        tp('/foo/bar', '/baz', '/baz')
        tp('/foo/bar', [[\baz]], [[\baz]])
        tp('/foo/bar', './baz', [[/foo/bar\./baz]])
        tp('/foo/bar', [[.\baz]], [[/foo/bar\.\baz]])

        tp('c:\\', 'windows', 'c:\\windows')
        tp('c:', 'windows', 'c:windows')

        tp('a\\b\\c', 'd', 'a\\b\\c\\d')
        tp('\\a\\b\\c', 'd', '\\a\\b\\c\\d')
        tp('a\\b', 'c\\d', 'a\\b\\c\\d')
        tp('a\\b', '\\c\\d', '\\c\\d')
        tp('a\\b', '.', 'a\\b\\.')
        tp('a\\b', '..\\c', 'a\\b\\..\\c')
        tp('a\\b', 'C:a.txt', 'C:a.txt')
        tp('a\\b', 'C:\\a.txt', 'C:\\a.txt')
        tp('C:\\a', 'C:\\b.txt', 'C:\\b.txt')
        tp('C:\\a\\b\\c', 'C:d', 'C:d')
        tp('C:a\\b\\c', 'C:d', 'C:d')
        tp('C:', [[a\b\c]], [[C:a\b\c]])
        tp('C:', [[..\a]], [[C:..\a]])
        tp('\\\\server\\share\\foo', 'bar', '\\\\server\\share\\foo\\bar')
        tp('\\\\server\\share\\foo', 'C:baz', 'C:baz')
        tp('\\\\?\\C:\\a\\b', 'C:c\\d', 'C:c\\d')
        tp('\\\\?\\C:a\\b', 'C:c\\d', 'C:c\\d')
        tp('\\\\?\\C:\\a\\b', 'C:\\c\\d', 'C:\\c\\d')
        tp('\\\\?\\foo\\bar', 'baz', '\\\\?\\foo\\bar\\baz')
        tp('\\\\?\\UNC\\server\\share\\foo', 'bar', '\\\\?\\UNC\\server\\share\\foo\\bar')
        tp('\\\\?\\UNC\\server\\share', 'C:\\a', 'C:\\a')
        tp('\\\\?\\UNC\\server\\share', 'C:a', 'C:a')

        -- Note: modified from old path API
        tp('\\\\?\\UNC\\server', 'foo', '\\\\?\\UNC\\server\\foo')

        tp('C:\\a', '\\\\?\\UNC\\server\\share', '\\\\?\\UNC\\server\\share')
        tp('\\\\.\\foo\\bar', 'baz', '\\\\.\\foo\\bar\\baz')
        tp('\\\\.\\foo\\bar', 'C:a', 'C:a')
        -- again, not sure about the following, but I'm assuming \\.\ should be verbatim
        tp('\\\\.\\foo', '..\\bar', '\\\\.\\foo\\..\\bar')

        tp('\\\\?\\C:', 'foo', '\\\\?\\C:\\foo') -- this is a weird one

        tp([[\\?\C:\bar]], '../foo', [[\\?\C:\foo]])
        tp([[\\?\C:\bar]], '../../foo', [[\\?\C:\foo]])
        tp([[\\?\C:\]], '../foo', [[\\?\C:\foo]])
        tp([[\\?\C:]], [[D:\foo/./]], [[D:\foo/./]])
        tp([[\\?\C:]], [[\\?\D:\foo\.\]], [[\\?\D:\foo\.\]])
        tp([[\\?\A:\x\y]], '/foo', [[\\?\A:\foo]])
        tp([[\\?\A:]], [[..\foo\.]], [[\\?\A:\foo]])
        tp([[\\?\A:\x\y]], [[.\foo\.]], [[\\?\A:\x\y\foo]])
        tp([[\\?\A:\x\y]], '', [[\\?\A:\x\y\]])
    end
end)

describe('test_pop', function()
    local function tp(path: string, expected: string, expectedOutput: boolean)
        it(
            `checks if calling pop on '{display(path)}' gives '{display(expected)}' and returns {expectedOutput}`,
            function()
                local actual = Path.new(path)
                local output = actual:pop()

                expect(actual:toString()).toEqual(expected)
                expect(output).toEqual(expectedOutput)
            end
        )
    end

    tp('', '', false)
    tp('/', '/', false)
    tp('foo', '', true)
    tp('.', '', true)
    tp('/foo', '/', true)
    tp('/foo/bar', '/foo', true)
    tp('foo/bar', 'foo', true)
    tp('foo/.', '', true)
    tp('foo//bar', 'foo', true)

    if IS_WINDOWS then
        tp('a\\b\\c', 'a\\b', true)
        tp('\\a', '\\', true)
        tp('\\', '\\', false)

        tp('C:\\a\\b', 'C:\\a', true)
        tp('C:\\a', 'C:\\', true)
        tp('C:\\', 'C:\\', false)
        tp('C:a\\b', 'C:a', true)
        tp('C:a', 'C:', true)
        tp('C:', 'C:', false)
        tp('\\\\server\\share\\a\\b', '\\\\server\\share\\a', true)
        tp('\\\\server\\share\\a', '\\\\server\\share\\', true)
        tp('\\\\server\\share', '\\\\server\\share', false)
        tp('\\\\?\\a\\b\\c', '\\\\?\\a\\b', true)
        tp('\\\\?\\a\\b', '\\\\?\\a\\', true)
        tp('\\\\?\\a', '\\\\?\\a', false)
        tp('\\\\?\\C:\\a\\b', '\\\\?\\C:\\a', true)
        tp('\\\\?\\C:\\a', '\\\\?\\C:\\', true)
        tp('\\\\?\\C:\\', '\\\\?\\C:\\', false)
        tp('\\\\?\\UNC\\server\\share\\a\\b', '\\\\?\\UNC\\server\\share\\a', true)
        tp('\\\\?\\UNC\\server\\share\\a', '\\\\?\\UNC\\server\\share\\', true)
        tp('\\\\?\\UNC\\server\\share', '\\\\?\\UNC\\server\\share', false)
        tp('\\\\.\\a\\b\\c', '\\\\.\\a\\b', true)
        tp('\\\\.\\a\\b', '\\\\.\\a\\', true)
        tp('\\\\.\\a', '\\\\.\\a', false)

        tp('\\\\?\\a\\b\\', '\\\\?\\a\\', true)
    end
end)

describe('test_set_file_name', function()
    local function tfn(path: string, file: string, expected: string)
        it(
            `checks if setting file name of '{display(path)}' to '{display(file)}' gives {display(
                expected
            )}`,
            function()
                local p = Path.new(path)
                p:setFileName(file)

                expect(p:toString()).toEqual(expected)
            end
        )
    end

    tfn('foo', 'foo', 'foo')
    tfn('foo', 'bar', 'bar')
    tfn('foo', '', '')
    tfn('', 'foo', 'foo')

    -- if cfg!(unix) || cfg!(all(target_env = "sgx", target_vendor = "fortanix")) {
    if not IS_WINDOWS then
        tfn('.', 'foo', './foo')
        tfn('foo/', 'bar', 'bar')
        tfn('foo/.', 'bar', 'bar')
        tfn('..', 'foo', '../foo')
        tfn('foo/..', 'bar', 'foo/../bar')
        tfn('/', 'foo', '/foo')
    else
        tfn('.', 'foo', [[.\foo]])
        tfn([[foo\]], 'bar', [[bar]])
        tfn([[foo\.]], 'bar', [[bar]])
        tfn('..', 'foo', [[..\foo]])
        tfn([[foo\..]], 'bar', [[foo\..\bar]])
        tfn([[\]], 'foo', [[\foo]])
    end
end)

describe('test_set_extension', function()
    local function tfe(path: string, ext: string, expected: string, expectedOutput: boolean)
        it(
            `checks if setting extension of '{path}' to '{ext}' gives {expected} and returns {expectedOutput}`,
            function()
                local p = Path.new(path)
                local output = p:setExtension(ext)

                expect(p:toString()).toEqual(expected)
                expect(output).toEqual(expectedOutput)
            end
        )
    end

    tfe('foo', 'txt', 'foo.txt', true)
    tfe('foo.bar', 'txt', 'foo.txt', true)
    tfe('foo.bar.baz', 'txt', 'foo.bar.txt', true)
    tfe('.test', 'txt', '.test.txt', true)
    tfe('foo.txt', '', 'foo', true)
    tfe('foo', '', 'foo', true)
    tfe('', 'foo', '', false)
    tfe('.', 'foo', '.', false)
    tfe('foo/', 'bar', 'foo.bar', true)
    tfe('foo/.', 'bar', 'foo.bar', true)
    tfe('..', 'foo', '..', false)
    tfe('foo/..', 'bar', 'foo/..', false)
    tfe('/', 'foo', '/', false)
end)

describe('test_with_extension', function()
    local function twe(input: string, extension: string, expected: string)
        it(
            `checks if calling withExtension on '{display(input)}' with '{display(extension)}' gives {display(
                expected
            )}`,
            function()
                local input = Path.new(input)
                local output = input:withExtension(extension)

                expect(output:toString()).toEqual(expected)
            end
        )
    end

    twe('foo', 'txt', 'foo.txt')
    twe('foo.bar', 'txt', 'foo.txt')
    twe('foo.bar.baz', 'txt', 'foo.bar.txt')
    twe('.test', 'txt', '.test.txt')
    twe('foo.txt', '', 'foo')
    twe('foo', '', 'foo')
    twe('', 'foo', '')
    twe('.', 'foo', '.')
    twe('foo/', 'bar', 'foo.bar')
    twe('foo/.', 'bar', 'foo.bar')
    twe('..', 'foo', '..')
    twe('foo/..', 'bar', 'foo/..')
    twe('/', 'foo', '/')

    -- New extension is smaller than file name
    twe('aaa_aaa_aaa', 'bbb_bbb', 'aaa_aaa_aaa.bbb_bbb')
    -- New extension is greater than file name
    twe('bbb_bbb', 'aaa_aaa_aaa', 'bbb_bbb.aaa_aaa_aaa')

    -- New extension is smaller than previous extension
    twe('ccc.aaa_aaa_aaa', 'bbb_bbb', 'ccc.bbb_bbb')
    -- New extension is greater than previous extension
    twe('ccc.bbb_bbb', 'aaa_aaa_aaa', 'ccc.aaa_aaa_aaa')
end)

describe('test_eq_receivers', function()
    it("compares 'foo/bar'", function()
        local borrowed = Path.new('foo/bar')
        local owned = Path.new('')
        owned:push('foo')
        owned:push('bar')

        expect(borrowed:equal(owned)).toEqual(true)
    end)
end)

describe('test_compare', function()
    local function tc(
        path1: string,
        path2: string,
        info: {
            eq: boolean,
            startsWith: boolean,
            endsWith: boolean,
            relativeFrom: string?,
        }
    )
        it(
            `checks that '{display(path1)}' {if info.eq then '=' else '~'}= '{display(path2)}'`,
            function()
                local path1 = Path.new(path1)
                local path2 = Path.new(path2)
                local areEqual = path1:equal(path2)

                expect(areEqual).toEqual(info.eq)
            end
        )

        it(
            `checks that '{display(path1)}' `
                .. (if info.startsWith then 'starts' else 'does not start')
                .. ` with '{display(path2)}'`,
            function()
                local path1 = Path.new(path1)
                local path2 = Path.new(path2)

                expect(path1:startsWith(path2)).toEqual(info.startsWith)
            end
        )

        it(
            `checks that '{display(path1)}' `
                .. (if info.startsWith then 'ends' else 'does not end')
                .. ` with '{display(path2)}'`,
            function()
                local path1 = Path.new(path1)
                local path2 = Path.new(path2)

                expect(path1:endsWith(path2)).toEqual(info.endsWith)
            end
        )

        it(
            `checks that removing '{display(path2)}' from '{display(path1)}' gives '{display(
                info.relativeFrom
            )}'`,
            function()
                local path1 = Path.new(path1)
                local path2 = Path.new(path2)

                local result = path1:stripPrefix(path2)
                expect(result and result:toString()).toEqual(info.relativeFrom)
            end
        )
    end

    tc('', '', {
        eq = true,
        startsWith = true,
        endsWith = true,
        relativeFrom = '',
    })

    tc('foo', '', {
        eq = false,
        startsWith = true,
        endsWith = true,
        relativeFrom = 'foo',
    })

    tc('', 'foo', {
        eq = false,
        startsWith = false,
        endsWith = false,
        relativeFrom = nil,
    })

    tc('foo', 'foo', {
        eq = true,
        startsWith = true,
        endsWith = true,
        relativeFrom = '',
    })

    tc('foo/', 'foo', {
        eq = true,
        startsWith = true,
        endsWith = true,
        relativeFrom = '',
    })

    tc('foo/.', 'foo', {
        eq = true,
        startsWith = true,
        endsWith = true,
        relativeFrom = '',
    })

    tc('foo/./bar', 'foo/bar', {
        eq = true,
        startsWith = true,
        endsWith = true,
        relativeFrom = '',
    })

    tc('foo/bar', 'foo', {
        eq = false,
        startsWith = true,
        endsWith = false,
        relativeFrom = 'bar',
    })

    tc('foo/bar/baz', 'foo/bar', {
        eq = false,
        startsWith = true,
        endsWith = false,
        relativeFrom = 'baz',
    })

    tc('foo/bar', 'foo/bar/baz', {
        eq = false,
        startsWith = false,
        endsWith = false,
        relativeFrom = nil,
    })

    tc('./foo/bar/', '.', {
        eq = false,
        startsWith = true,
        endsWith = false,
        relativeFrom = 'foo/bar',
    })

    if IS_WINDOWS then
        tc([[C:\src\rust\cargo-test\test\Cargo.toml]], [[c:\src\rust\cargo-test\test]], {
            eq = false,
            startsWith = true,
            endsWith = false,
            relativeFrom = 'Cargo.toml',
        })

        tc([[c:\foo]], [[C:\foo]], {
            eq = true,
            startsWith = true,
            endsWith = true,
            relativeFrom = '',
        })

        tc([[C:\foo\.\bar.txt]], [[C:\foo\bar.txt]], {
            eq = true,
            startsWith = true,
            endsWith = true,
            relativeFrom = '',
        })

        tc([[C:\foo\.]], [[C:\foo]], {
            eq = true,
            startsWith = true,
            endsWith = true,
            relativeFrom = '',
        })

        tc([[\\?\C:\foo\.\bar.txt]], [[\\?\C:\foo\bar.txt]], {
            eq = false,
            startsWith = false,
            endsWith = false,
            relativeFrom = nil,
        })
    end
end)
