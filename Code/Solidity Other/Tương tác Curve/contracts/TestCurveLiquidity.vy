# @version ^0.2
from vyper.interfaces import ERC20
# Trong vyper có sẵn built-in interface là ERC20 và ERC721 mà ta có thể import được như trên
# có thể import interface từ chính contract hiện tại với import <tên contract này> as <tên>
# from contracts import <tên contract> as <tên> : là import contract trong thư mục contracts cùng cấp thư
# mục hiện tại. Khi import 1 contract trong vyper nó cũng tự động convert contract đó thành interface bằng cách
# sinh ra contract tương tự y hệt nhưng body chỉ có pass

interface StableSwap:
  def add_liquidity(amounts: uint256[3], min_lp: uint256): nonpayable
  def remove_liquidity(lp: uint256, min_amounts: uint256[3]): nonpayable
  def remove_liquidity_one_coin(lp: uint256, i: int128, min_amount: uint256): nonpayable
  def calc_withdraw_one_coin(lp: uint256, i: int128) -> uint256: view
  def get_virtual_price() -> uint256: view
#interface gọi các hàm của curvev

interface CurveToken:
  def balanceOf(account: address) -> uint256: view

# StableSwap3Pool là địa chỉ pool chứa 3 loại coins bên dưới
SWAP: constant(address) = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
LP: constant(address) = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490

DAI: constant(address) = 0x6B175474E89094C44Da98b954EedeAC495271d0F
USDC: constant(address) = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
USDT: constant(address) = 0xdAC17F958D2ee523a2206206994597C13D831ec7

TOKENS: constant(address[3]) = [
  DAI,
  USDC,
  USDT
]

# VD approve của USDT k return True mà các coin khác lại có thì vyper báo lỗi nên phải dùng raw_call check như dưới
@internal
def _safeApprove(token: address, spender: address, amount: uint256):
  res: Bytes[32] = raw_call(
    token,
    concat(
        method_id("approve(address,uint256)"),
        convert(spender, bytes32),
        convert(amount, bytes32),
    ),
    max_outsize=32,
  )
  if len(res) > 0:
      assert convert(res, bool)


@external
def addLiquidity():
  tokens: address[3] = TOKENS
  balances: uint256[3] = [0, 0, 0]
  for i in range(3):
    balances[i] = ERC20(tokens[i]).balanceOf(self)
    if balances[i] > 0:
      # USDT does not return True
      # ERC20(tokens[i]).approve(SWAP, balances[i])
      self._safeApprove(tokens[i], SWAP, balances[i])
  StableSwap(SWAP).add_liquidity(balances, 1)
  # add toàn bộ balance và min LP token nhận về sẽ là 1


@external
@view
def getShares() -> uint256:
  return CurveToken(LP).balanceOf(self)
  # gọi vào interface của contract LP token, lấy balance LP của contract này


@external
def removeLiquidity():
  shares: uint256 = CurveToken(LP).balanceOf(self)
  minAmounts: uint256[3] = [0, 0, 0]
  StableSwap(SWAP).remove_liquidity(shares, minAmounts)


@external
@view
def calcWithdrawOneCoin(i: int128) -> (uint256, uint256):
  shares: uint256 = CurveToken(LP).balanceOf(self)
  w: uint256 = StableSwap(SWAP).calc_withdraw_one_coin(shares, i)
  vp: uint256 = StableSwap(SWAP).get_virtual_price()
  return (w, vp * shares / 10 ** 18)
# Hàm này nhận vào index của coin muốn lấy và trả ra lượng coin nhận được bằng 2 cách nên trả ra 2 giá trị
# Cách thứ 2 nó tính vp là số lượng token mà 1 share(LP) có thể rút ra nhân với shares là ra tổng lượng coin rút được
# Hàm get_virtual_price: sẽ lấy D là total amount of coin when they equal price / total supply của LP token

@external
def removeLiquidityOneCoin(i: int128):
  shares: uint256 = CurveToken(LP).balanceOf(self)
  minAmount: uint256 = 1
  StableSwap(SWAP).remove_liquidity_one_coin(shares, i, 1)


@external
@view
def getBalances() -> uint256[3]:
  tokens: address[3] = TOKENS
  balances: uint256[3] = [0, 0, 0]
  for i in range(3):
    balances[i] = ERC20(tokens[i]).balanceOf(self)
  return balances