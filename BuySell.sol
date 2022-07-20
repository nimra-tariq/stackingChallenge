// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./XToken.sol";

contract BuySellX is Ownable {

    event BuyTokens(address buyer,uint256 amountOfEth,uint256 amountOfTokens);
    event SellTokens(address seller,uint256 amountOfEth,uint256 amountOfTokens);

    //Buy X for 0.01 Eth
    uint256 constant public pricePerToken = 10000000000000000 wei;

    XToken public xToken ;
    constructor(address addressXToken) {
        xToken = XToken(addressXToken);
    }

    //user can buy X token
    function buyTokens() public payable {
      // require(msg.value>500 wei,"too small amount");
      uint256 amountOfTokens = msg.value / pricePerToken;
      require(xToken.balanceOf(address(this)) >= amountOfTokens,"BuySell don't have enough Tokens");
      xToken.transfer(msg.sender,amountOfTokens);
      emit BuyTokens(msg.sender,msg.value,amountOfTokens);
      
    }

    //user can sell token back to BuySell contract
    function sellTokens(uint256 _tokenAmount) public {
    uint256 priceOfTokens = pricePerToken*_tokenAmount;
    //checking if contract has enough eth for buying tokens
    require(address(this).balance >= priceOfTokens,"BuySell don't have enough eth");
    //seller must approve BuySell contract for XToken
    xToken.transferFrom(msg.sender,address(this),_tokenAmount);
    //transfer amount to seller
    payable(address(msg.sender)).transfer(priceOfTokens);
    emit SellTokens(msg.sender,priceOfTokens,_tokenAmount);
    }
}

