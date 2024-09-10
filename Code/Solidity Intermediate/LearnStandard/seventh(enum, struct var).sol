pragma solidity >=0.7.0 <=0.9.0;

contract Seventh {
    // State pattern
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    Status public status; // Giá trị mặc định là giá trị đầu tiên của enum
    
    function ship() public {
        require(status == Status.Pending);
        status = Status.Shipped;
    }
    function accept() public {
        require(status == Status.Shipped);
        status = Status.Accepted;
    }
    function reject() public {
        require(status == Status.Shipped);
        status = Status.Rejected;
    }
    function cancel() public {
        require(status == Status.Pending);
        status == Status.Canceled;
    }
}

contract Todos{
    // # Basic / Dùng struct
    struct Todo {
        string text;
        bool completed;
    } // VD mapping chỉ cho ánh xạ 1 biến gán với 1 biến. Nếu ta muốn 1 tập hợp biến có qh với nhau thì dùng struct
    Todo[] public todos;
    function create(string memory _text) public {
        // todos.push(Todo(_text, false));
        todos.push(Todo({
            text: _text,
            completed: false
        }));
        // Cách khởi tạo kiểu object k quan tâm thứ tự biến và dễ nhìn hơn khi có nhiều var phức tạp
        /*// C3 là tạo biến và gán từng props, nhanh và dễ nhìn(3 cách tạo struct nhanh)
        Todo memory todo;
        todo.text = _text;
        // todo.completed = false; // Biến boolean mặc định là false nên k cần khởi tạo
        */
    }

    // Hàm get tự có get mặc định r
    // function get(uint _index) public view returns(string memory, bool) {
    function get(uint _index) public view returns(string memory textPrint, bool completed) {
        // Có biến ở returns làm nó in ra thêm thông tin biến nào là gì nx
        // K được returns(Todo) nhé => struct bắt buộc lấy từng phần tử
        Todo storage todo = todos[_index]; // Bất cứ lúc nào lấy state var là kiểu struct,.. đều phải có data location. Cái này là lấy trực tiếp từ state var, refer đến địa chỉ lưu chứ k copy j hết, đổi nó cx là đổi state var
        Todo memory todo2 = todos[_index];
        todo2.text = "Dont have any effect";
        // Ta có thể tùy ý dùng memory or storage nếu muốn biến copy hay đổi TT => cách copy biến
        return (todo.text, todo.completed);
    }
    function update(uint _index, string memory _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    } // Thay vì tạo 2 hàm gán true, false, ta tạo hàm toggle nó cho cả 2 TH sẽ tốt hơn
}
