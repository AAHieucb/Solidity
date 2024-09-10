pragma solidity >=0.7.0 <0.9.0;

// # Kế thừa class
// B kế thừa A. Tùy mô hình khác nhau sẽ khác nhau
contract A{
    function getContractName() public pure virtual returns(string memory){
        return "Contract A";
    }
    
    string public name;
    constructor(string memory _name) {
        name = _name;
    }
}

// contract B is A("Name from B"){ // nếu muốn truyền giá trị cho constructor ngày từ đây
contract B is A{
    // override thì phải đổi A thành virtual và thêm keyword override
    function getContractName() public pure override returns(string memory){
        return "Contract B";
    }
    
    constructor(string memory _name) A(_name) { // Truyền fixed "" nếu muôn
        
    }
}
