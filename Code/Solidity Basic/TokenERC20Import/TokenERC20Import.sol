pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract TokenFromImport is ERC20{
    function decimals() public view virtual override returns (uint8) {
        return 20;
    }
    constructor(uint256 initialSupply) ERC20("Hieu","NTH"){
        _mint(msg.sender, initialSupply);
        // _mint(msg.sender, 100*10**(decimals());
    }
}