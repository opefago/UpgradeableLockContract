pragma solidity 0.8.14;

contract LockV1 {
    bool internal _initialized;
    uint256 internal _totalBalance;
    mapping(address => uint256) internal balances;
    mapping(address => uint256) internal duration;
    
    function initialize() public {
        require(!_initialized);
        _initialized = true;
    }

    function deposit(uint256 amount, uint256 duration_in_seconds) public {
        require(balances[msg.sender] == 0, "Withdraw existing tokens before depositing another");

        balances[msg.sender] = amount;
        duration[msg.sender] = block.timestamp + (duration_in_seconds * 1 seconds);
        
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No Token has been deposited in locking account");
        require(duration[msg.sender] < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        duration[msg.sender] = 0;
        address payable to = payable(msg.sender);
        to.transfer(currentBalance);
    }
}