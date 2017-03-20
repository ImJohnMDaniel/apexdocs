public class CodeInfosSelector
    extends fflib_SObjectSelector
    implements ICodeInfosSelector
{
    public static ICodeInfosSelector newInstance()
    {
        return (ICodeInfosSelector) Application.Selector.newInstance(CodeInfo__c.SObjectType);
    }

    public list<Schema.SObjectField> getSObjectFieldList()
    {
        return new list<Schema.SObjectField>
        {
            CodeInfo__c.Id,
            CodeInfo__c.Name,
            CodeInfo__c.CreatedDate,
            CodeInfo__c.CreatedById,
            CodeInfo__c.LastModifiedDate,
            CodeInfo__c.LastModifiedById,
            CodeInfo__c.OwnerId,
            CodeInfo__c.ModelType__c,
            CodeInfo__c.ApexClassId__c,
            CodeInfo__c.FileName__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return CodeInfo__c.sObjectType;
    }

    public list<CodeInfo__c> selectById(set<id> idSet)
    {
        return (list<CodeInfo__c>) selectSObjectsById(idSet);
    }

    public list<CodeInfo__c> selectByApexClassNameWithClassLinks(set<string> fileNameSet)
    {
    	fflib_QueryFactory mainQueryFactory = newQueryFactory().setCondition(CodeInfo__c.Filename__c + ' in :fileNameSet');

		new ClassLinksSelector().addQueryFactorySubselect( mainQueryFactory );

		new AttachmentsSelector().addQueryFactorySubselect( mainQueryFactory );

    	return Database.query( mainQueryFactory.toSOQL() );
    }

    public list<CodeInfo__c> selectAll()
    {
    	return Database.query( newQueryFactory().toSOQL() );
    }
}