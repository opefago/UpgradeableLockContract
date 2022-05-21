pragma solidity 0.8.10;

contract LockV1 {
    bool internal _initialized;
    mapping(address => uint256) internal balances;
    mapping(address => uint256) internal duration;

    event Deposit(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);
    
    function initialize() public {
        require(!_initialized);
        _initialized = true;
    }

    function deposit(uint256 duration_in_seconds) external payable {
        require(balances[msg.sender] == 0, "Withdraw existing tokens before depositing another");

        balances[msg.sender] = msg.value;
        duration[msg.sender] = block.timestamp + duration_in_seconds * 1 seconds;
        
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No Token has been deposited in locking account");
        require(duration[msg.sender] < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        duration[msg.sender] = 0;
        (bool resp, ) = msg.sender.call{value: currentBalance}("");

        require(resp, "Transaction Failed!");

        emit Withdraw(msg.sender, currentBalance);
    }

    function balance() public view returns(uint256){
        return balances[msg.sender];
    }
}