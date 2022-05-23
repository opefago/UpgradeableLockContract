pragma solidity 0.8.10;

contract LockV1 {
    bool internal _initialized;
    struct UserInfo {
        uint256 balance;
        uint256 duration;
    }

    mapping(address => UserInfo) internal userInfo;

    event Deposit(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);
    
    function initialize() public {
        require(!_initialized);
        _initialized = true;
    }

    function deposit(uint256 duration_in_seconds) external payable {
        UserInfo storage user = userInfo[msg.sender];
        require(user.balance == 0, "Withdraw existing tokens before depositing another");

        user.balance = msg.value;
        user.duration = block.timestamp + duration_in_seconds * 1 seconds;
        
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.balance > 0, "No Token has been deposited in locking account");
        require(user.duration < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance = user.balance;
        user.balance = 0;
        user.duration = 0;
        (bool resp, ) = msg.sender.call{value: currentBalance}("");

        require(resp, "Transaction Failed!");

        emit Withdraw(msg.sender, currentBalance);
    }

    function balance() public view returns(uint256){
         UserInfo storage user = userInfo[msg.sender];
        return user.balance;
    }
}