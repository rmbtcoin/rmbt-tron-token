// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Proxy {
    // EIP-1967 standard storage slots
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor(address _implementation) {
        _setSlot(IMPLEMENTATION_SLOT, _implementation);
        _setSlot(ADMIN_SLOT, msg.sender);
    }

    modifier onlyAdmin() {
        require(msg.sender == _getAdmin(), "Only admin");
        _;
    }

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { impl := sload(slot) }
    }

    function _getAdmin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly { adm := sload(slot) }
    }

    function _setSlot(bytes32 slot, address val) internal {
        assembly { sstore(slot, val) }
    }

    function upgradeTo(address newImplementation) public onlyAdmin {
        _setSlot(IMPLEMENTATION_SLOT, newImplementation);
		emit Upgraded(newImplementation);
    }
	event Upgraded(address indexed newImplementation);

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        _setSlot(ADMIN_SLOT, newAdmin);
    }

    fallback() external payable {
        address impl = _getImplementation();
        require(impl != address(0), "Implementation not set");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
