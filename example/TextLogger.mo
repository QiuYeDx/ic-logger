import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";

import ICActor "ICActor";
import LoggerActor "LoggerActor";

actor {
  private type LoggerActor = LoggerActor.LoggerActor;
  private type LoggerInfo = {
    id : Principal;
    start_index : Nat;
    var num : Nat;
  };
  private type View<A> = {
    start_index: Nat;
    messages: [A];
  };
  private let IC : ICActor.ICActor = actor ("aaaaa-aa");
  private let LIMIT = 100;
  private let cycle_limit = 1_000_000_000_000;
  private var index = 0;
  private var index_logger = 0;
  private var loggers = Buffer.Buffer<LoggerInfo>(10);

  public shared (msg) func initLogger() {
    Cycles.add(cycle_limit);
    let principal_id = Principal.fromActor(await LoggerActor.LoggerActor(0));
    _addLogger({
      id = principal_id;
      start_index = 0;
      num = 0;
    });
  };

  public shared (msg) func append(msgs: [Text]) {
    let total_size = msgs.size();
    var rest = total_size;
    var newest = loggers.get(index_logger);
    if(newset.num < LIMIT){
      let tmp = LIMIT - newest.num;
      rest -= tmp;
      let newest_logger : LoggerActor.LoggerActor = actor(Principal.toText(newest.id));
      var tmp_arr : [var Text] = Array.init<Text>(tmp, "");
      for(i in range(0, tmp - 1)){
        tmp_arr[i] := msgs[i];
      };
      ignore await newest_logger.append(tmp_arr); // may be wrong?
      loggers.put(index_logger, {
        id = newest.id;
        start_index = newest.start_index;
        num = newest.num + ;
      });
    };
  };

  public shared query (msg) func view(from: Nat, to: Nat) : async View<Text> {

  };

  public shared({caller}) func wallet_receive() : async Nat {
    Cycles.accept(Cycles.available())
  };

  private func _addLogger(info : LoggerInfo) {
    loggers.add({
      id =  info.id;
      start_index = info.start_index;
      num = info.num;
    });
  };
}
