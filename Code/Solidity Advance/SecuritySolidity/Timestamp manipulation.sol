// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Timestamp manipulation

// Game này là mn mất phí để spin, nếu spin đúng lúc block.timestamp chia hết cho 15 thì sẽ nhận được toàn bộ tiền
contract Roulette {
    uint public pastBlockTime;

    constructor() payable {}

    function spin() external payable {
        require(msg.value >= 1 ether); // must send at least 1 ether to play
        require(block.timestamp != pastBlockTime); // only 1 transaction per block. 1 block chỉ có 1 timestamp

        pastBlockTime = block.timestamp;
        // Giả sử trong 1 block có 2 người cùng spin thì người 1 nếu k thỏa mãn thì pastBlockTime mang giá trị block đó và trans người spin sau thực hiện trong cùng block sẽ thất bại luôn từ require
        // Còn nếu người đó trúng thì những người sau cũng trúng nhưng cùng block và k được nhận nx

        if (block.timestamp % 15 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}
// Để ý số 15 nếu tăng lên hay giảm đi cũng chính là tăng hay giảm xs spin trúng. Tuy nhiên các miner có cách tăng tỉ lệ trúng của mình vì họ có thể thêm trans vào và mine với constraint là timestamp sẽ phải lớn hơn timestamp block trước và k quá xa trong tương lai vì ethereum mine 1 block mất trung bình 15s. Miner là người đào block có quyền quyết định timestamp cho block nên họ cố tình để 1 số timestamp cho block chia hết cho 15 và nếu họ may mắn mine được ra block đó thì họ sẽ win. Còn node bth k can thiệp được vào timestamp. Giả sử miner đó có 30% năng lượng đào tức tỉ lệ họ mine block thành công hay tỉ lệ win của họ là 30% lớn hơn 1/15 của người chơi bth rất nhiều. Miễn là tx họ mine thành công thì chắc chắn họ sẽ thắng game. Do đó kinh nghiệm là không nên dùng timestamp cho random và luôn biết rằng các miner có thể chọn được timestamp cho block tiếp theo của họ

// Tuy nhiên, trong ethereum có 15-second rule. Do mạng lưới nó tạo ra refuse timestamp > 15 trong tương lai và trung bình cx chỉ 15s 1 block. Tức miner có thể chọn set timestamp nhưng k thể quá 15s so với hiện tịa Nên nếu thời gian của app vary trong 1 khoảng lớn hơn 15s thì có thể dùng được timestamp. 
// VD ở trên là 20 thì miner sẽ chọn trong 15s sau có timestamp nào chia hết cho 20 thì lấy và thêm vào block, do 20>15 nên có những khoảng mà k có giá trị nào chia hết cho 20 cả nhưng khi có thì họ vẫn ưu tiên lấy được => TH trên k được dùng timestamp