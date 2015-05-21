@isTest
private class CodeDocumenterTest
{
	@isTest
	static void testProcessingOfAllSampleClasses()
	{
		CodeDocumenter.documentApexFiles( ApexDocsTestHelper.generateApexClassesFromAllStaticResourceFiles() );
	}

	@isTest
	static void testProcessingOfASingleSampleClasse()
	{
		for (ApexClass clazz : ApexDocsTestHelper.generateApexClassesFromStaticResourceFiles( new set<ApexDocsTestHelper.TEST_CLASSES>{ ApexDocsTestHelper.TEST_CLASSES.UnitTestFile_FooBar } ) )
		{
			CodeDocumenter.documentApexFile( clazz );
		}
	}
}