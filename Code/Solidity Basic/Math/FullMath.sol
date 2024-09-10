// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// # Math trong solidity
// Fullmath library -> có package uniswap về FullMath
contract FullMath {
    // Phantom overflow tính 3% của x
    function get3PercentOf(uint x) public pure returns(uint){
        // nếu x nhỏ thì x*3/100 là chuẩn
        // nếu x lớn gây overflow khi nhân 3 thì x/100*3 là ổn
        return x > (2**256-1)/3 ? x/100*3 : x*3/100;
    }
    // Cách làm trên là cùi bắp vì tính 3% ez, nếu 3.14% thì x*314/10000 và nếu 3.141592653542739847%
    // thì (2**256-1)/3141592653542739847 sẽ rất nhỏ và tính toán dần k chính xác. Giả sủ nó giảm
    // đến nhỏ hơn 100, khi đó nhỏ hơn 100 nếu nhân lên sẽ overflow ta buộc chia và x/100 = 0 làm kết
    // quả là 0, cách này vẫn chưa tốt.

    // Bản chuẩn của muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) public pure returns (uint256 result) {
        uint256 prod0; 
        uint256 prod1; 
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }
        require(denominator > prod1);
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        uint256 twos = (type(uint).max - denominator + 1) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }
        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;
        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; 
        inv *= 2 - denominator * inv; 
        inv *= 2 - denominator * inv; 
        inv *= 2 - denominator * inv; 
        inv *= 2 - denominator * inv;
        inv *= 2 - denominator * inv; 
        result = prod0 * inv;
        return result;
    }
}
