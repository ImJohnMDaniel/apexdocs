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
    	return Database.query( newQueryFactory().setCondition(ClassLink__c.LinksTo__c + ' = null or ' + ClassLink__c.CoreApexLink__c + ' = null').toSOQL() );
    }

    public list<ClassLink__c> selectByLinkTo(final id linkToId)
    {
    	return Database.query( newQueryFactory().setCondition(ClassLink__c.LinksTo__c + ' = :linkToId').toSOQL() );
    }

    public list<ClassLink__c> selectByApexClassNameParent(final set<string> fileNameSet)
    {
    	return Database.query( newQueryFactory()
    									.setCondition(ClassLink__c.LinksTo__c + ' in (select id from ' + CodeInfo__c.SObjectType
    									                                                    + ' where ' + CodeInfo__c.FileName__c + ' in :fileNameSet)')
    									.toSOQL() );
    }
}