@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'SM30 Data Maintain',
    typeNamePlural: 'SM30Data',
    title: {
    type: #STANDARD,
    label: 'Dummy',
    value: 'SM30SingletonField'
    }
}

define root view entity ZC_SM30_SINGLETON
  provider contract transactional_query
  as projection on ZI_SM30_SINGLETON
{

      @UI.facet: [{      id: 'SM30_Data',
                          purpose: #STANDARD,
                          type: #LINEITEM_REFERENCE,
                          position: 10,
                          targetElement: '_SM30_DATA',
                          label: 'SM30 Data'
                          } ]

      @UI.lineItem: [{  position: 10}]
  key SM30SingletonField,
      maxChangeAt,
      
      
      /* Associations */
      _SM30_DATA : redirected to composition child ZC_SM30_ROC
}
