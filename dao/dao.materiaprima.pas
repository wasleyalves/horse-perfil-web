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
    '  PRODUTO.COD_INTERNO, '+
    '  PRODUTO.NOME_PRO, '+
    '  COALESCE(PRODUTO.QUANT_ESTOQ, 0) AS QUANT_ESTOQ, '+
    '  COALESCE(PRODUTO.ESTOQUE_BARRA, 0) AS ESTOQUE_BARRA, '+
    '  PRODUTO.LOCALIZACAO, '+
    '  PRODUTO.COR, '+
    '  PRODUTO.PERFIL '+
    'FROM PRODUTO '+
    'WHERE PRODUTO.ATIVO_PRO = ''S'' '+
    'ORDER BY PRODUTO.CODIGO';
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
