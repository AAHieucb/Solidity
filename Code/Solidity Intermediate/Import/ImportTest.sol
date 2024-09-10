pragma solidity >=0.7.0 <0.9.0;

import "./Foo.sol";

// # Basic / Dùng new
// Dùng constructor
contract TestImportBasic{
    Foo foo = new Foo(); // Tạo để có 1 instance đã, new này chính là deploy còn gì
    function getFooName() public view returns(string memory) {
        return foo.name();
    }
}

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
// import token ERC20 của ethereum => kế thừa để tạo token ERC20 của riêng ta 

contract MyToken is ERC20{
    constructor(uint256 initialSupply) ERC20("Hieu","No Symbol!!"){
        _mint(msg.sender, initialSupply);
    }
}
// Lỗi need to marked as abstract là phải tạo contructor cho nó, khi class kế thừa thì phải có constructor, chỉ có lớp trừu tượng chỉ để lớp khác kế thừa thì mới k có constructor thôi

// Master: khi contract A kế thừa contract B -> mà contract B có constructor có nhận đối số thì buộc phải viết constructor của contract B trong A, để khi gọi vào constructor của contract A sẽ gọi vào constructor của contract B
// Còn nếu constructor của B k có or có nhưng k nhận đối số thì contract A k nhất thiết phải có constructor vì khi deploy contract A nó cũng tự tạo instance của contract B của nó bị gộp chung vào như default k cần truyền thêm dữ liệu

// VD: A kế thừa B; constructor của B lại có payable -> payable của B sẽ kbh được dùng khi gọi từ A nếu A k là payable
// Khi A kế thừa B thì mọi hàm của B sẽ là của A, nếu ta gọi 1 hàm của B để truyền vào contract 1 lượng ether chẳng hạn thì lượng ether đó nằm trong contract A kế thừa B -> getBalance ở cả A và B đều cho ra lượng ether đó. Nó chỉ là 1 contract duy nhât
