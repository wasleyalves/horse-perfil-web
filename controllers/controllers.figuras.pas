unit controllers.figuras;

interface

procedure Registry;

implementation

uses
  Horse,
  System.Classes,
  System.SysUtils,
  System.IOUtils;

const
  // Pasta onde ficam as figuras (thumbnails) dos perfis
  FIGURA_DIR = 'C:\EstoqueP\DESENHO\CEM\TECNICO\';

function ContentTypeByExt(const AExt: string): string;
begin
  if AExt.ToLower = '.bmp' then
    Result := 'image/bmp'
  else if AExt.ToLower = '.png' then
    Result := 'image/png'
  else if AExt.ToLower = '.gif' then
    Result := 'image/gif'
  else
    Result := 'image/jpeg';
end;

procedure DoFigura(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LArquivo : string;
  LCaminho : string;
begin
  // Recebe apenas o nome do arquivo (ex.: 000107V.JPG)
  LArquivo := Trim(Req.Params['arquivo']);

  // Sanitiza: descarta qualquer diretorio (evita path traversal)
  LArquivo := TPath.GetFileName(LArquivo);

  if LArquivo = EmptyStr then
  begin
    Res.Status(THTTPStatus.BadRequest).Send('Figura invalida.');
    Exit;
  end;

  LCaminho := TPath.Combine(FIGURA_DIR, LArquivo);

  if not TFile.Exists(LCaminho) then
  begin
    Res.Status(THTTPStatus.NotFound).Send('Figura nao encontrada.');
    Exit;
  end;

  // Cache no navegador para aliviar o tunel quando ha muitas miniaturas
  Res.AddHeader('Cache-Control', 'public, max-age=86400');
  Res.SendFile(LCaminho, ContentTypeByExt(TPath.GetExtension(LCaminho)));
end;

procedure Registry;
begin
  THorse.Get('/figura/:arquivo', DoFigura);
end;

end.
