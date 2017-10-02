package web3;

import haxe.ds.Either;

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

extern class Web3Version{
	function getNetwork(callback : Error -> String -> Void) : Void;
}

extern class Providers{
	// @:native("HttpProvider")
	function HttpProvider(url:String) : HttpProvider;
}

#if hxnodejs
@:require("web3")
#end
extern class Web3{
	function new(?provider : Either<String,Provider>);
	static var providers : Providers;
	static var utils : Utils; 
	var eth : Eth;
	var version : Web3Version;
	var currentProvider : Provider;
	function setProvider(provider : Provider) : Void;
	function isConnected() : Bool;
	function reset() : Void;	
}

extern class Utils{
	static function BN(number:Either<String,Float>) : BN;
	static function toBN(val : Dynamic) : BN;

	@:overload(function(number:BN,?unit:String):BN{})
	static function toWei(number:Either<String,Float>,?unit : String) : String;

	static function soliditySha3(args : haxe.extern.Rest<Dynamic>):String;
	static function sha3(str : Either<String,BN>):String; 
	static function toHex(v:Dynamic):String;
}