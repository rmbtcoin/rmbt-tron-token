// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Migrations {
    address public owner;
    uint public last_completed_migration;

    constructor() {
        owner = msg.sender;
    }

    function setCompleted(uint _completed) public {
        last_completed_migration = _completed;
    }

    function upgrade(address newAddress) public {
        require(msg.sender == owner, "Only owner can upgrade");
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(last_completed_migration);
    }
}
