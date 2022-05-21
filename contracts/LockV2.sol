pragma solidity 0.8.10;

contract LockV2 {
    bool internal _initialized;
    uint256 internal _totalBalance;
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
        duration[msg.sender] = block.timestamp + (duration_in_seconds * 1 seconds);
        
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No Token has been deposited in locking account");
        require(duration[msg.sender] < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        duration[msg.sender] = 0;
        address payable to = payable(msg.sender);
        to.transfer(currentBalance);

        emit Withdraw(msg.sender, currentBalance);
    }

    //Forces withdrawal but penalises the user if the hold duration has not ealpsed
    function forceWithdraw() public {
        require(balances[msg.sender] > 0, "No Token has been deposited in locking account");

        uint256 currentBalance = balances[msg.sender];
        uint256 penalty = 0;
        if(duration[msg.sender] < block.timestamp){
            penalty = currentBalance * 1/50;
        }

        balances[msg.sender] = 0;
        duration[msg.sender] = 0;
        address payable to = payable(msg.sender);
        to.transfer(currentBalance - penalty);

        emit Withdraw(msg.sender, currentBalance - penalty);
    }

    function withdrawTo(address payable _to) public {
        require(_to != address(0), "Invalid destination account");
        require(balances[msg.sender] > 0, "No Token has been deposited in locking account");
        require(duration[msg.sender] < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        duration[msg.sender] = 0;

        _to.transfer(currentBalance);

        emit Withdraw(_to, currentBalance);
    }

    function balance() public view returns(uint256){
        return balances[msg.sender];
    }
}