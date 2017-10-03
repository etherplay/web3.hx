package web3;

import haxe.extern.EitherType;
import web3.providers.HttpProvider;

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
	value : String,
	gasPrice : String,
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


typedef CallInfo = {
	?from: Address,
	?value: String,
	?gas : UInt,
	?gasPrice : String
}

typedef TransactionInfo = {
	?from: Address,
	?value: String,
	gas : UInt,
	?gasPrice : String,
	?nonce : UInt, //TODO check UInt ?
	?privateKey : Dynamic
}

typedef Error = Dynamic;

extern class Providers{
	// @:native("HttpProvider")
	function HttpProvider(url:String) : HttpProvider;
}

#if hxnodejs
@:jsRequire("web3")
#end
@:native("Web3")
extern class Web3{
	function new(?provider : EitherType<String,Provider>);
	var eth : Eth;
	var currentProvider : Provider;
	function setProvider(provider : Provider) : Void;
	function isConnected() : Bool;
	function reset() : Void;	
}

@:native("Web3.utils")
extern class Utils{
	// @:native("BN")
	static function BN(number:EitherType<String,Float>) : BN;
	static function toBN(val : Dynamic) : BN;

	@:overload(function(number:BN,?unit:String):BN{})
	static function toWei(number:EitherType<String,Float>,?unit : String) : String;
	static function fromWei(number:EitherType<String,Float>,?unit : String) : String;

	static function soliditySha3(args : haxe.extern.Rest<Dynamic>):String;
	static function sha3(str : EitherType<String,BN>):String; 
	static function toHex(v:Dynamic):String;
}