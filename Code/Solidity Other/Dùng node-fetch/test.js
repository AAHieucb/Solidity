// # NodeJS / # Dùng json-server(bản chất của server) / Dùng node-fetch

const fetch = require('node-fetch');
async function test() {
    const response = await fetch('https://google.com/');
    const body = await response.text();
    console.log(body);
}
test();

// Dùng trực tiếp file json thành object luôn
const data = require("./data.json");
console.log(data);