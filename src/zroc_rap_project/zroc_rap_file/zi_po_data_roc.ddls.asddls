@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Table ZROC_PO_DATA'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PO_DATA_ROC
  as select from zroc_po_data
  association to parent ZI_FILE_DATA_ROC as _file_data on  $projection.EndUser = _file_data.EndUser
                                                       and $projection.FileId  = _file_data.FileId
{

  key zroc_po_data.end_user      as EndUser,
  key zroc_po_data.file_id       as FileId,
  key zroc_po_data.line_id       as LineId,
  key zroc_po_data.line_no       as LineNum,
      zroc_po_data.ebeln         as Ebeln,
      zroc_po_data.ebelp         as Ebelp,
      @Semantics.quantity.unitOfMeasure: 'BaseUom'
      zroc_po_data.quantity      as Quantity,
      zroc_po_data.base_uom      as BaseUom,
      zroc_po_data.error         as Error,
      zroc_po_data.error_message as ErrorMessage,
      _file_data
}
