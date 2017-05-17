package web3.macro;

import haxe.DynamicAccess;
import haxe.macro.Context;
import haxe.macro.Expr;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef ContractInfos = DynamicAccess<DynamicAccess<Dynamic>>;
typedef ContractType = {
	name : String,
	type : String
};
typedef ContractFunction = {
	?constant : Bool,
 	inputs : Array<ContractType>,
 	?name : String,
 	?outputs: Array<ContractType>,
 	?type : String
};
typedef ContractABI = Array<ContractFunction>;

class ContractBuilder{
	macro public static function run(){
		var pos = Context.currentPos();
		var contractsPath = "web3_contracts.json";
		
		if(Context.defined("web3_contracts") && Context.definedValue("web3_contracts") != ""){
			contractsPath = Context.definedValue("web3_contracts");
			if(!FileSystem.exists(contractsPath)){
				Context.error("the file specified (" + contractsPath + ") via -D web3_contracts=<filename> cannot be found, (this need to be set relative to haxe execution (where hxml is usually))) \n aleternatively you can just name your file : \"web3_contracts.json\" ", pos);
				return null;
			}
		}else{
			if(!FileSystem.exists(contractsPath)){
				contractsPath = "../web3_contracts.json";
				if(!FileSystem.exists(contractsPath)){
					return null;
				}
			}
		}
		
		var allowDeploy = Context.defined("web3_allow_deploy");
			
		var content = File.getContent(contractsPath);
		
		var contractInfos :ContractInfos = Json.parse(content);
		for(contractName in contractInfos.keys()){
			var contractInfo = contractInfos[contractName];
			var contractABIString = contractInfo["interface"];
			var contractABI : ContractABI = Json.parse(contractABIString);
			var contractBytecode = "";
			if(allowDeploy){
				contractBytecode = contractInfo["bytecode"];
			}
			 			
			var typePath = {pack :["web3","contract"], name : contractName};
			
			var typeDefinition = macro class $contractName {
				static var factory : haxe.DynamicAccess<Dynamic>;
				static var code : String;
				var _web3 : web3.Web3;
				public var address(default,null) : web3.Web3.Address;
				static function setup(_web3 : web3.Web3){
					if(factory == null){
						code = "0x" + $v{contractBytecode};//TODO Do it earlier in compiler output
						factory = _web3.eth.contract(haxe.Json.parse( $v{contractABIString} ));
					}
				}
				var _instance : Dynamic;
				private function new(_web3 : web3.Web3,address : web3.Web3.Address) { 
					this._web3 = _web3;
					_instance = factory["at"](address);
					this.address = address;
				}
			}

			typeDefinition.pack = typePath.pack;
			
			
			typeDefinition.fields.push({
					pos:pos,
					name:"at",
					kind:FFun({
						ret:TPath(typePath),
						expr:macro {
							setup(_web3);
							return new $typePath(_web3,address);
						},
						args:[
							{name:"_web3",type:TPath({pack:["web3"],name:"Web3"})},
							{name:"address",type:macro :web3.Web3.Address},
							]
					}),
					access : [APublic,AStatic]
				});	
			
			var constructorFunc : ContractFunction = null;
			var funcSet = new Map<String,ContractFunction>();
			for(func in contractABI){
				if((func.type == null || func.type == "function") && func.name != null){
					if(!funcSet.exists(func.name)){
						funcSet.set(func.name,func);
					}else{
						//trace("duplicate func with name : " + func.name);
						//TODO support overloading?
					}
					
				}else if(func.type == "constructor"){
					constructorFunc = func; //TODO overloading
				}
			}

			

			if(allowDeploy){

				if(constructorFunc != null && constructorFunc.inputs.length == 1){ //TODO n inputs
					typeDefinition.fields.push({
						pos:pos,
						name:"deploy",
						kind:FFun({
							ret:null,
							expr:macro {
								var mining = false;
								setup(_web3);
								//trace(code);
								factory["new"](param,{
									from: address,
									gas : 3000000, //TODO gas
									data: code
								}, function(err, deployedContract){
									if(err){
										if(mining){
											mineCallback(err, null);
										}else{
											callback(err, null);
										}
									}else{
										if(deployedContract.address != null){
											mineCallback(null, new $typePath(_web3,deployedContract.address));
										}else{
											if(mining){
												mineCallback("no address", null);
											}else{
												callback(null,deployedContract);
											}
										}
									}
									mining = true;
								});
							},
							args:[
								{name:"_web3",type:TPath({pack:["web3"],name:"Web3"})},
								{name:"address",type:macro :web3.Web3.Address},
								{name:"param",type:haxeType(constructorFunc.inputs[0].type)},
								{name:"callback",type:TFunction([macro :Dynamic, macro :Dynamic],macro : Void)},
								{name:"mineCallback",type:TFunction([macro :Dynamic, TPath(typePath)],macro : Void)}
								]
						}),
						access : [APublic,AStatic]
					});	
				}else{
					typeDefinition.fields.push({
						pos:pos,
						name:"deploy",
						kind:FFun({
							ret:null,
							expr:macro {
								var mining = false;
								setup(_web3);
								//trace(code);
								factory["new"]({
									from: address,
									gas : 3000000, //TODO gas
									data: code
								}, function(err, deployedContract){
									if(err){
										if(mining){
											mineCallback(err, null);
										}else{
											callback(err, null);
										}
									}else{
										if(deployedContract.address != null){
											mineCallback(null, new $typePath(_web3,deployedContract.address));
										}else{
											if(mining){
												mineCallback("no address", null);
											}else{
												callback(null,deployedContract);
											}
										}
									}
									mining = true;
								});
							},
							args:[
								{name:"_web3",type:TPath({pack:["web3"],name:"Web3"})},
								{name:"address",type:macro :web3.Web3.Address},
								{name:"callback",type:TFunction([macro :Dynamic, macro :Dynamic],macro : Void)},
								{name:"mineCallback",type:TFunction([macro :Dynamic, TPath(typePath)],macro : Void)}
								]
						}),
						access : [APublic,AStatic]
					});
				}

			
			}
			
			for(func in funcSet){
				if(func.name != null){
					//TODO call vs transaction?
					
					if(!func.constant){
						var args = new Array<FunctionArg>();
						var callArgs : Array<Expr> = [];
						var paramFields = [];
						for (input in func.inputs){
							var inputName = input.name;
							paramFields.push({pos:pos,name:inputName,kind: FVar(haxeType(input.type),null)});
							callArgs.push(macro params.$inputName);
						}
						if(paramFields.length > 0){
							args.push({name:"params", type: TAnonymous(paramFields)});
						}
						args.push({name:"option",type: macro : web3.Web3.TransactionInfo}); 
						args.push({name:"callback",type:TFunction([macro :web3.Web3.Error, macro :web3.Web3.TransactionHash],macro :Void)});
						args.push({name:"mineCallback",type:TFunction([macro :web3.Web3.Error, macro :web3.Web3.TransactionReceipt],macro :Void), opt:true});
						callArgs.push(macro option);
						callArgs.push(macro function(err,txHash){
							callback(err,txHash);
							if(mineCallback != null){
								web3.Web3Util.waitForTransactionReceipt(_web3,txHash,mineCallback);
							}
						});
						var funcCall = "this._instance." + func.name + ".sendTransaction";
						var funcExpr = {pos:pos, expr:ECall(macro untyped __js__($v{funcCall}), callArgs)}; 
						typeDefinition.fields.push({
							pos:pos,
							name:"commit_to_"+func.name,
							kind:FFun({
								ret:null,
								expr:funcExpr,
								args:args
							}),
							access : [APublic]
						});
					}
					
					var args = new Array<FunctionArg>();
					var callArgs : Array<Expr> = [];
					var paramFields = [];
					for (input in func.inputs){
						var inputName = input.name;
						paramFields.push({pos:pos,name:inputName,kind: FVar(haxeType(input.type),null)});
						callArgs.push(macro params.$inputName);
					}
					if(paramFields.length > 0){
						args.push({name:"params", type: TAnonymous(paramFields)});
					}
					
					args.push({name:"option",type: macro : web3.Web3.CallInfo});
					var callbackArgs = [macro :web3.Web3.Error];
					var callbackCall = "function(err,result){
						if(err){callback(err);}else{
						callback(err"; 
					if(func.outputs != null){
						var typeFields = [];
						for(output in func.outputs){
							//callbackArgs.push(haxeType(output.type));
							typeFields.push({pos:pos,name:output.name,kind:FVar(haxeType(output.type),null)});
						}
						callbackArgs.push(TAnonymous(typeFields));
						
						callbackCall += ",{";
						
						for (i in 0...func.outputs.length){
							var output = func.outputs[i];
							
							var value = "result[" + i +"]";
							if(func.outputs.length == 1){
								value = "result";
							}
							
							
							if(output.type == "address[]"){

							}else if(output.type == "uint32"){
								value = value + ".toNumber()";
							}else if(output.type == "bytes"){

							}else if(output.type == "uint8[]"){
								value = value + ".map(function(curr,index,arr){return curr.toNumber();})";
							}else if(output.type == "uint8"){
								value = value + ".toNumber()";
							}else if(output.type == "uint256"){
								
							}else if(output.type == "address"){
								
							}else if(output.type == "bytes32"){

							}else{
								
							}
							callbackCall += output.name + ":" + value;
							if(i < func.outputs.length-1){
								callbackCall+= ",";
							}
						} 
						
						callbackCall += "})}}";
					}else{
						callbackCall = "function(err,result){callback(err)}";
					}
					 
					
					args.push({name:"callback",type:TFunction(callbackArgs,macro :Void)});
					callArgs.push(macro option);
					callArgs.push(macro untyped __js__($v{callbackCall}) );
					var funcCall = "this._instance." + func.name + ".call";
					var funcExpr = {pos:pos, expr:ECall(macro untyped __js__($v{funcCall}), callArgs)}; 
					typeDefinition.fields.push({
						pos:pos,
						name:"probe_" + func.name,
						kind:FFun({
							ret:null,
							expr:funcExpr,
							args:args
						}),
						access : [APublic]
					});
					
					
				}
			}
				
			

			// var typeDefinition = {
			// 	pos : pos,
			// 	pack : ["web3","contract"], 
			// 	name : contractName,
			// 	kind : TDAlias(TPath({
			// 		pack:newPack,
			// 		name:newName
			// 	})),
			// 	fields : []
			// }
			
			
			Context.defineType(typeDefinition);
		}
		
		return null;
		
	}
	
	static function haxeType(solidityType : String) : ComplexType{
		return switch(solidityType){
			case "bool": macro : Bool;
			case "address[]": macro : Array<web3.Web3.Address>;
			case "uint32" | "uint8" | "uint16" : macro : UInt;
			case "bytes" | "bytes32" : macro : String;
			case "uint256" | "uint64" | "uint88" | "uint128" : macro : bignumberjs.BigNumber;
			case "address" : macro : web3.Web3.Address;
			case "uint8[]" : macro : Array<UInt>;
			case "string" : macro : String;
			default:	trace("solidityType", solidityType); macro : Dynamic;	
		}
	}
}
