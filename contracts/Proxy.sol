pragma solidity 0.8.10;
import "./StorageSlot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Proxy{
    bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    
     bytes32 private constant _ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor(address _owner, address _impl) {
        _admin(_owner);
        _implementation(_impl);
    }

    function _admin(address admin) internal {
        StorageSlot.setAddressAt(_ADMIN_SLOT, admin);
    }

    function _implementation(address implementation) internal {
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation);
    }

    function setAdmin(address admin) public onlyAdmin{
         StorageSlot.setAddressAt(_ADMIN_SLOT, admin);
    }

    function getAdmin() public view returns(address) {
        return StorageSlot.getAddressAt(_ADMIN_SLOT);
    }

    modifier onlyAdmin(){
        require(msg.sender == getAdmin(), 'Invalid Admin!');
        _;
    }
    
    function setImplementation(address implementation) public onlyAdmin{
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation);
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressAt(_IMPL_SLOT);
    }


    function _delegate(address implementation) internal {
        assembly {
            let ptr := mload(0x40)

            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), implementation, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {revert(ptr, size)}
            default{return(ptr, size)}
        }
    }

    function _fallback() internal virtual {
        _delegate(getImplementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }
}