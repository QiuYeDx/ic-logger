import type { Principal } from '@dfinity/principal';
export type Error = { 'CanisterNotExist' : null } |
  { 'PermissionDenied' : null } |
  { 'ProposeNotExist' : null } |
  { 'VotesAlready' : null } |
  { 'ProposeRepeat' : null };
export type Result = { 'ok' : string } |
  { 'err' : Error };
export type Result_1 = { 'ok' : Array<[bigint, canister_id]> } |
  { 'err' : Error };
export type Result_2 = { 'ok' : canister_id } |
  { 'err' : Error };
export type canister_id = Principal;
export interface class3 {
  'create_canister' : () => Promise<Result_2>,
  'delete_canister' : (arg_0: bigint) => Promise<Result>,
  'get_canisters' : () => Promise<Result_1>,
  'install_code' : (arg_0: Array<number>, arg_1: bigint) => Promise<Result>,
  'propose' : (arg_0: bigint, arg_1: bigint) => Promise<Result>,
  'start_canister' : (arg_0: bigint) => Promise<Result>,
  'stop_canister' : (arg_0: bigint) => Promise<Result>,
  'vote' : (arg_0: bigint, arg_1: boolean) => Promise<Result>,
}
export interface _SERVICE extends class3 {}
