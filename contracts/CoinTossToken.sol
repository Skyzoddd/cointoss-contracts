// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Router {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract CoinTossToken is ERC20, Ownable {
    address public constant taxReceiver = 0xa6A9359B163E7c2a2295C56AFFAA38Fd5B05Fe13;
    uint256 public constant TAX_PERCENT = 1;
    uint256 public constant OWNER_ALLOCATION = 2;
    bool public launched = false;
    address public uniswapRouter;
    address public pairAddress;
    uint256 public marketCapUSD;

    mapping(address => uint256) public lastBuyTimestamp;

    event MarketCapTargetReached(address indexed token);
    event BuyLogged(address indexed buyer, uint256 timestamp);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address routerAddress
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(routerAddress != address(0), "Router required");
        uniswapRouter = routerAddress;

        uint256 ownerAmount = (totalSupply_ * OWNER_ALLOCATION) / 100;
        uint256 launchAmount = totalSupply_ - ownerAmount;

        _mint(msg.sender, launchAmount);
        _mint(taxReceiver, ownerAmount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 tax = (amount * TAX_PERCENT) / 100;
        uint256 rest = amount - tax;

        super.transfer(taxReceiver, tax);
        bool success = super.transfer(to, rest);

        if (msg.sender != taxReceiver && to != taxReceiver) {
            lastBuyTimestamp[to] = block.timestamp;
            emit BuyLogged(to, block.timestamp);
        }

        return success;
    }

    function launchOnUniswap() external payable onlyOwner {
        require(!launched, "Already launched");
        require(msg.value >= 0.2 ether, "Need at least 0.2 ETH to launch");

        _approve(address(this), uniswapRouter, balanceOf(address(this)));

        IUniswapV2Router router = IUniswapV2Router(uniswapRouter);
        router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(0xdead),
            block.timestamp + 360
        );

        renounceOwnership();
        launched = true;

        emit MarketCapTargetReached(address(this));
    }

    function setMarketCap(uint256 capUSD) external onlyOwner {
        marketCapUSD = capUSD;
    }

    receive() external payable {}
}
