// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    address public tokenOwner;
    address public buyerAddress;
    uint public lockDuration;
    uint public tokenPriceToEth;
    uint public tokenAmount;
    mapping(address=>bytes) public txData;
    mapping(bytes=>bool)public isWaiting;
    mapping(bytes=>uint)public tokenAmountData;
    bytes internal encdData;


    constructor() ERC20("MyToken", "MTK") {
        lockDuration = (1 days)/24;
        tokenOwner = msg.sender;
        _mint(address(this), 10000000 * 10 ** decimals());
        tokenPriceToEth = 1000;  //1 Eth = 1000 MyTokens 
    }

    function orderTokens()public payable returns(bytes memory){

        require(msg.value*(tokenPriceToEth)<=10000*10**decimals(),"Can not buy tokens more than 10,000");
        require(msg.value>0,"Provide more than zero ether");

        buyerAddress = msg.sender;
        tokenAmount = msg.value*(tokenPriceToEth);
        isWaiting[encodeTransactionData(tokenAmount)] = true;    //this will put data in queue
        encdData = encodeTransactionData(tokenAmount);
        tokenAmountData[encdData] = tokenAmount;
        return encdData;  //It will return encoded data which will be required in order to collect tokens after one hour
    }

    function collectTokens(bytes calldata data)public{                                    //user has to provide encoded data returned from ordering tokens
        (uint _amount,uint _time,address _addr) = abi.decode(data, (uint,uint,address));
        require(block.timestamp>=_time + 1,"Lock duration is not satisfied");             //check if lock time criteria is satisfied or not
        require(!isWaiting[encodeTransactionData(tokenAmount)],"Order tokens first");     //check if the order of tokens is valid or not
        require(tokenAmountData[data]==_amount,"Invalid data");                           //check the amount of tokens

        _transfer(address(this),_addr,_amount);
        isWaiting[encodeTransactionData(tokenAmount)] = false;
    }


    function encodeTransactionData(uint _amount) internal returns (bytes memory) {

        bytes memory encodedData = abi.encode(_amount,block.timestamp,msg.sender);
        txData[msg.sender] = encodedData;
        return encodedData;
    }

    function decodeTransactionData(bytes memory data)internal pure returns (uint _amount,uint _time,address _addr) {
        (_amount,_time,_addr) = abi.decode(data, (uint,uint,address));
    }

    function getUserData(address _addr)public view returns(uint,uint,address){   //Will return token that user ordered, time of ordering and his address
        return decodeTransactionData(txData[_addr]);
    }

}