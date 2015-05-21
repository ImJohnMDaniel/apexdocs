@isTest
private class ApexClassesSelectorTest
{
	@isTest
	static void test()
	{
		IApexClassesSelector apexClassesSelectorInstance = ApexClassesSelector.newInstance();

		list<ApexClass> apexClassesList = apexClassesSelectorInstance.selectAll();

		system.assert( ! apexClassesList.isEmpty() );

		// find the first class
		ApexClass aClass = apexClassesList[0];

		system.assert( apexClassesSelectorInstance.selectById( new set<id>{ aClass.id } ) != null );

		system.assert( apexClassesSelectorInstance.selectByName( new set<string>{ aClass.name } ) != null );		
	}
}