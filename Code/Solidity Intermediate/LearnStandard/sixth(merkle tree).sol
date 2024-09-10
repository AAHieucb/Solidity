pragma solidity >=0.7.0 <0.9.0;

// # Other / Thử verify merkle tree tx trong solidity
contract Sixth{
    // Hàm check 1 trans có nằm trong block hay k: 1 là array of hash, vd có 8 trans cần verify trans thứ 3 thì array này chứa: hash của hash trans 1 và 2, hash của trans 4, hash của hash của hash trans 5,6,7,8; 2 là merkle root; 3 là leaf là hash của trans cần tính; 4 là index của hash ta sẽ check vị trí ở đây ta check vị trí số 3 có phải k nên index = 2 => tính từ 0
    // Đây chỉ là 1 vd test, còn thực tế, node sẽ lấy thông tin từ 1 fullnode neighbor về hash và merkle root để làm đối số chứ kp ta truyền vào chay như này
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
        // Ta lấy cái leaf -> nối thêm hash từng cái trong proof và SHA3 với nó -> cuối cùng được merkle root thì ss xem có bằng k
        bytes32 hash = leaf;
        
        // Đầu vào mảng proof kp theo thứ tự nhé mà là tỏa ra từ vị trí cần tính trở đi. VD ở đây check index số 3 thì truyền vào là hash index 4 xong đến hash index 1 và 2
        for(uint i = 0; i < proof.length; i++){
            if(index%2  == 0)
                hash = keccak256(abi.encodePacked(hash, proof[i]));
            else 
                hash = keccak256(abi.encodePacked(proof[i], hash));
                // Thứ tự quan trọng vì nó sẽ cộng 2 cái vào r thực hiện hash theo thứ tự tạo merkle root
            index = index/2;
        }
        
        return hash == root;
    }
}

contract TestMerkleProof is Sixth {
    bytes32[] public hashes;
    // Mảng lưu merkle tree dưới dạng liên tiếp từ dưới lên, trái sang phải lần lượt index mảng

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];
        // Giả sử có 4 transaction biểu diễn bằng string đi (thực tế nó hash nhiều thông tin)

        // Tạo và thêm các hàng tiếp theo bên trên của merkle tree vào mảng
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }
        uint n = transactions.length;
        uint offset = 0;
        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }
    
    // root là phần tử cuối cùng
    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    // Có 4 transaction -> ta lấy ra các giá trị trong mảng hash để check được(nhưng check làm éo gì vì ta tạo ra như này sai sao đc, hiểu cơ chế là được r) vị trí index = 3, 4 là proof và root và 2 để check
    /* verify
    3rd leaf
    0x1bbd78ae6188015c4a6772eb1526292b5985fc3272ead4c65002240fb9ae5d13

    root
    0x074b43252ffb4a469154df5fb7fe4ecce30953ba8b7095fe1e006185f017ad10

    index
    2

    proof
    0x948f90037b4ea787c14540d9feb1034d4a5bc251b9b5f8e57d81e4b470027af8 -> đây là hash của leaf thứ 4
    0x63ac1b92046d474f84be3aa0ee04ffe5600862228c81803cce07ac40484aee43 -> đây là hash leaf 1 và 2
    phải truyền đúng thứ tự như trên
    */
}
