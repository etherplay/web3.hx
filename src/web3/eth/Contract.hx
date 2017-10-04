package web3.eth;

import web3.Web3;
import web3.Eth;

typedef ContractOptions = {
	?from:Address,
	?gasPrice:Wei,
	?gas:Float,
	?data:String
}

typedef ContractCurrentOptions = {
	?from:Address,
	?gasPrice:Wei,
	?gas:Float,
	?data:String,
	
	?address:Address,
	jsonInterface:ABI,
}

typedef DeployOptions = {
	?data:String,
	?arguments : Array<Dynamic>
}

@:forward
abstract ContractPromiEvent(PromiEvent<Contract>) from(PromiEvent<Contract>){
	public inline function onceTransactionHash(callback : TransactionHash -> Void): ContractPromiEvent{
		return this.once(Hash,callback);
	}
	public inline function onceReceipt(callback : TransactionReceipt -> Void): ContractPromiEvent{
		return this.once(Receipt,callback);
	}
	public inline function onConfirmation(callback: Float -> TransactionReceipt -> Void) : ContractPromiEvent{
		return this.on(Confirmation,callback);
	}
	public inline function onError(callback: Error -> TransactionReceipt -> Void) : ContractPromiEvent{
		return this.on(Error,callback);
	}
}

@:forward
abstract DynamicPromiEvent(PromiEvent<Dynamic>) from(PromiEvent<Dynamic>){
	public inline function onceTransactionHash(callback : TransactionHash -> Void): DynamicPromiEvent{
		return this.once(Hash,callback);
	}
	public inline function onceReceipt(callback : TransactionReceipt -> Void): DynamicPromiEvent{
		return this.once(Receipt,callback);
	}
	public inline function onConfirmation(callback: Float -> TransactionReceipt -> Void) : DynamicPromiEvent{
		return this.on(Confirmation,callback);
	}
	public inline function onError(callback: Error -> TransactionReceipt -> Void) : DynamicPromiEvent{
		return this.on(Error,callback);
	}
}

extern class DeployTransaction{
	var arguments : Array<Dynamic>;
	function send(txInfo : TransactionInfo, ?callback : Error -> TransactionHash -> Void) : ContractPromiEvent;
	function estimateGas(?callback: Error -> Float -> Void) : js.Promise<Float>;
	function encodeABI() : String;
}

extern class MethodTransaction{
	var arguments : Array<Dynamic>;
	function call(callInfo : CallInfo, ?callback : Error -> Dynamic -> Void) : DynamicPromiEvent;
	function send(txInfo : TransactionInfo, ?callback : Error -> TransactionHash -> Void) : Web3PromiEvent;
	function estimateGas(?callback: Error -> Float -> Void) : js.Promise<Float>;
	function encodeABI() : String;
}


extern class Contract{
	function new(abi : ABI, ?address : Address, ?options:ContractOptions);
	var options : ContractCurrentOptions;
	function clone() : Contract;
	function deploy(options : DeployOptions) : DeployTransaction;
	var methods : Dynamic;
	function once(event : String,?options:Dynamic, callback : Error -> Log -> Void) : Void; //TODO Dynamic //TODO check argument provided / not provided
	var events : Dynamic; //.allEvents(...)
	function getPastEvents(event : String, ?options:Dynamic,callback : Error -> Array<Log> -> Void) : js.Promise<Array<Log>>; //TODO Dynamic
}