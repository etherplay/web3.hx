package web3;

import web3.Web3;

interface Provider{
	function sendAsync(payload : Dynamic, callback : Error -> Dynamic -> Void) : Void;
}