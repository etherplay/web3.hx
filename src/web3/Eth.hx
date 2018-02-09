package web3;

import haxe.extern.EitherType;
import web3.Web3;
import web3.eth.Contract;

extern class SyncingData{
	var startingBlock : Float;
	var currentBlock : Float;
	var highestBlock : Float;
}

extern class SyncingHandle{
	function stopWatching() : Void;
}


extern class Net{
	function getId(?callback : Error -> String -> Void) : js.Promise<String>;
}

extern class Abi{
	function encodeFunctionSignature(functionName : EitherType<ABIElement,String>):String;
	function encodeEventSignature(eventName : EitherType<ABIElement,String>):String;
	function encodeParameter(type : String, parameter : Dynamic) : String; //TODO remove Dynamic ?
	function encodeParameters(typesArray:EitherType<Array<ABIParam>,Array<String>>, parameters : Array<Dynamic>) : String; //TODO remove Dynamic ?
	function encodeFunctionCall(jsonInterface : ABIElement, parameters : Array<Dynamic>) : String; //TODO remove Dynamic ?
	function decodeParameter(type:String,hexString:String):Dynamic; //is the return not allways a String ?
	function decodeParameters(typesArray:EitherType<Array<ABIParam>,Array<String>>,hexString : String):Dynamic;
	function decodeLog(inputs:Array<ABIParam>,hexString:String,topics:Array<String>):Dynamic;
}

@:enum
abstract PromiEventType(String){
	var Hash = "transactionHash";
	var Receipt = "receipt";
	var Confirmation = "confirmation";
	var Error = "error";
}

extern class PromiEvent<T> extends js.Promise<T>{
	function once(eventType : PromiEventType, callback :  Dynamic -> Void) : PromiEvent<T>;
	
	@:overload(function(eventType : PromiEventType, callback : Dynamic -> Dynamic -> Void):PromiEvent<T>{})
	function on(eventType : PromiEventType, callback : Dynamic -> Void) : PromiEvent<T>;

	@:overload(function(eventType : PromiEventType, callback : Dynamic -> Dynamic -> Void):PromiEvent<T>{})
	function off(eventType : PromiEventType, callback : Dynamic -> Void) : PromiEvent<T>; //TODO test

	function removeAllListeners(?eventType:PromiEventType) : PromiEvent<T>;
}

@:forward
abstract Web3PromiEvent(PromiEvent<TransactionReceipt>) from(PromiEvent<TransactionReceipt>){
	public inline function onceTransactionHash(callback : TransactionHash -> Void): Web3PromiEvent{
		return this.once(Hash,callback);
	}
	public inline function onceReceipt(callback : TransactionReceipt -> Void): Web3PromiEvent{
		return this.once(Receipt,callback);
	}
	public inline function onConfirmation(callback: Float -> TransactionReceipt -> Void) : Web3PromiEvent{
		return this.on(Confirmation,callback);
	}
	public inline function onError(callback: Error -> TransactionReceipt ->  Void) : Web3PromiEvent{ //transactionReceipt is not null when out of gas error
		return this.on(Error,callback);
	}
}

typedef LogOptions = {
	fromBlock : haxe.ds.Either<String,Float>,
	toBlock : haxe.ds.Either<String,Float>,
	address : Address,
	topics : Array<haxe.ds.Either<String,Array<String>>> 
}

extern class Account{
	var address : Address;
	var privateKey : String;
	function signTransaction(txData : Dynamic, ?callback:Error -> Dynamic -> Void) : Dynamic; //TODO remove Dynamic
	// function sign(data : String)
	//TODO more
}

extern class Accounts{
	function privateKeyToAccount(pk : String): Account;
	//TODO more
}

@:enum 
abstract SubscriptionType(String){
	 var PendingTransactions = "pendingTransactions";
	 var NewBlockHeaders = "newBlockHeaders";
	 var Syncing = "syncing";
	 var Logs = "logs";
}

extern class Eth{
	var defaultAccount : Address;
	var net : Net;
	var abi : Abi;

	var accounts : Accounts;

	inline function newContract(abi : ABI, ?address : Address, ?options:ContractOptions) : Contract{
		return untyped __new__(this.Contract, abi,address,options);
	}

	function isSyncing(callback : Error -> haxe.extern.EitherType<Bool,SyncingData> -> Void) : SyncingHandle;
	function getSyncing(?callback : Error -> haxe.extern.EitherType<Bool,SyncingData> -> Void) : js.Promise<haxe.extern.EitherType<Bool,SyncingData>>;
	function getAccounts(?callback : Error -> Array<Address> -> Void) : js.Promise<Array<Address>>;
	function contract(abi : ABI) : Dynamic;
	function getTransactionReceipt(txHash : TransactionHash, ?callback : Error -> TransactionReceipt -> Void) : js.Promise<TransactionReceipt>;
	function getTransaction(txHash : TransactionHash, ?callback : Error -> Transaction -> Void) : js.Promise<Transaction>;
	
	function signTransaction(txInfo : TransactionInfo, ?callback : Error -> SignedTransaction -> Void) :  js.Promise<SignedTransaction>; 
	function sendSignedTransaction(signedTransactionData : String, ?callback : Error -> TransactionHash -> Void) : Web3PromiEvent; 
	function sendTransaction(txInfo : TransactionInfo, ?callback : Error -> TransactionHash -> Void) : Web3PromiEvent;
	

	function getBalance(address : Address,?callback : Error -> Wei -> Void) : js.Promise<Wei>;
	function getBlockNumber(?callback : Error -> Float -> Void) : js.Promise<Float>;
	function getBlock(blockNumber : haxe.extern.EitherType<SpecialBlock,Float>, ?callback : Error -> Block -> Void) : js.Promise<Block>;
	function getGasPrice(?callback : Error -> Wei -> Void) : js.Promise<Wei>;
	function getTransactionFromBlock(block : String, index : UInt, ?callback : Error -> Transaction -> Void) : js.Promise<Transaction>;
	function getTransactionCount(address : Address, ?callback : Error -> UInt -> Void)  : js.Promise<UInt>;


	function getPastLogs(options : LogOptions, ?callback : Error -> Array<Log> -> Void) : js.Promise<Array<Log>>;
	
	function clearSubscriptions(?exceptSyncing:Bool):Void;
	// function subscribe(type:SubscriptionType,?options:Dynamic,?callback:Error->Dynamic->Void):js.node.events.EventEmitter<Dynamic>; //TODO remove Dynamic

	// inline function subscribePendingTransactions(?callback:Error->Dynamic->Void):js.node.events.EventEmitter{
	// 	subscribe(PendingTransactions,callback)
	// }
}