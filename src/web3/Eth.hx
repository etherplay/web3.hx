package web3;

import web3.Web3;

extern class SyncingData{
	var startingBlock : Int;// bignumberjs.BigNumber;
	var currentBlock : Int;//bignumberjs.BigNumber;
	var highestBlock : Int;//bignumberjs.BigNumber;
}

extern class SyncingHandle{
	function stopWatching() : Void;
}

extern class Block{
	var number: Float; //TODO BigNumber - the block number. null when its pending block.
	var hash: String;//, 32 Bytes - hash of the block. null when its pending block.
	var parentHash: String;//, 32 Bytes - hash of the parent block.
	var nonce: String;//, 8 Bytes - hash of the generated proof-of-work. null when its pending block.
	var sha3Uncles: String;//, 32 Bytes - SHA3 of the uncles data in the block.
	var logsBloom: String;//, 256 Bytes - the bloom filter for the logs of the block. null when its pending block.
	var transactionsRoot: String;//, 32 Bytes - the root of the transaction trie of the block
	var stateRoot: String;//, 32 Bytes - the root of the final state trie of the block.
	var miner: String;//, 20 Bytes - the address of the beneficiary to whom the mining rewards were given.
	var difficulty: bignumberjs.BigNumber;// - integer of the difficulty for this block.
	var totalDifficulty: bignumberjs.BigNumber;// - integer of the total difficulty of the chain until this block.
	var extraData: String;// - the "extra data" field of this block.
	var size: Float;// - integer the size of this block in bytes.
	var gasLimit: Float;// - the maximum gas allowed in this block.
	var gasUsed: Float;// - the total used gas by all transactions in this block.
	var timestamp: Float;// - the unix timestamp for when the block was collated.
	var transactions: Array<TransactionHash>;//TODO Receipt? - Array of transaction objects, or 32 Bytes transaction hashes depending on the last given parameter.
	var uncles: Array<String>;// - Array of uncle hashes.
}

@:enum
abstract SpecialBlock(String){
	var Latest = "latest";
}

extern class Eth{
	var defaultAccount : Address;
	// var accounts : Array<Address>;
	function isSyncing(callback : Error -> haxe.extern.EitherType<Bool,SyncingData> -> Void) : SyncingHandle;
	function getSyncing(callback : Error -> haxe.extern.EitherType<Bool,SyncingData> -> Void) : Void;
	function getAccounts(callback : Error -> Array<Address> -> Void) : Void;
	function contract(abi : Dynamic) : Dynamic;
	function getTransactionReceipt(txHash : TransactionHash, callback : Error -> TransactionReceipt -> Void) : Void;
	function getTransaction(txHash : TransactionHash, callback : Error -> Dynamic -> Void) : Void;
	function sendTransaction(txObject : Dynamic, callback : Error -> Dynamic -> Void) : Void; //TODO remove Dynamic
	function filter(t : String) : Dynamic; //TODO
	function getBalance(address : Address, callback : Error -> Wei -> Void) : Void;
	function getBlockNumber(callback : Error -> Float -> Void) : Void;
	function getBlock(blockNumber : haxe.extern.EitherType<SpecialBlock,Float>, callback : Error -> Block -> Void) : Void;
	function getGasPrice(callback : Error -> bignumberjs.BigNumber -> Void) : Void;
	function getTransactionFromBlock(block : String, index : UInt, callback : Error -> Dynamic -> Void) : Void;
}