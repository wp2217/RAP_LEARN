@EndUserText.label: 'Abstract Entity for Get GR Item Params'
define abstract entity ZD_ROC_GETGR_PARAMS
  //with parameters parameter_name : parameter_type
{

  @EndUserText.label: 'Purchase Order Type'
  PurchaseOrderType : abap.char(5);

  @EndUserText.label: 'Purchase Order'
  PurchaseOrder     : abap.char(10);

  @EndUserText.label: 'Material'
  Material          : abap.char(40);

  @EndUserText.label: 'Material Document Year'
  MatDocYear        : abap.char(4);

  @EndUserText.label: 'Material Document'
  MatDoc            : abap.char(10);

  @EndUserText.label: 'Posting Date From'
  DateFrom          : abap.dats;

  @EndUserText.label: 'Posting Date To'
  DateTo            : abap.dats;
}
