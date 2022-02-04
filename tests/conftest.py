from enum import auto
import pytest
from brownie import (
    MockBTC,
    MockUSD,
    Shorter,
    Swapper,
    Vegalabs,
    Contract,
    interface,
    accounts
)


@pytest.fixture(scope="function", autouse=True)
def isolate_func(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass

@pytest.fixture(scope="function")
def mockUSDT(deployer):
    usdt = MockUSD.deploy("MockToken", "usdt", {"from": deployer})
    usdt.mint(100_000e6, {"from": deployer})
    yield usdt

@pytest.fixture(scope="function")
def mockBTC(deployer):
    btc = MockBTC.deploy("MockToken", "usdt", {"from": deployer})
    btc.mint(100_000e8, {"from": deployer})
    yield btc



@pytest.fixture(scope="function")
def deployer(accounts):
    yield accounts[0]


@pytest.fixture(scope="function")
def aggregator():
    feed = "0x007A22900a3B98143368Bd5906f8E17e9867581b"
    yield feed


@pytest.fixture(scope="function")
def swapper(deployer, mockUSDT, mockBTC, aggregator):
    swap = Swapper.deploy(aggregator, mockUSDT, mockBTC, {"from": deployer})
    mockUSDT.transfer(swap, 80_000e6, {"from": deployer})
    mockBTC.transfer(swap, 100_000e8, {"from": deployer})
    yield swap


@pytest.fixture(scope="function")
def vegalabs(deployer, aggregator):
    vega = Vegalabs.deploy(aggregator, {"from": deployer})
    yield vega
    

@pytest.fixture(scope="function")
def shorter(deployer, mockBTC, mockUSDT, swapper, vegalabs, aggregator):
    shorter = Shorter.deploy(swapper, vegalabs, aggregator, mockUSDT, mockBTC, {"from": deployer})
    yield shorter