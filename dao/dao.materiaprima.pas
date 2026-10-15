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
    '  PRODUTO.QUANT_ESTOQ, '+
    '  PRODUTO.ESTOQUE_BARRA, '+
    '  PRODUTO.LOCALIZACAO, '+
    '  PRODUTO.COR, '+
    '  PRODUTO.PERFIL '+
    'FROM PRODUTO '+
    'WHERE PRODUTO.ATIVO_PRO = ''S'' '+
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
