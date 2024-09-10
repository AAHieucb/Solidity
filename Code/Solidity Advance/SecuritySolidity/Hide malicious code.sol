// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Hide malicious code

contract Foo {
    Bar bar;

    constructor(address _bar) {
        bar = Bar(_bar);
    }

    function callBar() public {
        bar.log();
    }
}
contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}

// This code is hidden in a separate file và chỉ publish phần trên lên etherscan
// Deploy Foo với address của Mal chứ kp Bar
contract Mal {
    event Log(string message);
    function log() public {
        emit Log("Mal was called");
        //malicious code goes here
    }
}
// Kinh nghiệm là kbh tin tưởng vào external address. Nếu 1 contract được tạo ra có external address thì phải kiểm chứng address đó có code khớp với code ta mong đợi k. Đặc biệt các address chưa được kiểm chứng. Do đó nền tảng nên publish code ra ngoài