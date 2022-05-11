const { ethers } = require("ethers");
var request = require('request');
var Config = require('./miner_config.js');

////////////////////////////////////////////////////////////////////////////////

var provider = new ethers.providers.JsonRpcProvider(Config.rpc_url);
var walletMnemonic = new ethers.Wallet.fromMnemonic(Config.mnemonic, `m/44'/60'/0'/0/0`);
var wallet = walletMnemonic.connect(provider);
var portfolio = new ethers.Contract(Config.portfolio_address, Config.portfolio_abi, wallet);
var c = 0;

async function process(){

  var balance = ethers.utils.formatEther(await wallet.getBalance().catch(function(error){
    console.log('getBalance error');
    console.log(error);
    setTimeout(function(){ process(); }, Config.interval);
  }));

  var options = { gasLimit: 150000, gasPrice: ethers.utils.parseUnits(Config.gas_price_gwei, 'gwei') };
  portfolio.estimateGas.execute().then(function(tx) {
    options.gasLimit = tx.toString()*2;
    console.log(c+' Success: gasLimit = '+options.gasLimit);
    portfolio.execute().then(function(tx) {
      console.log(wallet.address);
      //console.log(tx);
      c++;
    });
    setTimeout(function(){ process(); }, Config.interval);
  }).catch(function(error){
    console.log('['+balance+'] '+JSON.parse(error.error.body).error.message);
    setTimeout(function(){ process(); }, Config.interval);
  });

}

process();
