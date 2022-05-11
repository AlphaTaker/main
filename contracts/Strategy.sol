// SPDX-License-Identifier: MIT License
// Part of AlphaTaker.com demo environment (c) 2022-02-19

pragma solidity ^0.8.7;

contract Strategy{
  
    struct indicator{
        int256 number;
        uint256 decimals;
        uint256 updateId;
    }

    indicator private _indicator;
    address private _owner;
    address private _oracle;
    string  private _oracle_feed;
    address private _dex;
    address private _tokenA;
    address private _tokenB;

    constructor() {
        _owner = msg.sender;
        _oracle = address(0);
        _oracle_feed = "btcusd";
        _dex    = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router v2
        _tokenA = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; // Binance-Peg BTCB Token
        _tokenB = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // busd
    }

    function setOwner(address owner_address) public {
        require(msg.sender == _owner, "Forbidden");
        _owner = owner_address;
    }

    function setOracle(address oracle_address, string memory oracle_feed_name) public {
        require(msg.sender == _owner, "Forbidden");
        _oracle = oracle_address;
        _oracle_feed = oracle_feed_name;
    }

    function setExchange(address dex_address, address tokenA_address, address tokenB_address ) public {
        require(msg.sender == _owner, "Forbidden");
        _dex = dex_address;
        _tokenA = tokenA_address;
        _tokenB = tokenB_address;
    }

    function portfolioCall(address remote_contract, bytes memory data) private returns(bool success, bytes memory returnData){
        (bool success_proxy, bytes memory returnData_proxy) = address(msg.sender).call(abi.encodeWithSignature("proxy(address,bytes)", remote_contract, data ));      
        require(success_proxy, "External call error");
        (success, returnData) = abi.decode(returnData_proxy, (bool, bytes));
    }

    function getBuyCalldata(address token_buy, address token_sell, uint256 amount_sell) private view returns(bytes memory callData){   
        address[] memory path = new address[](2);
        path[0] = token_sell;
        path[1] = token_buy;
        callData = abi.encodeWithSignature("swapExactTokensForTokens(uint256,uint256,address[],address,uint256)", amount_sell, 0, path, msg.sender, block.timestamp);
    }
    
    function getAmount(address portfolio, address token) private returns(uint256 amount){
        (bool success, bytes memory returnData) = address(token).call(abi.encodeWithSignature("balanceOf(address)", portfolio));     
        require(success, "getAmount call error");
        amount = abi.decode(returnData, (uint256));
    }
    
    function approveAmount(address token, uint256 amount) private returns(bool done){
        (bool success, bytes memory returnData) = portfolioCall(token, abi.encodeWithSignature("approve(address,uint256)", _dex, amount));   
        require(success, "approveAmount call error");
        done = abi.decode(returnData, (bool));
    }

    function execute() external returns(string memory){
        (bool oracle_success, bytes memory oracle_returnData) = portfolioCall(_oracle, abi.encodeWithSignature("read(string)", _oracle_feed));
        if (!oracle_success) return "Oracle not exist"; 
        indicator memory upd = abi.decode(oracle_returnData, (indicator));
        if (upd.updateId == _indicator.updateId) return "Feed not updated";

        if (upd.number > _indicator.number){
            uint256 amountB = getAmount(msg.sender, _tokenB);
            if (amountB > 0){
                bool approve_amount = approveAmount(_tokenB, amountB);
                if (!approve_amount) return "Token B approve fail";
                (bool buy_success, ) = portfolioCall(_dex, getBuyCalldata(_tokenA, _tokenB, amountB));
                if (!buy_success) return "Token A buy fail";
            }
        }else if (upd.number < _indicator.number){
            uint256 amountA = getAmount(msg.sender, _tokenA);
            if (amountA > 0){
                bool approve_amount = approveAmount(_tokenA, amountA);
                if (!approve_amount) return "Token A approve fail";
                (bool buy_success, ) = portfolioCall(_dex, getBuyCalldata(_tokenB, _tokenA, amountA));
                if (!buy_success) return "Token B buy fail";
            } 
        }else{
            return "Indicator not updated";
        }

        _indicator = upd;
        return "";
    }

}
