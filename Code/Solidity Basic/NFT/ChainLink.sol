pragma solidity ^0.8.0;

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBase.sol";
// Thay vì import từng file ta import link chính là remix tự động add cũng được nhưng k nên vì nó k bảo tồn lâu

// # Chainlink
contract RandomNumberConsumer is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    // lấy từ https://docs.chain.link/docs/vrf-contracts/#rinkeby
    constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
    /** 
     * Requests randomness 
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator. Hàm tự gọi sau đó để cập nhập giá trị randomness lưu vào đâu
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
// Để test -> lấy link token gửi cho contract này r gọi hàm getRandomNumber để cập nhập lấy số random và cũng lấy được ra qua fulfillRandomness 