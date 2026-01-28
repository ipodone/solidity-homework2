// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title 讨饭合约
 * @notice 这是代币合约、不是NFT合约
 */
contract BeggingContract is Ownable {

    // todo error

    // 记录捐赠者及捐赠金额
    mapping(address => uint256) donations;

    // event
    event Donated(
        address indexed donor,
        uint256 amount,
        uint256 totalDonationAmount,
        string transferType
    );

    // 
    event Withdrawed(address indexed owner, uint256 amount);


    // 初始化合约所有者
    constructor() Ownable(msg.sender) {}

    // donate
    function donate() external payable {
        // 检查金额
        require(msg.value > 0, "Donation amount must be greater than 0");
        // 用户捐赠金额累加
        donations[msg.sender] += msg.value;
        // 触发捐赠事件
        emit Donated(msg.sender, msg.value, donations[msg.sender], "donate transfer");
    } 

    // receive 函数 - 允许合约直接接收以太币
    receive() external payable {
       // 用户捐赠金额累加
       donations[msg.sender] += msg.value;
    // 触发捐赠事件
        emit Donated(msg.sender, msg.value, donations[msg.sender], "recevie transfer");
    }

    // 合约所有者提取所有金额
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        // 检查合约余额
        require(balance > 0, "No balance");
        // 把合约余额转给所有者
        // payable(owner()).transfer(balance);
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");
        // 触发取款事件
        emit Withdrawed(msg.sender, balance);
    }

    // 查询某个地址的捐赠金额
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    // 查询合约余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}