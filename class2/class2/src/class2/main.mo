import IC "./ic";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";

shared(install) actor class class2() = this {
    private type Canister_id = IC.canister_id;
    private let ic : IC.Self = actor "aaaaa-aa";
    private var canister_number : Nat = 0;
    private var canisters = TrieMap.TrieMap<Nat, Canister_id>(Nat.equal, Hash.hash);

    public shared(caller) func create_canister() : async Canister_id {
        let settings = {
            freezing_threshold = ?2592000;
            controllers = ?[Principal.fromActor(this)];
            memory_allocation = ?0;
            compute_allocation = ?0;
        };
        let res = await ic.create_canister({ settings = ?settings;});
        canister_number += 1;
        canisters.put(canister_number, res.canister_id);
        res.canister_id
    };

    public shared(caller) func install_code(wsm : [Nat8], canister_id : Canister_id) : async Text {
        await ic.install_code({ 
            arg = [];
            wasm_module = wsm;
            mode = #install;
            canister_id = canister_id;
        });
        "Installed."
    };

    public shared(caller) func start_canister(canister_id : Canister_id) : async Text {
        await ic.start_canister({ canister_id = canister_id;});
        "Started."
    };

    public shared(caller) func stop_canister(canister_id : Canister_id) : async Text {
        await ic.stop_canister({ canister_id = canister_id;});
        "Stopped."
    };

    public shared(caller) func delete_canister(canister_id : Canister_id) : async Text {
        await ic.delete_canister({ canister_id = canister_id;});
        "Deleted."
    };

};