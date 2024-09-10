require("hardhat-gas-reporter");
require('solidity-docgen');
require('solidity-coverage');
require("hardhat-interface-generator");
require("hardhat-if-gen");

const {
  task, types
} = require("hardhat/config");
// hardhat/config chứa thông tin về networks config là biến global cung thông tin về Config DSL
// DSL là Digital subscriber line là công nghệ truyền tải dữ liệu số qua đường dây 

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// # Thao tác hardhat / Dùng task
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  // Các hàm của task sẽ tự có hre làm đối số thứ 2. Ta chỉ có thể dùng hre ở trong hàm này chứ ra ngoài k có đâu

  for (const account of accounts) {
    console.log(account.address);
  }
});

// Tự tạo task
task("balance", "Print an account's balance")
  .addOptionalParam("greeting", "The greeting to print", "Hello, World!")
  .addParam("account", "The account'address") // Thêm 1 param vào task thì task mới đủ param để chạy
  // => Khi thêm 1 param vào task thì nó sẽ sinh ra 1 help message có thể xem với npx hardhat help <tên task>
  .setAction(async(taskArgs, hre) => { // hre luôn là đối số 2
    const account = web3.utils.toChecksumAddress(taskArgs.account);
    const balance = await web3.eth.getBalance(account);

    console.log(web3.utils.fromWei(balance, "ether"), "ETH");
  })
// Chạy task bằng npx hardhat balance --account <address>
// Các tham số mandatory k được theo sau các optional para
// Các tham số positional k được theo sau variadic para

// Có thể định nghĩa trực tiếp tương tự như dùng setAction
task(
  "hello",
  "Prints 'Hello, World!'",
  async function (taskArguments, hre, runSuper) {
    console.log(taskArguments); // Nhiều param sẽ vào đây thành 1 object
    console.log("Hello, World!");
  }
  // hàm 3 có taskArguments, hre đã biết, còn runSuper là hàm override lên 1 hàm đã có, nếu chạy hàm này thì sẽ chạy hàm bị override luôn.
).addParam("account","test param thui")

// Để 1 task hoạt động thì hàm đó k thể return 1 promise trước khi 1 hàm async nào đó bên trong chạy chưa xong
// Holy shit: task bên dưới nó trả ra 1 promise, ta hiểu nhầm. Cái hàm thứ 3 trả ra undefined vì nó k return gì cả; task = <chỉ tên function/khai báo function> đồng bộ sẽ trả ra typeof function là hàm đó; Còn task = async <function> thì task đó vẫn là 1 function nhưng khi gọi nó task() thì nó lại return ra promise. Và cái ý của nó ở đây là task() khi gọi mà return ra 1 promise trong khi 1 hàm async nào đó chưa chạy xong thì k thỏa mãn. Ở dưới setTimeout chưa chạy xong bên trong sẽ k thỏa mãn và bị lỗi
task("BAD", "This task is broken", async () => {
  setTimeout(() => {
    throw new Error(
      "This task's action returned a promise that resolved before I was thrown"
    );
  }, 1000);
});
// VD đây là 1 action bị lỗi vì task return hàm trước khi setTimeout chạy xong
// Ta có thể fix bằng cách thế này thì khi gọi task() nó sẽ chạy luôn promise và k return promise trước khi chạy hết hàm setTimeout
task("delayed-hello", "Prints 'Hello, World!' after a second", async () => {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      console.log("Hello, World!");
      resolve();
    }, 1000);
  });
});
// Chạy với npx hardhat delayed-hello

// Check type
task("hello1", "Prints 'Hello' multiple times")
  .addOptionalParam(
    "times",
    "The number of times to print 'Hello'",
    1, // Tham số mặc định của times
    types.int // Xác định type của tham số truyền vào phải thỏa mãn => types này lấy từ hardhat/config
    // Nếu dùng npx hardhat hello1 --times notanumber => sẽ bị lỗi
  )
  .setAction(async ({ times }) => {
    for (let i = 0; i < times; i++) {
      console.log("Hello");
    }
  });

// task overriding k thể dổi parameter -> dùng khi cần mở rộng or thay dổi behaviour task cũ
task(
  "hello",
  "Prints 'Hello, World!'",
  async function (taskArguments, hre, runSuper) {
    if(runSuper.isDefined)
      runSuper({account: "test param nè"});
    // Nếu k truyền tham số cho runSuper, nó sẽ lấy tham số của cha luôn. Phải truyền dạng object cho các tham số
    console.log("Hello, World!");
  }
  // Hàm 3 có taskArguments, hre đã biết, còn runSuper là hàm override lên 1 task đã có, nếu chạy hàm này thì sẽ chạy hàm bị override luôn
)
// Hàm override k được khai báo param nào cả vì task nó k cho đổi params, ta cứ gọi là tự gọi vào task khai báo sau. task override chỉ cần trùng tên, k cần trùng description
// Khi chạy hàm vẫn phải khai báo đầy đủ para của task gốc

task("hello-world", "Prints a hello world message").setAction(
  async (taskArgs, hre) => {
    console.log(hre);
    await hre.run("print", { message: "Hello, World!" });
    // hre.run để gọi 1 subtask, đối số 2 là tham số truyền vào subtask
  }
);
subtask("print", "Prints a message")
  .addParam("message", "The message to print")
  .setAction(async (taskArgs) => {
    console.log(taskArgs.message);
  });
// Chạy với npx hardhat hello-world
// Chơi cả subtask k hiện ra trên help, tái sử dụng được ở nh task

// console.log(hre.ethers); // K dùng được trực tiếp ở ngoài

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {},
    development: {
      url: 'http://127.0.0.1:8545',
    },
    quorum: {
      url: 'http://127.0.0.1:22000',
    },
  },
  solidity: {
    compilers: [{
        version: "0.5.5"
      },
      {
        version: "0.6.7",
        settings: {}
      }
    ], // Set compile nh phiên bản. Nếu trùng 2 số đầu thì dùng, nếu k sẽ dùng phiên bản cao nhất
    overrides: {
      "contracts/Greeter.sol": {
        version: "0.8.4",
        settings: {}
      }
    }, // Compile specific contract nào phiên bản nào nhưng lệnh này k hoạt động
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 20000,
  },
};