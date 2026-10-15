program srvHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.Logger,
  Horse.Logger.Provider.Console,
  Horse.Logger.Provider.LogFile,
  Horse.Paginate,
  Horse.HandleException,
  Horse.BasicAuthentication,
  System.Json,
  System.SysUtils,
  REST.Json,
  Dataset.Serialize,
  Dataset.Serialize.Config,
  RESTRequest4D,
  controllers.mesas in 'controllers\controllers.mesas.pas',
  dao.mesas in 'dao\dao.mesas.pas',
  dao.usuarios in 'dao\dao.usuarios.pas',
  controllers.usuarios in 'controllers\controllers.usuarios.pas',
  controllers.comandas in 'controllers\controllers.comandas.pas',
  dao.comandas in 'dao\dao.comandas.pas',
  controllers.produtos in 'controllers\controllers.produtos.pas',
  dao.produtos in 'dao\dao.produtos.pas',
  controllers.pedidos in 'controllers\controllers.pedidos.pas',
  dao.pedidos in 'dao\dao.pedidos.pas',
  controllers.cores in 'controllers\controllers.cores.pas',
  dao.cores in 'dao\dao.cores.pas',
  controllers.perfil in 'controllers\controllers.perfil.pas',
  dao.perfil in 'dao\dao.perfil.pas',
  dao.materiaprima in 'dao\dao.materiaprima.pas',
  controllers.materiaprima in 'controllers\controllers.materiaprima.pas',
  controllers.figuras in 'controllers\controllers.figuras.pas';

var
  LLogConsoleConfig : THorseLoggerConsoleConfig;
  LLogFileConfig    : THorseLoggerLogFileConfig;
  LLog              : string;

  // Middleware de CORS: libera o acesso da pagina web (file:// ou outra origem)
  procedure MiddlewareCORS(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  begin
    Res.AddHeader('Access-Control-Allow-Origin', '*');
    Res.AddHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');
    Res.AddHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    if Req.Method = 'OPTIONS' then
    begin
      Res.Status(THTTPStatus.NoContent).Send('').Abort;
      Exit;
    end;
    Next;
  end;

begin
  THorse
    .Use(Jhonson)
    .Use(HandleException)
    .Use(Paginate)
    .Use(MiddlewareCORS);

  (*
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('admin') and APassword.Equals('123456');
    end)
  );
  *)

  if ParamStr(1).Equals(EmptyStr)
  then LLog := '--c'
  else LLog := ParamStr(1);

  if LLog.Equals('--c') or LLog.Equals('--console') then
  begin
    LLogConsoleConfig := THorseLoggerConsoleConfig.New
      .SetLogFormat('${request_clientip} [${time}] ${response_status}');
    THorseLoggerManager.RegisterProvider(THorseLoggerProviderConsole.New());
    THorse.Use(THorseLoggerManager.HorseCallback);
  end
  else if ParamStr(1).Equals('--f') or ParamStr(1).Equals('--file') then
  begin
    LLogFileConfig := THorseLoggerLogFileConfig.New
      .SetLogFormat('${request_clientip} [${time}] ${response_status}')
      .SetDir('D:\Servidores\Log');
    THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New());
    THorse.Use(THorseLoggerManager.HorseCallback);
  end;

  //Para fins de testes de funcionamento
  THorse
    .Get('/healthcheck',
    procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('Em execu��o...');
    end
    );

  THorse
    .Get('/version',
    procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LVersion : String;
      LObj     : TJSONObject;
    begin
      Randomize;
      LVersion := (Format('%3.3d', [Random(100)]));
      LObj := TJSONOBject.Create;
      LObj.AddPair('Version', LVersion);
      Res.Send<TJSONObject>(LObj);
    end
    );

    THorse
      .Get('/ping',
      procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
      var
        LJSON     : TJSONValue;
        LResponse : IResponse;
      begin
        LResponse :=
          TRequest.New.BaseURL('https://api.myip.com')
            .ContentType('application/json')
            .Get;
        LJson := TJSONObject.ParseJSONValue(LResponse.Content) as TJSONValue;
        WriteLn(TJson.Format(LJson));
        Res.Send(LResponse.Content);
      end
      );

  controllers.mesas.Registry;
  controllers.usuarios.Registry;
  controllers.comandas.Registry;
  controllers.produtos.Registry;
  controllers.pedidos.Registry;
  controllers.cores.Registry;
  controllers.perfil.Registry;
  controllers.materiaprima.Registry;
  controllers.figuras.Registry;

  //Configura o DataSet Serialize para pegar o padr�o do banco
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;
  TDataSetSerializeConfig.GetInstance.Export.ExportNullValues := False;
  TDataSetSerializeConfig.GetInstance.Export.FormatCurrency := '0.00##';

  THorse
    .Listen(9000,
    procedure
    begin
      WriteLn(Format('Servidor Stokalc Na Porta: %d ', [THorse.Port]));
      WriteLn('Pronto para funcionameto!');
      if LLog.Equals('--f') or LLog.Equals('--file') then
        WriteLn('Atencao! Log salvando em arquivo!');
    end
  );
end.
