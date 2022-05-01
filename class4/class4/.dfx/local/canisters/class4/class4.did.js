export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const Error = IDL.Variant({
    'ProposalNotFound' : IDL.Null,
    'RestrictedCanister' : IDL.Null,
    'PermissionDenied' : IDL.Null,
    'MemberOnly' : IDL.Null,
    'ArgsError' : IDL.Null,
  });
  const Result_2 = IDL.Variant({ 'ok' : canister_id, 'err' : Error });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const StopCanisterArgs = IDL.Record({ 'canister_id' : canister_id });
  const Oprate = IDL.Variant({
    'InstallCode' : IDL.Null,
    'StopCanister' : IDL.Null,
  });
  const InstallCodeArgs = IDL.Record({
    'wsm' : IDL.Vec(IDL.Nat8),
    'canister_id' : canister_id,
  });
  const ProposalAgrs = IDL.Record({
    'stop_canister_args' : IDL.Opt(StopCanisterArgs),
    'oprate' : Oprate,
    'memo' : IDL.Text,
    'install_code_args' : IDL.Opt(InstallCodeArgs),
  });
  const class4 = IDL.Service({
    'create_canister' : IDL.Func([IDL.Bool], [Result_2], []),
    'delete_canister' : IDL.Func([canister_id], [Result_1], []),
    'exeProposal' : IDL.Func([IDL.Nat], [Result], []),
    'install_code' : IDL.Func([IDL.Vec(IDL.Nat8), canister_id], [Result_1], []),
    'issuedProposal' : IDL.Func([ProposalAgrs], [Result], []),
    'setRestrictedCanister' : IDL.Func([IDL.Bool, IDL.Principal], [Result], []),
    'start_canister' : IDL.Func([canister_id], [Result_1], []),
    'stop_canister' : IDL.Func([canister_id], [Result_1], []),
    'voteProposal' : IDL.Func([IDL.Nat, IDL.Bool], [Result], []),
  });
  return class4;
};
export const init = ({ IDL }) => { return [IDL.Nat, IDL.Vec(IDL.Principal)]; };
