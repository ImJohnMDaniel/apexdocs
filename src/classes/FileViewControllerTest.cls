@isTest
private class FileViewControllerTest
{


	@isTest
	static void isFileAnInterface()
	{
		// Given
		fflib_ApexMocks apexMocks = new fflib_ApexMocks();

		IApexDocsService mockService = new ApexDocsMocks.ApexDocsService( apexMocks );

		Application.Service.setMock( IApexDocsService.class, mockService );

		apexMocks.startStubbing();

		//apexMocks.when( mockService.findAllFiles() ).thenReturn( mockServiceResponseToFindAllFiles );

		apexMocks.stopStubbing();

		// When
		FileViewController controller = new FileViewController();

		PageReference pageRef = Page.fileview;

		pageRef.getParameters().put(FileViewController.PARAM_NAME, FileViewController.class.getName());

		Test.setCurrentPage(pageRef);

	}

	@isTest
	static void isBasicControllerFeaturesAvailable()
	{
		// Given
		fflib_ApexMocks apexMocks = new fflib_ApexMocks();

		IApexDocsService mockService = new ApexDocsMocks.ApexDocsService( apexMocks );

		Application.Service.setMock( IApexDocsService.class, mockService );

		list<IFile> mockServiceResponseToFindAllFiles = new list<IFile>();

		ClassModel testClassModel = new ClassModel();

		InterfaceModel testInterfaceModel = new InterfaceModel();

		mockServiceResponseToFindAllFiles.add( testClassModel );
		mockServiceResponseToFindAllFiles.add( testInterfaceModel );

		apexMocks.startStubbing();

		apexMocks.when( mockService.findAllFiles() ).thenReturn( mockServiceResponseToFindAllFiles );

		apexMocks.stopStubbing();

		// When
		FileViewController controller = new FileViewController();

		PageReference pageRef = Page.fileview;

		Test.setCurrentPage(pageRef);

		controller.getAvailableClasses();
		system.debug( controller.isFileViewable );

		system.debug( controller.apexFileInfo );
		system.debug( controller.fileable );
		system.debug( controller.apexModelable );
		system.debug( controller.methodsable );
		system.debug( controller.propertiesable );
		system.debug( controller.constructorsable );
		system.debug( controller.authorable );
		system.debug( controller.innerClassesable );
		system.debug( controller.extensible );
		system.debug( controller.implementable );

		controller.refreshAll();

		// Then


	}
}