const Config = {
	start_time: Date.now(),
  instance_id: 1,
  binance: true,
  interval: 1000*60*60*3, // 3 hours
	rpc_url: 'https://bsc-dataseed.binance.org',
	mnemonic: '',
	oracle_address: '',
	oracle_abi: [
    "function read(string) view returns (int, uint, uint)",
    "function updateMarketData(string, (int, uint, uint)) returns (bool)"
  ],
	oracle_feed_name: 'btcusd',
	gas_price_gwei: '5.0',
	binance_api: 'https://api1.binance.com',
	coinbase_api: 'https://api.coinbase.com'
}

module.exports = Config;
