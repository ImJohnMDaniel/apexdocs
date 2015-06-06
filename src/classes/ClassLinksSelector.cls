public with sharing class ClassLinksSelector
    extends fflib_SObjectSelector
    implements IClassLinksSelector
{
    public static IClassLinksSelector newInstance()
    {
        return (IClassLinksSelector) Application.Selector.newInstance(ClassLink__c.SObjectType);
    }

    public list<Schema.SObjectField> getSObjectFieldList()
    {
        return new list<Schema.SObjectField>
        {
            ClassLink__c.Id,
            ClassLink__c.Name,
            ClassLink__c.CreatedDate,
            ClassLink__c.CreatedById,
            ClassLink__c.LastModifiedDate,
            ClassLink__c.LastModifiedById,
            ClassLink__c.CodeInfo__c,
            ClassLink__c.CodeInfoName__c,
            ClassLink__c.CoreApexLink__c,
            ClassLink__c.LinksTo__c,
            ClassLink__c.LinksToName__c,
            ClassLink__c.Type__c,
            ClassLink__c.RelatedConstruct__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return ClassLink__c.sObjectType;
    }

    public List<ClassLink__c> selectById(final set<ID> idSet)
    {
        return (List<ClassLink__c>) selectSObjectsById(idSet);
    }

    public list<ClassLink__c> selectByLinksNotResolved()
    {
        String query = string.format('select {0} ' +
                                       'from {1} ' +
                                      'where {2} = null ' +
                                         'or {3} = null ',
                                    new list<string>{
                                        getFieldListString(),
                                        getSObjectName(),
                                        ClassLink__c.LinksTo__c.getDescribe().getName(),
                                        ClassLink__c.CoreApexLink__c.getDescribe().getName()
                                    });

        return (List<ClassLink__c>) Database.query(query);
    }

    public list<ClassLink__c> selectByLinkTo(final id linkToId)
    {
        String query = string.format('select {0} ' +
                                       'from {1} ' +
                                      'where {2} = :linkToId',
                                    new list<string>{
                                        getFieldListString(),
                                        getSObjectName(),
                                        ClassLink__c.LinksTo__c.getDescribe().getName()
                                    });

        return (List<ClassLink__c>) Database.query(query);
    }

    public list<ClassLink__c> selectByApexClassNameParent(final set<string> fileNameSet)
    {
        String query = string.format('select {0} ' +
                                       'from {1} ' +
                                      'where {2} in (select id from {3} where {4} in :fileNameSet)',
                                    new list<string>{
                                        getFieldListString(),   // 0
                                        getSObjectName(),       // 1
                                        ClassLink__c.CodeInfo__c.getDescribe().getName(),   // 2
                                        CodeInfo__c.SObjectType.getDescribe().getName(),    // 3
                                        CodeInfo__c.FileName__c.getDescribe().getName()     // 4
                                    });

        return (List<ClassLink__c>) Database.query(query);
    }

}