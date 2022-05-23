pragma solidity 0.8.10;

import "./LockV1.sol";

contract LockV2 is LockV1{
    //Forces withdrawal but penalises the user if the hold duration has not ealpsed
    function forceWithdraw() public {
        UserInfo memory user = userInfo[msg.sender];
        require(user.balance > 0, "No Token has been deposited in locking account");

        uint256 currentBalance = user.balance;
        uint256 penalty = 0;
        if(user.duration > block.timestamp){
            penalty = currentBalance * 1/50;
            currentBalance = currentBalance - penalty;
        }

        user.balance = 0;
        user.duration = 0;
        address payable to = payable(msg.sender);
        to.transfer(currentBalance);

        emit Withdraw(msg.sender, currentBalance);
    }

    function withdrawTo(address payable _to) public {
        UserInfo memory user = userInfo[msg.sender];
        require(_to != address(0), "Invalid destination account");
        require(user.balance > 0, "No Token has been deposited in locking account");
        require(user.duration < block.timestamp, "Token not mature for withdrawal");

        uint256 currentBalance =user.balance;
        user.balance = 0;
        user.duration = 0;

        _to.transfer(currentBalance);

        emit Withdraw(_to, currentBalance);
    }
}