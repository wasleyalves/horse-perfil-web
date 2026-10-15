unit controllers.materiaprima;

interface

procedure Registry;

implementation

uses
  Horse,

  ADRConn.Model.Factory,
  ADRConn.Model.Interfaces,

  DAO.MateriaPrima,

  System.Classes,
  System.JSON,
  System.StrUtils,
  System.SysUtils;

procedure DoList(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LDAO    : TADRConnDAOMateriaPrima;
  LConn   : IADRConnection;
  LResult : TJSONArray;
begin
  LConn := TADRConnModelFactory.GetConnectionIniFile();
  LConn.Connect;
  LDAO := TADRConnDAOMateriaPrima.Create(LConn);
  try
    LResult := LDAO.List;
    if LResult.Count > 0 then
      Res
        .Send<TJSONArray>(LResult)
        .Status(THTTPStatus.OK)
    else
      Res
        .Send<TJSONArray>(LResult)
        .Status(THTTPStatus.NotFound)
  finally
    LDao.Free;
  end;
end;

procedure Registry;
begin
  THorse.Get('/materiaprima', DoList);
end;

end.
