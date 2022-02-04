import brownie


# def test_short(deployer, shorter, mockUSDT, mockBTC):

#     mockUSDT.approve(shorter, 10_000e6, {"from": deployer})
#     shorter.short(10_000e6, 1, {"from": deployer})
#     mockUSDT.approve(shorter, 1_000e6, {"from": deployer})
#     with brownie.reverts():
#         shorter.short(1_000e6, 1, {"from": deployer})

def test_leverage(deployer, shorter, mockUSDT, mockBTC, swapper):
    mockUSDT.mint(1_000_000e6, {"from": deployer})
    # send amount collateral to shorter
    mockUSDT.transfer(shorter, 100_000e6, {"from": deployer})
    mockUSDT.approve(shorter, 20_000e6, {"from": deployer})
    shorter.addUSD(20_000e6, {"from": deployer})
    tx = shorter.short(20_000e6, 5, {"from": deployer})
    # print(tx.events["StateVerify"]["newAmountUSD"])
    # assert tx.events["StateVerify"]["newAmountUSD"] == 28_000e6 - 1_000e6
    # with brownie.reverts():
    #     shorter.short(1_000e6, 1, {"from": deployer})
    # shorter.short(10_000e6, 3, {"from": deployer})
    # shorter.short(1_000e6, 1, {"from": deployer})
    # with brownie.reverts():
    #     shorter.short(1_000e6, 1, {"from": deployer}) 
    # mockUSDT.approve(shorter, 30_000e6, {"from": deployer})
    # shorter.addUSD(28_000e6, {"from": deployer})
    # shorter.short(10_000e6, 3, {"from": deployer})
    # shorter.short(1_000e6, 1, {"from": deployer}) 
    # with brownie.reverts("!slippage"):
    #     shorter.short(1_000e6, 1, {"from": deployer})

def test_get_total_asset_usd(deployer, vegalabs):
    total = vegalabs.getTotalAssetUSD(80_000e6, 0, 20_000e6, {"from": deployer})
    assert total == 100_000e6

def test_get_total_asset_btc(deployer, vegalabs):
    total = vegalabs.getTotalAssetBTC(80_000e6, 0, {"from": deployer})
    assert total == 80_000e6

def test_get_target_btc(deployer, vegalabs):
    total = vegalabs.getTargetBTC(100_000e6, 41000e8, {"from": deployer})
    assert total == 24390243902439024

def test_get_slippage(deployer, vegalabs):
    slippage = vegalabs.getSlippage(70000000, 100000000, {"from": deployer})
    assert slippage == 30000000
