// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract A{
    // # Basic
    string public name = "hello";
}
// trong VSC với solidity extension chi compile k deploy đc, phải dùng thêm tool khác để deploy
// Có thể dùng tool run and deploy của extension remix của vsc -> có option connect vào custom 
// network với các tool Ganache, Truffle, Hardhat or connect to remix website or connect vào wallet luôn
// Để connect vào remix website thì phải mở remix lên và đổi sang namespace localhost để kết nối thế thì thà
// dùng remix trên web luôn cho nhanh
// connect vào ví thì nó sẽ cung cấp URI để kết nối vào ví
// Dùng cái này tốt nhất là connect vào các tool custom network

// Extension: F5 để compile contract hiện tại or ctrl+f5 để compile mọi solidity contracts