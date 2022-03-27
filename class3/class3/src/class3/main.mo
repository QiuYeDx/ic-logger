import IC "./ic";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Result "mo:base/Result";
import TrieSet "mo:base/TrieSet";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";

shared(installer) actor class class3(_init : Nat, owners : [Principal]) = this {
    private type canister_id = IC.canister_id;
    private type Error = {
        #PermissionDenied;
        #CanisterNotExist;
        #ProposeNotExist;
        #ProposeRepeat;
        #VotesAlready;
    };
    private let _THEN = owners.size();
    private let ic : IC.Self = actor "aaaaa-aa";
    private stable var canister_number  : Nat = 0;
    private stable var canister_entries : [var (Nat, canister_id)] = [var];
    private stable var propose_entries  : [var (Nat, (Nat, Nat, Nat))] = [var];
    private stable var vote_buffer_entries : [var (Nat, TrieSet.Set<Principal>)] = [var];
    private stable var owner_set = TrieSet.fromArray<Principal>(owners, Principal.hash, Principal.equal);
    private var canisters = TrieMap.fromEntries<Nat, canister_id>(canister_entries.vals(), Nat.equal, Hash.hash);
    private var proposes = TrieMap.fromEntries<Nat, (Nat, Nat, Nat)>(propose_entries.vals(), Nat.equal, Hash.hash);
    private var votes_buffer = TrieMap.fromEntries<Nat, TrieSet.Set<Principal>>(vote_buffer_entries.vals(), Nat.equal, Hash.hash);
    private stable var _THEM = do { 
        if (_init >= owners.size()) {
            owners.size()
        } else { 
            _init
        }
    };
    
    public query({caller}) func get_canisters() : async Result.Result<[(Nat, canister_id)], Error> {
        #ok(Iter.toArray<(Nat, canister_id)>(canisters.entries()))
    };
    
    public shared({caller}) func propose(num : Nat, action : Nat) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch (canisters.get(num)) {
            case null { #err(#CanisterNotExist) };
            case (?canister_id) {
                switch(proposes.get(num)) {
                    case (?agreenum) {
                        #err(#ProposeRepeat)
                    };
                    case (null) {
                        proposes.put(num, (0, 0, action));
                        #ok("Propose successfully!")
                    };
                }
            };
        }
    };

    public shared({caller}) func vote(num : Nat, agree : Bool) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch(proposes.get(num)) {
            case (?propose) {
                switch(votes_buffer.get(num)) {
                    case null {
                        let set_tmp = TrieSet.empty<Principal>();
                        let set_in = TrieSet.put(set_tmp, caller, Principal.hash(caller), Principal.equal);
                        votes_buffer.put(num, set_in);
                    };
                    case (?set) {
                        if (TrieSet.mem<Principal>(set, caller, Principal.hash(caller), Principal.equal)) {
                            return #err(#VotesAlready);
                        } else {
                            let set_in = TrieSet.put(set, caller, Principal.hash(caller), Principal.equal);
                            votes_buffer.put(num, set_in);
                        };
                    };
                };
                if (agree) {
                    if ((propose.0 + 1) == _THEM) {
                        proposes.delete(num);
                        // ToDo
                        return #ok("ToDo execute the propose!");
                    };
                    proposes.put(num, (propose.0 + 1, propose.1, propose.2));
                    return #ok("vote agree successfully!");
                } else {
                    let left : Nat = _THEN - _THEM;
                    if ((propose.1 + 1) > left) {
                        proposes.delete(num);
                        return #ok("after vote finally propose failed!");
                    } else {
                        proposes.put(num, (propose.0, propose.1 + 1, propose.2));
                        return #ok("vote not agree successfully!");
                    };
                };
            };
            case (null) {
                #err(#ProposeNotExist)
            };
        }
    };

    public shared({caller}) func create_canister() : async Result.Result<canister_id, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        } else { 
            let settings = {
                freezing_threshold = ?2592000;
                controllers = ?[Principal.fromActor(this)];
                memory_allocation = ?0;
                compute_allocation = ?0;
            };
            Cycles.add(1_000_000_000_000);
            let res = await ic.create_canister({ settings = ?settings;});
            canister_number += 1;
            canisters.put(canister_number, res.canister_id);
            return #ok(res.canister_id);
        };
    };

    public shared({caller}) func install_code(wsm : [Nat8], num : Nat) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch(canisters.get(num)) {
            case null { #err(#CanisterNotExist) };
            case (?canister_id) {
                await ic.install_code({ 
                    arg = [];
                    wasm_module = wsm;
                    mode = #install;
                    canister_id = canister_id;
                });
                #ok("install ok")
            };
        }
    };

    public shared({caller}) func start_canister(num : Nat) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch(canisters.get(num)) {
            case null { #err(#CanisterNotExist) };
            case (?canister_id) {
                await ic.stop_canister({ canister_id = canister_id;});
                #ok("ok")
            };
        }
    };

    public shared({caller}) func stop_canister(num : Nat) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch(canisters.get(num)) {
            case null { #err(#CanisterNotExist) };
            case (?canister_id) {
                await ic.stop_canister({ canister_id = canister_id;});
                #ok("ok")
            };
        }
    };

    public shared({caller}) func delete_canister(num : Nat) : async Result.Result<Text, Error> {
        if (not TrieSet.mem<Principal>(owner_set, caller, Principal.hash(caller), Principal.equal)) {
            return #err(#PermissionDenied);
        };
        switch(canisters.get(num)) {
            case null { #err(#CanisterNotExist) };
            case (?canister_id) {
                await ic.delete_canister({ canister_id = canister_id;});
                canisters.delete(num);
                canister_number -= 1;
                #ok("ok")
            };
        }
    };

    system func preupgrade() {
        let cid : canister_id = Principal.fromText("aaaaa-aa");
        canister_entries := Array.init<(Nat, canister_id)>(canisters.size(), (0, cid));
        var canister_index = 0;
        for (e in canisters.entries()) {
            canister_entries[canister_index] := (e.0, e.1); 
            canister_index += 1;
        };

        let propose_tmp : (Nat, (Nat, Nat, Nat)) = (0, (0, 0, 0));
        propose_entries := Array.init<(Nat, (Nat, Nat, Nat))>(proposes.size(), propose_tmp);
        var propose_index = 0;
        for (e in proposes.entries()) {
            propose_entries[propose_index] := (e.0, e.1); 
            propose_index += 1;
        };

        let trieset_tmp = TrieSet.empty<Principal>();
        let votes_buffer_tmp : (Nat, TrieSet.Set<Principal>) = (0, trieset_tmp);
        vote_buffer_entries := Array.init<(Nat, TrieSet.Set<Principal>)>(votes_buffer.size(), votes_buffer_tmp);
        var votes_index = 0;
        for (e in votes_buffer.entries()) {
            vote_buffer_entries[votes_index] := (e.0, e.1); 
            votes_index += 1;
        };

    };

    system func postupgrade() {
        canister_entries := [var];
        propose_entries := [var];
        vote_buffer_entries := [var];
    };

};