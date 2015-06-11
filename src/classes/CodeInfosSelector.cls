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
        assertIsAccessible();

        ClassLinksSelector theClassLinksSelector = new ClassLinksSelector();
        AttachmentsSelector theAttachmentsSelector = new AttachmentsSelector();

        theClassLinksSelector.assertIsAccessible();

        string query = string.format(
                'select {0} ' +
                     ', (select {4} ' +
                          'from {5} ' +
                         'order by {6})' +
                     ', (select {7} ' +
                          'from {8}) ' +
                  'from {1} ' +
                 'where {2} in :fileNameSet ' +
                 'order by {3}',
            new list<string>{
                getFieldListString(), // 0
                getSObjectName(), // 1
                CodeInfo__c.Filename__c.getDescribe().getName(), // 2
                getOrderBy(), // 3
                theClassLinksSelector.getFieldListString(), // 4
                'ClassLinks__r', // 5
                theClassLinksSelector.getOrderBy(), // 6
                theAttachmentsSelector.getFieldListString(), // 7
                'Attachments' // 8
        });

        system.debug(query);

        return (list<CodeInfo__c>) database.query(query);
    }

    public list<CodeInfo__c> selectAll()
    {
        assertIsAccessible();

        string query = string.format(
                'select {0} ' +
                  'from {1} ' +
                 'order by {2}',
            new list<string>{
                getFieldListString(),
                getSObjectName(),
                CodeInfo__c.FileName__c.getDescribe().getName()
        });

        return (list<CodeInfo__c>) database.query(query);
    }

    public list<CodeInfo__c> selectByModelType(final set<string> modelTypes)
    {
        assertIsAccessible();

        string query = string.format(
                'select {0} ' +
                  'from {1} ' +
                 'where {3} in :modelTypes ' +
                 'order by {2}',
            new list<string>{
                getFieldListString(),
                getSObjectName(),
                CodeInfo__c.FileName__c.getDescribe().getName(),
                CodeInfo__c.ModelType__c.getDescribe().getName()
        });

        return (list<CodeInfo__c>) database.query(query);
    }
}