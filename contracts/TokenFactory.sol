// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CointossToken.sol";

contract TokenFactory {
    address public platformWallet;
    uint256 public tokenSupply = 1_000_000_000 * 10 ** 18;
    uint256 public initialMarketcapUSD = 2400;
    uint256 public ethPriceUSD = 3000; // prix ETH estimé en USD

    event TokenCreated(address token, address owner, uint256 percentPurchased);

    constructor(address _platformWallet) {
        platformWallet = _platformWallet;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 percentToBuy
    ) external payable {
        require(percentToBuy > 0 && percentToBuy <= 100, "Invalid percentage");

        uint256 tokenPriceUSD = initialMarketcapUSD * percentToBuy / 100;
        uint256 requiredETH = (tokenPriceUSD * 1 ether) / ethPriceUSD;

        require(msg.value >= requiredETH, "Not enough ETH sent");

        // Deploy new token
        CointossToken token = new CointossToken(name, symbol, tokenSupply, msg.sender, platformWallet);

        // Transfer user's tokens
        uint256 userTokens = (tokenSupply * percentToBuy) / 100;
        token.transfer(msg.sender, userTokens);

        // Transfer platform fee (optional)
        payable(platformWallet).transfer(msg.value);

        emit TokenCreated(address(token), msg.sender, percentToBuy);
    }
}

}
