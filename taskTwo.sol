// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract MyToken is ERC20 {
    
    uint256 public immutable supply;
    uint public bal;
    mapping(address=>uint) public purchaseData;
    mapping(address=>uint) public claimedTokenInfo;
    mapping(address=>uint) public remainingTokensToClaim;

    address public address1;
    address public address2;
    address public address3;
    address public address4;
    address public address5;

    constructor() ERC20("MyToken", "MTK") {
        supply = 1000 * 10 ** decimals();

        address1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;  //defining initial address
        address2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        address3 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        address4 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        address5 = 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;

        _mint(address(this), supply/2);

        _mint(address1,((supply*5)/100));                       //minting tokens to defined addresses and storing their data about token mints
        purchaseData[address1] = ((supply*5)/100);
        remainingTokensToClaim[address1] = ((supply/2)*5)/100;

        _mint(address2,((supply*5)/100));
        purchaseData[address2] = ((supply*5)/100);
        remainingTokensToClaim[address2] = ((supply/2)*5)/100;

        _mint(address3,(supply/10));
        purchaseData[address3] = (supply/10);
        remainingTokensToClaim[address3] = ((supply/2)*5)/100;

        _mint(address4,(supply/10));
        purchaseData[address4] = (supply/10);
        remainingTokensToClaim[address4] = ((supply/2)*5)/100;

        _mint(address5,((supply*20)/100));
        purchaseData[address5] = ((supply*20)/100);
        remainingTokensToClaim[address5] = ((supply/2)*5)/100;

    }

    function claimTokens(uint _amount)public{
        bal = (totalSupply()*5/100);
        require(purchaseData[msg.sender]>0,"Invalid user");          //only defined wallets can claim the tokens
        require(_amount*10**decimals()<=remainingTokensToClaim[msg.sender],"Not enough capacity to buy tokens");  //the amount should be in the limit and the capacity for each wallet of 5% of half of the supply
        claimedTokenInfo[msg.sender] =claimedTokenInfo[msg.sender] + _amount*10**decimals();          //stores data about how much tokens the user have claimed
        _transfer(address(this),msg.sender,_amount*10**decimals());                                    //user claims tokens from the contract
        remainingTokensToClaim[msg.sender] = remainingTokensToClaim[msg.sender] - (_amount*10**decimals());   //stores data about how much tokens are remaining to be claimed by a user
    }

}