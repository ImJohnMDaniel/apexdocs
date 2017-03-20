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

    private static final set<string> ADDITIONAL_FIELDS_SET = new set<String>{ 'LastModifiedBy.Name', 'CreatedBy.Name' };

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
		return Database.query( newQueryFactory().setCondition('id in :idSet ' + DEFAULT_WHERE_CLAUSE_AS_ADDITION).selectFields( ADDITIONAL_FIELDS_SET ).toSOQL() );
    }

    public list<ApexClass> selectByName(set<String> nameSet)
    {
    	return Database.query( newQueryFactory().setCondition('name in :nameSet ' + DEFAULT_WHERE_CLAUSE_AS_ADDITION).selectFields( ADDITIONAL_FIELDS_SET ).toSOQL() );
    }

    public string selectAllQuery()
    {
    	return newQueryFactory().setCondition(DEFAULT_WHERE_CLAUSE).selectFields( ADDITIONAL_FIELDS_SET ).toSOQL();
	}

    public list<ApexClass> selectAll()
    {
        string query = selectAllQuery();
    	system.debug(query);
        return (list<ApexClass>) Database.query(query);
    }

}