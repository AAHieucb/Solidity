// SPDX-License-Identifier: BSD-4-Clause
pragma solidity >=0.8.0;

import "./ABDK64x64.sol";

// # Math trong solidity
//Chú ý là library luôn dùng hàm internal vì nó như là 1 phần của contract luôn
contract FloatNumber{
    //ABDK64x64lib cho ta dùng float.
    //Để tính: chuyển đổi số từ uint thành kiểu của nó-> tính toán
    //Để lấy kết quả ở front end: lấy trực tiếp và dịch bit để lấy giá trị 
    //Để lấy kết quả trong solidity-> gọi hàm chuyển sang uint là xong
    //Tức là kết quả ta lấy là uint nhưng quá trình tính nó tính như float
    //VD: (8/16)*2 -> ra là 0 trong solidity nhưng dùng thư viện nó tính float va ra 1. 
    function test(uint a) public pure returns(uint){
        uint b = 16;
        return ABDKMath64x64.toUInt(
            ABDKMath64x64.mul(
            ABDKMath64x64.div(ABDKMath64x64.fromUInt(a), ABDKMath64x64.fromUInt(b)),
            ABDKMath64x64.fromUInt(2)));
    }
    function test1(uint a) public pure returns(uint){//truyền 8 vào 2 hàm đẻ test
        return (a/16)*2;
    }
    //các hàm có u là unsigned. Nó hỗ trợ cả âm dương

    //tính loga lấy phần nguyên
    //Cách occho
    function fakeLogaOf(uint x) public pure returns(uint n){
        for (n = 0; x > 1; x >>= 1) n += 1;
        //dịch bit binary của x. Vì để tạo ra 1 số binary nó chia đôi liên tục đến khi dư 1 thì mới
        //ghi 1 vào. Số lần chia đôi chính là số các chữ số của binary nên dịch bit hết là số lần 
        //chia đổi. Tính chất, số các bit binary của n bằng log2(n)
    }
    //Cách tiết kiệm gas
    function logaOf(uint x) public pure returns(uint n){
        if (x >= 2**128) { x >>= 128; n += 128; }
        if (x >= 2**64) { x >>= 64; n += 64; }
        if (x >= 2**32) { x >>= 32; n += 32; }
        if (x >= 2**16) { x >>= 16; n += 16; }
        if (x >= 2**8) { x >>= 8; n += 8; }
        if (x >= 2**4) { x >>= 4; n += 4; }
        if (x >= 2**2) { x >>= 2; n += 2; }
        if (x >= 2**1) { /* x >>= 1; */ n += 1; }
        // Vd: x = 2**129 thì n = 128, x dịch vào 128 bit còn 1 bit vì ban đầu có 129 bit theo tính
        //chất chạy tiếp vào vòng if cuối-> n = 129
        //tưng đây lần if là đủ xử 1 số max 2**256 bit
    }

    //để tính cả phần phân số, có nhiều cách nhưng đm lấy mẹ ABDK cho nhàn
    function logaFull() public pure returns(uint){
        uint a = 10;
        return ABDKMath64x64.toUInt(
            ABDKMath64x64.mul(
            ABDKMath64x64.log_2(
            ABDKMath64x64.fromUInt(a)), ABDKMath64x64.fromUInt(4))
        );
        //do loga của 10 nó tính cả phần thập phân nên nhân 4 lên ms là 13 đó
    }

    //hoán vị
    uint public u = 1;
    uint public q = 2;
    function test() public {
        (u, q) = (q, u);
    }
}