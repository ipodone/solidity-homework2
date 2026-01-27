// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 我的代币
 * @notice 我们自己的代币合约在进行转账时，区别于sepolia直接转账：
 * @notice 1、转账时，不转ETH代币（即此处显示ETH为0）、转的是我们自己的代币数量
 * @notice 2、但转账时，实际的gas费用，仅能通过ETH结算
 * @notice 3、我的代币合约的交易（此时to显示合约地址）、区别于ETH直接的转账交易（此时to显示账户地址）
 */
contract MyToken {

    // 不一致的余额
    error InsufficientBalance(uint256 available, uint256 required);
    // 不一致的授权
    error InsufficientAllowance();
    // 无效的零地址
    error InvalidZeroAddress();

    // 代币名称 - MyToken
    string public name;
    // 代币标识 - MTK
    string public symbol;
    uint8 private constant DECIMALS = 18;
    // 代币最供应量 - 1000
    uint256 public toalSupply;

    // 余额信息
    mapping(address => uint256) public balances;
    // 授权信息
    mapping(address => mapping(address => uint256)) public allowances;

    // 合约所有者
    address public owner;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 铸造事件
    event Mint(address indexed to, uint256 amount);

    // 只有合约所有者可以调用
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev 初始化代币名称、代币标识、代币最供应量、合约所有者
     * @param _name 代币名称
     * @param _symbol 代币标识
     * @param _initialSupply 代币初始供应量
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        toalSupply = _initialSupply * 10**uint256(DECIMALS);
        owner = msg.sender;
        balances[msg.sender] = toalSupply;
        emit Transfer(address(0), msg.sender, toalSupply);
    }

    /**
     * @dev 查询余额
     * @param account 账户地址
     * @return 余额
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @dev 转账
     * @param to 转账账户
     * @param amount 转账金额
     * @return true或false
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert InvalidZeroAddress();
        if (balances[msg.sender] < amount) revert InsufficientBalance(balances[msg.sender], amount);

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev 授权
     * @param spender 被授权者
     * @param amount 授权金额
     * @return true或false
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) revert InvalidZeroAddress();

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev 授权转账
     * @param from from转账账号
     * @param to to转账账户
     * @param amount 转账金额
     * @return true或false
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (from == address(0)) revert InvalidZeroAddress();
        if (to == address(0)) revert InvalidZeroAddress();
        if (balances[from] < amount) revert InsufficientBalance(balances[from], amount);
        if (allowances[from][msg.sender] < amount) revert InsufficientAllowance();

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 铸造（仅合约所有者有此权限）
     * @param to 转账账户
     * @param amount 转账金额
     * @return true或false
     */
    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        if (to == address(0)) revert InvalidZeroAddress();

        toalSupply += amount;
        balances[to] += amount;

        emit Transfer(address(0), to, amount);
        return true;
    }
    // 测试过程：
    // 1、部署 2、按函数测试
}