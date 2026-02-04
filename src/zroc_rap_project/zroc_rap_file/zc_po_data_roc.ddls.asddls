@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for ZI_PO_DATA_ROC'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PO_DATA_ROC
  as projection on ZI_PO_DATA_ROC
{
  key EndUser,
  key FileId,
  key LineId,
  key LineNum, 
      Ebeln,
      Ebelp,
      @Semantics.quantity.unitOfMeasure: 'BaseUom'
      Quantity,
      BaseUom,
      Error,
      ErrorMessage,
      /* Associations */
      _file_data : redirected to parent ZC_FILE_DATA_ROC 
}
