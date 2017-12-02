package web3;

import haxe.extern.EitherType;
import web3.providers.HttpProvider;


typedef ExtendedTransactionInfo = {
	> TransactionInfo
	,?privateKey : String
}

abstract TransactionHash(String) to(String){
	public inline function new(value : String){
		this = value;
	}
}

abstract Wei(String) to(String){
	inline public function toString():String{return this;}
	inline public function new(s : String){
		this = s;
	}
	@:to inline public function toEther() : Ether {
		return untyped Utils.fromWei(this,'ether');   	
	}  
	@:from inline static public function fromEther(value : Ether) : Wei {
		return untyped Utils.toWei(value.toString(),'ether');   	
	}  
}

abstract Ether(String) to(String){
	inline public function toString():String{return this;}
	inline public function new(s : String){
		this = s;
	}
	@:to inline public function toWei() : Wei {
		return untyped Utils.toWei(this,'ether');   	
	}  
	@:from inline static public function fromWei(value : Wei) : Ether {
		return untyped Utils.fromWei(value.toString(),'ether');   	
	}
}

extern class Block{
	var number: Float; // the block number. null when its pending block.
	var hash: String;//, 32 Bytes - hash of the block. null when its pending block.
	var parentHash: String;//, 32 Bytes - hash of the parent block.
	var nonce: String;//, 8 Bytes - hash of the generated proof-of-work. null when its pending block.
	var sha3Uncles: String;//, 32 Bytes - SHA3 of the uncles data in the block.
	var logsBloom: String;//, 256 Bytes - the bloom filter for the logs of the block. null when its pending block.
	var transactionsRoot: String;//, 32 Bytes - the root of the transaction trie of the block
	var stateRoot: String;//, 32 Bytes - the root of the final state trie of the block.
	var miner: String;//, 20 Bytes - the address of the beneficiary to whom the mining rewards were given.
	var difficulty: String;// - integer of the difficulty for this block.
	var totalDifficulty: String;// - integer of the total difficulty of the chain until this block.
	var extraData: String;// - the "extra data" field of this block.
	var size: Float;// - integer the size of this block in bytes.
	var gasLimit: Float;// - the maximum gas allowed in this block.
	var gasUsed: Float;// - the total used gas by all transactions in this block.
	var timestamp: Float;// - the unix timestamp for when the block was collated.
	var transactions: Array<TransactionHash>;//TODO Receipt? - Array of transaction objects, or 32 Bytes transaction hashes depending on the last given parameter.
	var uncles: Array<String>;// - Array of uncle hashes.
}

@:enum
abstract ABIElementType(String){
	var uint256 = "uint256";
	var bytes32 = "bytes32";
	var address = "address";
	var uint32 = "uint32";
	var uint8 = "uint8";
	var uint16 = "uint16";

	//TODO ...
}

@:enum
abstract ABIType(String){
	var Function = "function";
	var Event = "event";
	var Constructor = "constructor";
}

typedef ABIParam = {
	name : String,
	type : ABIType,
	?indexed : Bool	
} 

typedef ABIElement = {
	name : String,
	type : ABIElementType,
	?anonymous : Bool,
	?inputs : Array<ABIParam>,
	?outputs : Array<ABIParam>,
	?payable : Bool,
	?constant : Bool
}

typedef ABI = Array<ABIElement>;

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
	value : Wei,
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
	?value: Wei,
	?gas : UInt,
	?gasPrice : Wei
}

typedef TransactionInfo = {
	?from: Address,
	?value: Wei,
	gas : UInt,
	?gasPrice : Wei,
	?nonce : UInt, 
	?to:Address,
	?data:String
}

typedef SignedTransaction = {
	raw : String,
	tx : {
		nonce: String,
        gasPrice: Wei,
        gas: String,
        to: String,
        value: Wei,
        input: String,
        v: String,
        r: String,
        s: String,
        hash: String
	}
}

@:enum
abstract SpecialBlock(String){
	var Latest = "latest";
}

typedef Error = Dynamic;


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
	static function BN(number:EitherType<String,Float>) : BN;
	static function toBN(val : Dynamic) : BN;

	@:overload(function(number:BN,?unit:String):BN{})
	static function toWei(number:EitherType<String,Float>,?unit : String) : String;
	static function fromWei(number:EitherType<String,Float>,?unit : String) : String;

	static function soliditySha3(args : haxe.extern.Rest<Dynamic>):String;
	static function sha3(str : EitherType<String,BN>):String; 
	static function toHex(v:Dynamic):String;
}