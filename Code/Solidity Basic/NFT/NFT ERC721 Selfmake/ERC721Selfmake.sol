// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyContext.sol";
import "./MyERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./IERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

// Trong OpenZeppelin có nhiều các lib có sẵn cung các tính năng hay vd enumerable cho ta duyệt qua các token. Vd ERC721Burnable ta tự implement trong này r.
// Hàm beforeTokenTransfer của ERC-721, ta tự hỏi là để làm gì? Thực chất là khi ta thêm các extensions mở rộng cho contract của ta thì sẽ cần đến hàm này. Vd: thêm enumerable thì phải gắn thêm index vào các hàm để lưu lại trong 1 mapping mà duyệt. Thế chẳng lẽ viết vào từng hàm 1. K, trước khi transfer, ta lưu lại thông tin vào biến mapping để duyệt, tất cả thao tác trong 1 hàm chung là beforeTokenTransfer
contract MyERC721 is MyContext, MyERC165, IERC721, IERC721Metadata, IERC721Enumerable{
    // Utilities
    modifier _checkBound(uint256 index, uint length){
        require(index < length, "Out of bound");
        _;
    }
    function _addEnumerableWhenMint(address to, uint tokenId) internal {
        allTokenIndexes[tokenId] = totalToken.length;
        totalToken.push(tokenId);
        tokenOwnerEnumerable[to].push(tokenId);
        tokenIndexes[tokenId] = balanceOf(to);
    }
    // Quá đơn giản, dùng mapping để lưu ngược value=>index còn mảng lưu [index]=value
    function _removeEnumerableWhenBurn(address from, uint tokenId) internal {
        uint tempIndex = allTokenIndexes[tokenId];
        totalToken[tempIndex] = totalToken[totalToken.length - 1];
        delete totalToken[totalToken.length - 1];
        tempIndex = tokenIndexes[tokenId];
        delete tokenIndexes[tokenId]; // mapping và array đều delete được, nhưng k cần delete mapping làm gì
        uint lastIndex = tokenOwnerEnumerable[from].length - 1;
        tokenOwnerEnumerable[from][tempIndex] = tokenOwnerEnumerable[from][lastIndex];
        delete tokenOwnerEnumerable[from][lastIndex];
        // Thiếu update allTokenIndexes của phần tử cuối sau khi đảo lên đầu => ngáo à, cái này là mapping thì cần gì xóa, thực tế tokenId bị xóa luôn mà nên gán là 0 cũng được. Như trên delete mapping tokenIndexes nhưng chả để làm gì vì xóa r nên chả đụng nữa
    }
    // Đây là cách lưu hay, cứ tách nhiều mapping với array ra lưu là ok
    function _addEnumerableWhenTransfer(address from, address to, uint tokenId) internal {
        uint tempIndexOfFrom = tokenIndexes[tokenId];
        uint lastIndexOfFrom = tokenOwnerEnumerable[from].length - 1;
        tokenOwnerEnumerable[from][tempIndexOfFrom] = tokenOwnerEnumerable[from][lastIndexOfFrom];
        delete tokenOwnerEnumerable[from][lastIndexOfFrom];
        tokenOwnerEnumerable[to].push(tokenId);
        tokenIndexes[tokenId] = balanceOf(to);
    }
    function _mint(uint tokenId) internal {
        _balances[_msgSender()] += 1;
        _owners[tokenId] = _msgSender();
    }
    function _transfer(address from, address to, uint tokenId) internal {
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        _approvedAccounts[tokenId] = address(0);
    }
    function _isApprovedOrOwner(address from, uint tokenId) internal view {
        address owner = ownerOf(tokenId);
        require(owner == _msgSender() || _approvedAccounts[tokenId] == owner || _approvedAccountsAll[owner][_msgSender()] == true,
            "You are not allowed");
        require(from == ownerOf(tokenId), "Original address doesn't own token");
    }
    modifier _onlyOwner(uint tokenId) {
        require(_owners[tokenId] == _msgSender(), "You are not owner");
        _;
    }
    
    // IERC721Enumerable
    // Giải quyết vấn đề: muốn xóa phần tử có giá trị chỉ định. Rõ ràng ta dùng mapping[địa chỉ sở hữu][index để duyệt] = tokenId => bh muốn xóa 1 tokenId, ta phải duyệt 1 vòng for rất dễ dàng vì forloop solidity ez như C++. Tuy nhiên phần tử càng nhiều thì for loop càng chậm, do đó ta dùng 1 mapping khác lưu ngược lại tokenId => index thì sẽ ez hơn
    // => Đó là cách truy xuất 1 phần tử mảng tránh gas vô tận khi mảng quá lớn. Ở đây chỉ thêm bộ nhớ lưu còn tốc độ thì ok
    // Dù càng nhiêu phần tử càng tốn gas nhưng cách thứ 2 sẽ nhanh và tốn ít hơn cách 1.
    uint256[] private totalToken;
    mapping(address => uint[]) private tokenOwnerEnumerable;
    mapping(uint => uint) private tokenIndexes;
    mapping(uint => uint) private allTokenIndexes;
    function totalSupply() public view override returns(uint256){ // Lấy tổng lượng token đang có ở thời điểm hiện tại
        return totalToken.length;
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) _checkBound(index, tokenOwnerEnumerable[owner].length) 
    public view override returns(uint256 tokenId){
        return tokenOwnerEnumerable[owner][index];
    }
    function tokenByIndex(uint256 index) _checkBound(index, totalToken.length) public view override returns(uint256){
        return totalToken[index];
    }
    function _beforeTokenTransfer(address from, address to, uint tokenId) internal {
        // mint lần đầu
        if(from == address(0)){
            _addEnumerableWhenMint(to, tokenId);
        }// burn
        else if(to == address(0)){
            _removeEnumerableWhenBurn(from, tokenId);
        }// normal transfer
        else{
            _addEnumerableWhenTransfer(from, to, tokenId);
        }
    }
    
    // MyERC165
    function supportsInterface(bytes4 interfaceId) public view override(MyERC165, MyIERC165) returns(bool){
        // Phải override 2 cái vì metadata có kế thừa cả interface gốc nên phải thực hiện các hàm của interface gốc
        return interfaceId == type(MyERC165).interfaceId || super.supportsInterface(interfaceId);
    } // Kế thừa hẳn contract r nên hàm này thừa
    
    // ERC721
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balances;
    mapping(uint => address) private _approvedAccounts;
    mapping(address => mapping(address => bool)) private _approvedAccountsAll;
    modifier existedToken(uint tokenId) {
        require(_owners[tokenId] != address(0), "This token haven't minted yet");
        _;
    }
    modifier validAddress(address address_) {
        require(address_ != address(0), "Invalid address");
        _;
    }
    function baseURL() internal pure returns(string memory){
        return "";
    }
    function mint(uint tokenId) public validAddress(_owners[tokenId]) {
        _beforeTokenTransfer(address(0), _msgSender(), tokenId);
        _mint(tokenId);
    }
    function safeMint(uint tokenId) public validAddress(_owners[tokenId]) {
        _checkOnERC721Received(address(0), _msgSender(), tokenId, "");
        _beforeTokenTransfer(address(0), _msgSender(), tokenId);
        _mint(tokenId);
    }
    // Burn là ta gửi vào address 0 -> thế thì vẫn mint đc sau khi burn. Ta có thể thêm biến bool để xác định đã burn k thể mint tiếp cx đc
    function burn(uint tokenId) public _onlyOwner(tokenId){
        // Bhủ của tokenId mới đc burn
        _beforeTokenTransfer(_msgSender(), address(0), tokenId);
        _balances[_msgSender()] -= 1;
        _approvedAccounts[tokenId] = address(0);
        delete _owners[tokenId]; // Hàm delete thực ra là gán giá trị hiện có về giá trị mặc định là 0
    }
    
    // openzeppelin-contracts
    using Address for address;
    using Strings for uint256; // Dùng openzeppelin Strings tha hồ chuyển sang string
    
    //IERC721Metadata
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) { // tên biến truyền vào hàm k đc trùng với các tên hàm
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view override returns(string memory){
        return _name;
    }
    function symbol() public view override returns (string memory){
        return _symbol;
    }
    // Override this function only => return tokenURI by baseURL + Id + "suffix of file (json)";
    function tokenURI(uint256 tokenId) existedToken(tokenId) public view override returns (string memory){
        return bytes(baseURL()).length > 0 ? string(abi.encodePacked(baseURL(), tokenId.toString())) : "";
    }
    
    // IERC721
    function balanceOf(address owner) validAddress(owner) public view override returns (uint256 balance){
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) existedToken(tokenId) public view override returns(address owner) {
        return _owners[tokenId];
    }
    function transferFrom(address from, address to, uint256 tokenId) public override 
    validAddress(from) validAddress(to) existedToken(tokenId){
        // Luôn tạo tên ra như thế này: check dễ hơn, k phải gọi lại nhiều lần
        _isApprovedOrOwner(from, tokenId);
        _beforeTokenTransfer(from, to, tokenId);
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public override
    validAddress(from) validAddress(to) existedToken(tokenId){
        _isApprovedOrOwner(from, tokenId);
        _checkOnERC721Received(from, to, tokenId, "");
        _beforeTokenTransfer(from, to, tokenId);
        _transfer(from, to, tokenId);
    }
    // Nếu ở đây ta cần thao tác mạnh vói chuỗi như cắt chuỗi thì dùng datalocation là calldata 
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override{
        _isApprovedOrOwner(from, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
        _beforeTokenTransfer(from, to, tokenId);
        _transfer(from, to, tokenId);
    }
    // Cho ai sở hữu chung token đang sở hữu
    function approve(address to, uint256 tokenId) public override validAddress(to) _onlyOwner(tokenId){
        require(ownerOf(tokenId) == _msgSender(), "You are not owner");
        require(_msgSender() != to, "You cannot approve to yourself");
        _approvedAccounts[tokenId] = to;
    }
    function getApproved(uint256 tokenId) existedToken(tokenId) public view override returns (address operator){
        return _approvedAccounts[tokenId];
    }

    // cho ai sở hữu chung tất cả mọi token nếu bh or sau này người này sở hữu
    function setApprovalForAll(address operator, bool _approved) public override validAddress(operator){
        _approvedAccountsAll[_msgSender()][operator] = _approved;
    }
    function isApprovedForAll(address owner, address operator) public override view returns (bool){
        return _approvedAccountsAll[owner][operator];
    }
    
    // Hàm check ERC721Receiver
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) { // hàm của thư viện address
            // Cách dùng try vừa khai báo luôn 1 hàm. Đb là k return true sau khi biết nó có nhận mà cứ để v
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    /*Cơ chế: to là nơi ta gửi đến. Ta có thể gửi đến 1 account người dùng thì mặc định là nhận được. Nhưng nếu gửi vào 1 địa chỉ contract thì phải check xem địa chỉ đó có chịu nhận ERC721 k, vì nhiều ứng dụng mà có khả năng thao tác với NFT 721 thì địa chỉ contract nó dùng phải đc implement khă năng nhận ERC-721
    Cơ chế tương tự ERC165: contract to phải được implement hàm có signature là:
    onERC721Received(address,address,uint256,bytes) và xử lý nhận ERC721 rồi return ra bytes4
    IERC721Receiver.onERC721Received.selector => Do đó, nó gọi hàm onERC721Received của tại địa chỉ của contract, nếu hàm này có signature như v sẽ return true, nếu chưa implement thì báo lỗi k có hàm, ta catch error đó và revert như trên
    Hàm onERC721Received nhận vào address operator có ý nghĩa, address from có thế là 0, 1 uint và bytes memory*/
}
// Đặt là: _x thì storage var, x là tên hàm, x_ là tham số hàm, _x_ là biến tạo tạm thời
