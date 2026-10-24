// Use external tools so game repository has no Node runtime dependency.
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
process.chdir(root);
const prefix = process.env.MOON_CHECK_TOOLS || '/tmp/moon-checks/node_modules';
const parser = require(path.join(prefix, 'luaparse'));
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require(path.join(prefix, 'fengari'));
let files = 0;
function walk(dir) {
    for (const item of fs.readdirSync(dir, {withFileTypes: true})) {
        const file = path.join(dir, item.name);
        if (item.isDirectory()) walk(file);
        else if (file.endsWith('.lua')) {
            parser.parse(fs.readFileSync(file, 'utf8'), {luaVersion: '5.3'});
            files++;
        }
    }
}
walk('src'); walk('tests');
console.log(`PASS syntax: ${files} Lua source/test files`);
for (const name of fs.readdirSync('tests').filter(name => name.endsWith('.spec.lua')).sort()) {
    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    const status = lauxlib.luaL_dofile(L, to_luastring(path.join('tests', name)));
    if (status !== lua.LUA_OK) {
        const error = to_jsstring(lua.lua_tostring(L, -1));
        lua.lua_close(L);
        throw new Error(`${name}: ${error}`);
    }
    lua.lua_close(L);
}
console.log('PASS all test suites completed');
