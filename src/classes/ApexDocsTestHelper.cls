@isTest
public class ApexDocsTestHelper
{
    public enum TEST_CLASSES
    {
        UnitTestFile_ApexModel,
        UnitTestFile_ClassModel,
        UnitTestFile_FooBar,
        UnitTestFile_IAttachmentsSelector,
        UnitTestFile_XMLDom
    }

    public static final string UNIT_TEST_STATIC_RESOURCE_FILE_PREFIX = 'UnitTestFile';

    public static list<ApexClass> generateApexClassesFromStaticResourceFiles(final list<StaticResource> staticResourceFiles)
    {
        list<ApexClass> output = new list<ApexClass>();

        for (StaticResource staticResourceFile : staticResourceFiles)
        {
            ApexClass clazz = new ApexClass();

            clazz.id = fflib_IDGenerator.generate(ApexClass.SObjectType);

            clazz.name = staticResourceFile.Name.replace(UNIT_TEST_STATIC_RESOURCE_FILE_PREFIX + '_','');
            clazz.ApiVersion = 39.0;
            clazz.Status = 'Active';
            clazz.IsValid = true;
            clazz.Body = staticResourceFile.body.toString();
            clazz.LengthWithoutComments = staticResourceFile.body.toString().split('\n').size();

            output.add(clazz);
        }

        return output;
    }

    public static list<ApexClass> generateApexClassesFromStaticResourceFiles(final set<TEST_CLASSES> staticResourceFileEnumSet)
    {
        set<string> staticResourceFileNameSet = new set<string>();

        for (TEST_CLASSES classNameEnum : staticResourceFileEnumSet)
        {
            staticResourceFileNameSet.add( classNameEnum.name() );
        }

        return generateApexClassesFromStaticResourceFiles( staticResourceFileNameSet );
    }

    public static list<ApexClass> generateApexClassesFromStaticResourceFiles(final set<String> staticResourceFileNameSet)
    {
        list<StaticResource> testFiles = [select Id, NamespacePrefix, Name, ContentType, BodyLength, Body
                                                , Description, CreatedDate, CreatedById, LastModifiedDate
                                                , LastModifiedById, SystemModstamp, CacheControl
                                             from StaticResource
                                            where Description = :UNIT_TEST_STATIC_RESOURCE_FILE_PREFIX
                                              and name in :staticResourceFileNameSet];

        return generateApexClassesFromStaticResourceFiles(testFiles);
    }

    public static list<ApexClass> generateApexClassesFromAllStaticResourceFiles()
    {
        list<StaticResource> testFiles = [select Id, NamespacePrefix, Name, ContentType, BodyLength, Body
                                                , Description, CreatedDate, CreatedById, LastModifiedDate
                                                , LastModifiedById, SystemModstamp, CacheControl
                                             from StaticResource
                                            where Description = :UNIT_TEST_STATIC_RESOURCE_FILE_PREFIX];

        return generateApexClassesFromStaticResourceFiles(testFiles);
    }
}