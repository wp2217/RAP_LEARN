@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view of Table ZROC_CODE'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ROC_CODE
  as select from ZROC_CODE
  composition [0..*] of ZI_ROC_CODE_ATTACH as _CodeAttach
{
  key code_uuid          as CodeUuid,
      title              as Title,
      description        as Description,
      category           as Category,
      subcategory        as Subcategory,
      content            as Content,
      linkurl            as Linkurl,
      localcreatedby     as Localcreatedby,
      locallastchangedby as Locallastchangedby,
      localcreatedat     as Localcreatedat,
      locallastchangedat as Locallastchangedat,
      lastchangedat      as Lastchangedat,

      //Compoment
      _CodeAttach // Make association public
}
