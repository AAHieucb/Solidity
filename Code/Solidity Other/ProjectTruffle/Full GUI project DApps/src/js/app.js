//cái này thật ra ta tự code được hết, chẳng qua nó dùng jquery + web3 nên mới thấy code lạ thôi
// tương tác từ contract sang giao diện htmls
App = {
  web3Provider: null,
  contracts: {},

  init: async function () {
    // lấy dữ liệu file data json và điền vào các thẻ về thông tin
    $.getJSON('../pets.json', function (data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');
      for (i = 0; i < data.length; i++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-breed').text(data[i].breed);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-location').text(data[i].location);
        petTemplate.find('.btn-adopt').attr('data-id', data[i].id);
        petsRow.append(petTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function () {
    // Modern dapp browsers... Nếu user xài trình duyệt xin or dùng metamask thì window.ethereum tồn tại
    //lại là webapi
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try { // Request account access 
        await window.ethereum.enable();
      } catch (error) { // User denied account access... 
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers... Nếu window.ethereum k tồn tại tức ng dùng đang dùng trình dapp cũ như Mist hay MetaMask 
    //phiên bản cũ
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache. K có Web3 instance thì k dùng web3 đc, ta phải tạo
    // web3 bằng local provider của ta
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  }, //chạy xong 2 hàm init đến đây là ng dùng có thể tương tác với ethereum qua web3 r

  initContract: function () {
    // tương tác với contract nào: @truffle/contract là thư viện có sẵn trong truffle giúp tạo instance của contract
    //Ta đừng tưởng occho là đọc file solidity nhé, thực ra khi build nó thành json hết và để kết nối ứng dụng của ta
    //với contract solidity chỉ cần đọc file json đó như này mà thôi. Tương tác với nó bằng cách 
    //dùng module @truffle/contract của nodejs. Ta dùng cdn ở đây
    $.getJSON('Adoption.json', function (data) {
      var AdoptionArtifact = data;
      // artifact là những thông tin về hợp đồng như địa chỉ và ABI của nó. ABI giao diện nhị phân là 1 object js xác 
      //định các tương tác với hợp đồng. Truyền artifact vào TruffleContract() sẽ khởi tạo 1 instance của contract
      App.contracts.Adoption = TruffleContract(AdoptionArtifact);
      // Set the provider for our contract bằng giá trị App.web3Provider vừa lưu lúc nãy khi init web3
      App.contracts.Adoption.setProvider(App.web3Provider);
      // Use our contract to retrieve and mark the adopted pets
      return App.markAdopted(); //hàm markAdopted của app nếu thú cưng đã đc nhận nuôi từ trc.
      //ta gọi nó ở hàm riêng bên dưới vì ta cần cập nhật giao diện mỗi lần đổi dữ liệu data truyền vào hàm
    });
    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function () { //hàm lấy danh sách pet nhận nuôi và cập nhật giao diện. Dễ hiểu r
    var adoptionInstance;
    //check đã deployed rồi thì gọi hàm getAdopters lấy giá trị trả về xem cái nào đã nhận nuôi thì chỉnh sưa
    App.contracts.Adoption.deployed().then(function (instance) {
      adoptionInstance = instance;
      return adoptionInstance.getAdopters.call();//call là hàm gọi k thực hiện giao dịch
    }).then(function (adopters) {
      for (i = 0; i < adopters.length; i++) {
        if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
        }
      }
    }).catch(function (err) {
      console.log(err.message);
    });
  },

  handleAdopt: function (event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    var adoptionInstance;
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Adoption.deployed().then(function (instance) {
        adoptionInstance = instance;
        // Execute adopt as a transaction by sending account 
        return adoptionInstance.adopt(petId, {//k dùng call vì đây thực hiện 1 giao dịch
          from: account
        });
      }).then(function (result) {
        return App.markAdopted();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  }
};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
//để có 1 instance contract ta phải: TruffleContract(<data từ file json of contract>) khi tương tác với browser mới dùng 
//dc v rồi-> const instance = await MyContract.deployed(); const result = await instance.someFunction(5); để gọi 1
//transaction. call bth thì gọi 1 hàm k tốn gas. 
//Thực ra trong web3 cũng có hàm thực hiện 1 transaction, k cần đến truffle contract cx đc nhưng dùng với browser thì
//muốn gọi hàm nên dùng truffle-contract cho tiện