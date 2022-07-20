// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
pragma solidity ^0.8.7;

contract XToken is ERC20 {

    constructor() ERC20("XToken","X"){
        //minted 100000X tokens
        _mint(msg.sender,100000);
    } 
    
}