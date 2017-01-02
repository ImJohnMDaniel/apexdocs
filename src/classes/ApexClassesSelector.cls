/**
 * Class encapsulates query logic for ApexClass SObject
 *
 * {@link https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer }
 **/
public class ApexClassesSelector
    extends fflib_SObjectSelector
    implements IApexClassesSelector
{
    public static IApexClassesSelector newInstance()
    {
        return (IApexClassesSelector) Application.Selector.newInstance(ApexClass.SObjectType);
    }

    private static final string ADDITIONAL_FIELDS = 'LastModifiedBy.Name, CreatedBy.Name';

    public list<Schema.SObjectField> getSObjectFieldList()
    {
        return new list<Schema.SObjectField>
        {
            ApexClass.Id,
            ApexClass.NamespacePrefix,
            ApexClass.Name,
            ApexClass.ApiVersion,
            ApexClass.Status,
            ApexClass.IsValid,
            ApexClass.BodyCrc,
            ApexClass.Body,
            ApexClass.LengthWithoutComments,
            ApexClass.CreatedDate,
            ApexClass.CreatedById,
            ApexClass.LastModifiedDate,
            ApexClass.LastModifiedById
        };
    }

    private static final string DEFAULT_WHERE_CLAUSE;
    private static final string DEFAULT_WHERE_CLAUSE_AS_ADDITION;

    static
    {
        Organization currentOrganzationRecord = [select Id, Name, NamespacePrefix, InstanceName, IsSandbox from Organization limit 1];

        DEFAULT_WHERE_CLAUSE = ' ' + ApexClass.NamespacePrefix + ' = '
                                        + (string.isblank(currentOrganzationRecord.NamespacePrefix)
                                            ? 'null'
                                            : '\'' + currentOrganzationRecord.NamespacePrefix + '\'');
        DEFAULT_WHERE_CLAUSE_AS_ADDITION = ' and' + DEFAULT_WHERE_CLAUSE;
    }

    public Schema.SObjectType getSObjectType()
    {
        return ApexClass.sObjectType;
    }

    public list<ApexClass> selectById(set<ID> idSet)
    {
        assertIsAccessible();
        return (list<ApexClass>) Database.query(String.format('select {0}, {4}' +
 						                                      ' from {1}' +
 						                                     ' where id in :idSet {3}' +
 						                                     ' order by {2}'
 						                                    , new List<String>{
 						                                            getFieldListString(),
						                                            getSObjectName(),
						                                            getOrderBy(),
						                                            DEFAULT_WHERE_CLAUSE_AS_ADDITION,
						                                            ADDITIONAL_FIELDS
						                                        }));

    }

    public list<ApexClass> selectByName(set<String> nameSet)
    {
        assertIsAccessible();
        return (list<ApexClass>) Database.query(String.format('select {0}, {4}' +
                                                               ' from {1}' +
                                                              ' where name in :nameSet {3}' +
                                                              ' order by {2}'
                                                             , new List<String>{
                                                                    getFieldListString(),
                                                                    getSObjectName(),
                                                                    getOrderBy(),
                                                                    DEFAULT_WHERE_CLAUSE_AS_ADDITION,
                                                                    ADDITIONAL_FIELDS
                                                                    }));
    }

    public string selectAllQuery()
    {
    	return string.format('select {0}, {4}' +
                              ' from {1}' +
                             ' where {3}' +
                             ' order by {2}',
                        new list<string>{
                            getFieldListString(),
                            getSObjectName(),
                            getOrderBy(),
                            DEFAULT_WHERE_CLAUSE,
                            ADDITIONAL_FIELDS
                        });
      }

    public list<ApexClass> selectAll()
    {
    	assertIsAccessible();

        string query = selectAllQuery();
    	system.debug(query);
        return (list<ApexClass>) Database.query(query);
    }

}