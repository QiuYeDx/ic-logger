import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Result "mo:base/Result";
import Principal "mo:base/Principal";

import Logger "mo:ic-logger/Logger";
import SingleLogger "./SingleLogger";

shared(installer) actor class MultiLogger() = this{
    private let CYCLE_LIMIT = 2_000_000_000_000;
    private let IC : ICActor = actor "aaaaa-aa";
    private var loggers = TrieMap.TrieMap<Nat, Principal>(Nat.equal, Hash.hash);
    private var current_logger_index = 0;
    private var current_msg_index = 0;
    private var total_msg_index = 0;
    private type Error = {
        #MsgInputSizeErr;
        #LoggerNotExist;
        #ViewRangeError;
    };
    private type SL = actor {
        append : shared (msgs : [Text]) -> async ();
        view : query (from: Nat, to: Nat) -> async Logger.View<Text>;
        stats : query () -> async Logger.Stats;
        wallet_receive : shared() -> async Nat;
    };
    private type canister_id = Principal;

    private type canister_settings = {
        freezing_threshold : ?Nat;
        controllers : ?[Principal];
        memory_allocation : ?Nat;
        compute_allocation : ?Nat;
    };

    private type definite_canister_settings = {
        freezing_threshold : Nat;
        controllers : [Principal];
        memory_allocation : Nat;
        compute_allocation : Nat;
    };

    private type wasm_module = [Nat8];

    private type ICActor = actor {
        canister_status : shared { canister_id : canister_id } -> async {
            status : { #stopped; #stopping; #running };
            memory_size : Nat;
            cycles : Nat;
            settings : definite_canister_settings;
            module_hash : ?[Nat8];
        };

        create_canister : shared { settings : ?canister_settings } -> async {
            canister_id : canister_id;
        };
        
        delete_canister : shared { canister_id : canister_id } -> async ();
        
        deposit_cycles : shared { canister_id : canister_id } -> async ();
        
        install_code : shared {
            arg : [Nat8];
            wasm_module : wasm_module;
            mode : { #reinstall; #upgrade; #install };
            canister_id : canister_id;
            } -> async ();
        
        provisional_create_canister_with_cycles : shared {
            settings : ?canister_settings;
            amount : ?Nat;
            } -> async { canister_id : canister_id };
        
        provisional_top_up_canister : shared {
            canister_id : canister_id;
            amount : Nat;
            } -> async ();
        
        raw_rand : shared () -> async [Nat8];
        start_canister : shared { canister_id : canister_id } -> async ();
        stop_canister : shared { canister_id : canister_id } -> async ();
        uninstall_code : shared { canister_id : canister_id } -> async ();
        
        update_settings : shared {
            canister_id : Principal;
            settings : canister_settings;
            } -> async ();
    };

    public shared (msg) func append(msgs: [Text]) : async Result.Result<Text, Error>{
        switch(await _append(msgs)){
            case (#ok(info)) { #ok(info) };
            case (#err(err)) { #err(err) };
        }
    };

    public shared (msg) func view(from : Nat, to : Nat) : async Result.Result<[Text], Error>{
        switch(await _view(from, to)){
            case (#ok(txts)) { #ok(txts) };
            case (#err(err)) { #err(err) };
        }
    };

    public shared({caller}) func wallet_receive() : async Nat {
        Cycles.accept(Cycles.available())
    };

    public func _append(msgs : [Text]) : async Result.Result<Text, Error> {
        let input_size = msgs.size();
        if (input_size <= 0) {
            return #err(#MsgInputSizeErr);
        };
        if (current_logger_index == 0) {
            await _getNewLogger();
        };
        var msg_index = 0;
        var input_tmp_size = 0;
        var once_size : Nat = 100 - current_msg_index;
        if(100 - current_msg_index >= msgs.size()){
            once_size := msgs.size();
        };
        var tmp : [var Text] = Array.init<Text>(once_size, "");

        label l loop {
            tmp[input_tmp_size] := msgs[msg_index];
            current_msg_index := current_msg_index + 1;
            total_msg_index := total_msg_index + 1;

            msg_index := msg_index + 1;
            input_tmp_size := input_tmp_size + 1;

            if (input_tmp_size == once_size) {
                input_tmp_size := 0;
                switch (loggers.get(current_logger_index)) {
                    case null { return #err(#LoggerNotExist); };
                    case (?sl_principal) {
                        let sl = actor(Principal.toText(sl_principal)) : SL;
                        await sl.append(Array.freeze(tmp));
                    };
                };
                if (current_msg_index < 100) {
                    break l;
                } else { 
                    await _getNewLogger();
                    current_msg_index := 0;
                    if (input_size == msg_index) break l;
                    once_size := input_size - msg_index;
                    if(100 < once_size) {
                        once_size := 100;
                    };
                    tmp := Array.init<Text>(once_size, "");
                };
            };
        };

        #ok("Append Over")        
    };

    public func _view(from : Nat, to : Nat) : async Result.Result<[Text], Error> {
        if (from > to or from < 0 or to < 0 or (to + 1) > total_msg_index) return #err(#ViewRangeError);
        var res : [var Text] = [var];
        var res_ : [var Text] = [var];
        var from_index = from;
        var msg_index = 0;
        var logger_index = from_index / 100 + 1; 
        var start_index = from_index % 100; 
        label l loop {
            var end_index : Nat = 99; 
            if(to - from_index < (99 - start_index)){
                end_index := start_index - from_index + to;
            };

            var tmp : [var Text] = [var];
            switch (loggers.get(logger_index)) {
                case null { return #err(#LoggerNotExist); };
                case (?sl_principal) {
                    let sl = actor(Principal.toText(sl_principal)) : SL;
                    tmp := Array.thaw<Text>((await sl.view(start_index, end_index)).messages);
                };
            };
            
            // res := await _appendText(res, tmp);

            res_ := do{
                switch(res.size(), tmp.size()) {
                    case (0, 0) { [var] };
                    case (0, _) { tmp };
                    case (_, 0) { res };
                    case (xsSize, ysSize) {
                        let res2 = Array.init<Text>(res.size() + tmp.size(), "");
                        var i = 0;
                        for(e in res2.vals()){
                            res2[i] := res2[i];
                            i += 1;
                        };
                        for(e in tmp.vals()){
                            res2[i] := tmp[i - res2.size()];
                            i += 1;
                        };
                        res2
                    };
                }
            };

            if (end_index < 99) {
                break l;
            } else { 
                from_index += end_index - start_index + 1;
                logger_index += 1;
                start_index := 0;
            };
        };

        #ok(Array.freeze(res_))
    };

    public func _getNewLogger() : async () {
        Cycles.add(CYCLE_LIMIT);
        let new_SL = await SingleLogger.SingleLogger();
        let new_principal = Principal.fromActor(new_SL);
        await IC.update_settings({
            canister_id = new_principal;
            settings = {
                freezing_threshold = ?2592000;
                controllers = ?[Principal.fromActor(this)]; // owners + container
                memory_allocation = ?0;
                compute_allocation = ?0;
            }
        });
        current_logger_index += 1;
        loggers.put(current_logger_index, new_principal);
    };
    
};