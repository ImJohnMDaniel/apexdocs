/**
 * Class encapsulates query logic for Attachment
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
public class AttachmentsSelector
	extends fflib_SObjectSelector
	implements IAttachmentsSelector
{
    public static IAttachmentsSelector newInstance()
    {
        return (IAttachmentsSelector) Application.Selector.newInstance(Attachment.SObjectType);
    }

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Attachment.Id,
				Attachment.IsDeleted,
				Attachment.ParentId,
				Attachment.Name,
				Attachment.IsPrivate,
				Attachment.ContentType,
				Attachment.BodyLength,
				// This field cannot be included by default because when Attachments are included in other
				// queries as a sub-select, SOQL does not allow binary fields in sub-selects
				// Attachment.Body,
				Attachment.OwnerId,
				Attachment.CreatedDate,
				Attachment.CreatedById,
				Attachment.LastModifiedDate,
				Attachment.LastModifiedById,
				Attachment.SystemModstamp,
				Attachment.Description
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Attachment.sObjectType;
	}

	public List<Attachment> selectById(Set<ID> idSet)
	{
		return (List<Attachment>) selectSObjectsById(idSet);
	}

	public list<Attachment> selectByApexClassNameParent(set<string> parentApexClassNameSet)
    {
        assertIsAccessible();

        string query = string.format(
                'select {0}'
				   + ', Body'
               + ' from {1}'
              + ' where ParentId in (select id from CodeInfo__c where FileName__c in :parentApexClassNameSet)'
              + ' order by {2}',
            new list<string>{
                getFieldListString(), // 0
                getSObjectName(), // 1
                getOrderBy() // 2
        });

        //system.debug(query);

        return (list<Attachment>) database.query(query);
    }

	public list<Attachment> selectByApexClassNameParent(set<id> parentCodeInfoIdSet)
    {
        assertIsAccessible();

        string query = string.format(
                'select {0}'
				   + ', Body'
               + ' from {1}'
              + ' where ParentId in :parentCodeInfoIdSet'
              + ' order by {2}',
            new list<string>{
                getFieldListString(), // 0
                getSObjectName(), // 1
                getOrderBy() // 2
        });

        //system.debug(query);

        return (list<Attachment>) database.query(query);
    }

}