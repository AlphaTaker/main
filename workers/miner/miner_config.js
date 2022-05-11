const Config = {
	start_time: Date.now(),
  instance_id: 1,
  interval: 1000*30, // 30 sec
	rpc_url: 'https://bsc-dataseed.binance.org',
	mnemonic: '',
	portfolio_address: '',
	portfolio_abi: [
    "function execute() returns (string)"
  ],
	gas_price_gwei: '5.0'
}

module.exports = Config;
