package web3;

import web3.Web3;

class Web3Util{
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