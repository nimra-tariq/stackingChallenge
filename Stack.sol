// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./XToken.sol";
import "./XXToken.sol";

//stackinng native token is XX 
//assuming deployer has transfered XX Token to stacking
contract Stacking is Ownable {

    //total stacked tokens in pool 
    uint256 public totalStackedTokens;
    //total stackers in ppol
    uint256 public noOfStackers;
    //mapping stacker to his stacked amount of Tokens
    mapping (address=>uint256) public stacks;
    //mapping stacker to blockNumber 
    mapping (address=>uint256) public stackedAtBlock;
   
    //event StackToken
    event Stack(address stacker,uint256 amountOfStackTokens);
    //event UnStack Tokens
    event UnStack(address stacker, uint256 amountOfUnStackTokens);

    //checking if the caller is stacker 
    modifier isStacker(){
        require(stacks[msg.sender]>uint256(0),"caller is not a stacker");
        _;
    }

    //checking if the stacker can claim has pending reward
    modifier canClaim(){
        require(block.number-stackedAtBlock[msg.sender]>uint256(0),"you don't have pending reward");
        _;
    }
    
    //interacting with XToken and XXToken
    XToken public xToken;
    XXToken public xxToken;

    //constructor Stacking
    constructor(address addressXToken,address addressXXToken) {
        xToken = XToken(addressXToken);
        xxToken = XXToken(addressXXToken);
    } 

    //user can stake X receive XX
    function stack(uint256 amountOfTokens) public {

    //checking if stacking has enough xxTokens
    require(xxToken.balanceOf(address(this))>=amountOfTokens,"Stacking don't have enough xx Tokens");
  
    //stacker must have approved stacking for his XTokens
    //transfer x tokens to stacking
    xToken.transferFrom(msg.sender,address(this),amountOfTokens);

    //tranfer xx to stacker from 
    xxToken.transfer(msg.sender,amountOfTokens);

    //incrementing totalStackers if stacker is new
    if(stacks[msg.sender]==0){
        noOfStackers++;
    }
    totalStackedTokens += amountOfTokens; 
    stacks[msg.sender] += amountOfTokens;
    //the block number at which the stacker stacked 
    stackedAtBlock[msg.sender]= block.number;
    emit Stack(msg.sender,amountOfTokens);
    }

    //stacker can unstack his x-tokens 
    //@dev return stacker his stacked x-tokens receive his xx-tokens
    function unStack() public isStacker{
        //stackers stacked tokens
        uint256 amountOfTokens = stacks[msg.sender];
        //stacker must approve stacking for his xx tokens
        //receive xx-tokens
        xxToken.transferFrom(msg.sender,address(this),amountOfTokens);

        //checking if stacker has any pending reward
        if(block.number-stackedAtBlock[msg.sender]>uint256(0)){
            uint256 reward = _calculateReward();
            //transfer his reward and stacked x tokens
            xToken.transfer(msg.sender,amountOfTokens+reward);
            stackedAtBlock[msg.sender] = uint256(0);
        }
        else{
        //transfer stackers x-tokens back to stacking
        xToken.transfer(msg.sender,amountOfTokens);
        }

        noOfStackers--;
        //decrement stacked tokens
        totalStackedTokens -= amountOfTokens;
        stacks[msg.sender] = uint256(0);
        emit UnStack(msg.sender,amountOfTokens);
    }

    //calculate for stackers in pool
    function _calculateReward() private view returns(uint256 rewardPerBlock) {
        //checking if there's any stacker in pool
        require(noOfStackers>0,"there's no stacker in pool");
        //@dev amountOfStackerTokens will be equally distributed in all stackers
        uint256 noOfBlocksPassed = block.number - stackedAtBlock[msg.sender]; 
        uint256 _rewardPerBlock = (noOfBlocksPassed * 10**18) * totalStackedTokens / noOfStackers;
        return _rewardPerBlock;
    } 

    //@dev stacker can claim only if he has pending reward 
    function claim() public isStacker canClaim{
    uint256 reward = _calculateReward();
    //@dev tranfer xTokens to the stacker
    xToken.transfer(msg.sender,reward);
    //updating the block number for the stacker next time he claims
    stackedAtBlock[msg.sender] = block.number;
    }

}
