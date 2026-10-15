unit dao.materiaprima;

interface

uses
  ADRConn.DAO.Base,
  ADRConn.Model.Factory,
  ADRConn.Model.Interfaces,

  Dataset.Serialize,

  System.Classes,
  System.JSON,
  System.StrUtils,
  System.SysUtils;

type
  TADRConnDAOMateriaPrima = class(TADRConnDAOBase)
    private
    public
      function List(): TJSONArray;
  end;

implementation

{ TADRConnDAOMateriaPrima }

function TADRConnDAOMateriaPrima.List: TJSONArray;
{$Region 'SELECT'}
const
  LSelect =
    'SELECT '+
    '  PRODUTO.COD_PRO, '+
    '  PRODUTO.CODIGO_BARRA_PRO, '+
    '  PRODUTO.NOME_PRO, '+
    '  PRODUTO.DESC_CUPOM, '+
    '  PRODUTO.QUANT_ESTOQ, '+
    '  PRODUTO.LOCALIZACAO, '+
    '  PRODUTO.COR, '+
    '  PRODUTO.PERFIL, '+
    '  PRODUTO.ATIVO_PRO '+
    'FROM PRODUTO '+
    'ORDER BY PRODUTO.NOME_PRO';
{$EndRegion}
var
  LDataSet : TDataSet;
begin
  try
    try
      LDataset :=
        FQuery
          .SQL(LSelect)
          .OpenDataSet;

      Result := LDataset.ToJSONArray;
    except
      Result := TJSONArray.Create;
    end;
  finally
    LDataSet.Free;
  end;
end;

end.
