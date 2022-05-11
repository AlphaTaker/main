// SPDX-License-Identifier: MIT License
// Part of AlphaTaker.com demo environment (c) 2022-02-19

pragma solidity ^0.8.7;

contract Oracle{
    
    struct indicator{
        int256 number;
        uint256 decimals;
        uint256 sequenceId;
    }

    mapping(string => indicator) private _indicators;
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function setOwner(address owner_address) public {
        require(msg.sender == _owner, "Forbidden");
        _owner = owner_address;
    }

    function updateMarketData(string memory name, indicator memory value) public {
        require(msg.sender == _owner, "Forbidden");
        indicator memory old_value = _indicators[name];
        if( old_value.sequenceId + 1 == value.sequenceId || old_value.sequenceId == 0 ){
            _indicators[name] = value;
        }else{
            revert("Sequence error");
        }
    }

    function read(string memory name) public view returns(indicator memory) {
        return _indicators[name];
    }

}