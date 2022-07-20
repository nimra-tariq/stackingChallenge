// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
pragma solidity ^0.8.7;

contract XXToken is ERC20 {

    constructor() ERC20("XXToken","XX"){
        //minted 100000XX tokens
        _mint(msg.sender,100000);
    } 
    
}