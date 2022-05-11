const { ethers } = require("ethers");
var request = require('request');
var Config = require('./oracle_config.js');

////////////////////////////////////////////////////////////////////////////////

var provider = new ethers.providers.JsonRpcProvider(Config.rpc_url);
var walletMnemonic = new ethers.Wallet.fromMnemonic(Config.mnemonic, `m/44'/60'/0'/0/0`);
var wallet = walletMnemonic.connect(provider);
var oracle = new ethers.Contract(Config.oracle_address, Config.oracle_abi, wallet);
var localSequenceId = 0;

async function post_price(market, symbol, price){
  console.log(localSequenceId+' - '+market+' - '+symbol+' - '+price);
  // read last sequence
  var last_value = await oracle.read(symbol);
  var sequenceId = last_value[2].toString()*1;
  // write market data
  var options = { gasLimit: 150000, gasPrice: ethers.utils.parseUnits(Config.gas_price_gwei, 'gwei') };
  if (sequenceId == localSequenceId){

    oracle.estimateGas.updateMarketData(symbol, [(price*100).toFixed(0)*1, 2, sequenceId + 1], options).then(function(tx) {
      options.gasLimit = tx.toString()*2;
      console.log('Success: gasLimit = '+options.gasLimit);
      oracle.updateMarketData(symbol, [(price*100).toFixed(0)*1, 2, sequenceId + 1], options).then(function(tx) {
        console.log(wallet.address);
        console.log(tx);
        localSequenceId++;
      });
    }).catch(function(error){
      console.log(JSON.parse(error.error.body).error.message);
    });;

  }else{
    localSequenceId = sequenceId;
  }
}

function Binance(symbol){
  request.get({url: Config.binance_api+'/api/v3/avgPrice?symbol='+symbol, json: true}, function (error, response, body) {
    if (!error && response.statusCode == 200) post_price('Binance', Config.oracle_feed_name, body.price);
  });
}

function Coinbase(symbol){
  request.get({url: Config.coinbase_api+'/v2/prices/'+symbol+'/spot', json: true}, function (error, response, body) {
    if (!error && response.statusCode == 200) post_price('Coinbase', Config.oracle_feed_name, body.data.amount);
  });
}

function update(){
  (Config.binance)? Binance('BTCUSDT') : Coinbase('BTC-USD') ;
}

////////////////////////////////////////////////////////////////////////////////

update();

setTimeout(function () {
  update();
}, 5000);

setInterval(function(){
  update();
}, Config.interval);
