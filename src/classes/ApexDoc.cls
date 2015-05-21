/**
 * Apex Docs
 * @author John M. Daniel
 * @description This class does something
 * @see ApexDocsService
 * @since 1.0
 * @version 1.0
 *
 */
public class ApexDoc
{
    /**
     *  RunApexDoc
     *
     */
    public static void execute()
    {
        execute( ApexClassesSelector.newInstance().selectAllQuery() );
    }

    public static void execute(final list<ApexClass> files)
    {
    	CodeDocumenter.documentApexFiles(files);
    }

    public static void execute(final string apexClassName)
    {
    	string stringMatch = '%' + apexClassName + '%';

    	execute([select Id, NamespacePrefix, Name, ApiVersion, Status, IsValid, BodyCrc, Body
                           , LengthWithoutComments, CreatedDate, CreatedById, LastModifiedDate
                           , LastModifiedById, SystemModstamp
                        from ApexClass
                       where NamespacePrefix = null
                         and Name like :stringMatch]);
    }

    public static void reset()
    {
        delete [select id from CodeInfo__c];
    }

}