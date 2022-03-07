export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
    'LoggerNotExist' : IDL.Null,
    'ViewRangeError' : IDL.Null,
    'MsgInputSizeErr' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Result = IDL.Variant({ 'ok' : IDL.Vec(IDL.Text), 'err' : Error });
  const MultiLogger = IDL.Service({
    '_append' : IDL.Func([IDL.Vec(IDL.Text)], [Result_1], []),
    '_getNewLogger' : IDL.Func([], [], []),
    '_view' : IDL.Func([IDL.Nat, IDL.Nat], [Result], []),
    'append' : IDL.Func([IDL.Vec(IDL.Text)], [Result_1], []),
    'view' : IDL.Func([IDL.Nat, IDL.Nat], [Result], []),
    'wallet_receive' : IDL.Func([], [IDL.Nat], []),
  });
  return MultiLogger;
};
export const init = ({ IDL }) => { return []; };
