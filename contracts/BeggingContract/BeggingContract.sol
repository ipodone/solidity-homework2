// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title 讨饭合约
 * @notice 这是代币合约、不是NFT合约
 * @notice 合约地址：0xd5F8806512F2Ce745702208eFD80b30Db72492d5
 */
contract BeggingContract is Ownable {

    // error todo

    // 记录捐款（捐赠者及捐赠金额）
    mapping(address => uint256) private donations;

    /**
     * @dev 捐款事件
     * @param donor 捐赠者
     * @param amount 捐赠金额
     * @param totalDonationAmount 所有捐赠金额
     * @param transferType 捐赠类型
     */
    event Donated(
        address indexed donor,
        uint256 amount,
        uint256 totalDonationAmount,
        string transferType
    );

    /**
     * @dev 合约所有者提取所有金额事件
     * @param owner 合约所有者
     * @param amount 提取金额
     */
    event Withdrawed(address indexed owner, uint256 amount);

    // modifier 使用Ownable

    /**
     * @dev 初始化合约所有者
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev 捐款函数 - 允许合约直接接收以太币（2、有data且donate函数存在时调用）
     */
    function donate() external payable {
        // 检查金额
        require(msg.value > 0, "Donation amount must be greater than 0");
        // 用户捐赠金额累加
        donations[msg.sender] += msg.value;
        // 触发捐赠事件
        emit Donated(msg.sender, msg.value, donations[msg.sender], "donate transfer");
    } 

    /**
     * receive函数 - 允许合约直接接收以太币（1、无data是调用）
     */
    // receive() external payable {
    //    // 用户捐赠金额累加
    //    donations[msg.sender] += msg.value;
    //     // 触发捐赠事件
    //     emit Donated(msg.sender, msg.value, donations[msg.sender], "recevie transfer");
    // }

    /**
     * receive函数 - 允许合约直接接收以太币（3、有data且donate函数不存在时调用）
     */
    // fallback() external payable {
    //    // 用户捐赠金额累加
    //    donations[msg.sender] += msg.value;
    //     // 触发捐赠事件
    //     emit Donated(msg.sender, msg.value, donations[msg.sender], "recevie transfer");
    // }

    /**
     * @dev 合约所有者提取所有金额
     */
    function withdraw() external onlyOwner payable { // 这里无需使用paybale，没有实际用处
        uint balance = address(this).balance;
        // 检查合约余额
        require(balance > 0, "No balance");
        // 把合约余额转给所有者
        payable(owner()).transfer(balance);
        // 推荐使用下面两行代码（call+require） 替换 上面一行代码（trasfer）
        // (bool success, ) = payable(owner()).call{value: balance}("");
        // require(success, "Transfer failed");
        // 触发取款事件
        emit Withdrawed(msg.sender, balance);
    }

    /**
     * @dev 查询某个地址的捐赠金额
     * @param donor 捐赠者
     * @return 捐赠金额
     */
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    /**
     * @dev 查询合约金额
     * @return 合约金额
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}