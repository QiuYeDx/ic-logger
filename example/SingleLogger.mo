// Persistent logger keeping track of what is going on.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";

import Logger "mo:ic-logger/Logger";
import Cycles "mo:base/ExperimentalCycles";

shared(msg) actor class SingleLogger() {
  let OWNER = msg.caller;

  stable var state : Logger.State<Text> = Logger.new<Text>(0, null);
  let logger = Logger.Logger<Text>(state);

  // Principals that are allowed to log messages.
  stable var allowed : [Principal] = [OWNER];

  // Set allowed principals.
  public shared (msg) func allow(ids: [Principal]) {
    assert(msg.caller == OWNER);
    allowed := ids;
  };

  // Add a set of messages to the log.
  public shared (msg) func append(msgs: [Text]) {
    // assert(Option.isSome(Array.find(allowed, func (id: Principal) : Bool { msg.caller == id })));
    logger.append(msgs);
  };

  // Return log stats, where:
  //   start_index is the first index of log message.
  //   bucket_sizes is the size of all buckets, from oldest to newest.
  public query func stats() : async Logger.Stats {
    logger.stats()
  };

  // Return the messages between from and to indice (inclusive).
  public shared query (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {
    assert(msg.caller == OWNER);
    logger.view(from, to)
  };

  public shared({caller}) func wallet_receive() : async Nat {
    Cycles.accept(Cycles.available())
  };

};
