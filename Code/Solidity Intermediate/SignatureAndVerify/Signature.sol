pragma solidity >=0.7.0 <0.9.0;

// # Basic / Verify signature

// 1 ví dụ dùng smart contract để verify signature: Tạo 1 message hash(tạo mess r hash nó) -> dùng tài khoản wallet của ta để ký message(off chain k tương tác với smart contract vì phải dùng pivkey) -> verify signature bằng smart contract để biết ai đã ký luôn
// Chú ý ở đây ta k tạo ra trans nào hết mà chỉ ký 1 message và verify nó, thực ra kể cả khi có trans thì nó cx chỉ lấy các thông tin bên trong và tạo trans hash r ký mà thôi, trans hash ở đây tương đương message hash của ta.
// Xác thực cx chỉ là làm ngược lại quá trình sign mà thôi, nó nhận vào chữ ký sau khi sign và message ban đầu -> tìm ngược lại người đã ký -> nếu người đã ký đúng tức đã chứng minh anh ta là người ký cái message này và signature của anh ta là đúng(anh ta đã phải dùng pivkey để ký giao dịch, anh ta đồng ý cho transaction(message) được thực hiện).
// Thực tế: người dùng tự tạo transaction và ký offline r online submit để các node verify tương tự

contract VerifySignature{
    function getMessageHash(address _to, uint _amount, string memory _message, uint nonce)
        public pure returns(bytes32) {
            return keccak256(abi.encodePacked(_to, _amount, _message, nonce));
        }
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function verify(address _signer, 
                    address _to, uint _amount, string memory _message, uint _nonce, 
                    bytes memory signature) public pure returns(bool) {
            // Lấy hash bth của message
            bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);

            // Các nền tảng thg có 1 format transaction hash khác nhau, bitcoin hay ethereum khác nhau và cấu trúc trans hash của ethereum nó như thế này cơ
            bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

            return recoverSigner(ethSignedMessageHash, signature) == _signer;
            // Hàm recover sẽ tìm ra signer từ signature và message hash theo cấu trúc của ethereum
            // Tức là ta dùng pivkey để ký trans xác nhận muốn thực hiện trans -> ai cx có thể vào check xem có đúng là ta đã ký trans hay k -> nếu 1 người khác mà ký trans thì sẽ sai vì k đúng pivkey
            // Ở đây kp là trans mà chỉ là message bth
        }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public pure returns(address) { 
            // bytes phải specific nơi lưu, bytes32 thì k vì 1 cái reference type và 1 cái primitive type
            (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
            return ecrecover(_ethSignedMessageHash, v, r, s);
            // ecrecover là built-in function trả ra address của người đã ký hash thành signature mà có thể lấy được giá trị r,s,v như v
        }
    function splitSignature(bytes memory sig) public pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        // signature trong ethereum phải có 65 bytes, 32 bytes đầu r, 32 sau là s, bytes cuối là v 
        
        // Dùng ngôn ngữ assembly để lấy bytes trong khoảng bao nhiêu từ
        assembly{
            r := mload(add(sig, 32)) // đọc 32 bytes tiếp theo từ vị trí số 32(bỏ qua 32 bytes đầu)
            s := mload(add(sig, 64)) // đọc 32 bytes tiếp theo từ vị trí byte số 64
            v := byte(0, mload(add(sig, 96))) // đọc 32 byte tiếp theo từ vị trí số 96 xong chỉ lấy mỗi giá trị ở byte đầu tiên vói hàm byte(<num>, <bytes>)
        }

        // Hàm mload sẽ lấy 32 bytes tiếp theo của cái gì
        // Hàm add(<var>,<pos>) trả ra con trỏ trỏ tới byte thứ <pos> của biến bytes <var>
        // bytes32 là biến lưu chuỗi ký tự có độ dài cố định
        
        // Tự ngầm trả về r,s,v vì đã khai báo rõ biến ở returns
    }
}

// Để test -> ký: truyền vào các tham số cho message để lấy message hash -> vào https://www.myetherwallet.com/wallet (để thao tác với giao diện) để dùng được các hàm ethereum -> gọi trong console của browser ethereum.enable()(deprecated r) or bản mới sẽ dùng ethereum.request({ method: 'eth_requestAccounts' }) -> gọi hàm ký: 
// hash = "<message hash>";account = "<address account ví meta mask của ta>"
// ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log);
// Ký và in ra giá trị signature đã được hash -> truyền vào hàm verify để check signer chuẩn k
// Metamask k hỗ trợ web3 để sign message nx nên k đc dùng. Có nhiều kiểu kkys, ở đây chỉ là 1 kiểu personal_sign

// Người dùng: nhận messageHash -> ký message bằng pivkey -> trả ra signature
// Người khác: nhận messageHash, nhận signature -> tính ra pubkey(address) của người đã ký transaction
// Pivkey là 1 thứ có thể mã hóa thông tin thành 1 đoạn mã mà từ đoạn mã đó có thể truy ngược lại pubkey cặp đôi với pivkey đó. Cơ chế của pivkey hay pubkey chỉ là thuật toán mã hóa mà thôi

// MD5: biến đầu vào string -> hash k đọc được. K truy ngược đc. H thì đã truy ngược được
// RSA: sinh cặp pivkey và pubkey. 1 key biến string -> k thể đọc. 1 key giải mã ngược key còn lại
// AES: cung 1 passphrase -> biến đầu vào thành k thể đọc. Truy ngược bằng cách cung lại passphrase đó

// Ta có thể tạo ra 1 system ký và xác thực như blockchain nếu muốn: dùng RSA sinh ra cặp key cho mỗi người dùng
// Người A dùng pivkey "ký"(mã hóa) message thành chuỗi hash + mã hóa pubkey thành chuỗi hash và nối 2 cái lại.
// Bất cứ 1 ai cx có thể tách ra, dùng pubkey của người A giải mã đoạn sau. Nếu đoạn sau ra trùng với pubkey đó luôn thì đúng là ông A ký cái này r.
// Hàm xác thực bên trên cơ ché chắc cũng tương tự, nó tách ra và so sánh đó nhưng thêm thắt phức tạp hơn thôi


/*TK pb:
Nhận vào message cho ra message hash
- Trong solidity code: messageHash là keccak(abi.encodePacked(<data>));
ethSignedMessageHash là keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", <messageHash>));
Nó nhận vào ethSignedMessageHash và signature là ra địa chỉ ví
- Trong Web3: chỉ cần request method personal_sign -> nhận vào mã messageHash là keccak(abi.encodePacked(<data>)); và địa chỉ ví là trả ra signature
- Web: signature of function -> chính là 4 bytes đầu của messageHash string là format của function đó keccak(abi.encodePacked(<transaction>)); => sign function thực chất cũng là sign messsage hash mà thôi
- Trong Ethereum wallet: là 1 kiểu hoàn toàn khác nó sign 1 message thành 1 cái thứ có thể đọc được xong verify được ai là người đã ký nó -> k liên quan gì ở đây
- Remix: sign truyền vào 1 message hash -> nhận ra signature thì message là message hash ban đầu truyền vào keccak(abi.encodePacked(<data>)); trả ra signature đúng còn mã hash nó trả ra về sau ta vẫn chưa hiểu nó là cái gì
=> Nch là code trong solidity là chuẩn r. Các thú khác chỉ là 1 công đoạn của code solidity mà thôi
 */