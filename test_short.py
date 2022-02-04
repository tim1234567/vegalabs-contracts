import brownie


def test_short(deployer, shorter, mockUSDT, mockBTC):

    mockUSDT.approve(shorter, 10_000e6, {"from": deployer})
    shorter.short(10_000e6, 1, {"from": deployer})
    mockUSDT.approve(shorter, 10_000e18, {"from": deployer})
    with brownie.reverts():
        shorter.short(10_000e18, 2, {"from": deployer})
