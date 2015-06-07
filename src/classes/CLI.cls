global class CLI
{
    global static string document(final string apexClassName)
    {
        string output = null;

        list<ApexClass> classes = ApexClassesSelector.newInstance().selectByName( new set<string>{ apexClassName });

        if ( ! classes.isEmpty() )
        {
            IFile classAsIFile = ApexDocsService.document( classes[0] );

            output = classAsIFile != null ? JSON.SerializePretty( classAsIFile ) : null;
        }
        else
        {
            throw new CLIException('Unable to find class named '+apexClassName);
        }

        return output;
    }

    global static void documentAll()
    {
        ApexDocsService.documentAll();
    }

    global static void reset()
    {
        ApexDocsService.reset();
    }

    global class CLIException extends Exception { }
}