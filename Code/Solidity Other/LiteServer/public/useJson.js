// # Dùng liteserver

// Để fetch API trong javascript -> big problems. Trước tiên ta cần xét file javascript của ta dùng để làm gì? 
// Nếu file javascript của ta dùng cho front end thì phải xác định có file html -> dùng hàm fetch bth và chạy bằng file html đó, sẽ fetch được và console.log response xem trên Console của trình duyệt. Còn nếu file js dùng cho backend nodejs -> thì phải cài module node-fetch@2.0 sau đó dùng: const fetch = require("node-fetch"); mới dùng fetch được (bản v18 đã có sẵn fetch)
// Bản chất: fetch là 1 hàm thuộc về web API có sẵn trong browser chứ kp của bản thân server hay client gì cả. Nếu ta chạy client k dùng trình duyệt mà dùng cái gì khác k hỗ trợ WebAPI thì sẽ k hoạt động. Do đó ta fetch ở react app của nodejs, fetch ở file js xong chạy file html thì đều được, nhưng ở mọi file js bth ta chạy node <tên file>.js đều k được, là vì ta k dùng đến trình duyệt nên k bản thân nodejs k có sẵn webAPI như browser. Cụ thể chạy file đó k tương tác gì với trình duyệt mà chỉ hiện ở console. Ở react-app tạo bởi nodejs lại chạy được vì vẫn bật trên trình duyệt mà, chứ chạy node <file đó> thì vẫn k đc thôi. Do đó muốn fetch mà k tác động tới trình duyệt thì install node-fetch or dùng các module thư viện khác như axios

// Khi ta chạy live-server thì thực chất nó dựng 1 server ảo ở port 5500 tăng dần lên. Server này chỉ GET được từ cây thư mục gốc vì nó server toàn bộ thư mục. Ta có thể GET server như dưới:
// curl -X GET "http://127.0.0.1:5500/LiteServer/public/data.json"

// Thực tế, file .json cx hoạt động như 1 local server khi ta mở file đó bằng trình duyệt, lấy nó như thế này
// curl -X GET "file:///B:/Solidity/Solidity%20Other/LiteServer/public/data.json" => uri mở bằng browser. Tương tự vì máy của ta lúc này như 1 browser còn trình duyệt như 1 client v nhưng chỉ có điều k dùng http request

fetch('./sontung.jpg').then(res => console.log(res)); // => Miễn tương tác với trình duyệt là dùng đc fetch

// Để lấy dữ liệu của file json, nếu từ xa thì ta fetch đến file json đó. Để lấy file json local dùng trong dự án, ta chỉ cần link tới nó bth là được.
// Để dùng javascript phía client truy cập vào 1 file json:
// C1: dùng hàm fetch đến file data.json đó sau đó chạy bằng trình duyệt là đc => dùng được cả remote, cả local
// C2: cdn cái axios rồi dùng để GET đến file data.json đó éo cần dùng trình duyệt => cả remote, cả local
// C3: lưu data json dưới dạng string trong js vào 1 biến r script tới cả file đó nx, sau đó lấy ra bằng JSON.parse và JSON.stringify để gán lại nó, thế là vẫn đọc vẫn update data như bth. Nhưng như v, nó sẽ restart sau mỗi lần thao tác vì vc thay đổi biến này k làm thay đổi database dữ liệu thực => chỉ dùng local. 
// Để dùng với js server: 
// C1: dùng module fs để read file như read file bth r JSON parse nó => dùng như 1 database luôn nhưng read write khó
// C2: dùng const data = require("./data.json"); => cách này lưu vào 1 biến nên k write đc
// C3: dựng 1 json server or lite server cho data json đó => vừa như 1 server có GET POST, vừa như 1 database có thể chỉnh sửa data

data = JSON.parse(data);
console.log(data);