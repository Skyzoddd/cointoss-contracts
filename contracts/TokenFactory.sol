// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CoinTossToken.sol";

contract TokenFactory {
    address public platformWallet;
    uint256 public tokenSupply = 1_000_000_000 * 10 ** 18;
    uint256 public initialMarketcapUSD = 2400;
    uint256 public ethPriceUSD = 3000;

    event TokenCreated(address token, address owner, uint256 percentPurchased);

    constructor(address _platformWallet) {
        platformWallet = _platformWallet;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 percentToBuy,
        address router
    ) external payable returns (address) {
        require(percentToBuy > 0 && percentToBuy <= 100, "Invalid percentage");

        // Calcul du montant ETH requis (simulation USD)
        uint256 tokenPriceUSD = (initialMarketcapUSD * percentToBuy) / 100;
        uint256 requiredETH = (tokenPriceUSD * 1 ether) / ethPriceUSD;

        require(msg.value >= requiredETH, "Not enough ETH sent");

        // Déploiement du token
        CoinTossToken token = new CoinTossToken(name, symbol, tokenSupply, router);

        // Envoi des tokens à l'utilisateur
        uint256 userTokens = (tokenSupply * percentToBuy) / 100;
        token.transfer(msg.sender, userTokens);

        // Paiement à la plateforme
        payable(platformWallet).transfer(msg.value);

        emit TokenCreated(address(token), msg.sender, percentToBuy);
        return address(token);
    }
}
