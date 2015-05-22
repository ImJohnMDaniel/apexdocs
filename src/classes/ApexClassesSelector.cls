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

    public Schema.SObjectType getSObjectType()
    {
        return ApexClass.sObjectType;
    }

    public list<ApexClass> selectById(set<ID> idSet)
    {
        assertIsAccessible();
        return (list<ApexClass>) Database.query(String.format('SELECT {0}, {3} FROM {1} WHERE id in :idSet ORDER BY {2}'
                                                            , new List<String>{
                                                                    getFieldListString(),
                                                                    getSObjectName(),
                                                                    getOrderBy(),
                                                                    ADDITIONAL_FIELDS
                                                                }));

    }

    public list<ApexClass> selectByName(set<String> nameSet)
    {
        assertIsAccessible();
        return (list<ApexClass>) Database.query(String.format('SELECT {0}, {3} FROM {1} WHERE name in :nameSet ORDER BY {2}'
                                                             , new List<String>{
                                                                    getFieldListString(),
                                                                    getSObjectName(),
                                                                    getOrderBy(),
                                                                    ADDITIONAL_FIELDS
                                                                    }));
    }

    public string selectAllQuery()
    {
    	return string.format('select {0}, {3}' +
                         ' from {1}' +
                        ' order by {2}',
                        new list<string>{
                            getFieldListString(),
                            getSObjectName(),
                            getOrderBy(),
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