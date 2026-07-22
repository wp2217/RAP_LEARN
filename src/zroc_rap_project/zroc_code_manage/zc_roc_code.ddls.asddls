@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for ZI_ROC_CODE'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ROC_CODE
  provider contract transactional_query
  as projection on ZI_ROC_CODE
{
  key CodeUuid,
      Title,
      Description,
      Category,
      Subcategory,
      Content,
      Linkurl,
      Localcreatedby,
      Locallastchangedby,
      Localcreatedat,
      Locallastchangedat,
      Lastchangedat,
      /* Associations */
      _CodeAttach : redirected to composition child ZC_ROC_CODE_ATTACH
}
