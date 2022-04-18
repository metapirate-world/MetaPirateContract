pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    event SetMember(string name, address member);
    event SetUserPermit(address user, string permit, bool enable);

    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
        emit SetMember(name, member);
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
        emit SetUserPermit(user, permit, enable);
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}
