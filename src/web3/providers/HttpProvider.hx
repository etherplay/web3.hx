package web3.providers;

import web3.Web3;

extern class HttpProvider implements web3.Provider{
	function sendAsync(payload : Dynamic, callback : Error -> Dynamic -> Void) : Void;
}