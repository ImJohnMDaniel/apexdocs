@isTest
private class ApexDocsServiceTest
{
	/*
	IApexDocsService

	IFile getClass(final id classId);
    IFile getClass(final string className);
    list<IFile> findAllFiles();
    list<ClassLinkModel> findKnownSubClassesForFile(final IFile model);
    list<ClassLinkModel> findKnownImplementorsForFile(final IFile model);
    void documentAll();
    void document(final IFile model);
	*/
	@isTest
	static void test()
	{
		ApexDocsService.documentAll();
	}


    @isTest
    static void testGetClassById()
    {
        list<ApexClass> testClazzes = ApexDocsTestHelper.generateApexClassesFromStaticResourceFiles( new set<ApexDocsTestHelper.TEST_CLASSES>{ ApexDocsTestHelper.TEST_CLASSES.UnitTestFile_ClassModel } );

        ApexClass testClazz = testClazzes[0];

        IFile testFile = CodeDocumenter.documentApexFile( testClazz );

        system.debug( testFile );

        ApexDocsService.getClass( testFile.getId() );
    }

    @isTest
    static void testGetClassByClassName()
    {
        list<ApexClass> testClazzes = ApexDocsTestHelper.generateApexClassesFromStaticResourceFiles( new set<ApexDocsTestHelper.TEST_CLASSES>{ ApexDocsTestHelper.TEST_CLASSES.UnitTestFile_ClassModel } );

        ApexClass testClazz = testClazzes[0];

        CodeDocumenter.documentApexFile( testClazz );

        ApexDocsService.getClass( testClazz.name );
    }

//	@isTest
//	static void itShould()
//	{
//		fflib_ApexMocks apexMocks = new fflib_ApexMocks();
//
//		IApexDocsService mockService = new ApexDocsMocks.ApexDocsService( apexMocks );
//
//		Application.Service.setMock( IApexDocsService.class, mockService );
//
//		apexMocks.startStubbing();
//
//		//apexMocks.when( mockService.findAllFiles() ).thenReturn( mockServiceResponseToFindAllFiles );
//
//		apexMocks.stopStubbing();
//
//		// When
//		FileViewController controller = new FileViewController();
//
//		PageReference pageRef = Page.fileview;
//
//		pageRef.getParameters().put(FileViewController.PARAM_NAME, FileViewController.class.getName());
//
//		Test.setCurrentPage(pageRef);
//
//	}

	@isTest
	static void itShould()
	{
		fflib_ApexMocks apexMocks = new fflib_ApexMocks();

		IApexClassesSelector mockApexClassesSelector = new ApexDocsMocks.ApexClassesSelector( apexMocks );

		Application.Selector.setMock( mockApexClassesSelector );
	}
}