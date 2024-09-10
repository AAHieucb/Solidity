/* 
VD UpgradeabilityContract hoàn chỉnh
Initializable của openzeppelin cung 1 modifier chỉ dùng trong constructor or các hàm init ở lần đầu tiên (k thể chạy 1 hàm 2 lần) => nó k cản recursive. Điều này là do các contract proxy và contract gọi bằng proxy k có hàm constructor, nên mọi contract có logic constructor khi gọi bằng proxy đều phải thêm Initializable. Khi deploy contract xong phải gọi init cho nó setup các thứ. Do đó mới có hàm kẹp vừa set proxy vừa thực hiện 1 tx nào đó 
Context của openzeppelin lấy msgsender và msgdata thôi
Thư viện Address cung utility cho address
Ownable cung biến owner khi khởi tạo là msg.sender

Proxy contract sẽ delegate call tới các contract khác, k có constructor
UpgradableProxy kế thừa từ proxy tức nó có khả năng delegatecall tới 1 hàm của contract khác, nó lại cung thêm 1 biến lưu địa chỉ contract để delegatecall tới
TransparentUpgradeableProxy kế thừa UpgradableProxy nhưng cung thêm biến admin. Chỉ admin mới được đổi địa chỉ contract. Do đó các hàm trong UpgradableProxy toàn là internal ở tầng dưới và TransparentUpgradeableProxy kế thừa để dùng. 
=> Chung quy lại là TransparentUpgradeableProxy cung 1 admin được quyền update địa chỉ contract để gọi delegatecall mà thôi

ProxyAdmin kế thừa Ownable, nó có 1 owner là người có thể gọi hàm update của TransparentUpgradeableProxy để update contract chính gọi bằng delegatecall.
=> Tức là ProxyAdmin có owner là EOA của dev, còn TransparentUpgradeableProxy có admin là address contract ProxyAdmin

SafeMathUpgradeable là contract Math bth hoàn toàn k thêm gì hết.
ContextUpgradable kế thừa Initializable y hệt Context, việc kế thừa Initializable chỉ để đảm bảo nó gọi hàm __Context_init 1 lần, mà bên trong lại chả làm gì cả
OwnableUpgradeable kế thừa ContextUpgradable và Initializable, nó giống hệt contract Owner bth nhưng do các contract gọi bằng proxy đều k có constructor nên phải kế thừa Initializable để viết constructor trong hàm init
Tương tự ERC20Upgradeable kế thừa Initializable, ContextUpgradeable, IERC20Upgradeable và nội dung constructor viết trong hàm __ERC20_init có modifier initializer, còn lại y hệt ERC20 bth

DAILogic1 và DAILogic2 ké thừa ERC20Upgradeable để làm nó thay đổi được, kế thừa thêm OwnableUpgradeable vì chỉ owner được phép mint nên cần biến owner và contract đó cũng có thể upgrade.
DAIProxy kế thừa TransparentUpgradeableProxy ngoài ra chả làm gì cả. Tức là contract này có biến admin sẵn sàng update địa chỉ contract chính là DAILogic bất cứ lúc nào, tùy ý gọi hàm contract chính thông qua delegatecall

DAIProxyAdmin kế thừa ProxyAdmin để gọi các hàm của DAIProxy
*/

// # Viết test trong truffle

const DAILogic1 = artifacts.require('DAILogic1');
const DAILogic2 = artifacts.require('DAILogic2');

const DAIProxy = artifacts.require('DAIProxy');
const DAIProxyAdmin = artifacts.require('DAIProxyAdmin');

// Nhanh: DAIProxy có implementation là contract DAILogic1, mọi người có thể gọi hàm của DAILogic1 thông qua DAIProxy -> DAIProxy có admin là contract DAIProxyAdmin, contract DAIProxyAdmin có thể gọi hàm update implementation của DAIProxy để đổi sang contract DAILogic2 -> DAIProxyAdmin có owner là người có thể gọi hàm update đó (chứ kp ai cũng gọi được)

// Quy trình: deploy DAILogic1 -> Deploy DAIProxyAdmin có owner là tài khoản proxyAdmin -> Deploy DAIProxy lấy admin là DAIProxyAdmin, implementation là DAILogic1 -> thế là mọi người gọi hàm của DAILogic1 thông qua address DAIProxy -> deploy DAILogic2 -> admin gọi được hàm update của DAIProxyAdmin, hàm update đó gọi sang DAIProxy đổi implementation sang địa chỉ mới là DAILogic2 -> mọi người vẫn gọi được hàm của DAILogic2 thông qua DAIProxy address k đổi
contract('DAI Proxy', ([proxyAdmin, daiOwner, user, someuser]) => {
  it('DAI Proxy', async () => {
    // deploy DAILogic1
    let dai = await DAILogic1.new({ from: someuser });
    // someuser là owner của DAILogic1, chỉ nó mới được mint DAI, đây chỉ là xử lý logic riêng của ERC20 thôi

    // deploy DAIProxyAdmin
    let daiProxyAdmin = await DAIProxyAdmin.new({ from: proxyAdmin });

    // Get bytes of initialize('DAI', 'DAI')
    let data = await dai.contract.methods.initialize('DAI', 'DAI').encodeABI();

    // deploy DAIProxy
    let daiProxy = await DAIProxy.new(dai.address, daiProxyAdmin.address, data, {
      from: daiOwner,
    });
    // contract DAIProxyAdmin là admin của DAIProxy
    // daiOwner là người deploy contract DAIProxy nhưng chả có vai trò gì cả, ta dùng deploy cho tiện thôi

    // create DAILogic1 instance at daiProxy.address
    let realDai = await DAILogic1.at(daiProxy.address);

    // Mint 1000 for user
    await realDai.mint(user, '1000', { from: daiOwner });

    // check user's balance = 1000
    assert.equal(await realDai.balanceOf(user), '1000');

    // deploy DAILogic2
    let daiLogic2 = await DAILogic2.new({ from: someuser });

    // upgrade daiProxy's implementation to daiLogic2
    await daiProxyAdmin.upgrade(daiProxy.address, daiLogic2.address);

    // mint 1000 for user
    await realDai.mint(user, '1000', { from: daiOwner });

    // check user's balance = 3000
    assert.equal(await realDai.balanceOf(user), '3000');
  });
});
