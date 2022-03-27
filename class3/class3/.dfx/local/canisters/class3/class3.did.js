export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const Error = IDL.Variant({
    'CanisterNotExist' : IDL.Null,
    'PermissionDenied' : IDL.Null,
    'ProposeNotExist' : IDL.Null,
    'VotesAlready' : IDL.Null,
    'ProposeRepeat' : IDL.Null,
  });
  const Result_2 = IDL.Variant({ 'ok' : canister_id, 'err' : Error });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(IDL.Nat, canister_id)),
    'err' : Error,
  });
  const class3 = IDL.Service({
    'create_canister' : IDL.Func([], [Result_2], []),
    'delete_canister' : IDL.Func([IDL.Nat], [Result], []),
    'get_canisters' : IDL.Func([], [Result_1], ['query']),
    'install_code' : IDL.Func([IDL.Vec(IDL.Nat8), IDL.Nat], [Result], []),
    'propose' : IDL.Func([IDL.Nat, IDL.Nat], [Result], []),
    'start_canister' : IDL.Func([IDL.Nat], [Result], []),
    'stop_canister' : IDL.Func([IDL.Nat], [Result], []),
    'vote' : IDL.Func([IDL.Nat, IDL.Bool], [Result], []),
  });
  return class3;
};
export const init = ({ IDL }) => { return [IDL.Nat, IDL.Vec(IDL.Principal)]; };
