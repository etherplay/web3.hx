package web3;

import bignumberjs.BigNumber;

abstract TransactionHash(String) to(String){
	public inline function new(value : String){
		this = value;
	}
}

typedef Log = {
	removed: Bool, // ? only in the doc
	logIndex: UInt,
	transactionIndex: UInt,
	transactionHash: String,
	blockHash: String,
	blockNumber: Float,
	address: Address,
	data: String,
	topics: Array<String>,
	type : String // ? not in the doc 
}

typedef TransactionReceipt = {
	blockHash : String,
	blockNumber : Float,
	transactionHash : String,
	transactionIndex : Float,
	from : String,
	to : String,
	cumulativeGasUsed : Float,
	gasUsed : Float,
	contractAddress : String,
	logs : Array<Dynamic>
};

typedef Transaction = {
	hash : String,
	nonce : Float,
	blockHash : String,
	blockNumber : Float,
	transactionIndex : Float,
	from : String,
	to : String,
	value : bignumberjs.BigNumber,
	gasPrice : bignumberjs.BigNumber,
	gas : Float,
	input : String
};


abstract Address(String) to(String){
	public inline function new(value : String){
		this = value;
	}

	public inline function toLowerCase() : Address{
		return new Address(this.toLowerCase());
	}
}

@:forward
abstract Ether(BigNumber) to(BigNumber){
	inline function new(value : BigNumber){
		this = value;
	}
		
	@:from inline static public function fromInt(value : Int) : Ether{
		return new Ether(value);
	}
	
	@:to inline public function toWei() : Wei{
		return Web3Lib.toWei(this, "ether");
	}
}

@:forward
abstract Wei(BigNumber) from(BigNumber) to(BigNumber){
	inline public function new(value : BigNumber){
		this = value;
	}	
	@:from inline static public function fromEther(ether : Ether) : Wei{
		return new Wei(Web3Lib.toWei(ether, "ether"));
	}
	@:from inline static public function fromInt(value : Int) : Wei{
		return new Wei(value);
	}
	
}

typedef CallInfo = {
	?from: Address,
	?value: Wei,
	?gas : UInt,
	?gasPrice : Wei
}

typedef TransactionInfo = {
	?from: Address,
	?value: Wei,
	gas : UInt,
	?gasPrice : Wei,
	?nonce : UInt, //TODO check UInt ?
	?privateKey : Dynamic
}

typedef Error = Dynamic;


class Web3Lib{
	public static function createHttpProvider(url : String) : Provider{
		return untyped  __js__("new Web3.providers.HttpProvider(url)");
	};
	#if nodejs
	public static function createIpcProvider(url : String) : Provider{
		var client = new js.node.net.Socket();
		return untyped  __js__("new Web3.providers.IpcProvider(url,client)");
	};
	#end
	static var _web3 : Web3;//cache an instance of web3 to access its function through the static (for now see: https://github.com/ethereum/web3.js/issues/428)
	public static function setup() : Void{ 
		untyped __js__("if(typeof Web3 == 'undefined'){
				if(typeof global != 'undefined'){
					global.Web3 = require('web3');
				}else if(typeof window != 'undefined'){
					window.Web3 = require('web3');
				}
			}"); //TODO macro based Main override?
		if(_web3 == null){//used for wei conversions
			_web3 = createInstance();
			_web3.reset();
		}
	}
	public inline static function createInstance() : Web3{
		return untyped __js__("new Web3()");
	}
	//TODO similar function
	inline static public function toWei(value : BigNumber, base : String) : String { setup(); return untyped _web3["toWei"](value,base);}

	//accept only  utf8 string and number represented as hex
	inline static public function sha3(elems : Array<String>) : String { 
		setup();
		var str = "";
		for(elem in elems){
			if(StringTools.startsWith(elem,"0x")){
				str += elem.substr(2);
			}else{
				str += untyped _web3.toHex(elem).substr(2);
			}
		}
		// trace("web3 sha3 str", str);
		return untyped _web3.sha3(str,{ encoding: 'hex' });
	}
}

extern class Web3Version{
	function getNetwork(callback : Error -> String -> Void) : Void;
}

extern class Web3{
	var eth : Eth;
	var version : Web3Version;
	var currentProvider : Provider;
	function setProvider(provider : Provider) : Void;
	function isConnected() : Bool;
	function reset() : Void;
}