import type { Principal } from '@dfinity/principal';
export type Error = { 'ProposalNotFound' : null } |
  { 'RestrictedCanister' : null } |
  { 'PermissionDenied' : null } |
  { 'MemberOnly' : null } |
  { 'ArgsError' : null };
export interface InstallCodeArgs {
  'wsm' : Array<number>,
  'canister_id' : canister_id,
}
export type Oprate = { 'InstallCode' : null } |
  { 'StopCanister' : null };
export interface ProposalAgrs {
  'stop_canister_args' : [] | [StopCanisterArgs],
  'oprate' : Oprate,
  'memo' : string,
  'install_code_args' : [] | [InstallCodeArgs],
}
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type Result_1 = { 'ok' : string } |
  { 'err' : Error };
export type Result_2 = { 'ok' : canister_id } |
  { 'err' : Error };
export interface StopCanisterArgs { 'canister_id' : canister_id }
export type canister_id = Principal;
export interface class4 {
  'create_canister' : (arg_0: boolean) => Promise<Result_2>,
  'delete_canister' : (arg_0: canister_id) => Promise<Result_1>,
  'exeProposal' : (arg_0: bigint) => Promise<Result>,
  'install_code' : (arg_0: Array<number>, arg_1: canister_id) => Promise<
      Result_1
    >,
  'issuedProposal' : (arg_0: ProposalAgrs) => Promise<Result>,
  'setRestrictedCanister' : (arg_0: boolean, arg_1: Principal) => Promise<
      Result
    >,
  'start_canister' : (arg_0: canister_id) => Promise<Result_1>,
  'stop_canister' : (arg_0: canister_id) => Promise<Result_1>,
  'voteProposal' : (arg_0: bigint, arg_1: boolean) => Promise<Result>,
}
export interface _SERVICE extends class4 {}
