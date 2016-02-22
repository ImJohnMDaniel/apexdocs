/**
 * Class encapsulates query logic for Contact
 *
 * {@link https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer}
 **/
public with sharing class ReferenceClass0005
    extends fflib_SObjectSelector
    implements blue, green
{
    public interface blue
    {

    }

    public interface green    { }

    public static ReferenceClass0005 newInstance()
    {
        return new ReferenceClass0005();
    }

    private static map<id, id> userToResourceIdMapCache = new map<id, id>();

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                Contact.Id,
                Contact.Name,
                Contact.FirstName,
                Contact.LastName,
                Contact.RecordTypeId,
                Contact.OwnerId,
                Contact.CreatedDate,
                Contact.CreatedById,
                Contact.LastModifiedDate,
                Contact.LastModifiedById,
                Contact.ReportsToId,
                Contact.SystemModstamp
            };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Contact.sObjectType;
    }

    public class ContactLite
    {
        public id id { get; set; }
        public string name { get; set; }

        public ContactLite()
        {

        }

        public ContactLite(final Contact record)
        {
            this.id = record.id;
            this.name = record.name;
        }
    }
}