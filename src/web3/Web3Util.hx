package web3;

import web3.Web3;

class Web3Util{

	// public static function createHttpProvider(url : String) : Provider{
	// 	return untyped  __js__("new Web3.providers.HttpProvider(url)");
	// };
	// #if nodejs
	// public static function createIpcProvider(url : String) : Provider{
	// 	var client = new js.node.net.Socket();
	// 	return untyped  __js__("new Web3.providers.IpcProvider(url,client)");
	// };
	// #end

	//accept only  utf8 string and number represented as hex
	inline static public function sha3(web3 : Web3, elems : Array<String>) : String { 
		var str = "";
		for(elem in elems){
			if(StringTools.startsWith(elem,"0x")){
				str += elem.substr(2);
			}else{
				str += untyped _web3.toHex(elem).substr(2);
			}
		}
		// trace("web3 sha3 str", str);
		return untyped Web3.sha3(str);
	}

	static public function getLogs(web3 : Web3, topics : Array<String>, fromBlock : String, toBlock : String, address : String, callback : Dynamic -> Array<Log> -> Void){
		var jsonRPCData = {
			method: "eth_getLogs",
			params: [{
  				fromBlock : fromBlock,
  				toBlock : toBlock,
  				address:address,
  				topics: topics
			}],
			jsonrpc: "2.0",
			id: Std.int(Math.random() * 1000000)
		};
		untyped web3.currentProvider.sendAsync(jsonRPCData, function (err, result) {
			if(err != null){
				callback(err,null);
			}else if(result.error != null){
				callback(result.error,null);
			}else if(result.result == null){
				callback("no result",null);
			}else{
				callback(null,result.result);
			}
		});
	}

	public static function waitForTransactionReceipt(_web3 : Web3, txHash : TransactionHash, mineCallback : Error -> String -> TransactionReceipt -> Void, ?timeout : UInt = 240) : Void{
		var interval : Int = 0;
		var attempts = 0;
		var make_attempt = function() {
			_web3.eth.getTransactionReceipt(txHash, function(e, receipt) {

				if (e != null) {
					#if report
					Report.anEvent("web3","error getTransactionReceipt for " + txHash +  ": ",e);
					#end
				}
				
				if (receipt != null && receipt.blockHash != null && receipt.transactionHash  == txHash) {
					untyped clearInterval(interval);
					mineCallback(null,txHash,receipt);
				}else if (attempts >= timeout) { //TODO configure interval / timeout + add option to error on timeout
					#if report
					Report.anEvent("web3","attempts  >= " + timeout);
					#end
					untyped clearInterval(interval);
					mineCallback(null,txHash,null); 
				}else{
					attempts += 1;
				}

			});
		};

		untyped interval = setInterval(make_attempt, 1000);
		make_attempt();
	}
}