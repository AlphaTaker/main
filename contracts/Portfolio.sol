// SPDX-License-Identifier: MIT License
// Part of AlphaTaker.com demo environment (c) 2022-02-19

pragma solidity ^0.8.7;

contract Portfolio{

    address private _owner;
    address private _strategy;

    event error(uint256 code);

    constructor() {
        _owner = msg.sender;
    }

    function setOwner(address owner_address) public {
        require(msg.sender == _owner, "Forbidden");
        _owner = owner_address;
    }

    function setStrategy(address strategy_address) public {
        require(msg.sender == _owner, "Forbidden");
        _strategy = strategy_address;
    }

    function claimToken(address token_address, uint256 amount) public {
        require(msg.sender == _owner, "Forbidden");
        (bool call_success, bytes memory transfer_data) = address(token_address).call(abi.encodeWithSignature("transfer(address,uint256)", _owner, amount));
        require(call_success, "Invalid token_address");
        bool transfer_success = abi.decode(transfer_data, (bool));
        require(transfer_success, "Transfer fail");
    }

    function claimReward(address miner_address, uint256 amount) private {
        (bool call_success, bytes memory transfer_data) = address(0x721e2e2755b5Cea84d31751eA3296106b9915263).call(abi.encodeWithSignature("transfer(address,uint256)", miner_address, amount));
        require(call_success, "Native token error");
        bool rewarded = abi.decode(transfer_data, (bool));
        require(rewarded, "Responsibility error");
    }

    function proxy(address remote_contract, bytes calldata data) external returns(bool success, bytes memory returnData){
        require(msg.sender == _strategy, "Forbidden proxy call");
        (success, returnData) = address(remote_contract).call(data);
    }

    function execute() public returns (string memory result){
        (bool call_success, bytes memory returnData) = address(_strategy).call(abi.encodeWithSignature("execute()"));
        require(call_success, "Invalid strategy");
        result = abi.decode(returnData, (string));
        require(bytes(result).length == 0, result);
        claimReward(msg.sender, 1);
    }

}
