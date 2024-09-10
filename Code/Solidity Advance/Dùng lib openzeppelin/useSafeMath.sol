pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// # Library / Dùng lib openzeppelin

contract UseSafeMath{
    using SafeMath for uint;
    function cal() public pure returns(uint){
        uint a = 1;
        uint b = 2;
        return b.sub(a);
    }

    using SafeCast for uint;
    function castToUint8(uint _a) public pure returns(uint8) {
        return _a.toUint8();
    }
}
