public class Application
{
    // SObject's used by the logic in this service, listed in dependency order
    private static list<Schema.SObjectType> SERVICE_SOBJECTS =
                    new list<Schema.SObjectType>
                    {
                        CodeInfo__c.SObjectType,
                        ClassLink__c.SObjectType,
                        Attachment.SObjectType
                    };

    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork =
        new fflib_Application.UnitOfWorkFactory(SERVICE_SOBJECTS);

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service =
        new fflib_Application.ServiceFactory(
            new Map<Type, Type> {
                    IApexDocsService.class => ApexDocsServiceImpl.class
                    });

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector =
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                    ApexClass.SObjectType => ApexClassesSelector.class,
                    CodeInfo__c.SObjectType => CodeInfosSelector.class,
                    ClassLink__c.SObjectType => ClassLinksSelector.class,
                    Attachment.SObjectType => AttachmentsSelector.class
                    });

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain =
        new fflib_Application.DomainFactory(
            Application.Selector,
            new Map<SObjectType, Type> {
                    CodeInfo__c.SObjectType => CodeInfos.Constructor.class
                 });
}