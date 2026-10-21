@EndUserText.label: 'Abstract Entity for Get GR Item Params'
define abstract entity ZD_ROC_GETGR_PARAMS
  //with parameters parameter_name : parameter_type
{

      @EndUserText.label: 'Purchase Order Type'
  key PurchaseOrderType : abap.char(5);

      @EndUserText.label: 'Purchase Order'
  key PurchaseOrder     : abap.char(10);

      @EndUserText.label: 'Material Document Year'
  key MatDocYear        : abap.char(4);

      @EndUserText.label: 'Material Document'
  key MatDoc            : abap.char(10);

      @EndUserText.label: 'Material'
      Material          : abap.char(40);

      @EndUserText.label: 'Posting Date From'
      DateFrom          : abap.dats;

      @EndUserText.label: 'Posting Date To'
      DateTo            : abap.dats;

      _root             : association to parent ZD_ROC_GETGR_PARAMS_ROOT on  $projection.PurchaseOrderType = _root.PurchaseOrderType

                                                                         and $projection.PurchaseOrder     = _root.PurchaseOrder;
}
