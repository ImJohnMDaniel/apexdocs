global class CLI
{
    global static void document(final string apexClassName)
    {
        list<ApexClass> classes = ApexClassesSelector.newInstance().selectByName( new set<string>{ apexClassName });

        if ( ! classes.isEmpty() )
        {
            ApexDocsService.document( classes[0] );
        }
    }

    global static void documentAll()
    {
        ApexDocsService.documentAll();
    }

    global static void reset()
    {
        ApexDocsService.reset();
    }
}