const DeveloperFactory = artifacts.require('./DeveloperFactory.sol')

module.exports = function(deployer){
    deployer.deploy(DeveloperFactory);
}

// Trong mạng test ganache, nó cho mỗi block 1 transaction chứ k gom nhiều tx vào 1 block như mạng real
