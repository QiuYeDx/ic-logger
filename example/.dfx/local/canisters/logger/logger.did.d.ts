import type { Principal } from '@dfinity/principal';
export type Error = { 'LoggerNotExist' : null } |
  { 'ViewRangeError' : null } |
  { 'MsgInputSizeErr' : null };
export interface MultiLogger {
  '_append' : (arg_0: Array<string>) => Promise<Result_1>,
  '_getNewLogger' : () => Promise<undefined>,
  '_view' : (arg_0: bigint, arg_1: bigint) => Promise<Result>,
  'append' : (arg_0: Array<string>) => Promise<Result_1>,
  'view' : (arg_0: bigint, arg_1: bigint) => Promise<Result>,
  'wallet_receive' : () => Promise<bigint>,
}
export type Result = { 'ok' : Array<string> } |
  { 'err' : Error };
export type Result_1 = { 'ok' : string } |
  { 'err' : Error };
export interface _SERVICE extends MultiLogger {}
