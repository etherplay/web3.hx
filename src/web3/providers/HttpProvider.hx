package web3.providers;

import web3.Web3;

@:native("Web3.providers.HttpProvider")
extern class HttpProvider implements web3.Provider{
	public function new(url:String);
	function sendAsync(payload : Dynamic, callback : Error -> Dynamic -> Void) : Void;
}